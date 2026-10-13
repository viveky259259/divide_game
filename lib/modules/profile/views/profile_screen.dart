import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/local/sync_service.dart';
import 'package:mumbai_train_quiz/data/models/user_model.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';
import 'package:mumbai_train_quiz/widgets/app_widgets.dart';

/// Who you are on the line, how far you have got, and whether your progress
/// has reached the server yet.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.to;

    return Obx(() {
      final user = auth.current.value;
      if (user == null) return const SizedBox.shrink();

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Identity(user: user),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  icon: Icons.stars_rounded,
                  value: '${user.lifetimePoints}',
                  label: 'points earned',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  icon: Icons.flag,
                  value:
                      '${user.completedLevels.length}/${AppConstants.totalLevels}',
                  label: 'stations cleared',
                  color: AppColors.correct,
                ),
              ),
            ],
          ),
          if (user.role != UserRole.player) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.edit_note,
                    value: '${user.questionsContributed}',
                    label: 'questions sent',
                    color: AppColors.lifeline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    icon: Icons.verified_outlined,
                    value: '${user.questionsApproved}',
                    label: 'approved',
                    color: AppColors.marketplace,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const _SyncCard(),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: auth.logout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('GET OFF THE TRAIN'),
          ),
        ],
      );
    });
  }
}

class _Identity extends StatelessWidget {
  final UserModel user;

  const _Identity({required this.user});

  @override
  Widget build(BuildContext context) {
    final role = switch (user.role) {
      UserRole.player => 'Passenger',
      UserRole.contributor => 'Contributor',
      UserRole.admin => 'Admin',
    };
    final initial = user.name.isEmpty ? '?' : user.name[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.trackGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accentGold.withOpacity(0.15),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.accentGold,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
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

class _SyncCard extends StatelessWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context) {
    final sync = Get.find<SyncService>();

    return Obx(() {
      final online = sync.isOnline.value;
      final queued = sync.pendingCount.value;

      final status = online ? 'Online' : 'Offline';
      final detail = queued == 0
          ? 'Everything on this device is up to date.'
          : '$queued change${queued == 1 ? '' : 's'} saved here, '
              'waiting for the server.';

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.trackGrey),
        ),
        child: Row(
          children: [
            Icon(
              online ? Icons.cloud_done_outlined : Icons.cloud_off,
              color: online ? AppColors.correct : AppColors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (online && queued > 0)
              TextButton(
                onPressed: sync.syncNow,
                child: const Text('SYNC'),
              ),
          ],
        ),
      );
    });
  }
}
