import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/address_model.dart';
import '../../data/models/nurse_model.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const BookingConfirmationScreen({
    super.key,
    this.bookingData = const {},
  });

  NurseModel? get _nurse {
    final value = bookingData['nurse'];
    return value is NurseModel ? value : null;
  }

  AddressModel? get _address {
    final value = bookingData['selectedAddress'];
    return value is AddressModel ? value : null;
  }

  DateTime? get _selectedDate {
    final value = bookingData['selectedDate'];
    return value is DateTime ? value : null;
  }

  String get _selectedTime {
    final value = bookingData['selectedTimeSlot']?.toString().trim();
    return value == null || value.isEmpty ? 'Not selected' : value;
  }

  double get _total {
    final value = bookingData['total'];

    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;

    return 0.0;
  }

  String get _bookingId {
    final raw = DateTime.now().millisecondsSinceEpoch.toString();
    return 'ML-${raw.substring(raw.length - 7)}';
  }

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not selected';

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

  void _goBookings(BuildContext context) {
    context.go(AppRoutes.bookingHistory);
  }

  void _goHome(BuildContext context) {
    context.go(AppRoutes.patientHome);
  }

  @override
  Widget build(BuildContext context) {
    final nurse = _nurse;
    final address = _address;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Confirmed'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          color: AppColors.successGreen,
                          size: 64,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        'Your booking is confirmed',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        'Booking ID: #$_bookingId',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.bgGray,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: AppColors.borderGray),
                        ),
                        child: Column(
                          children: [
                            _InfoRow(
                              icon: Icons.person_rounded,
                              label: 'Nurse',
                              value: nurse?.name ?? 'Selected Nurse',
                            ),
                            _InfoRow(
                              icon: Icons.medical_services_rounded,
                              label: 'Service',
                              value: nurse?.specialty ?? 'Home Healthcare',
                            ),
                            _InfoRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'Date',
                              value: _formatDate(_selectedDate),
                            ),
                            _InfoRow(
                              icon: Icons.access_time_rounded,
                              label: 'Time',
                              value: _selectedTime,
                            ),
                            _InfoRow(
                              icon: Icons.location_on_rounded,
                              label: 'Address',
                              value: address?.fullAddress ?? 'Selected address',
                            ),
                            _InfoRow(
                              icon: Icons.payments_rounded,
                              label: 'Total',
                              value: _money(_total),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              CustomButton(
                label: 'Go to My Bookings',
                onPressed: () => _goBookings(context),
              ),

              const SizedBox(height: AppSpacing.md),

              CustomButton(
                label: 'Back to Home',
                isOutlined: true,
                onPressed: () => _goHome(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
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