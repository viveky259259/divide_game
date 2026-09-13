import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/modules/quiz/quiz_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';
import 'package:mumbai_train_quiz/widgets/app_widgets.dart';

/// Note on the `Obx` sprinkled through this file: an observable read inside a
/// child widget's `build` is not tracked by an `Obx` further up the tree, so
/// each piece that watches the clock or the answer state owns one.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = QuizController.to;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmQuit(c);
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Obx(() {
              if (!c.hasQuestions) return const _NoQuestions();

              return Column(
                children: [
                  _Header(controller: c, onQuit: () => _confirmQuit(c)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        children: [
                          _QuestionCard(controller: c),
                          const SizedBox(height: 20),
                          _Options(controller: c),
                          const SizedBox(height: 16),
                          if (c.audienceVotes.isNotEmpty)
                            _AudiencePoll(votes: c.audienceVotes.toList()),
                        ],
                      ),
                    ),
                  ),
                  _Lifelines(controller: c),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void _confirmQuit(QuizController c) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Get off here?'),
        content: Text(
          'You keep the ${c.score.value} points you have banked, but '
          '${c.stationName} stays locked.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Stay on'),
          ),
          TextButton(
            onPressed: () {
              Get.back<void>();
              c.quit();
            },
            child:
                const Text('Get off', style: TextStyle(color: AppColors.wrong)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final QuizController controller;
  final VoidCallback onQuit;

  const _Header({required this.controller, required this.onQuit});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onQuit,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            tooltip: 'Leave the round',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.stationName.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Obx(
                  () => Text(
                    'Level ${c.level}  ·  Question '
                    '${c.currentIndex.value + 1} of ${c.questions.length}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() => PointsChip(points: c.score.value)),
          const SizedBox(width: 12),
          Obx(() => _CountdownRing(seconds: c.secondsLeft.value)),
        ],
      ),
    );
  }
}

/// The clock, which turns red once the last ten seconds start.
class _CountdownRing extends StatelessWidget {
  final int seconds;

  const _CountdownRing({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 10;
    final fraction =
        (seconds / AppConstants.questionSeconds).clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: fraction, end: fraction),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) => SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 3,
                backgroundColor: AppColors.trackGrey,
                valueColor: AlwaysStoppedAnimation<Color>(
                  urgent ? AppColors.wrong : AppColors.accentGold,
                ),
              ),
            ),
          ),
          Text(
            '$seconds',
            style: TextStyle(
              color: urgent ? AppColors.wrong : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizController controller;

  const _QuestionCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final q = controller.question;
      final showExplanation =
          controller.revealed.value && q.explanation != null;

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Container(
          key: ValueKey('${q.id}_$showExplanation'),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.trackGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.window_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  const Text(
                    'OUT OF THE WINDOW',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  _DifficultyPill(difficulty: q.difficulty.name),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                q.questionText,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showExplanation) ...[
                const SizedBox(height: 16),
                _Explanation(text: q.explanation!),
              ],
            ],
          ),
        ),
      );
    });
  }
}

/// The bit of context that turns a wrong guess into something learned.
class _Explanation extends StatelessWidget {
  final String text;

  const _Explanation({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              size: 15, color: AppColors.accentGold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyPill extends StatelessWidget {
  final String difficulty;

  const _DifficultyPill({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final color = switch (difficulty) {
      'easy' => AppColors.correct,
      'hard' => AppColors.wrong,
      _ => AppColors.accentGold,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _Options extends StatelessWidget {
  final QuizController controller;

  const _Options({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Obx(() {
      final q = c.question;
      final revealed = c.revealed.value;
      final picked = c.selectedOption.value;

      return Column(
        children: List.generate(q.options.length, (i) {
          final hidden = c.hiddenOptions.contains(i);
          final isCorrect = i == q.correctOptionIndex;
          final isPicked = picked == i;

          var border = AppColors.trackGrey;
          var fill = AppColors.cardBg;
          var text = AppColors.textPrimary;

          if (revealed) {
            if (isCorrect) {
              border = AppColors.correct;
              fill = AppColors.correct.withOpacity(0.18);
              text = AppColors.correct;
            } else if (isPicked) {
              border = AppColors.wrong;
              fill = AppColors.wrong.withOpacity(0.18);
              text = AppColors.wrong;
            }
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: hidden ? 0.2 : 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border, width: 1.5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: hidden || revealed ? null : () => c.answer(i),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: border),
                            ),
                            child: Text(
                              String.fromCharCode(65 + i),
                              style: TextStyle(
                                color: text,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              hidden ? '—' : q.options[i],
                              style: TextStyle(
                                color: text,
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                          ),
                          if (revealed && isCorrect)
                            const Icon(Icons.check_circle,
                                color: AppColors.correct, size: 20),
                          if (revealed && isPicked && !isCorrect)
                            const Icon(Icons.cancel,
                                color: AppColors.wrong, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      );
    });
  }
}

/// The audience lifeline, drawn as bars under the options.
class _AudiencePoll extends StatelessWidget {
  final List<int> votes;

  const _AudiencePoll({required this.votes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lifeline.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.groups, size: 16, color: AppColors.lifeline),
              SizedBox(width: 8),
              Text(
                'THE COMPARTMENT VOTES',
                style: TextStyle(
                  color: AppColors.lifeline,
                  fontSize: 10,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(votes.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    child: Text(
                      String.fromCharCode(65 + i),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: votes[i] / 100),
                      duration: Duration(milliseconds: 500 + i * 100),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 10,
                          backgroundColor: AppColors.surface,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.lifeline),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${votes[i]}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Lifelines extends StatelessWidget {
  final QuizController controller;

  const _Lifelines({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LifelineButton(
              icon: Icons.call_split,
              label: '50:50',
              used: c.used(Lifeline.fiftyFifty),
              onTap: c.useFiftyFifty,
            ),
            _LifelineButton(
              icon: Icons.groups,
              label: 'Compartment',
              used: c.used(Lifeline.audiencePoll),
              onTap: c.useAudiencePoll,
            ),
            _LifelineButton(
              icon: Icons.skip_next,
              label: 'Skip stop',
              used: c.used(Lifeline.skip),
              onTap: c.useSkip,
            ),
          ],
        ),
      ),
    );
  }
}

class _LifelineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool used;
  final VoidCallback onTap;

  const _LifelineButton({
    required this.icon,
    required this.label,
    required this.used,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = used ? AppColors.trackGrey : AppColors.lifeline;

    return InkWell(
      onTap: used ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.12),
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (used)
                  Transform.rotate(
                    angle: -0.6,
                    child: Container(
                      width: 50,
                      height: 1.5,
                      color: AppColors.wrong,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: used ? AppColors.trackGrey : AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A station with nothing approved for it yet — an invitation rather than a
/// dead end.
class _NoQuestions extends StatelessWidget {
  const _NoQuestions();

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.help_outline,
      title: 'Nothing to ask here yet',
      message:
          'No approved questions for this station. Contribute one and an admin '
          'will put it on the line.',
      action: ElevatedButton(
        onPressed: () => Get.back<void>(),
        child: const Text('BACK TO THE MAP'),
      ),
    );
  }
}
