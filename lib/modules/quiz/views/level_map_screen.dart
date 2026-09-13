import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/routes/app_routes.dart';
import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/modules/quiz/quiz_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';

/// The line itself: twenty stations from Virar down to Churchgate, drawn as a
/// route map you travel rather than a list of levels.
class LevelMapScreen extends StatelessWidget {
  const LevelMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final user = auth.current.value;
      if (user == null) return const SizedBox.shrink();

      final cleared = user.completedLevels.toSet();

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: AppConstants.totalLevels + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _JourneyHeader(clearedCount: cleared.length);

          final level = index;
          final station = Stations.byLevel(level);
          final isCleared = cleared.contains(level);
          final unlocked = level <= user.currentLevel;
          final isNext = level == user.currentLevel && !isCleared;

          return _StationStop(
            station: station,
            cleared: isCleared,
            unlocked: unlocked,
            isNext: isNext,
            isFirst: level == 1,
            isLast: level == AppConstants.totalLevels,
            bestScore: HiveService.bestScoreForLevel(user.id, level),
            approvedCount: HiveService.approvedForLevel(level).length,
            onTap: unlocked ? () => _board(level) : null,
          );
        },
      );
    });
  }

  void _board(int level) {
    Get.find<QuizController>().start(level);
    Get.toNamed(AppRoutes.quiz);
  }
}

class _JourneyHeader extends StatelessWidget {
  final int clearedCount;

  const _JourneyHeader({required this.clearedCount});

  @override
  Widget build(BuildContext context) {
    final fraction = clearedCount / AppConstants.totalLevels;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THE WESTERN LINE',
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 12,
              letterSpacing: 2.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$clearedCount of ${AppConstants.totalLevels} stations cleared',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: AppColors.trackGrey,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accentGold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One stop on the map — the dot, the length of track below it, and the card.
class _StationStop extends StatelessWidget {
  final StationInfo station;
  final bool cleared;
  final bool unlocked;
  final bool isNext;
  final bool isFirst;
  final bool isLast;
  final int? bestScore;
  final int approvedCount;
  final VoidCallback? onTap;

  const _StationStop({
    required this.station,
    required this.cleared,
    required this.unlocked,
    required this.isNext,
    required this.isFirst,
    required this.isLast,
    required this.bestScore,
    required this.approvedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckpoint = AppConstants.safeCheckpoints.contains(station.level);

    final dotColor = cleared
        ? AppColors.correct
        : unlocked
            ? AppColors.accentGold
            : AppColors.trackGrey;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 10,
                  color: isFirst ? Colors.transparent : AppColors.trackGrey,
                ),
                Container(
                  width: isCheckpoint ? 18 : 14,
                  height: isCheckpoint ? 18 : 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cleared ? dotColor : AppColors.darkBg,
                    border: Border.all(color: dotColor, width: 2.5),
                  ),
                  child: cleared
                      ? const Icon(Icons.check,
                          size: 9, color: AppColors.darkBg)
                      : null,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppColors.trackGrey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StationCard(
                station: station,
                cleared: cleared,
                unlocked: unlocked,
                isNext: isNext,
                isCheckpoint: isCheckpoint,
                bestScore: bestScore,
                approvedCount: approvedCount,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  final StationInfo station;
  final bool cleared;
  final bool unlocked;
  final bool isNext;
  final bool isCheckpoint;
  final int? bestScore;
  final int approvedCount;
  final VoidCallback? onTap;

  const _StationCard({
    required this.station,
    required this.cleared,
    required this.unlocked,
    required this.isNext,
    required this.isCheckpoint,
    required this.bestScore,
    required this.approvedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = cleared ? AppColors.correct : AppColors.accentGold;

    return Opacity(
      opacity: unlocked ? 1 : 0.45,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNext ? AppColors.accentGold : AppColors.trackGrey,
            width: isNext ? 1.8 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              station.name,
                              style: TextStyle(
                                color: unlocked
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _Tag(text: station.code),
                            if (isCheckpoint) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.flag,
                                  size: 12, color: AppColors.accentGold),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          station.landmark,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.help_outline,
                                size: 11,
                                color: AppColors.textSecondary
                                    .withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Text(
                              '$approvedCount in the pool',
                              style: TextStyle(
                                color:
                                    AppColors.textSecondary.withOpacity(0.8),
                                fontSize: 10.5,
                              ),
                            ),
                            if (bestScore != null) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.stars_rounded,
                                  size: 11, color: accent.withOpacity(0.9)),
                              const SizedBox(width: 4),
                              Text(
                                'best $bestScore',
                                style: TextStyle(
                                  color: accent.withOpacity(0.9),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (!unlocked)
                    const Icon(Icons.lock_outline,
                        size: 18, color: AppColors.trackGrey)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cleared ? 'REPLAY' : 'BOARD',
                        style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
