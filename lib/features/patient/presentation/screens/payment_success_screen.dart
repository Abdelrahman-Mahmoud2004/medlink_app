import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final Map<String, dynamic> bookingData;

  const PaymentSuccessScreen({
    super.key,
    this.bookingData = const {},
  });

  double get _total {
    final value = bookingData['total'];

    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;

    return 0.0;
  }

  String get _paymentMethod {
    final value = bookingData['paymentMethod']?.toString().trim();

    if (value == null || value.isEmpty) {
      return 'Payment';
    }

    switch (value.toLowerCase()) {
      case 'card':
        return 'Credit / Debit Card';
      case 'wallet':
        return 'MedLink Wallet';
      case 'mobilewallet':
      case 'mobile_wallet':
      case 'mobile-wallet':
        return 'Mobile Wallet';
      case 'cash':
        return 'Cash on Visit';
      default:
        return value;
    }
  }

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(2)}';
  }

  void _continue(BuildContext context) {
    context.go(
      AppRoutes.bookingConfirmation,
      extra: bookingData,
    );
  }

  void _goHome(BuildContext context) {
    context.go(AppRoutes.patientHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.successGreen.withValues(alpha: 0.16),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successGreen,
                  size: 86,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                'Payment Successful',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                'Your payment has been processed successfully. Your booking is almost confirmed.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxl),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.bgGray,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Amount Paid',
                      value: _money(_total),
                      valueColor: AppColors.primaryBlue,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SummaryRow(
                      label: 'Payment Method',
                      value: _paymentMethod,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              CustomButton(
                label: 'View Booking Confirmation',
                onPressed: () => _continue(context),
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                color: valueColor ?? AppColors.textDark,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}