import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/modules/admin/views/admin_review_screen.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';
import 'package:mumbai_train_quiz/modules/contribute/views/contribute_screen.dart';
import 'package:mumbai_train_quiz/modules/home/home_controller.dart';
import 'package:mumbai_train_quiz/modules/marketplace/views/marketplace_screen.dart';
import 'package:mumbai_train_quiz/modules/profile/views/profile_screen.dart';
import 'package:mumbai_train_quiz/modules/quiz/views/level_map_screen.dart';
import 'package:mumbai_train_quiz/utils/constants.dart';
import 'package:mumbai_train_quiz/widgets/app_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final home = HomeController.to;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              const _TopBar(),
              Expanded(
                child: Obx(() => _body(home.current)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final tabs = home.tabs;
        return NavigationBar(
          backgroundColor: AppColors.cardBg,
          selectedIndex: home.index.value.clamp(0, tabs.length - 1),
          onDestinationSelected: (i) {
            home.select(i);
            home.onTabShown(tabs[i]);
          },
          destinations: [
            for (final t in tabs)
              NavigationDestination(icon: Icon(_icon(t)), label: _label(t)),
          ],
        );
      }),
    );
  }

  Widget _body(HomeTab tab) => switch (tab) {
        HomeTab.map => const LevelMapScreen(),
        HomeTab.contribute => const ContributeScreen(),
        HomeTab.review => const AdminReviewScreen(),
        HomeTab.market => const MarketplaceScreen(),
        HomeTab.profile => const ProfileScreen(),
      };

  IconData _icon(HomeTab t) => switch (t) {
        HomeTab.map => Icons.train,
        HomeTab.contribute => Icons.edit_note,
        HomeTab.review => Icons.fact_check_outlined,
        HomeTab.market => Icons.storefront_outlined,
        HomeTab.profile => Icons.person_outline,
      };

  String _label(HomeTab t) => switch (t) {
        HomeTab.map => 'Line',
        HomeTab.contribute => 'Contribute',
        HomeTab.review => 'Review',
        HomeTab.market => 'Market',
        HomeTab.profile => 'Me',
      };
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              AppConstants.appName,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Obx(() => PointsChip(
                points: AuthController.to.current.value?.totalPoints ?? 0,
                onTap: () {
                  final home = HomeController.to;
                  final i = home.tabs.indexOf(HomeTab.market);
                  home.select(i);
                  home.onTabShown(HomeTab.market);
                },
              )),
        ],
      ),
    );
  }
}
