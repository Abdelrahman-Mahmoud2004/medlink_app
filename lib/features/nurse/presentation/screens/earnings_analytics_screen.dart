import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';

enum _Period {
  week,
  month,
  year,
}

extension _PeriodX on _Period {
  String get label {
    return switch (this) {
      _Period.week => 'WEEK',
      _Period.month => 'MONTH',
      _Period.year => 'YEAR',
    };
  }

  String get title {
    return switch (this) {
      _Period.week => 'This Week',
      _Period.month => 'This Month',
      _Period.year => 'This Year',
    };
  }
}

class EarningsAnalyticsScreen extends StatefulWidget {
  const EarningsAnalyticsScreen({super.key});

  @override
  State<EarningsAnalyticsScreen> createState() =>
      _EarningsAnalyticsScreenState();
}

class _EarningsAnalyticsScreenState extends State<EarningsAnalyticsScreen> {
  final ValueNotifier<_Period> _periodNotifier =
      ValueNotifier<_Period>(_Period.week);

  static const Map<_Period, List<double>> _chartData = {
    _Period.week: [450, 520, 680, 750, 620, 580, 890],
    _Period.month: [
      2200,
      2400,
      2100,
      2800,
      2600,
      2900,
      3100,
      2700,
      2500,
      3200,
      2950,
      3300,
      2850,
      3100,
      3450,
      3200,
      3100,
      3300,
      3600,
      3400,
      3200,
      3500,
      3700,
      3300,
      3200,
      3400,
      3600,
      3800,
      3500,
      3300,
      3700,
    ],
    _Period.year: [
      8500,
      9200,
      10100,
      10900,
      11300,
      12100,
      12800,
      13200,
      12500,
      13800,
      14200,
      15100,
    ],
  };

  static const double _serviceCharges = 38500;
  static const double _platformFees = 6730;

  @override
  void dispose() {
    _periodNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Earnings Analytics'),
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
                    _PeriodSelector(periodNotifier: _periodNotifier),
                    const SizedBox(height: AppSpacing.xl),
                    ValueListenableBuilder<_Period>(
                      valueListenable: _periodNotifier,
                      builder: (context, period, _) {
                        final data = _chartData[period] ?? const <double>[];

                        return Column(
                          children: [
                            _SummaryCards(
                              period: period,
                              data: data,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _ChartCard(
                              period: period,
                              data: data,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            const _BreakdownCard(
                              serviceCharges: _serviceCharges,
                              platformFees: _platformFees,
                            ),
                          ],
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

class _PeriodSelector extends StatelessWidget {
  final ValueNotifier<_Period> periodNotifier;

  const _PeriodSelector({
    required this.periodNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_Period>(
      valueListenable: periodNotifier,
      builder: (context, selectedPeriod, _) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: _Decorations.card(withShadow: false),
          child: Row(
            children: _Period.values.map((period) {
              final isSelected = selectedPeriod == period;

              return Expanded(
                child: GestureDetector(
                  onTap: () => periodNotifier.value = period,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      period.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textLight,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final _Period period;
  final List<double> data;

  const _SummaryCards({
    required this.period,
    required this.data,
  });

  double get _periodTotal {
    return data.fold<double>(0.0, (sum, value) => sum + value);
  }

  double get _average {
    if (data.isEmpty) return 0.0;
    return _periodTotal / data.length;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Earned',
            value: 'EGP ${_periodTotal.toStringAsFixed(0)}',
            subtitle: period.title,
            color: AppColors.successGreen,
            icon: Icons.payments_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: _SummaryCard(
            label: 'Average',
            value: 'EGP ${_average.toStringAsFixed(0)}',
            subtitle: 'Per point',
            color: AppColors.primaryBlue,
            icon: Icons.analytics_outlined,
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final _Period period;
  final List<double> data;

  const _ChartCard({
    required this.period,
    required this.data,
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
            Text(
              'Earnings Trend',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              period.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              height: 220,
              child: _TrendChart(data: data),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final double serviceCharges;
  final double platformFees;

  const _BreakdownCard({
    required this.serviceCharges,
    required this.platformFees,
  });

  double get _total => serviceCharges + platformFees;

  @override
  Widget build(BuildContext context) {
    final chargesPct = _total == 0 ? 0.0 : serviceCharges / _total;
    final feesPct = _total == 0 ? 0.0 : platformFees / _total;

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Breakdown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _BreakdownRow(
              label: 'Service Charges',
              amount: 'EGP ${serviceCharges.toStringAsFixed(0)}',
              percentage: chargesPct,
              color: AppColors.successGreen,
            ),
            const SizedBox(height: AppSpacing.lg),
            _BreakdownRow(
              label: 'Platform Fees',
              amount: 'EGP ${platformFees.toStringAsFixed(0)}',
              percentage: feesPct,
              color: AppColors.warningOrange,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(withShadow: false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textLight,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<double> data;

  const _TrendChart({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No chart data',
          style: TextStyle(color: AppColors.textLight),
        ),
      );
    }

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue <= 0 ? 1.0 : maxValue;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          final barHeight = ((value / safeMax) * 150).clamp(8.0, 150.0);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              width: 38,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(value / 1000).toStringAsFixed(1)}k',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 9,
                          color: AppColors.textLight,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontSize: 9,
                          color: AppColors.textLight,
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
  final Color color;

  const _BreakdownRow({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safePercentage = percentage.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
              ),
            ),
            Text(
              amount,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: safePercentage,
            minHeight: 8,
            backgroundColor: AppColors.borderGray,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card({bool withShadow = true}) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.borderGray),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );
  }
}