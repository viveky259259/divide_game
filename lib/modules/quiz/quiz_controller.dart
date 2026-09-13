import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'package:mumbai_train_quiz/app/routes/app_routes.dart';
import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/data/models/game_session_model.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

enum Lifeline { fiftyFifty, audiencePoll, skip }

/// One round at one station.
///
/// The rules are KBC's: a wrong answer or a run-out clock ends the round there
/// and then. Points for questions already answered are banked and kept — you
/// lose the station, not the money.
class QuizController extends GetxController {
  static QuizController get to => Get.find();

  final _uuid = const Uuid();
  final _random = Random();

  late int level;
  late String stationName;

  final questions = <QuestionModel>[].obs;
  final currentIndex = 0.obs;

  /// -1 until the player commits to an option.
  final selectedOption = (-1).obs;
  final revealed = false.obs;
  final secondsLeft = AppConstants.questionSeconds.obs;
  final score = 0.obs;
  final finished = false.obs;
  final clearedLevel = false.obs;

  /// Options struck out by the 50:50 lifeline.
  final hiddenOptions = <int>[].obs;
  final usedLifelines = <Lifeline>[].obs;
  final audienceVotes = <int>[].obs;

  final _answers = <AnswerRecord>[];
  Timer? _ticker;
  late GameSessionModel _session;
  int _questionStartedAt = 0;

  /// Bumped on every [start]. Delayed callbacks from the previous round check
  /// it and bow out, so a replay never gets a stray "next question" from the
  /// round before it.
  int _roundToken = 0;

  QuestionModel get question => questions[currentIndex.value];
  bool get isLastQuestion => currentIndex.value == questions.length - 1;
  bool get hasQuestions => questions.isNotEmpty;
  List<AnswerRecord> get answers => List.unmodifiable(_answers);

  bool used(Lifeline l) => usedLifelines.contains(l);

  QuestionModel? questionById(String id) {
    for (final q in questions) {
      if (q.id == id) return q;
    }
    return null;
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  /// Sets up a fresh round. The controller lives for the whole app session —
  /// the result screen reads the finished round off it — so everything is
  /// reset here rather than relying on a new instance.
  void start(int atLevel) {
    _ticker?.cancel();
    _roundToken++;
    level = atLevel;
    stationName = Stations.nameFor(atLevel);

    _answers.clear();
    currentIndex.value = 0;
    score.value = 0;
    finished.value = false;
    clearedLevel.value = false;
    usedLifelines.clear();
    hiddenOptions.clear();
    audienceVotes.clear();

    questions.assignAll(_draw(atLevel));
    _session = GameSessionModel(
      id: _uuid.v4(),
      userId: Get.find<AuthController>().current.value?.id ?? 'guest',
      level: atLevel,
    );

    if (questions.isEmpty) {
      finished.value = true;
      return;
    }
    _beginQuestion();
  }

  /// Takes a random handful from everything approved for the station, so the
  /// same level is not the same round twice. Contributor questions join the
  /// pool the moment an admin approves them.
  List<QuestionModel> _draw(int atLevel) {
    final pool = HiveService.approvedForLevel(atLevel)..shuffle(_random);
    return pool.take(AppConstants.questionsPerLevel).toList();
  }

  void _beginQuestion() {
    selectedOption.value = -1;
    revealed.value = false;
    hiddenOptions.clear();
    audienceVotes.clear();
    secondsLeft.value = AppConstants.questionSeconds;
    _questionStartedAt = AppConstants.questionSeconds;

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (revealed.value) return;
      secondsLeft.value--;
      if (secondsLeft.value <= 0) _timeUp();
    });
  }

  void _timeUp() {
    _ticker?.cancel();
    revealed.value = true;
    _record(selected: -1, isCorrect: false, points: 0);

    final token = _roundToken;
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (token == _roundToken) _endRound();
    });
  }

  void answer(int option) {
    if (revealed.value || hiddenOptions.contains(option)) return;

    _ticker?.cancel();
    selectedOption.value = option;
    revealed.value = true;

    final correct = option == question.correctOptionIndex;
    final taken = _questionStartedAt - secondsLeft.value;

    var points = 0;
    if (correct) {
      points = AppConstants.pointsPerCorrectAnswer;
      if (taken <= AppConstants.fastAnswerThresholdSeconds) {
        points += AppConstants.fastAnswerBonus;
      }
      score.value += points;
    }

    _record(selected: option, isCorrect: correct, points: points);

    final token = _roundToken;
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (token != _roundToken) return;
      if (!correct) {
        _endRound();
      } else if (isLastQuestion) {
        _endRound(cleared: true);
      } else {
        currentIndex.value++;
        _beginQuestion();
      }
    });
  }

  void _record({
    required int selected,
    required bool isCorrect,
    required int points,
  }) {
    _answers.add(AnswerRecord(
      questionId: question.id,
      selectedOption: selected,
      isCorrect: isCorrect,
      secondsTaken: _questionStartedAt - secondsLeft.value,
      pointsEarned: points,
    ));
  }

  // ── Lifelines ──────────────────────────────────────────────────────────

  /// Strikes out two of the three wrong options.
  void useFiftyFifty() {
    if (used(Lifeline.fiftyFifty) || revealed.value) return;
    usedLifelines.add(Lifeline.fiftyFifty);

    final wrong = <int>[];
    for (var i = 0; i < question.options.length; i++) {
      if (i != question.correctOptionIndex) wrong.add(i);
    }
    wrong.shuffle(_random);
    hiddenOptions.assignAll(wrong.take(2));
  }

  /// The compartment votes. The crowd leans right but is not infallible —
  /// harder questions split it more.
  void useAudiencePoll() {
    if (used(Lifeline.audiencePoll) || revealed.value) return;
    usedLifelines.add(Lifeline.audiencePoll);

    final confidence = switch (question.difficulty) {
      QuestionDifficulty.easy => 55 + _random.nextInt(30), // 55-84
      QuestionDifficulty.medium => 40 + _random.nextInt(30), // 40-69
      QuestionDifficulty.hard => 28 + _random.nextInt(27), // 28-54
    };

    final votes = List<int>.filled(question.options.length, 0);
    votes[question.correctOptionIndex] = confidence;

    var remaining = 100 - confidence;
    final others = <int>[];
    for (var i = 0; i < votes.length; i++) {
      if (i != question.correctOptionIndex && !hiddenOptions.contains(i)) {
        others.add(i);
      }
    }

    for (var i = 0; i < others.length; i++) {
      final last = i == others.length - 1;
      final share = last ? remaining : _random.nextInt(remaining + 1);
      votes[others[i]] = share;
      remaining -= share;
    }

    audienceVotes.assignAll(votes);
  }

  /// Moves past a question without ending the round. Nothing is scored for it.
  void useSkip() {
    if (used(Lifeline.skip) || revealed.value) return;
    usedLifelines.add(Lifeline.skip);

    _ticker?.cancel();
    _record(selected: -2, isCorrect: false, points: 0);

    if (isLastQuestion) {
      // Skipping the last one still clears the station — you did not get it
      // wrong, you just did not answer it.
      _endRound(cleared: true);
    } else {
      currentIndex.value++;
      _beginQuestion();
    }
  }

  // ── Ending ─────────────────────────────────────────────────────────────

  Future<void> _endRound({bool cleared = false}) async {
    if (finished.value) return;

    _ticker?.cancel();
    finished.value = true;
    clearedLevel.value = cleared;

    if (cleared) {
      score.value += level * AppConstants.levelClearBonusPerLevel;
      if (AppConstants.safeCheckpoints.contains(level)) {
        score.value += AppConstants.checkpointBonus;
      }
    }

    final auth = Get.find<AuthController>();
    final correct = _answers.where((a) => a.isCorrect).length;

    _session = _session.copyWith(
      score: score.value,
      totalCorrect: correct,
      totalWrong: _answers.length - correct,
      answers: _answers,
      clearedLevel: cleared,
      finishedAt: DateTime.now(),
    );

    await HiveService.saveSession(_session);
    await HiveService.enqueueSync('save_session', _session.toJson());
    Get.find<SyncService>().refreshPendingCount();

    await auth.awardPoints(score.value);
    if (cleared) await auth.completeLevel(level);

    Get.offNamed(AppRoutes.quizResult);
  }

  /// Leaving mid-round forfeits it — the same as getting one wrong.
  Future<void> quit() async {
    _ticker?.cancel();
    await _endRound();
  }
}
