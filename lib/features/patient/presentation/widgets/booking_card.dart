import 'package:flutter/material.dart';

import '../../../../config/theme.dart';
import '../../data/models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.borderGray),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BookingIcon(status: booking.status),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _BookingMainInfo(booking: booking),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    flex: 0,
                    child: _StatusBadge(status: booking.status),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              _IconRow(
                icon: Icons.medical_services_rounded,
                text: booking.serviceType,
              ),
              const SizedBox(height: AppSpacing.md),

              _IconRow(
                icon: Icons.calendar_today_rounded,
                text:
                    '${_formatDate(booking.dateTime)} at ${_formatTime(booking.dateTime)}',
              ),
              const SizedBox(height: AppSpacing.md),

              _IconRow(
                icon: Icons.location_on_rounded,
                text: booking.address,
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.bgGray,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_rounded,
                      color: AppColors.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Total Amount',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Text(
                      _money(booking.amount),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(2)}';
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

  String _formatTime(DateTime date) {
    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour12:$minute $period';
  }
}

// -----------------------------------------------------------------------------
// Private widgets
// -----------------------------------------------------------------------------

class _BookingMainInfo extends StatelessWidget {
  final BookingModel booking;

  const _BookingMainInfo({
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final nurseName = booking.nurseName.trim().isEmpty
        ? 'Healthcare Provider'
        : booking.nurseName;

    final specialty = booking.specialty.trim().isEmpty
        ? booking.serviceType
        : booking.specialty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nurseName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          specialty,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _BookingIcon extends StatelessWidget {
  final String status;

  const _BookingIcon({
    required this.status,
  });

  Color _statusColor() {
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return AppColors.successGreen;
      case 'pending':
      case 'upcoming':
        return AppColors.warningOrange;
      case 'completed':
        return AppColors.primaryBlue;
      case 'cancelled':
      case 'canceled':
        return AppColors.errorRed;
      default:
        return AppColors.primaryBlue;
    }
  }

  IconData _statusIcon() {
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'pending':
      case 'upcoming':
        return Icons.schedule_rounded;
      case 'completed':
        return Icons.verified_rounded;
      case 'cancelled':
      case 'canceled':
        return Icons.cancel_rounded;
      default:
        return Icons.event_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(
        _statusIcon(),
        color: color,
        size: 28,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  Color _color() {
    switch (status.trim().toLowerCase()) {
      case 'confirmed':
        return AppColors.successGreen;
      case 'pending':
      case 'upcoming':
        return AppColors.warningOrange;
      case 'completed':
        return AppColors.primaryBlue;
      case 'cancelled':
      case 'canceled':
        return AppColors.errorRed;
      default:
        return AppColors.textLight;
    }
  }

  String _label() {
    final cleanStatus = status.trim();

    if (cleanStatus.isEmpty) {
      return 'UNKNOWN';
    }

    return cleanStatus.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return Container(
      constraints: const BoxConstraints(maxWidth: 104),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        _label(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final safeText = text.trim().isEmpty ? 'Not specified' : text;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 17,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            safeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}