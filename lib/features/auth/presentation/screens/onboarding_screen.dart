import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../config/constants.dart';
import '../../../../config/routes.dart';
import '../../../../config/strings.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  int _currentPage = 0;
  bool _isFinishing = false;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: AppStrings.onboardingTitle1,
      description: AppStrings.onboardingDescription1,
      icon: Icons.health_and_safety_rounded,
      color: AppColors.lightBlue,
      iconColor: AppColors.primaryBlue,
    ),
    _OnboardingData(
      title: AppStrings.onboardingTitle2,
      description: AppStrings.onboardingDescription2,
      icon: Icons.event_available_rounded,
      color: Color(0xFFE0F2FE),
      iconColor: Color(0xFF0284C7),
    ),
    _OnboardingData(
      title: AppStrings.onboardingTitle3,
      description: AppStrings.onboardingDescription3,
      icon: Icons.medical_services_rounded,
      color: Color(0xFFFFF3C7),
      iconColor: Color(0xFFD97706),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_isFinishing) return;

    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animationDuration,
        curve: Curves.easeInOut,
      );
      return;
    }

    _finish();
  }

  Future<void> _finish() async {
    if (_isFinishing) return;

    setState(() => _isFinishing = true);

    await StorageService.instance.setOnboardingShown();

    if (!mounted) return;

    context.go(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isFinishing ? null : _finish,
                    child: Text(
                      AppStrings.skip,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (_, index) {
                  return _OnboardingPageWidget(
                    key: ValueKey(_pages[index].title),
                    data: _pages[index],
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      dotColor: AppColors.borderGray,
                      activeDotColor: AppColors.primaryBlue,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 4,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  CustomButton(
                    label:
                        isLastPage ? AppStrings.getStarted : AppStrings.next,
                    isLoading: _isFinishing,
                    onPressed: _goToNextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPageWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ModernOnboardingIcon(data: data),

          const SizedBox(height: AppSpacing.xl),

          Text(
            data.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ModernOnboardingIcon extends StatelessWidget {
  final _OnboardingData data;

  const _ModernOnboardingIcon({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(42),
        boxShadow: [
          BoxShadow(
            color: data.iconColor.withValues(alpha: 0.14),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 22,
            right: 24,
            child: _SoftCircle(
              size: 34,
              color: data.iconColor.withValues(alpha: 0.10),
            ),
          ),
          Positioned(
            bottom: 22,
            left: 26,
            child: _SoftCircle(
              size: 46,
              color: data.iconColor.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            top: 48,
            left: 30,
            child: _SoftCircle(
              size: 18,
              color: data.iconColor.withValues(alpha: 0.14),
            ),
          ),
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.iconColor.withValues(alpha: 0.16),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  data.icon,
                  color: data.iconColor,
                  size: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({
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

class _OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.iconColor,
  });
}