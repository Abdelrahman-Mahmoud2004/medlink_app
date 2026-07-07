import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';

class RescheduleBookingScreen extends StatefulWidget {
  const RescheduleBookingScreen({super.key});

  @override
  State<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends State<RescheduleBookingScreen> {
  final ValueNotifier<DateTime> _selectedDateNotifier =
      ValueNotifier<DateTime>(DateTime.now().add(const Duration(days: 1)));
  final ValueNotifier<TimeOfDay> _selectedTimeNotifier =
      ValueNotifier<TimeOfDay>(const TimeOfDay(hour: 10, minute: 0));
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _selectedDateNotifier.dispose();
    _selectedTimeNotifier.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_isSavingNotifier.value) return;

    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientBookings);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateNotifier.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked == null) return;

    _selectedDateNotifier.value = picked;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimeNotifier.value,
    );

    if (picked == null) return;

    _selectedTimeNotifier.value = picked;
  }

  Future<void> _save() async {
    if (_isSavingNotifier.value) return;

    _isSavingNotifier.value = true;

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    _isSavingNotifier.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Booking rescheduled successfully'),
        backgroundColor: AppColors.successGreen,
      ),
    );

    context.go(AppRoutes.patientBookings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Reschedule Booking'),
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
                    const _HeaderCard(),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _selectedDateNotifier,
                      builder: (context, selectedDate, _) {
                        return _PickerCard(
                          title: 'New Date',
                          value: AppDateFormatters.mediumDate(selectedDate),
                          icon: Icons.calendar_today_rounded,
                          onTap: _pickDate,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ValueListenableBuilder<TimeOfDay>(
                      valueListenable: _selectedTimeNotifier,
                      builder: (context, selectedTime, _) {
                        return _PickerCard(
                          title: 'New Time',
                          value: selectedTime.format(context),
                          icon: Icons.access_time_rounded,
                          onTap: _pickTime,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isSavingNotifier,
                      builder: (context, isSaving, _) {
                        return FilledButton(
                          onPressed: isSaving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2.4,
                                  ),
                                )
                              : const Text('Confirm Reschedule'),
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
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_repeat_rounded,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              'Choose a new suitable date and time for your booking.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
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

class _PickerCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _Decorations.card(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        value,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
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
    );
  }
}