import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

enum PaymentResultType {
  success,
  failed,
  cancelled,
  refunded,
}

extension PaymentResultTypeX on PaymentResultType {
  String get title {
    return switch (this) {
      PaymentResultType.success => 'Payment Successful',
      PaymentResultType.failed => 'Payment Failed',
      PaymentResultType.cancelled => 'Payment Cancelled',
      PaymentResultType.refunded => 'Payment Refunded',
    };
  }

  String get message {
    return switch (this) {
      PaymentResultType.success =>
        'Your booking payment has been completed successfully.',
      PaymentResultType.failed =>
        'We could not process your payment. Please try another method.',
      PaymentResultType.cancelled =>
        'Your payment was cancelled before completion.',
      PaymentResultType.refunded =>
        'Your payment refund request has been processed.',
    };
  }

  IconData get icon {
    return switch (this) {
      PaymentResultType.success => Icons.check_circle_outline_rounded,
      PaymentResultType.failed => Icons.error_outline_rounded,
      PaymentResultType.cancelled => Icons.cancel_outlined,
      PaymentResultType.refunded => Icons.assignment_return_outlined,
    };
  }

  Color get color {
    return switch (this) {
      PaymentResultType.success => AppColors.successGreen,
      PaymentResultType.failed => AppColors.errorRed,
      PaymentResultType.cancelled => AppColors.warningOrange,
      PaymentResultType.refunded => AppColors.primaryBlue,
    };
  }
}

class PaymentResultScreen extends StatelessWidget {
  final PaymentResultType type;

  const PaymentResultScreen({
    super.key,
    required this.type,
  });

  void _goHome(BuildContext context) {
    context.go(AppRoutes.patientHome);
  }

  void _retryPayment(BuildContext context) {
    context.go(AppRoutes.paymentMethod);
  }

  @override
  Widget build(BuildContext context) {
    final canRetry = type == PaymentResultType.failed;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    type.icon,
                    color: type.color,
                    size: 60,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  type.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  type.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (canRetry)
                  FilledButton.icon(
                    onPressed: () => _retryPayment(context),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                  )
                else
                  FilledButton(
                    onPressed: () => _goHome(context),
                    child: const Text('Back to Home'),
                  ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => _goHome(context),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}