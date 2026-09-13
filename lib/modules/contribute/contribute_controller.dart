import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

/// Writing a question. Submissions are saved locally and queued for the
/// server straight away, but they stay [QuestionStatus.pending] and out of
/// the game until an admin approves them.
class ContributeController extends GetxController {
  static ContributeController get to => Get.find();

  final _uuid = const Uuid();

  final level = 1.obs;
  final questionText = ''.obs;
  final options = <String>['', '', '', ''].obs;
  final correctIndex = 0.obs;
  final explanation = ''.obs;
  final difficulty = QuestionDifficulty.medium.obs;

  final mySubmissions = <QuestionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshSubmissions();
  }

  void refreshSubmissions() {
    final id = Get.find<AuthController>().current.value?.id;
    if (id == null) return;
    mySubmissions.assignAll(HiveService.questionsByContributor(id));
  }

  void setOption(int index, String value) {
    options[index] = value;
    options.refresh();
  }

  /// Null when the form is ready to send, otherwise what is missing.
  String? validate() {
    if (questionText.value.trim().length < 10) {
      return 'Write the question out in full.';
    }
    for (var i = 0; i < options.length; i++) {
      if (options[i].trim().isEmpty) {
        return 'Option ${String.fromCharCode(65 + i)} is empty.';
      }
    }
    final seen = options.map((o) => o.trim().toLowerCase()).toSet();
    if (seen.length != options.length) {
      return 'Two options are the same.';
    }
    return null;
  }

  Future<String?> submit() async {
    final problem = validate();
    if (problem != null) return problem;

    final auth = Get.find<AuthController>();
    final user = auth.current.value;
    if (user == null) return 'Sign in first.';

    final question = QuestionModel(
      id: _uuid.v4(),
      level: level.value,
      stationName: Stations.nameFor(level.value),
      questionText: questionText.value.trim(),
      options: options.map((o) => o.trim()).toList(),
      correctOptionIndex: correctIndex.value,
      explanation:
          explanation.value.trim().isEmpty ? null : explanation.value.trim(),
      difficulty: difficulty.value,
      status: QuestionStatus.pending,
      contributorId: user.id,
      contributorName: user.name,
    );

    await HiveService.saveQuestion(question);
    await HiveService.enqueueSync('submit_question', question.toJson());
    Get.find<SyncService>().refreshPendingCount();

    await auth.noteContribution(approved: false);

    reset();
    refreshSubmissions();
    return null;
  }

  void reset() {
    questionText.value = '';
    options.assignAll(['', '', '', '']);
    correctIndex.value = 0;
    explanation.value = '';
    difficulty.value = QuestionDifficulty.medium;
  }

  int get pendingCount =>
      mySubmissions.where((q) => q.status == QuestionStatus.pending).length;

  int get approvedCount =>
      mySubmissions.where((q) => q.status == QuestionStatus.approved).length;
}
