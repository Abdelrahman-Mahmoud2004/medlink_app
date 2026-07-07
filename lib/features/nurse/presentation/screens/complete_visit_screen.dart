import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../patient/data/models/vital_signs_model.dart';

class CompleteVisitScreen extends StatefulWidget {
  final String? patientName;
  final String? serviceType;
  final double? amount;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? initialNotes;
  final VitalSignsModel? vitals;

  const CompleteVisitScreen({
    super.key,
    this.patientName,
    this.serviceType,
    this.amount,
    this.startTime,
    this.endTime,
    this.initialNotes,
    this.vitals,
  });

  @override
  State<CompleteVisitScreen> createState() => _CompleteVisitScreenState();
}

class _CompleteVisitScreenState extends State<CompleteVisitScreen> {
  final ValueNotifier<int> _ratingNotifier = ValueNotifier<int>(5);
  final ValueNotifier<bool> _isCompletingNotifier = ValueNotifier<bool>(false);

  final TextEditingController _summaryController = TextEditingController();

  late final DateTime _startTime;
  late final DateTime _suggestedEndTime;

  @override
  void initState() {
    super.initState();

    _startTime = widget.startTime ??
        DateTime.now().subtract(const Duration(hours: 1));
    _suggestedEndTime = widget.endTime ?? DateTime.now();

    final notes = widget.initialNotes?.trim() ?? '';

    _summaryController.text = notes.isNotEmpty
        ? notes
        : 'Visit completed successfully. Patient condition stable.';
  }

  @override
  void dispose() {
    _ratingNotifier.dispose();
    _isCompletingNotifier.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isCompletingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);

    if (duration.isNegative) {
      return '00h 00m';
    }

    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');

    return '${hours}h ${minutes}m';
  }

  Future<void> _completeVisit() async {
    if (_isCompletingNotifier.value) return;

    final summary = _summaryController.text.trim();

    if (summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a visit summary'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    _isCompletingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final completedAt = DateTime.now();

    _isCompletingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Visit completed and clocked out'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.go(
      AppRoutes.nurseVisitReport,
      extra: {
        'patientName': widget.patientName ?? 'Patient',
        'serviceType': widget.serviceType ?? 'Home Visit',
        'amount': widget.amount ?? 250.0,
        'startTime': _startTime,
        'endTime': completedAt,
        'notes': summary,
        'vitals': widget.vitals,
        'rating': _ratingNotifier.value,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientName ?? 'Patient';
    final serviceType = widget.serviceType ?? 'Home Visit';
    final amount = widget.amount ?? 250.0;
    final endTime = widget.endTime ?? _suggestedEndTime;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Complete Visit'),
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
                    const _SuccessHeader(),
                    const SizedBox(height: AppSpacing.xl),
                    _VisitSummaryCard(
                      patientName: patientName,
                      serviceType: serviceType,
                      amount: amount,
                      startTimeText: _formatTime(_startTime),
                      endTimeText: _formatTime(endTime),
                      durationText: _formatDuration(_startTime, endTime),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (widget.vitals != null) ...[
                      _VitalsPreviewCard(vitals: widget.vitals!),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                    _SummaryEditor(controller: _summaryController),
                    const SizedBox(height: AppSpacing.xl),
                    _RatingCard(ratingNotifier: _ratingNotifier),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isCompletingNotifier,
                      builder: (context, isCompleting, _) {
                        return FilledButton(
                          onPressed: isCompleting ? null : _completeVisit,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: AppColors.successGreen,
                          ),
                          child: isCompleting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text('Clock Out & Complete Visit'),
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

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.successGreen, AppColors.primaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.successGreen.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to Complete',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Confirm summary, rating, and clock out from this visit.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                          height: 1.4,
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

class _VisitSummaryCard extends StatelessWidget {
  final String patientName;
  final String serviceType;
  final double amount;
  final String startTimeText;
  final String endTimeText;
  final String durationText;

  const _VisitSummaryCard({
    required this.patientName,
    required this.serviceType,
    required this.amount,
    required this.startTimeText,
    required this.endTimeText,
    required this.durationText,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Visit Overview',
      child: Column(
        children: [
          _DetailRow(label: 'Patient', value: patientName),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Service', value: serviceType),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Started At', value: startTimeText),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Finished At', value: endTimeText),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Duration', value: durationText),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Earning',
            value: 'EGP ${amount.toStringAsFixed(0)}',
            valueColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }
}

class _VitalsPreviewCard extends StatelessWidget {
  final VitalSignsModel vitals;

  const _VitalsPreviewCard({
    required this.vitals,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recorded Vital Signs',
      child: Column(
        children: [
          _DetailRow(label: 'Blood Pressure', value: vitals.bloodPressureText),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Heart Rate', value: vitals.heartRateText),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Temperature', value: vitals.temperatureText),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Oxygen Saturation',
            value: vitals.oxygenSaturationText,
          ),
        ],
      ),
    );
  }
}

class _SummaryEditor extends StatelessWidget {
  final TextEditingController controller;

  const _SummaryEditor({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Completion Summary',
      child: TextField(
        controller: controller,
        minLines: 5,
        maxLines: 8,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: 'Write final visit summary...',
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
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: const BorderSide(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.all(AppSpacing.lg),
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final ValueNotifier<int> ratingNotifier;

  const _RatingCard({
    required this.ratingNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Visit Quality',
      child: ValueListenableBuilder<int>(
        valueListenable: ratingNotifier,
        builder: (context, rating, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final selected = starValue <= rating;

              return IconButton(
                onPressed: () => ratingNotifier.value = starValue,
                icon: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.warningOrange,
                  size: 34,
                ),
              );
            }),
          );
        },
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
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
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
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
              ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: valueColor ?? AppColors.textDark,
                  fontWeight: FontWeight.w800,
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