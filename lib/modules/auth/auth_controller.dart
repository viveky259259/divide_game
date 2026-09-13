import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:mumbai_train_quiz/app/routes/app_routes.dart';
import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/data/models/user_model.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

/// Accounts live on the device so the game works with no network at all.
///
/// There is deliberately no password here — identity is the email address and
/// nothing is verified. When a backend is added, [login] and [register] are the
/// two methods that need to start calling it; everything downstream reads the
/// user through [current] and keeps working unchanged.
class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _uuid = const Uuid();
  final Rxn<UserModel> current = Rxn<UserModel>();

  bool get isLoggedIn => current.value != null;
  bool get isAdmin => current.value?.role == UserRole.admin;
  bool get isContributor =>
      current.value?.role == UserRole.contributor || isAdmin;

  @override
  void onInit() {
    super.onInit();
    current.value = HiveService.currentUser();
  }

  /// Re-reads the stored record. Call after anything that writes the user, so
  /// every `Obx` watching points or progress repaints.
  void reload() {
    final id = current.value?.id;
    if (id != null) current.value = HiveService.getUser(id);
  }

  Future<String?> login(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return 'Enter the email you signed up with.';

    final user = HiveService.findUserByEmail(trimmed);
    if (user == null) return 'No account on this device for $trimmed.';

    await HiveService.setCurrentUser(user.id);
    current.value = user;
    return null;
  }

  /// Returns null on success, or a message explaining what went wrong.
  Future<String?> register({
    required String name,
    required String email,
    required UserRole role,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty) return 'What should we call you?';
    if (!cleanEmail.contains('@')) return 'That does not look like an email.';
    if (HiveService.findUserByEmail(cleanEmail) != null) {
      return 'An account already exists for $cleanEmail. Sign in instead.';
    }

    final user = UserModel(
      id: _uuid.v4(),
      name: cleanName,
      email: cleanEmail,
      role: role,
    );

    await HiveService.saveUser(user);
    await HiveService.setCurrentUser(user.id);
    await HiveService.enqueueSync('create_user', user.toJson());
    Get.find<SyncService>().refreshPendingCount();

    current.value = user;
    return null;
  }

  Future<void> logout() async {
    await HiveService.setCurrentUser(null);
    current.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  /// Persists a change and queues it for the server. Every points, level and
  /// contribution update funnels through here.
  Future<void> save(UserModel updated) async {
    await HiveService.saveUser(updated);
    await HiveService.enqueueSync('update_user', updated.toJson());
    Get.find<SyncService>().refreshPendingCount();
    current.value = updated;
  }

  Future<void> awardPoints(int points) async {
    final user = current.value;
    if (user == null || points <= 0) return;
    await save(user.copyWith(
      totalPoints: user.totalPoints + points,
      lifetimePoints: user.lifetimePoints + points,
    ));
  }

  /// Spends from the balance only. Lifetime points never go down, so rank and
  /// progress survive a shopping trip.
  Future<bool> spendPoints(int points) async {
    final user = current.value;
    if (user == null || user.totalPoints < points) return false;
    await save(user.copyWith(totalPoints: user.totalPoints - points));
    return true;
  }

  /// Records a cleared level and unlocks the next station.
  Future<void> completeLevel(int level) async {
    final user = current.value;
    if (user == null) return;

    final cleared = {...user.completedLevels, level}.toList()..sort();
    final nextLevel = level + 1;
    await save(user.copyWith(
      completedLevels: cleared,
      currentLevel: nextLevel > user.currentLevel
          ? nextLevel.clamp(1, AppConstants.totalLevels)
          : user.currentLevel,
    ));
  }

  Future<void> noteContribution({required bool approved}) async {
    final user = current.value;
    if (user == null) return;
    await save(user.copyWith(
      questionsContributed: user.questionsContributed + 1,
      questionsApproved: user.questionsApproved + (approved ? 1 : 0),
    ));
  }
}
