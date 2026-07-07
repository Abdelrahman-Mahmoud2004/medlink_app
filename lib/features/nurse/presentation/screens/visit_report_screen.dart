import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../patient/data/models/vital_signs_model.dart';

class VisitReportScreen extends StatelessWidget {
  final Object? payload;

  const VisitReportScreen({
    super.key,
    this.payload,
  });

  _VisitReportData get _data => _VisitReportData.fromPayload(payload);

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Visit Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    _HeaderCard(data: data),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionCard(
                      title: 'Visit Details',
                      child: Column(
                        children: [
                          _DetailRow(label: 'Patient', value: data.patientName),
                          const SizedBox(height: AppSpacing.lg),
                          _DetailRow(label: 'Service', value: data.serviceType),
                          const SizedBox(height: AppSpacing.lg),
                          _DetailRow(
                            label: 'Start Time',
                            value:
                                '${AppDateFormatters.mediumDate(data.startTime)} · ${AppDateFormatters.time24(data.startTime)}',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _DetailRow(
                            label: 'End Time',
                            value:
                                '${AppDateFormatters.mediumDate(data.endTime)} · ${AppDateFormatters.time24(data.endTime)}',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _DetailRow(
                            label: 'Earning',
                            value: 'EGP ${data.amount.toStringAsFixed(0)}',
                            valueColor: AppColors.successGreen,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionCard(
                      title: 'Vital Signs',
                      child: data.vitals == null
                          ? const Text('No vitals recorded')
                          : Column(
                              children: [
                                _DetailRow(
                                  label: 'Blood Pressure',
                                  value: data.vitals!.bloodPressureText,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _DetailRow(
                                  label: 'Heart Rate',
                                  value: data.vitals!.heartRateText,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _DetailRow(
                                  label: 'Temperature',
                                  value: data.vitals!.temperatureText,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _DetailRow(
                                  label: 'Oxygen',
                                  value: data.vitals!.oxygenSaturationText,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _SectionCard(
                      title: 'Progress Notes',
                      child: Text(
                        data.notes.isEmpty ? 'No progress notes.' : data.notes,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textDark,
                              height: 1.5,
                            ),
                      ),
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

class _VisitReportData {
  final String patientName;
  final String serviceType;
  final DateTime startTime;
  final DateTime endTime;
  final double amount;
  final VitalSignsModel? vitals;
  final String notes;

  const _VisitReportData({
    required this.patientName,
    required this.serviceType,
    required this.startTime,
    required this.endTime,
    required this.amount,
    this.vitals,
    required this.notes,
  });

  factory _VisitReportData.fromPayload(Object? payload) {
    if (payload is Map) {
      final data = Map<String, dynamic>.from(payload);

      return _VisitReportData(
        patientName: data['patientName']?.toString() ?? 'Patient',
        serviceType: data['serviceType']?.toString() ?? 'Home Visit',
        startTime: data['startTime'] is DateTime
            ? data['startTime'] as DateTime
            : DateTime.now().subtract(const Duration(hours: 1)),
        endTime: data['endTime'] is DateTime
            ? data['endTime'] as DateTime
            : DateTime.now(),
        amount: data['amount'] is num ? (data['amount'] as num).toDouble() : 250,
        vitals: data['vitals'] is VitalSignsModel
            ? data['vitals'] as VitalSignsModel
            : null,
        notes: data['notes']?.toString() ?? '',
      );
    }

    return _VisitReportData(
      patientName: 'Patient',
      serviceType: 'Home Visit',
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now(),
      amount: 250,
      notes: 'Visit completed successfully.',
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final _VisitReportData data;

  const _HeaderCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.successGreen, AppColors.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              '${data.serviceType} report is ready.',
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