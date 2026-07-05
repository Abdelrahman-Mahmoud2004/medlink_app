import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../data/models/medical_record_model.dart';

class MedicalRecordDetailsScreen extends StatelessWidget {
  final MedicalRecordModel record;

  const MedicalRecordDetailsScreen({
    super.key,
    required this.record,
  });

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.medicalHistory);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  IconData get _icon {
    switch (record.type) {
      case MedicalRecordType.general:
        return Icons.health_and_safety_rounded;
      case MedicalRecordType.diagnosis:
        return Icons.medical_information_rounded;
      case MedicalRecordType.labResult:
        return Icons.science_rounded;
      case MedicalRecordType.prescription:
        return Icons.receipt_long_rounded;
      case MedicalRecordType.surgery:
        return Icons.healing_rounded;
      case MedicalRecordType.allergy:
        return Icons.warning_amber_rounded;
      case MedicalRecordType.vaccine:
        return Icons.vaccines_rounded;
      case MedicalRecordType.imaging:
        return Icons.image_search_rounded;
    }
  }

  Color get _color {
    switch (record.type) {
      case MedicalRecordType.labResult:
        return const Color(0xFF8B5CF6);
      case MedicalRecordType.prescription:
        return AppColors.primaryBlue;
      case MedicalRecordType.allergy:
        return AppColors.errorRed;
      case MedicalRecordType.surgery:
        return AppColors.warningOrange;
      default:
        return AppColors.successGreen;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Record Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: _color.withValues(alpha: 0.20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: _color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(
                        _icon,
                        color: _color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      record.displayTitle,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      record.type.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _color,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _DetailsCard(
                title: 'Record Information',
                children: [
                  _InfoRow(label: 'Provider', value: record.displayProvider),
                  _InfoRow(label: 'Date', value: _formatDate(record.recordDate)),
                  _InfoRow(label: 'Type', value: record.type.label),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              _DetailsCard(
                title: 'Summary',
                children: [
                  Text(
                    record.summary.trim().isEmpty
                        ? 'No summary available.'
                        : record.summary,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDark,
                          height: 1.55,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              _DetailsCard(
                title: 'Notes',
                children: [
                  Text(
                    record.notes.trim().isEmpty
                        ? 'No notes available.'
                        : record.notes,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDark,
                          height: 1.55,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              _DetailsCard(
                title: 'Attachments',
                children: record.attachments.isEmpty
                    ? [
                        Text(
                          'No attachments available.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                        ),
                      ]
                    : record.attachments.map((attachment) {
                        return _AttachmentTile(
                          title: attachment,
                          onTap: () =>
                              _showComingSoon(context, 'Open attachment'),
                        );
                      }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailsCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _AttachmentTile({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(
          Icons.attach_file_rounded,
          color: AppColors.primaryBlue,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}