import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';

/// Every screen sits on the same blue-to-dark wash, so moving between tabs
/// feels like one journey rather than a set of pages.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.pageGradient,
      child: child,
    );
  }
}

/// A thin strip that only appears when there is nothing to sync to. It states
/// what still works rather than what is broken — the game itself never needs
/// the network.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = Get.find<SyncService>();

    return Obx(() {
      final offline = !sync.isOnline.value;
      final queued = sync.pendingCount.value;
      if (!offline && queued == 0) return const SizedBox.shrink();

      final message = offline
          ? 'Offline — play on, progress is saved here'
          : '$queued change${queued == 1 ? '' : 's'} waiting to sync';

      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: offline
            ? AppColors.surface
            : AppColors.lifeline.withOpacity(0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              offline ? Icons.cloud_off : Icons.sync,
              size: 15,
              color: offline ? AppColors.textSecondary : AppColors.lifeline,
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: offline ? AppColors.textSecondary : AppColors.lifeline,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// The running points balance, shown in the app bar wherever points matter.
class PointsChip extends StatelessWidget {
  final int points;
  final VoidCallback? onTap;

  const PointsChip({super.key, required this.points, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded,
                size: 16, color: AppColors.accentGold),
            const SizedBox(width: 6),
            Text(
              '$points',
              style: const TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown wherever a list comes back empty — a queue with nothing in it, a
/// marketplace with no stock, a contributor with no submissions yet.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.trackGrey),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A small labelled number — points, levels cleared, questions approved.
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
