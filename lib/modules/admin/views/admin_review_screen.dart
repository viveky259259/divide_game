import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/models/question_model.dart';
import 'package:mumbai_train_quiz/modules/admin/admin_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';
import 'package:mumbai_train_quiz/widgets/app_widgets.dart';

/// The review desk. Everything a contributor has sent waits here until an
/// admin lets it onto the line.
class AdminReviewScreen extends StatelessWidget {
  const AdminReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AdminController.to;

    return Obx(() {
      if (c.queue.isEmpty && c.reviewed.isEmpty) {
        return const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Nothing waiting',
          message:
              'When a contributor sends a question in, it lands here for you '
              'to wave through or send back.',
        );
      }

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _QueueHeader(pending: c.queue.length),
          const SizedBox(height: 20),
          if (c.queue.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'The queue is clear.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                ),
              ),
            )
          else
            ...c.queue.map(
              (q) => _ReviewCard(
                question: q,
                onApprove: () => _approve(c, q),
                onReject: () => _askReason(c, q),
              ),
            ),
          if (c.reviewed.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              'ALREADY DECIDED',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...c.reviewed.take(20).map((q) => _DecidedRow(question: q)),
          ],
        ],
      );
    });
  }

  Future<void> _approve(AdminController c, QuestionModel q) async {
    await c.approve(q);
    Get.snackbar(
      'Approved',
      '${q.stationName} players can now draw this one. '
          '${q.contributorName ?? 'The contributor'} earned '
          '${AppConstants.contributionApprovedReward} points.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    );
  }

  /// A rejection without a reason is just a disappearance, so the reason is
  /// asked for here and shown back to the contributor on their submissions.
  Future<void> _askReason(AdminController c, QuestionModel q) async {
    final field = TextEditingController();

    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Send it back'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tell them what to fix. They will see this next to the '
              'question.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: field,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. That landmark is on the Central line.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final reason = field.text;
              Get.back<void>();
              await c.reject(q, reason);
              Get.snackbar(
                'Sent back',
                'The contributor can see your note and try again.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
            child: const Text(
              'SEND BACK',
              style: TextStyle(color: AppColors.wrong),
            ),
          ),
        ],
      ),
    );

    field.dispose();
  }
}

class _QueueHeader extends StatelessWidget {
  final int pending;

  const _QueueHeader({required this.pending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.trackGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold.withOpacity(0.15),
            ),
            child: Text(
              '$pending',
              style: const TextStyle(
                color: AppColors.accentGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Waiting on you. Nothing reaches a player until you approve it.',
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

/// The whole submission as the player would meet it, with the answer marked.
class _ReviewCard extends StatelessWidget {
  final QuestionModel question;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ReviewCard({
    required this.question,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.trackGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_outlined,
                  size: 14, color: AppColors.accentGold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${question.stationName} · level ${question.level}',
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                question.difficulty.name.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.questionText,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(question.options.length, (i) {
            final isAnswer = i == question.correctOptionIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isAnswer
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 15,
                    color: isAnswer ? AppColors.correct : AppColors.trackGrey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      question.options[i],
                      style: TextStyle(
                        color: isAnswer
                            ? AppColors.correct
                            : AppColors.textSecondary,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          if (question.explanation != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.explanation!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  question.contributorName ?? 'Unknown contributor',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.wrong,
                    side: const BorderSide(color: AppColors.wrong),
                  ),
                  child: const Text('SEND BACK'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.correct,
                    foregroundColor: AppColors.darkBg,
                  ),
                  child: const Text('APPROVE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecidedRow extends StatelessWidget {
  final QuestionModel question;

  const _DecidedRow({required this.question});

  @override
  Widget build(BuildContext context) {
    final approved = question.status == QuestionStatus.approved;
    final color = approved ? AppColors.correct : AppColors.wrong;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(approved ? Icons.check : Icons.undo, size: 15, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.questionText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  question.stationName,
                  style: TextStyle(color: color, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
