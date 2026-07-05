import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';

enum _Period { week, month, year }

extension on _Period {
  String get label => switch (this) {
        _Period.week => 'WEEK',
        _Period.month => 'MONTH',
        _Period.year => 'YEAR',
      };
}

class EarningsAnalyticsScreen extends StatefulWidget {
  const EarningsAnalyticsScreen({super.key});

  @override
  State<EarningsAnalyticsScreen> createState() =>
      _EarningsAnalyticsScreenState();
}

class _EarningsAnalyticsScreenState extends State<EarningsAnalyticsScreen> {
  _Period _selectedPeriod = _Period.week;

  // Placeholder trend data. In production this should come from a backend
  // aggregation endpoint rather than being hand-maintained here.
  static const Map<_Period, List<double>> _chartData = {
    _Period.week: [450, 520, 680, 750, 620, 580, 890],
    _Period.month: [
      2200, 2400, 2100, 2800, 2600, 2900, 3100, 2700, 2500, 3200, 2950, 3300,
      2850, 3100, 3450, 3200, 3100, 3300, 3600, 3400, 3200, 3500, 3700, 3300,
      3200, 3400, 3600, 3800, 3500, 3300, 3700,
    ],
    _Period.year: [
      8500, 9200, 10100, 10900, 11300, 12100, 12800, 13200, 12500, 13800,
      14200, 15100,
    ],
  };

  static const double _serviceCharges = 38500;
  static const double _platformFees = 6730;

  @override
  Widget build(BuildContext context) {
    final data = _chartData[_selectedPeriod] ?? const [];

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Earnings Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(context),
              const SizedBox(height: AppSpacing.xl),
              _buildSummaryCards(context),
              const SizedBox(height: AppSpacing.xl),
              _buildChartCard(context, data),
              const SizedBox(height: AppSpacing.xl),
              _buildBreakdown(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _Period.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return GestureDetector(
            onTap: () => setState(() => _selectedPeriod = period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Text(
                period.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color:
                          isSelected ? AppColors.white : AppColors.textLight,
                    ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    const total = _serviceCharges + _platformFees;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Earned',
            value: 'EGP ${total.toStringAsFixed(0)}',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        const Expanded(
          child: _SummaryCard(
            label: 'Avg/Day',
            value: 'EGP 1,450',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context, List<double> data) {
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
            'Earnings Trend',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(height: 200, child: _TrendChart(data: data)),
        ],
      ),
    );
  }

  Widget _buildBreakdown(BuildContext context) {
    const total = _serviceCharges + _platformFees;
    const chargesPct = total == 0 ? 0.0 : _serviceCharges / total;
    const feesPct = total == 0 ? 0.0 : _platformFees / total;

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
            'Breakdown',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.lg),
          _BreakdownRow(
            label: 'Service Charges',
            amount: 'EGP ${_serviceCharges.toStringAsFixed(0)}',
            percentage: chargesPct,
          ),
          const SizedBox(height: AppSpacing.lg),
          _BreakdownRow(
            label: 'Platform Fees',
            amount: 'EGP ${_platformFees.toStringAsFixed(0)}',
            percentage: feesPct,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textLight),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

/// Horizontally scrollable bar chart.
///
/// The original hard-sliced to `data.length > 7 ? 7 : data.length`, so
/// picking "Month" (31 points) or "Year" (12 points) only ever rendered the
/// first week — the rest of the data was silently dropped. This renders
/// every point at a fixed bar width and scrolls, so nothing is ever hidden.
class _TrendChart extends StatelessWidget {
  final List<double> data;

  const _TrendChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue; // guard against /0

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((value) {
          final barHeight = (value / safeMax) * 150;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 34,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(value / 1000).toStringAsFixed(1)}k',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String amount;
  final double percentage;

  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(
              amount,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.borderGray,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }
}