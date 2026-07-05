import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../data/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _scaleAnim;

  bool _hasNavigated = false;

  static const Duration _animationDuration = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNext();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnim = Tween<double>(
      begin: 0.88,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(AppConstants.splashDelay);

    if (!mounted || _hasNavigated) return;

    final storage = StorageService.instance;

    if (storage.isAuthenticated) {
      final userType = storage.getUserType();

      if (userType == UserType.nurse) {
        if (storage.isKycApproved) {
          _goTo(AppRoutes.nurseHome);
        } else {
          _goTo(AppRoutes.nurseVerification);
        }

        return;
      }

      _goTo(AppRoutes.patientHome);
      return;
    }

    if (!storage.isOnboardingShown) {
      _goTo(AppRoutes.onboarding);
      return;
    }

    _goTo(AppRoutes.welcome);
  }

  void _goTo(String route) {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    context.go(route);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _SplashMedicalLogo(),

                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        AppStrings.appName,
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                  fontFamily: AppFonts.poppins,
                                ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        'Professional Healthcare at Your Door',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashMedicalLogo extends StatelessWidget {
  const _SplashMedicalLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 18,
            right: 18,
            child: _SoftDot(
              size: 22,
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 18,
            child: _SoftDot(
              size: 30,
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: _SoftDot(
              size: 14,
              color: AppColors.successGreen.withValues(alpha: 0.16),
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: AppColors.lightBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.primaryBlue,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftDot extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftDot({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}