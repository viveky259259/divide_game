import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/routes/app_routes.dart';
import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/modules/quiz/quiz_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';
import 'package:mumbai_train_quiz/widgets/app_widgets.dart';

/// What happened at this station, and where the train goes next.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = QuizController.to;
    final cleared = c.clearedLevel.value;
    final isCheckpoint = AppConstants.safeCheckpoints.contains(c.level);
    final isEndOfLine = c.level >= AppConstants.totalLevels;
    final correct = c.answers.where((a) => a.isCorrect).length;

    final nextStation = isEndOfLine
        ? null
        : Stations.nameFor(c.level + 1);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Verdict(
                    cleared: cleared,
                    isEndOfLine: isEndOfLine && cleared,
                    station: c.stationName,
                  ),
                  const SizedBox(height: 32),
                  _ScoreDial(score: c.score.value),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          icon: Icons.check_circle_outline,
                          value: '$correct',
                          label: 'right',
                          color: AppColors.correct,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          icon: Icons.timer_outlined,
                          value: '${_totalSeconds(c)}s',
                          label: 'on the clock',
                          color: AppColors.lifeline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          icon: Icons.bolt,
                          value: '${3 - c.usedLifelines.length}',
                          label: 'lifelines left',
                          color: AppColors.accentGold,
                        ),
                      ),
                    ],
                  ),
                  if (cleared && isCheckpoint) ...[
                    const SizedBox(height: 20),
                    _CheckpointBadge(station: c.stationName),
                  ],
                  const SizedBox(height: 32),
                  _AnswerBreakdown(controller: c),
                  const SizedBox(height: 32),
                  if (cleared && nextStation != null)
                    ElevatedButton.icon(
                      onPressed: () => _ride(c, c.level + 1),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text('ON TO ${nextStation.toUpperCase()}'),
                    )
                  else if (!cleared)
                    ElevatedButton.icon(
                      onPressed: () => _ride(c, c.level),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('CATCH THE NEXT TRAIN'),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: const Text('BACK TO THE LINE MAP'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Starts the next round on the controller before routing, so the quiz
  /// screen finds a round already set up rather than building against the one
  /// that just ended.
  void _ride(QuizController c, int level) {
    c.start(level);
    Get.offNamed(AppRoutes.quiz);
  }

  int _totalSeconds(QuizController c) =>
      c.answers.fold<int>(0, (sum, a) => sum + a.secondsTaken);
}

class _Verdict extends StatelessWidget {
  final bool cleared;
  final bool isEndOfLine;
  final String station;

  const _Verdict({
    required this.cleared,
    required this.isEndOfLine,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    final headline = isEndOfLine
        ? 'END OF THE LINE'
        : cleared
            ? 'STATION CLEARED'
            : 'YOU GOT OFF EARLY';

    final blurb = isEndOfLine
        ? 'Churchgate. You rode the whole Western Line.'
        : cleared
            ? 'The train pulls out of $station with you still on it.'
            : 'The doors closed at $station. Ride it again whenever you like.';

    final color = cleared ? AppColors.correct : AppColors.wrong;
    final icon = isEndOfLine
        ? Icons.emoji_events
        : cleared
            ? Icons.directions_railway_filled
            : Icons.do_not_disturb_on_outlined;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            headline,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            blurb,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Counts the round's points up from zero rather than just printing them.
class _ScoreDial extends StatelessWidget {
  final int score;

  const _ScoreDial({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'POINTS THIS ROUND',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: score),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => Text(
            '$value',
            style: const TextStyle(
              color: AppColors.accentGold,
              fontSize: 52,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckpointBadge extends StatelessWidget {
  final String station;

  const _CheckpointBadge({required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentGold),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: AppColors.accentGold, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$station is a milestone',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Milestone bonus banked on top of the round.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Question by question, so a loss is legible rather than just a number.
class _AnswerBreakdown extends StatelessWidget {
  final QuizController controller;

  const _AnswerBreakdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    final answers = controller.answers;
    if (answers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HOW IT WENT',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(answers.length, (i) {
          final a = answers[i];
          final question = controller.questionById(a.questionId);

          // -1 is the clock running out, -2 is the skip lifeline.
          final (icon, color, note) = switch (a.selectedOption) {
            -1 => (Icons.timer_off, AppColors.wrong, 'ran out of time'),
            -2 => (Icons.skip_next, AppColors.lifeline, 'skipped'),
            _ when a.isCorrect =>
              (Icons.check, AppColors.correct, '+${a.pointsEarned}'),
            _ => (Icons.close, AppColors.wrong, 'wrong'),
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question?.questionText ?? 'Question ${i + 1}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  note,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
