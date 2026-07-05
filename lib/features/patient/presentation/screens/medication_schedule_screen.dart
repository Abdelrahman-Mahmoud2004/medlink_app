import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/medication_model.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  State<MedicationScheduleScreen> createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  late List<MedicationModel> _medications;

  @override
  void initState() {
    super.initState();

    _medications = [
      MedicationModel(
        id: '1',
        name: 'Paracetamol',
        dosage: '500 mg',
        frequency: 'Twice daily',
        times: const ['09:00 AM', '09:00 PM'],
        startDate: DateTime.now().subtract(const Duration(days: 4)),
        notes: 'Take after meals.',
      ),
      MedicationModel(
        id: '2',
        name: 'Vitamin D',
        dosage: '1000 IU',
        frequency: 'Once daily',
        times: const ['10:00 AM'],
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        notes: 'Morning dose preferred.',
      ),
    ];
  }

  List<MedicationModel> get _activeMedications {
    return _medications.where((medication) => medication.isActive).toList();
  }

  List<MedicationModel> get _inactiveMedications {
    return _medications.where((medication) => !medication.isActive).toList();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientProfile);
  }

  Future<void> _addMedication() async {
    final result = await context.push<MedicationModel>(
      AppRoutes.addEditMedication,
    );

    if (result == null || !mounted) return;

    setState(() {
      _medications.add(result);
    });
  }

  Future<void> _editMedication(MedicationModel medication) async {
    final result = await context.push<MedicationModel>(
      AppRoutes.addEditMedication,
      extra: medication,
    );

    if (result == null || !mounted) return;

    setState(() {
      final index = _medications.indexWhere((item) => item.id == result.id);

      if (index != -1) {
        _medications[index] = result;
      }
    });
  }

  void _toggleMedication(MedicationModel medication) {
    setState(() {
      final index = _medications.indexWhere((item) => item.id == medication.id);

      if (index != -1) {
        _medications[index] = medication.copyWith(
          isActive: !medication.isActive,
        );
      }
    });
  }

  Future<void> _deleteMedication(MedicationModel medication) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Medication?'),
          content: Text(
            'Are you sure you want to delete "${medication.displayName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
              onPressed: () => dialogContext.pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;

    setState(() {
      _medications.removeWhere((item) => item.id == medication.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeMedications;
    final inactive = _inactiveMedications;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Medication Schedule'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _medications.isEmpty
                  ? const _EmptyMedicationState()
                  : ListView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      children: [
                        _ScheduleSummaryCard(
                          activeCount: active.length,
                          totalCount: _medications.length,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        if (active.isNotEmpty) ...[
                          const _SectionTitle(title: 'Active Medications'),
                          const SizedBox(height: AppSpacing.md),
                          ...active.map(
                            (medication) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.lg,
                              ),
                              child: _MedicationCard(
                                medication: medication,
                                onEdit: () => _editMedication(medication),
                                onToggle: () => _toggleMedication(medication),
                                onDelete: () => _deleteMedication(medication),
                              ),
                            ),
                          ),
                        ],
                        if (inactive.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          const _SectionTitle(title: 'Paused Medications'),
                          const SizedBox(height: AppSpacing.md),
                          ...inactive.map(
                            (medication) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.lg,
                              ),
                              child: _MedicationCard(
                                medication: medication,
                                onEdit: () => _editMedication(medication),
                                onToggle: () => _toggleMedication(medication),
                                onDelete: () => _deleteMedication(medication),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.borderGray),
                ),
              ),
              child: CustomButton(
                label: 'Add Medication',
                onPressed: _addMedication,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleSummaryCard extends StatelessWidget {
  final int activeCount;
  final int totalCount;

  const _ScheduleSummaryCard({
    required this.activeCount,
    required this.totalCount,
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
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medication_rounded,
            color: AppColors.white,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$activeCount Active',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$totalCount medications in your schedule',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w600,
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

class _MedicationCard extends StatelessWidget {
  final MedicationModel medication;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _MedicationCard({
    required this.medication,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

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

  @override
  Widget build(BuildContext context) {
    final statusColor =
        medication.isActive ? AppColors.successGreen : AppColors.textLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${medication.displayDosage} • ${medication.displayFrequency}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  medication.isActive ? 'Active' : 'Paused',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          _MedicationInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Times',
            value: medication.times.isEmpty
                ? 'Not specified'
                : medication.times.join(', '),
          ),
          const SizedBox(height: AppSpacing.md),
          _MedicationInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Start Date',
            value: _formatDate(medication.startDate),
          ),
          if (medication.notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _MedicationInfoRow(
              icon: Icons.notes_rounded,
              label: 'Notes',
              value: medication.notes,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onToggle,
                  child: Text(medication.isActive ? 'Pause' : 'Activate'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorRed,
                    side: const BorderSide(color: AppColors.errorRed),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicationInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MedicationInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 18,
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _EmptyMedicationState extends StatelessWidget {
  const _EmptyMedicationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medication_outlined,
              color: AppColors.textLight,
              size: 70,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No medications yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add medications to keep track of your daily schedule.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}