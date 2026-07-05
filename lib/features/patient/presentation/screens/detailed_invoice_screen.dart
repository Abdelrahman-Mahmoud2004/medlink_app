import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../data/models/booking_model.dart';

class DetailedInvoiceScreen extends StatelessWidget {
  final BookingModel? booking;
  final Map<String, dynamic> invoiceData;

  const DetailedInvoiceScreen({
    super.key,
    this.booking,
    this.invoiceData = const {},
  });

  double get _serviceCharge {
    if (booking != null) return booking!.amount;

    final value = invoiceData['serviceCharge'] ?? invoiceData['subtotal'];
    return _toDouble(value, fallback: 250.0);
  }

  double get _transportationFee {
    final value = invoiceData['transportationFee'];
    return _toDouble(value, fallback: 35.0);
  }

  double get _discount {
    final value = invoiceData['discount'];
    return _toDouble(value);
  }

  double get _tax {
    final value = invoiceData['tax'];

    if (value != null) {
      return _toDouble(value);
    }

    return (_serviceCharge + _transportationFee - _discount) * 0.14;
  }

  double get _total {
    final value = invoiceData['total'];

    if (value != null) {
      return _toDouble(value);
    }

    return _serviceCharge + _transportationFee + _tax - _discount;
  }

  String get _invoiceNumber {
    final raw = booking?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    return 'INV-${raw.padLeft(6, '0')}';
  }

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(2)}';
  }

  static double _toDouble(Object? value, {double fallback = 0.0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.bookingHistory);
  }

  @override
  Widget build(BuildContext context) {
    final nurseName = booking?.nurseName ?? 'Selected Nurse';
    final serviceType = booking?.serviceType ?? 'Home Healthcare';

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Detailed Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.white,
                      size: 42,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      _invoiceNumber,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Invoice for your home healthcare booking',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.82),
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _SectionCard(
                title: 'Booking Info',
                children: [
                  _InvoiceRow(
                    label: 'Nurse',
                    value: nurseName,
                  ),
                  _InvoiceRow(
                    label: 'Service',
                    value: serviceType,
                  ),
                  if (booking != null)
                    _InvoiceRow(
                      label: 'Status',
                      value: booking!.statusLabel,
                    ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              _SectionCard(
                title: 'Price Breakdown',
                children: [
                  _InvoiceRow(
                    label: 'Service Charge',
                    value: _money(_serviceCharge),
                  ),
                  _InvoiceRow(
                    label: 'Transportation Fee',
                    value: _money(_transportationFee),
                  ),
                  if (_discount > 0)
                    _InvoiceRow(
                      label: 'Discount',
                      value: '-${_money(_discount)}',
                      valueColor: AppColors.successGreen,
                    ),
                  _InvoiceRow(
                    label: 'Tax (14%)',
                    value: _money(_tax),
                  ),
                  const Divider(color: AppColors.borderGray),
                  _InvoiceRow(
                    label: 'Total',
                    value: _money(_total),
                    isTotal: true,
                    valueColor: AppColors.primaryBlue,
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primaryBlue,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'This invoice is generated for your records. A downloadable PDF version will be available later.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryBlue,
                              height: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _InvoiceRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textDark,
            )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textDark,
            );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            value,
            style: style,
          ),
        ],
      ),
    );
  }
}