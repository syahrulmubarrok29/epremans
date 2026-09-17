import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/data_providers.dart';

/// Splash screen shown on app launch.
///
/// Phase 3 behaviour:
///  1. Shows the brand animation for [AppConstants.splashDuration].
///  2. During the delay, calls [AuthController.restoreSession()] to
///     re-hydrate any persisted login from [SharedPrefsService].
///  3. After the delay, marks splash complete via [splashCompletedProvider].
///     GoRouter's auth-aware `redirect` callback automatically resolves the
///     destination (/login or dashboard) without manual navigation calls.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();

    // Restore session concurrently with the splash animation after the initial frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initAndComplete();
      }
    });
  }

  Future<void> _initAndComplete() async {
    // Restore session while the animation plays.
    await ref.read(authControllerProvider.notifier).restoreSession();

    // Wait for the remaining splash duration (or the full duration if
    // restoreSession finished quickly).
    await Future.delayed(AppConstants.splashDuration);

    if (mounted) {
      // Signal splash completion. GoRouter's redirect will automatically
      // route to /login or the appropriate dashboard.
      ref.read(splashCompletedProvider.notifier).complete();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const _SplashContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo mark
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Icon(
                Icons.medical_services_rounded,
                size: 52,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // App name
          Text(
            AppConstants.appName,
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          // Tagline
          Text(
            AppConstants.appFullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textOnPrimary.withAlpha(178),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 56),

          // Loading indicator
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accent.withAlpha(200),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Company attribution
          Text(
            AppConstants.companyName,
            style: TextStyle(
              color: AppColors.textOnPrimary.withAlpha(120),
              fontSize: 11,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
