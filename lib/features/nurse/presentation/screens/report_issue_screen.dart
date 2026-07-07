import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final TextEditingController _descriptionController = TextEditingController();

  final ValueNotifier<String> _categoryNotifier =
      ValueNotifier<String>('Patient not available');
  final ValueNotifier<String> _severityNotifier = ValueNotifier<String>('Medium');
  final ValueNotifier<bool> _isSubmittingNotifier = ValueNotifier<bool>(false);

  static const categories = [
    'Patient not available',
    'Wrong address',
    'Medical emergency',
    'Payment issue',
    'Safety concern',
    'Other',
  ];

  static const severities = ['Low', 'Medium', 'High'];

  @override
  void dispose() {
    _descriptionController.dispose();
    _categoryNotifier.dispose();
    _severityNotifier.dispose();
    _isSubmittingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSubmittingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  Future<void> _submit() async {
    if (_isSubmittingNotifier.value) return;

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the issue'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    _isSubmittingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    _isSubmittingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Issue reported successfully'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.pop({
      'category': _categoryNotifier.value,
      'severity': _severityNotifier.value,
      'description': _descriptionController.text.trim(),
    });
  }

  Color _severityColor(String severity) {
    return switch (severity) {
      'Low' => AppColors.successGreen,
      'Medium' => AppColors.warningOrange,
      'High' => AppColors.errorRed,
      _ => AppColors.textLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Report Issue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    const _HeaderCard(),
                    const SizedBox(height: AppSpacing.xl),
                    _DropdownCard(
                      title: 'Issue Category',
                      valueNotifier: _categoryNotifier,
                      items: categories,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<String>(
                      valueListenable: _severityNotifier,
                      builder: (context, severity, _) {
                        return _SeverityCard(
                          selected: severity,
                          items: severities,
                          colorResolver: _severityColor,
                          onChanged: (value) =>
                              _severityNotifier.value = value,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _DescriptionCard(controller: _descriptionController),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSubmittingNotifier,
                      builder: (context, isSubmitting, _) {
                        return FilledButton.icon(
                          onPressed: isSubmitting ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.errorRed,
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.warning_amber_rounded),
                          label: Text(isSubmitting
                              ? 'Submitting...'
                              : 'Submit Issue Report'),
                        );
                      },
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.errorRed,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              'Report any visit issue immediately so MedLink support can review it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownCard extends StatelessWidget {
  final String title;
  final ValueNotifier<String> valueNotifier;
  final List<String> items;

  const _DropdownCard({
    required this.title,
    required this.valueNotifier,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: valueNotifier,
      builder: (context, value, _) {
        return _SectionCard(
          title: title,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (newValue) {
              if (newValue == null) return;
              valueNotifier.value = newValue;
            },
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColors.bgGray,
              border: OutlineInputBorder(),
            ),
          ),
        );
      },
    );
  }
}

class _SeverityCard extends StatelessWidget {
  final String selected;
  final List<String> items;
  final Color Function(String severity) colorResolver;
  final ValueChanged<String> onChanged;

  const _SeverityCard({
    required this.selected,
    required this.items,
    required this.colorResolver,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Severity',
      child: Row(
        children: items.map((item) {
          final isSelected = selected == item;
          final color = colorResolver(item);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => onChanged(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.12)
                        : AppColors.bgGray,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: isSelected ? color : AppColors.borderGray,
                    ),
                  ),
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected ? color : AppColors.textLight,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  final TextEditingController controller;

  const _DescriptionCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Description',
      child: TextField(
        controller: controller,
        minLines: 5,
        maxLines: 8,
        decoration: InputDecoration(
          hintText: 'Describe what happened...',
          filled: true,
          fillColor: AppColors.bgGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(color: AppColors.borderGray),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

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
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}