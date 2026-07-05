import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class TermsPrivacyScreen extends StatefulWidget {
  const TermsPrivacyScreen({super.key});

  @override
  State<TermsPrivacyScreen> createState() => _TermsPrivacyScreenState();
}

class _TermsPrivacyScreenState extends State<TermsPrivacyScreen> {
  int _selectedIndex = 0;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientProfile);
  }

  @override
  Widget build(BuildContext context) {
    final isTerms = _selectedIndex == 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgGray,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SegmentButton(
                        title: 'Terms',
                        isSelected: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                    ),
                    Expanded(
                      child: _SegmentButton(
                        title: 'Privacy',
                        isSelected: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                children: [
                  _HeaderCard(
                    icon: isTerms
                        ? Icons.description_outlined
                        : Icons.privacy_tip_outlined,
                    title: isTerms ? 'Terms of Service' : 'Privacy Policy',
                    subtitle: isTerms
                        ? 'Please read these terms carefully before using MedLink.'
                        : 'Learn how MedLink collects, uses, and protects your information.',
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Last updated: July 2026',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700,
                        ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (isTerms) const _TermsContent() else const _PrivacyContent(),

                  const SizedBox(height: AppSpacing.xl),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: AppColors.warningOrange.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.warningOrange,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'This content is prepared for app UI demonstration and should be reviewed legally before production release.',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textDark,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                      ],
                    ),
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

class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                        height: 1.4,
                        fontWeight: FontWeight.w500,
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

class _SegmentButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? AppColors.white : AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PolicySection(
          title: '1. Service Use',
          body:
              'MedLink helps patients discover and book home healthcare providers. By using MedLink, you agree to provide accurate information and use the service responsibly.',
        ),
        _PolicySection(
          title: '2. Account Responsibility',
          body:
              'You are responsible for maintaining the confidentiality of your account credentials and for all activity that occurs under your account.',
        ),
        _PolicySection(
          title: '3. Bookings',
          body:
              'Bookings depend on provider availability, location, selected service type, and payment confirmation. MedLink may update, reschedule, or cancel bookings when necessary.',
        ),
        _PolicySection(
          title: '4. Payments',
          body:
              'Payments may be processed through credit cards, debit cards, MedLink Wallet, mobile wallets, or cash on visit depending on service availability.',
        ),
        _PolicySection(
          title: '5. Cancellations & Refunds',
          body:
              'Cancellation and refund eligibility may vary depending on booking status, provider acceptance, time before visit, and payment method used.',
        ),
        _PolicySection(
          title: '6. Medical Responsibility',
          body:
              'MedLink is not a replacement for emergency medical services. For urgent or life-threatening situations, contact local emergency services immediately.',
        ),
        _PolicySection(
          title: '7. Provider Information',
          body:
              'Provider profiles, ratings, availability, and reviews are provided to help patients make informed choices, but service quality may vary by provider.',
        ),
        _PolicySection(
          title: '8. Changes to Terms',
          body:
              'MedLink may update these terms from time to time. Continued use of the app after updates means you accept the revised terms.',
        ),
      ],
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _PolicySection(
          title: '1. Information We Collect',
          body:
              'MedLink may collect account information, contact details, saved addresses, booking details, wallet activity, support requests, and app usage data.',
        ),
        _PolicySection(
          title: '2. Medical Information',
          body:
              'Medical history, medication schedules, family member information, and visit-related details may be stored to support care coordination and booking management.',
        ),
        _PolicySection(
          title: '3. How We Use Information',
          body:
              'We use information to manage bookings, communicate with users, process payments, provide support, improve service quality, and personalize the app experience.',
        ),
        _PolicySection(
          title: '4. Sharing Information',
          body:
              'Relevant booking and care information may be shared with selected healthcare providers to deliver requested services.',
        ),
        _PolicySection(
          title: '5. Payment Data',
          body:
              'Payment method details may be processed through secure payment providers. MedLink should not store full card details unless supported by secure payment infrastructure.',
        ),
        _PolicySection(
          title: '6. Data Security',
          body:
              'We apply reasonable safeguards to protect user information. However, no digital platform can guarantee absolute security.',
        ),
        _PolicySection(
          title: '7. User Choices',
          body:
              'Users can update profile information, manage saved addresses, adjust notification preferences, and contact support regarding account data.',
        ),
        _PolicySection(
          title: '8. Data Retention',
          body:
              'Information may be retained as long as needed to provide services, comply with obligations, resolve disputes, and maintain accurate records.',
        ),
      ],
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}