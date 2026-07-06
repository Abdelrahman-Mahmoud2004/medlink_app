import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../patient/data/models/request_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({super.key});

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  late final DateTime _firstDay;
  late final DateTime _lastDay;
  late final List<RequestModel> _allAppointments;
  late final Map<DateTime, List<String>> _calendarEvents;

  late DateTime _selectedDate;

  bool _isAvailable = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _firstDay = now.subtract(const Duration(days: 365));
    _lastDay = now.add(const Duration(days: 365));
    _selectedDate = AppDateFormatters.dateOnly(now);

    _allAppointments = NurseMockData.todaysAppointments;
    _calendarEvents = NurseMockData.calendarEvents;
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  List<String> _eventsForDay(DateTime day) {
    return _calendarEvents[AppDateFormatters.dateOnly(day)] ?? const [];
  }

  List<RequestModel> get _appointmentsForSelectedDay {
    return _allAppointments
        .where(
          (request) => AppDateFormatters.isSameDay(
            request.requestedTime,
            _selectedDate,
          ),
        )
        .toList(growable: false);
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  bool get _hasValidWorkingHours {
    return _timeToMinutes(_endTime) > _timeToMinutes(_startTime);
  }

  Color _statusColor(RequestStatus status) {
    return switch (status) {
      RequestStatus.active => AppColors.successGreen,
      RequestStatus.scheduled => AppColors.warningOrange,
      RequestStatus.completed => AppColors.primaryBlue,
      RequestStatus.cancelled => AppColors.errorRed,
      RequestStatus.unknown => AppColors.textLight,
    };
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _saveChanges() {
    if (_isAvailable && !_hasValidWorkingHours) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAvailable
              ? 'Availability saved for ${AppDateFormatters.mediumDate(_selectedDate)}'
              : 'You are marked unavailable for this day',
        ),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointments = _appointmentsForSelectedDay;
    final dayEvents = _eventsForDay(_selectedDate);

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('My Schedule'),
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
                    _CalendarCard(
                      firstDay: _firstDay,
                      lastDay: _lastDay,
                      selectedDate: _selectedDate,
                      dayEvents: dayEvents,
                      eventLoader: _eventsForDay,
                      onDaySelected: (selectedDay) {
                        setState(() {
                          _selectedDate =
                              AppDateFormatters.dateOnly(selectedDay);
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _AvailabilityCard(
                      selectedDate: _selectedDate,
                      isAvailable: _isAvailable,
                      startTime: _startTime,
                      endTime: _endTime,
                      hasValidWorkingHours: _hasValidWorkingHours,
                      onAvailabilityChanged: (value) {
                        setState(() => _isAvailable = value);
                      },
                      onPickStart: () => _pickTime(isStart: true),
                      onPickEnd: () => _pickTime(isStart: false),
                      onSave: _saveChanges,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _AppointmentsSection(
                      selectedDate: _selectedDate,
                      appointments: appointments,
                      statusColorResolver: _statusColor,
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

class _CalendarCard extends StatelessWidget {
  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime selectedDate;
  final List<String> dayEvents;
  final List<String> Function(DateTime day) eventLoader;
  final ValueChanged<DateTime> onDaySelected;

  const _CalendarCard({
    required this.firstDay,
    required this.lastDay,
    required this.selectedDate,
    required this.dayEvents,
    required this.eventLoader,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _CardDecoration.standard(),
        child: Column(
          children: [
            TableCalendar<String>(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: selectedDate,
              selectedDayPredicate: (day) {
                return AppDateFormatters.isSameDay(selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                onDaySelected(selectedDay);
              },
              eventLoader: eventLoader,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                leftChevronIcon: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.primaryBlue,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                markersMaxCount: 1,
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
                todayTextStyle: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
                defaultTextStyle: Theme.of(context).textTheme.bodySmall!,
                weekendTextStyle:
                    Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColors.textLight,
                        ),
              ),
            ),
            if (dayEvents.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const Divider(color: AppColors.borderGray),
              const SizedBox(height: AppSpacing.lg),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Calendar Notes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...dayEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _CalendarEventTile(event: event),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CalendarEventTile extends StatelessWidget {
  final String event;

  const _CalendarEventTile({
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              event,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityCard extends StatelessWidget {
  final DateTime selectedDate;
  final bool isAvailable;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final bool hasValidWorkingHours;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onSave;

  const _AvailabilityCard({
    required this.selectedDate,
    required this.isAvailable,
    required this.startTime,
    required this.endTime,
    required this.hasValidWorkingHours,
    required this.onAvailabilityChanged,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isAvailable ? AppColors.successGreen : AppColors.errorRed;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _CardDecoration.standard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _IconBox(
                  icon: isAvailable
                      ? Icons.check_circle_outline_rounded
                      : Icons.pause_circle_outline_rounded,
                  color: statusColor,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Availability',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isAvailable
                            ? 'Open for new shifts'
                            : 'Not accepting shifts',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isAvailable,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: onAvailabilityChanged,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.borderGray),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Working Hours for ${AppDateFormatters.mediumDate(selectedDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'From',
                    time: startTime,
                    enabled: isAvailable,
                    onTap: onPickStart,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _TimeField(
                    label: 'To',
                    time: endTime,
                    enabled: isAvailable,
                    onTap: onPickEnd,
                  ),
                ),
              ],
            ),
            if (isAvailable && !hasValidWorkingHours) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'End time must be after start time.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const _ClinicalHint(
              icon: Icons.lightbulb_outline_rounded,
              text:
                  'Keeping your schedule updated improves matching and reduces missed booking requests.',
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentsSection extends StatelessWidget {
  final DateTime selectedDate;
  final List<RequestModel> appointments;
  final Color Function(RequestStatus status) statusColorResolver;

  const _AppointmentsSection({
    required this.selectedDate,
    required this.appointments,
    required this.statusColorResolver,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = AppDateFormatters.isSameDay(selectedDate, DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isToday
              ? "Today's Appointments"
              : 'Appointments — ${AppDateFormatters.mediumDate(selectedDate)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (appointments.isEmpty)
          const _EmptyAppointments()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              final request = appointments[index];

              return _ScheduleCard(
                request: request,
                statusColor: statusColorResolver(request.status),
              );
            },
          ),
      ],
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            color: AppColors.textLight.withValues(alpha: 0.7),
            size: 44,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No appointments scheduled',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.time,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = enabled ? AppColors.primaryBlue : AppColors.textLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: enabled ? AppColors.bgGray : AppColors.borderGray,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.borderGray),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time.format(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: enabled
                              ? AppColors.textDark
                              : AppColors.textLight,
                        ),
                  ),
                  Icon(
                    Icons.access_time_rounded,
                    color: iconColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final RequestModel request;
  final Color statusColor;

  const _ScheduleCard({
    required this.request,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _CardDecoration.standard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.serviceType,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusPill(
                  label: request.status.label,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.lightBlue,
                  child: ClipOval(
                    child: Image.network(
                      request.patientImage,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    request.patientName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  AppDateFormatters.time24(request.requestedTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warningOrange,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _MiniInfo(
                    icon: Icons.location_on_outlined,
                    text: request.location.isEmpty
                        ? '${request.distance} km away'
                        : request.location,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'EGP ${request.calculatedPay.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.successGreen,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppColors.textLight,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ClinicalHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ClinicalHint({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _CardDecoration {
  const _CardDecoration._();

  static BoxDecoration standard() {
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