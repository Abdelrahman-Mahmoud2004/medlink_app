import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class UnderReviewScreen extends StatelessWidget {
  const UnderReviewScreen({super.key});

  void _contactSupport(BuildContext context) {
    context.push(AppRoutes.nurseHelpSupport);
  }

  void _refreshStatus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review status checked'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _goHome(BuildContext context) {
    context.go(AppRoutes.nurseHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    const SizedBox(height: AppSpacing.xl),
                    const _ReviewIllustration(),
                    const SizedBox(height: AppSpacing.xl),
                    const _StatusCard(),
                    const SizedBox(height: AppSpacing.xl),
                    const _StepsCard(),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => _refreshStatus(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Refresh Status'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () => _contactSupport(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('Contact Support'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => _goHome(context),
                      child: const Text('Go to Home Preview'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewIllustration extends StatelessWidget {
  const _ReviewIllustration();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            color: AppColors.primaryBlue,
            size: 64,
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _Decorations.card(),
      child: Column(
        children: [
          Text(
            'Your provider account is under review',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'MedLink is reviewing your identity, license, and professional documents. This process usually takes 24–72 hours.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'UNDER REVIEW',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.warningOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  const _StepsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _Decorations.card(),
      child: const Column(
        children: [
          _ReviewStep(
            title: 'Documents Submitted',
            subtitle: 'Your identity and license documents were uploaded.',
            done: true,
          ),
          _ReviewStep(
            title: 'Compliance Review',
            subtitle: 'MedLink team is checking your provider eligibility.',
            done: false,
          ),
          _ReviewStep(
            title: 'Account Activation',
            subtitle: 'Dashboard access will be fully enabled after approval.',
            done: false,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;
  final bool isLast;

  const _ReviewStep({
    required this.title,
    required this.subtitle,
    required this.done,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.successGreen : AppColors.warningOrange;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.schedule_rounded,
                size: 16,
                color: color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: AppColors.borderGray,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.borderGray),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}