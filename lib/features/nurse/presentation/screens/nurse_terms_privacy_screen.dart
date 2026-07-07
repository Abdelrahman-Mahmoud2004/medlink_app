import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class NurseTermsPrivacyScreen extends StatefulWidget {
  const NurseTermsPrivacyScreen({super.key});

  @override
  State<NurseTermsPrivacyScreen> createState() =>
      _NurseTermsPrivacyScreenState();
}

class _NurseTermsPrivacyScreenState extends State<NurseTermsPrivacyScreen> {
  final ValueNotifier<int> _tabNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _tabNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseProfileSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: _tabNotifier,
          builder: (context, index, _) {
            final isTerms = index == 0;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate.fixed(
                      [
                        _SegmentControl(tabNotifier: _tabNotifier),
                        const SizedBox(height: AppSpacing.xl),
                        _HeaderCard(isTerms: isTerms),
                        const SizedBox(height: AppSpacing.xl),
                        ...(isTerms ? _terms : _privacy).map(
                          (section) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: _LegalCard(section: section),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const _terms = [
    _LegalSection(
      title: 'Professional Conduct',
      body:
          'Providers must deliver healthcare services professionally, safely, and within their licensed scope of practice.',
    ),
    _LegalSection(
      title: 'Booking Commitment',
      body:
          'Accepted visits should be attended on time. Repeated cancellations may affect provider visibility.',
    ),
    _LegalSection(
      title: 'Patient Safety',
      body:
          'Providers must prioritize patient safety and report emergencies or issues immediately.',
    ),
  ];

  static const _privacy = [
    _LegalSection(
      title: 'Data Collection',
      body:
          'MedLink collects provider profile data, verification documents, service activity, and payout information.',
    ),
    _LegalSection(
      title: 'Data Usage',
      body:
          'Data is used to match providers with patients, process payments, verify identity, and improve safety.',
    ),
    _LegalSection(
      title: 'Confidentiality',
      body:
          'Providers must maintain confidentiality of patient information and visit records.',
    ),
  ];
}

class _SegmentControl extends StatelessWidget {
  final ValueNotifier<int> tabNotifier;

  const _SegmentControl({required this.tabNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabNotifier,
      builder: (context, index, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderGray),
          ),
          child: Row(
            children: [
              _SegmentButton(
                label: 'Terms',
                selected: index == 0,
                onTap: () => tabNotifier.value = 0,
              ),
              _SegmentButton(
                label: 'Privacy',
                selected: index == 1,
                onTap: () => tabNotifier.value = 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? AppColors.white : AppColors.textLight,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isTerms;

  const _HeaderCard({required this.isTerms});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Icon(
            isTerms ? Icons.description_outlined : Icons.privacy_tip_outlined,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              isTerms ? 'Provider Terms of Service' : 'Provider Privacy Policy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  final _LegalSection section;

  const _LegalCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            section.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  height: 1.55,
                ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection {
  final String title;
  final String body;

  const _LegalSection({
    required this.title,
    required this.body,
  });
}