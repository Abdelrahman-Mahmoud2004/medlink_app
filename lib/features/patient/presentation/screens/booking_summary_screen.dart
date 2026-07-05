import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../data/models/address_model.dart';
import '../../data/models/nurse_model.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final TextEditingController _promoCodeController = TextEditingController();

  bool _promoApplied = false;

  static const double _subtotal = 250.0;
  static const double _taxRate = 0.14;
  static const String _validPromoCode = 'WELCOME50';
  static const double _promoDiscountRate = 0.20;

  double _discount = 0.0;

  double get _tax => _subtotal * _taxRate;

  double get _total => _subtotal + _tax - _discount;

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  _BookingSummaryData _getBookingSummaryData() {
    final extra = GoRouterState.of(context).extra;

    if (extra is Map<String, dynamic>) {
      return _BookingSummaryData.fromMap(extra);
    }

    if (extra is Map) {
      return _BookingSummaryData.fromMap(
        Map<String, dynamic>.from(extra),
      );
    }

    if (extra is AddressModel) {
      return _BookingSummaryData(
        selectedAddress: extra,
      );
    }

    return const _BookingSummaryData();
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

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(2)}';
  }

  void _handleApplyPromoCode() {
    final code = _promoCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showSnackBar('Please enter a promo code');
      return;
    }

    if (_promoApplied) {
      _showSnackBar(
        'Promo code already applied',
        isSuccess: true,
      );
      return;
    }

    if (code == _validPromoCode) {
      setState(() {
        _discount = _subtotal * _promoDiscountRate;
        _promoApplied = true;
      });

      _showSnackBar(
        'Promo code applied! 20% discount added.',
        isSuccess: true,
      );

      return;
    }

    _showSnackBar(
      'Invalid promo code',
      isError: true,
    );
  }

  void _showSnackBar(
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? AppColors.successGreen
            : isError
                ? AppColors.errorRed
                : null,
      ),
    );
  }

  void _handleConfirmBooking(_BookingSummaryData data) {
    context.push(
      AppRoutes.paymentMethod,
      extra: {
        'nurse': data.nurse,
        'selectedDate': data.selectedDate,
        'selectedTimeSlot': data.selectedTimeSlot,
        'selectedAddress': data.selectedAddress,
        'subtotal': _subtotal,
        'tax': _tax,
        'discount': _discount,
        'total': _total,
      },
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.selectAddress);
  }

  @override
  Widget build(BuildContext context) {
    final data = _getBookingSummaryData();

    final nurseName = data.nurse?.name ?? 'Selected Nurse';
    final nurseSpecialty = data.nurse?.specialty ?? 'Healthcare Provider';
    final selectedDate = _formatDate(data.selectedDate);
    final selectedTime = data.selectedTimeSlot ?? 'Not selected';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Booking Summary'),
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
              const _SectionLabel(title: 'Service Details'),

              const SizedBox(height: AppSpacing.lg),

              _DetailCard(
                icon: Icons.health_and_safety_rounded,
                name: nurseName,
                subtitle: '$nurseSpecialty • Home Healthcare',
              ),

              const SizedBox(height: AppSpacing.xl),

              const _SectionLabel(title: 'Date & Time'),

              const SizedBox(height: AppSpacing.lg),

              Row(
                children: [
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: selectedDate,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _InfoBox(
                      icon: Icons.access_time_rounded,
                      label: 'Time',
                      value: selectedTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              const _SectionLabel(title: 'Address'),

              const SizedBox(height: AppSpacing.lg),

              _AddressBox(address: data.selectedAddress),

              const SizedBox(height: AppSpacing.xl),

              const _SectionLabel(title: 'Promo Code'),

              const SizedBox(height: AppSpacing.lg),

              _PromoCodeField(
                controller: _promoCodeController,
                isApplied: _promoApplied,
                onApply: _handleApplyPromoCode,
              ),

              const SizedBox(height: AppSpacing.xl),

              const _SectionLabel(title: 'Price Breakdown'),

              const SizedBox(height: AppSpacing.lg),

              _PriceLine(
                label: 'Service Charge',
                value: _money(_subtotal),
              ),

              if (_discount > 0) ...[
                const SizedBox(height: AppSpacing.md),
                _PriceLine(
                  label: 'Discount',
                  value: '-${_money(_discount)}',
                  isDiscount: true,
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              _PriceLine(
                label: 'Tax (14%)',
                value: _money(_tax),
              ),

              const SizedBox(height: AppSpacing.lg),

              const Divider(color: AppColors.borderGray),

              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                  ),
                  Text(
                    _money(_total),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
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
          child: CustomButton(
            label: 'Confirm Booking',
            onPressed: () => _handleConfirmBooking(data),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data helper
// ---------------------------------------------------------------------------

class _BookingSummaryData {
  final NurseModel? nurse;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final AddressModel? selectedAddress;

  const _BookingSummaryData({
    this.nurse,
    this.selectedDate,
    this.selectedTimeSlot,
    this.selectedAddress,
  });

  factory _BookingSummaryData.fromMap(Map<String, dynamic> map) {
    return _BookingSummaryData(
      nurse: map['nurse'] is NurseModel ? map['nurse'] as NurseModel : null,
      selectedDate: map['selectedDate'] is DateTime
          ? map['selectedDate'] as DateTime
          : null,
      selectedTimeSlot: map['selectedTimeSlot'] is String
          ? map['selectedTimeSlot'] as String
          : null,
      selectedAddress: map['selectedAddress'] is AddressModel
          ? map['selectedAddress'] as AddressModel
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Private widgets
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final String subtitle;

  const _DetailCard({
    required this.icon,
    required this.name,
    required this.subtitle,
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
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.35,
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

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
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
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
          ),
        ],
      ),
    );
  }
}

class _AddressBox extends StatelessWidget {
  final AddressModel? address;

  const _AddressBox({
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final title = address?.title ?? 'No address selected';
    final fullAddress =
        address?.fullAddress ?? 'Please select an address again';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgGray,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.primaryBlue,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  fullAddress,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.35,
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

class _PromoCodeField extends StatelessWidget {
  final TextEditingController controller;
  final bool isApplied;
  final VoidCallback onApply;

  const _PromoCodeField({
    required this.controller,
    required this.isApplied,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !isApplied,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Enter promo code',
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
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        if (isApplied)
          const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.successGreen,
                size: 28,
              ),
            ),
          )
        else
          SizedBox(
            width: 96,
            height: 48,
            child: FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: Size.zero,
                fixedSize: const Size(96, 48),
                maximumSize: const Size(96, 48),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Apply'),
            ),
          ),
      ],
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _PriceLine({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textDark,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDiscount ? AppColors.successGreen : AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}