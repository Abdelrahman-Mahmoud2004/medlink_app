import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../patient/data/models/request_model.dart';
import '../../../patient/data/models/visit_model.dart';
import '../../../patient/data/models/vital_signs_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class NurseActiveVisitScreen extends StatefulWidget {
  final Object? payload;

  const NurseActiveVisitScreen({
    super.key,
    this.payload,
  });

  @override
  State<NurseActiveVisitScreen> createState() => _NurseActiveVisitScreenState();
}

class _NurseActiveVisitScreenState extends State<NurseActiveVisitScreen> {
  late final _VisitInfo _visit;
  late final DateTime _startedAt;

  Timer? _timer;

  final ValueNotifier<Duration> _elapsedNotifier =
      ValueNotifier<Duration>(Duration.zero);

  final ValueNotifier<List<_VisitTask>> _tasksNotifier =
      ValueNotifier<List<_VisitTask>>(
    const [
      _VisitTask(label: 'Arrived at patient location'),
      _VisitTask(label: 'Record vital signs'),
      _VisitTask(label: 'Add progress notes'),
      _VisitTask(label: 'Complete care service'),
    ],
  );

  final ValueNotifier<VitalSignsModel?> _vitalsNotifier =
      ValueNotifier<VitalSignsModel?>(null);

  final ValueNotifier<String> _progressNotesNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();

    _visit = _VisitInfo.fromPayload(widget.payload);
    _startedAt = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedNotifier.value = DateTime.now().difference(_startedAt);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _elapsedNotifier.dispose();
    _tasksNotifier.dispose();
    _vitalsNotifier.dispose();
    _progressNotesNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  double _progress(Duration elapsed) {
    final plannedSeconds = (_visit.durationInHours * 3600).round();

    if (plannedSeconds <= 0) return 0;

    return (elapsed.inSeconds / plannedSeconds).clamp(0.0, 1.0);
  }

  void _toggleTask(int index) {
    final tasks = List<_VisitTask>.of(_tasksNotifier.value);
    final current = tasks[index];

    tasks[index] = current.copyWith(isDone: !current.isDone);

    _tasksNotifier.value = tasks;
  }

  void _markTaskDone(int index) {
    final tasks = List<_VisitTask>.of(_tasksNotifier.value);

    if (index < 0 || index >= tasks.length) return;

    tasks[index] = tasks[index].copyWith(isDone: true);

    _tasksNotifier.value = tasks;
  }

  Future<void> _openVitalSigns() async {
    final result = await context.push<VitalSignsModel>(
      AppRoutes.vitalSigns,
    );

    if (result == null || !mounted) return;

    _vitalsNotifier.value = result;
    _markTaskDone(1);
  }

  Future<void> _openProgressNotes() async {
    final result = await context.push<String>(
      AppRoutes.nurseProgressNotes,
      extra: _progressNotesNotifier.value,
    );

    if (result == null || !mounted) return;

    _progressNotesNotifier.value = result;
    _markTaskDone(2);
  }

  void _openCompleteVisit() {
  _markTaskDone(3);

  context.push(
    AppRoutes.nurseCompleteVisit,
    extra: {
      'patientName': _visit.patientName,
      'serviceType': _visit.serviceType,
      'amount': _visit.amount,
      'startTime': _startedAt,
      'endTime': DateTime.now(),
      'notes': _progressNotesNotifier.value,
      'vitals': _vitalsNotifier.value,
    },
  );
}

  void _reportIssue() {
  context.push(AppRoutes.nurseReportIssue);
}

  void _callPatient() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling patient feature coming soon'),
      ),
    );
  }

  void _openNavigation() {
    context.push(
      AppRoutes.nurseGpsNavigation,
      extra: _visit.toRequestModel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Active Visit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
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
                    _TimerCard(
                      elapsedNotifier: _elapsedNotifier,
                      plannedHours: _visit.durationInHours,
                      formatDuration: _formatDuration,
                      progressResolver: _progress,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _PatientInfoCard(
                      visit: _visit,
                      onCall: _callPatient,
                      onNavigate: _openNavigation,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ServiceDetailsCard(visit: _visit),
                    const SizedBox(height: AppSpacing.xl),
                    _TasksCard(
                      tasksNotifier: _tasksNotifier,
                      onToggle: _toggleTask,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _ClinicalRecordsCard(
                      vitalsNotifier: _vitalsNotifier,
                      notesNotifier: _progressNotesNotifier,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _QuickActions(
                      onVitalSigns: _openVitalSigns,
                      onProgressNotes: _openProgressNotes,
                      onReportIssue: _reportIssue,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
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
          child: FilledButton.icon(
            onPressed: _openCompleteVisit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              minimumSize: const Size(double.infinity, 52),
            ),
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Complete Visit / Clock Out'),
          ),
        ),
      ),
    );
  }
}

class _VisitInfo {
  final String id;
  final String patientName;
  final String patientImage;
  final String serviceType;
  final String location;
  final double durationInHours;
  final String notes;
  final double amount;

  const _VisitInfo({
    required this.id,
    required this.patientName,
    required this.patientImage,
    required this.serviceType,
    required this.location,
    required this.durationInHours,
    required this.notes,
    required this.amount,
  });

  factory _VisitInfo.fromPayload(Object? payload) {
    if (payload is RequestModel) {
      return _VisitInfo.fromRequest(payload);
    }

    if (payload is VisitModel) {
      return _VisitInfo.fromVisit(payload);
    }

    if (payload is Map) {
      final data = Map<String, dynamic>.from(payload);

      return _VisitInfo(
        id: data['id']?.toString() ?? 'visit_${DateTime.now().millisecondsSinceEpoch}',
        patientName: data['patientName']?.toString() ?? 'Patient',
        patientImage: data['patientImage']?.toString() ?? '',
        serviceType: data['serviceType']?.toString() ?? 'Home Visit',
        location: data['location']?.toString() ?? 'Patient location',
        durationInHours: data['durationInHours'] is num
            ? (data['durationInHours'] as num).toDouble()
            : 1.0,
        notes: data['notes']?.toString() ?? '',
        amount: data['amount'] is num ? (data['amount'] as num).toDouble() : 250.0,
      );
    }

    return _VisitInfo.fromRequest(NurseMockData.scheduledBloodTest);
  }

  factory _VisitInfo.fromRequest(RequestModel request) {
    return _VisitInfo(
      id: request.id,
      patientName: request.patientName,
      patientImage: request.patientImage,
      serviceType: request.serviceType,
      location: request.location,
      durationInHours: request.duration,
      notes: request.notes,
      amount: request.calculatedPay,
    );
  }

  factory _VisitInfo.fromVisit(VisitModel visit) {
    return _VisitInfo(
      id: visit.id,
      patientName: visit.patientName,
      patientImage: '',
      serviceType: visit.serviceType,
      location: visit.location,
      durationInHours: visit.durationInHours,
      notes: visit.notes,
      amount: 250.0,
    );
  }

  RequestModel toRequestModel() {
    return RequestModel(
      id: id,
      patientName: patientName,
      patientImage: patientImage,
      serviceType: serviceType,
      specialty: serviceType,
      calculatedPay: amount,
      distance: 2.5,
      duration: durationInHours,
      status: RequestStatus.scheduled,
      requestedTime: DateTime.now(),
      location: location,
      notes: notes,
    );
  }
}

class _VisitTask {
  final String label;
  final bool isDone;

  const _VisitTask({
    required this.label,
    this.isDone = false,
  });

  _VisitTask copyWith({
    String? label,
    bool? isDone,
  }) {
    return _VisitTask(
      label: label ?? this.label,
      isDone: isDone ?? this.isDone,
    );
  }
}

class _TimerCard extends StatelessWidget {
  final ValueNotifier<Duration> elapsedNotifier;
  final double plannedHours;
  final String Function(Duration duration) formatDuration;
  final double Function(Duration elapsed) progressResolver;

  const _TimerCard({
    required this.elapsedNotifier,
    required this.plannedHours,
    required this.formatDuration,
    required this.progressResolver,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: elapsedNotifier,
      builder: (context, elapsed, _) {
        final plannedMinutes = (plannedHours * 60).round();

        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.28),
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
                        vertical: AppSpacing.xs,
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
                  formatDuration(elapsed),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: progressResolver(elapsed),
                    minHeight: 7,
                    backgroundColor: AppColors.white.withValues(alpha: 0.30),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.successGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${elapsed.inMinutes} of $plannedMinutes minutes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.82),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PatientInfoCard extends StatelessWidget {
  final _VisitInfo visit;
  final VoidCallback onCall;
  final VoidCallback onNavigate;

  const _PatientInfoCard({
    required this.visit,
    required this.onCall,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Patient Information',
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.lightBlue,
            child: ClipOval(
              child: Image.network(
                visit.patientImage,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  color: AppColors.primaryBlue,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.patientName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  visit.serviceType,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _MiniAction(
                      icon: Icons.phone_rounded,
                      label: 'Call',
                      onTap: onCall,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _MiniAction(
                      icon: Icons.navigation_rounded,
                      label: 'Map',
                      onTap: onNavigate,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceDetailsCard extends StatelessWidget {
  final _VisitInfo visit;

  const _ServiceDetailsCard({
    required this.visit,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Service Details',
      child: Column(
        children: [
          _DetailRow(label: 'Service', value: visit.serviceType),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(label: 'Location', value: visit.location),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Duration',
            value: '${visit.durationInHours.toStringAsFixed(1)} hours',
          ),
          const SizedBox(height: AppSpacing.lg),
          _DetailRow(
            label: 'Estimated Earning',
            value: 'EGP ${visit.amount.toStringAsFixed(0)}',
            valueColor: AppColors.successGreen,
          ),
          if (visit.notes.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.borderGray),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                visit.notes,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textDark,
                      height: 1.45,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TasksCard extends StatelessWidget {
  final ValueNotifier<List<_VisitTask>> tasksNotifier;
  final ValueChanged<int> onToggle;

  const _TasksCard({
    required this.tasksNotifier,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_VisitTask>>(
      valueListenable: tasksNotifier,
      builder: (context, tasks, _) {
        final doneCount = tasks.where((task) => task.isDone).length;

        return _SectionCard(
          title: 'Visit Checklist',
          trailing: Text(
            '$doneCount/${tasks.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
          ),
          child: Column(
            children: List.generate(tasks.length, (index) {
              final task = tasks[index];

              return InkWell(
                onTap: () => onToggle(index),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        width: 24,
                        height: 24,
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
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Text(
                          task.label,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: task.isDone
                                        ? AppColors.textLight
                                        : AppColors.textDark,
                                    fontWeight: FontWeight.w700,
                                    decoration: task.isDone
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _ClinicalRecordsCard extends StatelessWidget {
  final ValueNotifier<VitalSignsModel?> vitalsNotifier;
  final ValueNotifier<String> notesNotifier;

  const _ClinicalRecordsCard({
    required this.vitalsNotifier,
    required this.notesNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Clinical Records',
      child: Column(
        children: [
          ValueListenableBuilder<VitalSignsModel?>(
            valueListenable: vitalsNotifier,
            builder: (context, vitals, _) {
              return _RecordTile(
                icon: Icons.monitor_heart_outlined,
                title: 'Vital Signs',
                subtitle: vitals == null
                    ? 'Not recorded yet'
                    : '${vitals.bloodPressureText} · ${vitals.heartRateText}',
                color: vitals == null
                    ? AppColors.textLight
                    : AppColors.successGreen,
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          ValueListenableBuilder<String>(
            valueListenable: notesNotifier,
            builder: (context, notes, _) {
              return _RecordTile(
                icon: Icons.edit_note_rounded,
                title: 'Progress Notes',
                subtitle: notes.trim().isEmpty
                    ? 'No notes added'
                    : '${notes.trim().length} characters saved',
                color: notes.trim().isEmpty
                    ? AppColors.textLight
                    : AppColors.successGreen,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onVitalSigns;
  final VoidCallback onProgressNotes;
  final VoidCallback onReportIssue;

  const _QuickActions({
    required this.onVitalSigns,
    required this.onProgressNotes,
    required this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.favorite_outline_rounded,
            label: 'Vital Signs',
            onTap: onVitalSigns,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _ActionButton(
            icon: Icons.note_alt_outlined,
            label: 'Notes',
            onTap: onProgressNotes,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _ActionButton(
            icon: Icons.warning_amber_rounded,
            label: 'Issue',
            color: AppColors.errorRed,
            onTap: onReportIssue,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryBlue),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _RecordTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = AppColors.primaryBlue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
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