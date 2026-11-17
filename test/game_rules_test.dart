import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/data/models/user_model.dart';
import 'package:mumbai_train_quiz/data/seed/seed_data.dart';
import 'package:mumbai_train_quiz/modules/admin/admin_controller.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/modules/contribute/contribute_controller.dart';
import 'package:mumbai_train_quiz/modules/marketplace/marketplace_controller.dart';
import 'package:mumbai_train_quiz/modules/quiz/quiz_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

/// The rules the game promises, checked against the real controllers and a
/// real Hive store in a temp directory: what reaches a round, who gets paid,
/// and what a purchase costs.
void main() {
  late Directory dir;
  late AuthController auth;

  setUp(() async {
    Get.testMode = true;
    dir = await Directory.systemTemp.createTemp('window_seat_test');
    await HiveService.init(path: dir.path);
    await HiveService.saveQuestions(SeedData.questions());
    await HiveService.saveProducts(SeedData.products());

    Get.put(SyncService(watchConnectivity: false));
    auth = Get.put(AuthController());
  });

  tearDown(() async {
    Get.reset();
    await Hive.close();
    await dir.delete(recursive: true);
  });

  Future<UserModel> signUp(String name, UserRole role) async {
    final error = await auth.register(
      name: name,
      email: '${name.toLowerCase()}@example.com',
      role: role,
    );
    expect(error, isNull);
    return auth.current.value!;
  }

  Future<QuestionModel> contribute(String text) async {
    final c = Get.put(ContributeController());
    c.level.value = 1;
    c.questionText.value = text;
    for (var i = 0; i < 4; i++) {
      c.setOption(i, ['Arnala', 'Worli', 'Versova', 'Madh'][i]);
    }
    expect(await c.submit(), isNull);
    return HiveService.pendingQuestions().last;
  }

  group('moderation', () {
    test('a contribution stays out of the game until approved, then pays',
        () async {
      final meera = await signUp('Meera', UserRole.contributor);
      final q = await contribute('Which village sits at the creek mouth?');

      expect(q.status, QuestionStatus.pending);
      expect(HiveService.approvedForLevel(1).map((q) => q.id),
          isNot(contains(q.id)));

      await signUp('Asha', UserRole.admin);
      final admin = Get.put(AdminController());
      expect(admin.queue.map((q) => q.id), [q.id]);

      await admin.approve(admin.queue.single);

      expect(HiveService.approvedForLevel(1).map((q) => q.id), contains(q.id));
      expect(admin.queue, isEmpty);
      final paid = HiveService.getUser(meera.id)!;
      expect(paid.totalPoints, AppConstants.contributionApprovedReward);
      expect(paid.lifetimePoints, AppConstants.contributionApprovedReward);
      expect(paid.questionsApproved, 1);
      // The admin approving is not the one who gets paid.
      expect(auth.current.value!.totalPoints, 0);
    });

    test('a rejected question never reaches the pool and keeps its reason',
        () async {
      final meera = await signUp('Meera', UserRole.contributor);
      final q = await contribute('Is this one worth sending back?');

      await signUp('Asha', UserRole.admin);
      final admin = Get.put(AdminController());
      await admin.reject(admin.queue.single, 'Not visible from the train.');

      final stored = HiveService.allQuestions().firstWhere((x) => x.id == q.id);
      expect(stored.status, QuestionStatus.rejected);
      expect(stored.rejectionReason, 'Not visible from the train.');
      expect(HiveService.approvedForLevel(1).map((q) => q.id),
          isNot(contains(q.id)));
      expect(HiveService.getUser(meera.id)!.totalPoints, 0);
    });
  });

  group('quiz', () {
    test('a round draws only approved questions for its own station',
        () async {
      await signUp('Ravi', UserRole.player);
      final pending = await contribute('Pending, so never in a round?');
      final quiz = Get.put(QuizController());

      for (var i = 0; i < 40; i++) {
        quiz.start(1);
        expect(quiz.questions, hasLength(AppConstants.questionsPerLevel));
        for (final q in quiz.questions) {
          expect(q.level, 1);
          expect(q.status, QuestionStatus.approved);
          expect(q.id, isNot(pending.id));
        }
      }
      Get.delete<QuizController>(); // cancels the round clock
    });

    test('clearing a station unlocks the next, and the line ends at 20',
        () async {
      await signUp('Ravi', UserRole.player);

      await auth.completeLevel(1);
      expect(auth.current.value!.currentLevel, 2);
      expect(auth.current.value!.completedLevels, [1]);

      await auth.completeLevel(AppConstants.totalLevels);
      expect(auth.current.value!.currentLevel, AppConstants.totalLevels);
    });
  });

  group('marketplace', () {
    test('buying spends the balance, never lifetime points, and takes stock',
        () async {
      final ravi = await signUp('Ravi', UserRole.player);
      await auth.awardPoints(500);
      final market = Get.put(MarketplaceController());
      final product = market.products.first; // cheapest first
      expect(product.priceInPoints, lessThanOrEqualTo(500));

      final code = await market.buy(product);

      expect(code, matches(RegExp(r'^[A-HJ-NP-Z2-9]{6}$')));
      final after = auth.current.value!;
      expect(after.totalPoints, 500 - product.priceInPoints);
      expect(after.lifetimePoints, 500);
      expect(HiveService.getProduct(product.id)!.stock, product.stock - 1);
      expect(HiveService.purchasesFor(ravi.id).single.redemptionCode, code);
    });

    test('an unaffordable buy changes nothing', () async {
      await signUp('Ravi', UserRole.player);
      await auth.awardPoints(100);
      final market = Get.put(MarketplaceController());
      final product = market.products.first;
      expect(product.priceInPoints, greaterThan(100));

      expect(await market.buy(product), isNull);
      expect(auth.current.value!.totalPoints, 100);
      expect(HiveService.getProduct(product.id)!.stock, product.stock);
    });
  });

  test('every change is queued for the server while there is no backend',
      () async {
    final before = HiveService.pendingSyncCount();
    await signUp('Ravi', UserRole.player);
    await auth.awardPoints(500);
    await Get.put(MarketplaceController())
        .buy(HiveService.availableProducts().first);

    final types = HiveService.syncQueue().values.map((e) => e['type']).toList();
    expect(HiveService.pendingSyncCount(), greaterThan(before));
    expect(types, containsAll(['create_user', 'update_user', 'purchase']));
  });
}
