import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mumbai_train_quiz/app/routes/app_routes.dart';
import 'package:mumbai_train_quiz/app/theme/app_theme.dart';
import 'package:mumbai_train_quiz/data/local/hive_service.dart';
import 'package:mumbai_train_quiz/data/seed/seed_data.dart';
import 'package:mumbai_train_quiz/modules/auth/auth_controller.dart';

/// Boots the app behind a train pulling out of Virar.
///
/// On a first run this is also where the shipped questions and marketplace
/// stock are written to disk, which is what makes the very first launch
/// playable with no network.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _train;
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _train = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _boot();
  }

  Future<void> _boot() async {
    if (!HiveService.isSeeded) {
      await HiveService.saveQuestions(SeedData.questions());
      await HiveService.saveProducts(SeedData.products());
      await HiveService.markSeeded();
    }

    // Let the train finish crossing before moving on.
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final loggedIn = Get.find<AuthController>().isLoggedIn;
    Get.offAllNamed(loggedIn ? AppRoutes.home : AppRoutes.login);
  }

  @override
  void dispose() {
    _train.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.pageGradient,
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      const Text(
                        'VIRAR',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'WINDOW SEAT',
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'A quiz along the Western Line',
                        style: TextStyle(
                          color: AppColors.textPrimary.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 56),
                _TrackAnimation(progress: _train),
                const SizedBox(height: 56),
                FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'CHURCHGATE',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      letterSpacing: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A train running left to right along a sleepered track, with the last
/// stretch easing off like a train pulling into a platform.
class _TrackAnimation extends StatelessWidget {
  final AnimationController progress;

  const _TrackAnimation({required this.progress});

  @override
  Widget build(BuildContext context) {
    final eased = CurvedAnimation(parent: progress, curve: Curves.easeOutCubic);

    return SizedBox(
      height: 64,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 24,
                right: 24,
                bottom: 16,
                child: Column(
                  children: [
                    Container(height: 2, color: AppColors.trackGrey),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        16,
                        (_) => Container(
                          width: 3,
                          height: 6,
                          color: AppColors.trackGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedBuilder(
                animation: eased,
                builder: (context, child) {
                  // Travel the full width less the train's own footprint.
                  final travel = (width - 72) * eased.value;
                  return Positioned(
                    left: 24 + travel,
                    bottom: 24,
                    child: child!,
                  );
                },
                child: const Icon(
                  Icons.directions_railway_filled,
                  color: AppColors.accentGold,
                  size: 34,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
