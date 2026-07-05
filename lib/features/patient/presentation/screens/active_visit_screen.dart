import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../nurse/data/models/vital_signs_model.dart';
import '../../data/models/visit_model.dart';

class ActiveVisitScreen extends StatefulWidget {
  final VisitModel visit;

  const ActiveVisitScreen({
    super.key,
    required this.visit,
  });

  @override
  State<ActiveVisitScreen> createState() => _ActiveVisitScreenState();
}

class _ActiveVisitScreenState extends State<ActiveVisitScreen> {
  Timer? _ticker;
  Duration _elapsed = Duration.zero;

  VitalSignsModel? _recordedVitals;

  late final List<_VisitTask> _tasks;

  @override
  void initState() {
    super.initState();

    _tasks = [
      _VisitTask('Check Vital Signs'),
      _VisitTask('Administer Medication'),
      _VisitTask('Progress Notes'),
      _VisitTask('Complete Visit'),
    ];

    _syncElapsed();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(_syncElapsed);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncElapsed() {
    final diff = DateTime.now().difference(widget.visit.startTime);

    _elapsed = diff.isNegative ? Duration.zero : diff;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  double get _progress {
    final plannedSeconds = widget.visit.plannedDuration.inSeconds;

    if (plannedSeconds <= 0) {
      return 0;
    }

    return (_elapsed.inSeconds / plannedSeconds).clamp(0.0, 1.0);
  }

  Future<void> _openVitalSigns() async {
    final result = await context.push<VitalSignsModel>(
      AppRoutes.vitalSigns,
    );

    if (result == null || !mounted) return;

    setState(() {
      _recordedVitals = result;
      _tasks[0].isDone = true;
    });
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
      ),
    );
  }

  void _confirmCompleteVisit() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Complete Visit?'),
          content: Text(
            'Elapsed time: ${_formatDuration(_elapsed)}.\n'
            'Are you sure you want to mark this visit as complete?',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.successGreen,
              ),
              onPressed: () {
                dialogContext.pop();

                if (!mounted) return;

                context.go(AppRoutes.nurseHome);
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Active Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimerCard(context),
              const SizedBox(height: AppSpacing.xl),
              _buildNurseInfo(context),
              const SizedBox(height: AppSpacing.xl),
              _buildServiceDetails(context),
              const SizedBox(height: AppSpacing.xl),
              _buildTasksChecklist(context),
              const SizedBox(height: AppSpacing.xl),
              _buildQuickActions(context),
              const SizedBox(height: AppSpacing.xl),
              _buildIssuesSection(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              top: BorderSide(color: AppColors.borderGray),
            ),
          ),
          child: FilledButton(
            onPressed: _confirmCompleteVisit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Complete Visit'),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerCard(BuildContext context) {
    final plannedMinutes = widget.visit.plannedDuration.inMinutes;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
            color: AppColors.primaryBlue.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Elapsed Time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  'IN PROGRESS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _formatDuration(_elapsed),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 7,
              backgroundColor: AppColors.white.withValues(alpha: 0.30),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.successGreen,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${_elapsed.inMinutes} of $plannedMinutes minutes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.82),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNurseInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.lightBlue,
                backgroundImage: widget.visit.nurseImage.trim().isEmpty
                    ? null
                    : NetworkImage(widget.visit.nurseImage),
                child: widget.visit.nurseImage.trim().isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        color: AppColors.primaryBlue,
                        size: 34,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.onlineGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.visit.nurseName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.visit.serviceType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  onTap: () => _showComingSoon('Call'),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 16,
                          color: AppColors.primaryBlue,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Call Now',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetails(BuildContext context) {
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
            'Service Details',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Patient',
            value: widget.visit.patientName,
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Location',
            value: widget.visit.location,
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Duration',
            value: '${widget.visit.durationInHours} hours',
          ),
          if (_recordedVitals != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(
              label: 'Vitals',
              value:
                  '${_recordedVitals!.bloodPressureSystolic}/${_recordedVitals!.bloodPressureDiastolic} mmHg · '
                  '${_recordedVitals!.heartRate} bpm',
              valueColor: AppColors.successGreen,
            ),
          ],
          if (widget.visit.notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.borderGray),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Notes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.visit.notes,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTasksChecklist(BuildContext context) {
    final doneCount = _tasks.where((task) => task.isDone).length;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tasks Checklist',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
              ),
              Text(
                '$doneCount/${_tasks.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(_tasks.length, (index) {
            final task = _tasks[index];

            return InkWell(
              onTap: () => _toggleTask(index),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: task.isDone
                            ? AppColors.successGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isDone
                              ? AppColors.successGreen
                              : AppColors.borderGray,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: task.isDone
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.white,
                              size: 15,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        task.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isDone
                                  ? AppColors.textLight
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.note_outlined,
            label: 'Progress Notes',
            onTap: () => _showComingSoon('Progress Notes'),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _ActionButton(
            icon: Icons.favorite_outline_rounded,
            label: 'Vital Signs',
            onTap: _openVitalSigns,
          ),
        ),
      ],
    );
  }

  Widget _buildIssuesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: AppColors.errorRed,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Report an Issue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.errorRed,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'If there are any issues during the visit, report them here immediately.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  height: 1.45,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () => _showComingSoon('Report Issue'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.errorRed),
              foregroundColor: AppColors.errorRed,
              minimumSize: const Size(double.infinity, 42),
            ),
            child: const Text('Report Issue'),
          ),
        ],
      ),
    );
  }
}

class _VisitTask {
  final String label;
  bool isDone;

  _VisitTask(
    this.label, {
    this.isDone = false,
  });
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
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textDark,
                ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.lightBlue,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}