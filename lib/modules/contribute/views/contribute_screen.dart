import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/modules/contribute/contribute_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';
import 'package:mumbai_train_quiz/widgets/app_widgets.dart';

/// Where a contributor writes a question about their own stretch of the line.
class ContributeScreen extends StatefulWidget {
  const ContributeScreen({super.key});

  @override
  State<ContributeScreen> createState() => _ContributeScreenState();
}

class _ContributeScreenState extends State<ContributeScreen> {
  final _question = TextEditingController();
  final _explanation = TextEditingController();
  final _options = List.generate(4, (_) => TextEditingController());
  bool _busy = false;

  @override
  void dispose() {
    _question.dispose();
    _explanation.dispose();
    for (final c in _options) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final c = ContributeController.to;
    c.questionText.value = _question.text;
    c.explanation.value = _explanation.text;
    for (var i = 0; i < _options.length; i++) {
      c.setOption(i, _options[i].text);
    }

    setState(() => _busy = true);
    final problem = await c.submit();
    if (!mounted) return;
    setState(() => _busy = false);

    if (problem != null) {
      Get.snackbar(
        'Not quite ready',
        problem,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    _question.clear();
    _explanation.clear();
    for (final o in _options) {
      o.clear();
    }

    Get.snackbar(
      'Sent for review',
      'An admin will check it. Once approved it joins the pool for that '
          'station.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = ContributeController.to;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const _Intro(),
        const SizedBox(height: 24),
        const _Label('WHICH STATION?'),
        const SizedBox(height: 8),
        Obx(() => _StationPicker(
              level: c.level.value,
              onChanged: (v) => c.level.value = v,
            )),
        const SizedBox(height: 22),
        const _Label('THE QUESTION'),
        const SizedBox(height: 8),
        TextField(
          controller: _question,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText:
                'Something a passenger could see, or wonder about, from the '
                'window here.',
          ),
        ),
        const SizedBox(height: 22),
        const _Label('FOUR OPTIONS — TAP THE RIGHT ONE'),
        const SizedBox(height: 8),
        Obx(
          () => Column(
            children: List.generate(4, (i) {
              final isCorrect = c.correctIndex.value == i;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => c.correctIndex.value = i,
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCorrect
                              ? AppColors.correct.withOpacity(0.2)
                              : AppColors.surface,
                          border: Border.all(
                            color: isCorrect
                                ? AppColors.correct
                                : AppColors.trackGrey,
                            width: 1.5,
                          ),
                        ),
                        child: isCorrect
                            ? const Icon(Icons.check,
                                size: 16, color: AppColors.correct)
                            : Text(
                                String.fromCharCode(65 + i),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _options[i],
                        decoration: InputDecoration(
                          hintText:
                              'Option ${String.fromCharCode(65 + i)}',
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        const _Label('WHY IS THAT THE ANSWER? (OPTIONAL)'),
        const SizedBox(height: 8),
        TextField(
          controller: _explanation,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Shown after the player answers.',
          ),
        ),
        const SizedBox(height: 22),
        const _Label('HOW HARD IS IT?'),
        const SizedBox(height: 8),
        Obx(() => _DifficultyPicker(
              value: c.difficulty.value,
              onChanged: (v) => c.difficulty.value = v,
            )),
        const SizedBox(height: 28),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SEND FOR REVIEW'),
        ),
        const SizedBox(height: 36),
        const _Label('WHAT YOU HAVE SENT'),
        const SizedBox(height: 12),
        Obx(() {
          if (c.mySubmissions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nothing yet. The first one is the hardest.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            );
          }
          return Column(
            children: c.mySubmissions
                .map((q) => _SubmissionRow(question: q))
                .toList(),
          );
        }),
      ],
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.trackGrey),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note, color: AppColors.accentGold, size: 22),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'You know your stretch of the line better than anyone. Write a '
              'question about it — once an admin approves it, other players '
              'start getting it.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 10,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StationPicker extends StatelessWidget {
  final int level;
  final ValueChanged<int> onChanged;

  const _StationPicker({required this.level, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: level,
          isExpanded: true,
          dropdownColor: AppColors.cardBg,
          icon: const Icon(Icons.expand_more, color: AppColors.textSecondary),
          items: Stations.all
              .map(
                (s) => DropdownMenuItem<int>(
                  value: s.level,
                  child: Text(
                    '${s.level}.  ${s.name}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _DifficultyPicker extends StatelessWidget {
  final QuestionDifficulty value;
  final ValueChanged<QuestionDifficulty> onChanged;

  const _DifficultyPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: QuestionDifficulty.values.map((d) {
        final selected = d == value;
        final color = switch (d) {
          QuestionDifficulty.easy => AppColors.correct,
          QuestionDifficulty.medium => AppColors.accentGold,
          QuestionDifficulty.hard => AppColors.wrong,
        };

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selected ? color.withOpacity(0.15) : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color : AppColors.trackGrey,
                  ),
                ),
                child: Text(
                  d.name.toUpperCase(),
                  style: TextStyle(
                    color: selected ? color : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  final QuestionModel question;

  const _SubmissionRow({required this.question});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (question.status) {
      QuestionStatus.approved => (AppColors.correct, 'LIVE'),
      QuestionStatus.rejected => (AppColors.wrong, 'SENT BACK'),
      QuestionStatus.pending => (AppColors.accentGold, 'IN REVIEW'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.stationName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            question.questionText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          if (question.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reviewer: ${question.rejectionReason}',
              style: const TextStyle(
                color: AppColors.wrong,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
