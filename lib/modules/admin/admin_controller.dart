import 'package:get/get.dart';

import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/data/models/user_model.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

/// The gate between a contributor's submission and the question pool players
/// actually draw from.
///
/// Nothing reaches a round until it passes through here: gameplay reads
/// [HiveService.approvedForLevel], which filters on
/// [QuestionStatus.approved], so approving is the single act that puts a
/// question into the game.
class AdminController extends GetxController {
  static AdminController get to => Get.find();

  final queue = <QuestionModel>[].obs;
  final reviewed = <QuestionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshQueue();
  }

  void refreshQueue() {
    queue.assignAll(HiveService.pendingQuestions());
    reviewed.assignAll(
      HiveService.allQuestions()
          .where((q) => !q.isSeed && q.status != QuestionStatus.pending)
          .toList()
        ..sort((a, b) => (b.reviewedAt ?? b.createdAt)
            .compareTo(a.reviewedAt ?? a.createdAt)),
    );
  }

  Future<void> approve(QuestionModel question) async {
    final admin = Get.find<AuthController>().current.value;

    final updated = question.copyWith(
      status: QuestionStatus.approved,
      reviewedBy: admin?.id ?? 'admin',
      reviewedAt: DateTime.now(),
    );

    await HiveService.saveQuestion(updated);
    await HiveService.enqueueSync('review_question', updated.toJson());
    await _payContributor(question.contributorId);
    Get.find<SyncService>().refreshPendingCount();

    refreshQueue();
  }

  Future<void> reject(QuestionModel question, String reason) async {
    final admin = Get.find<AuthController>().current.value;

    final updated = question.copyWith(
      status: QuestionStatus.rejected,
      reviewedBy: admin?.id ?? 'admin',
      reviewedAt: DateTime.now(),
      rejectionReason: reason.trim().isEmpty
          ? 'Not a fit for this station.'
          : reason.trim(),
    );

    await HiveService.saveQuestion(updated);
    await HiveService.enqueueSync('review_question', updated.toJson());
    Get.find<SyncService>().refreshPendingCount();

    refreshQueue();
  }

  /// An approved question earns its author points. The contributor is almost
  /// never the signed-in admin, so the record is written straight to the store
  /// rather than through [AuthController.save] — and the controller is only
  /// nudged when the two happen to be the same person.
  Future<void> _payContributor(String contributorId) async {
    final UserModel? contributor = HiveService.getUser(contributorId);
    if (contributor == null) return;

    final reward = AppConstants.contributionApprovedReward;
    final updated = contributor.copyWith(
      totalPoints: contributor.totalPoints + reward,
      lifetimePoints: contributor.lifetimePoints + reward,
      questionsApproved: contributor.questionsApproved + 1,
    );

    await HiveService.saveUser(updated);
    await HiveService.enqueueSync('update_user', updated.toJson());

    final auth = Get.find<AuthController>();
    if (auth.current.value?.id == updated.id) auth.current.value = updated;
  }

  int get pendingCount => queue.length;
}
