import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../patient/data/models/earning_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<EarningModel> _earnings;

  final ValueNotifier<double> _hourlyRateNotifier = ValueNotifier<double>(45.0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _earnings = NurseMockData.earnings;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _hourlyRateNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseHome);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  Color _earningStatusColor(EarningStatus status) {
    return switch (status) {
      EarningStatus.completed => AppColors.successGreen,
      EarningStatus.pending => AppColors.warningOrange,
      EarningStatus.withdrawn => AppColors.primaryBlue,
      EarningStatus.cancelled => AppColors.errorRed,
      EarningStatus.unknown => AppColors.textLight,
    };
  }

  Color _earningAmountColor(EarningStatus status) {
    return switch (status) {
      EarningStatus.completed => AppColors.successGreen,
      EarningStatus.withdrawn => AppColors.successGreen,
      EarningStatus.pending => AppColors.warningOrange,
      EarningStatus.cancelled => AppColors.errorRed,
      EarningStatus.unknown => AppColors.textLight,
    };
  }

  double get _completedEarnings {
    return _earnings
        .where((earning) => earning.status == EarningStatus.completed)
        .fold<double>(0.0, (sum, earning) => sum + earning.netAmount);
  }

  double get _pendingEarnings {
    return _earnings
        .where((earning) => earning.status == EarningStatus.pending)
        .fold<double>(0.0, (sum, earning) => sum + earning.netAmount);
  }

  @override
  Widget build(BuildContext context) {
    final completedEarnings = _completedEarnings;
    final pendingEarnings = _pendingEarnings;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Wallet & Business'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'Earnings analytics',
            onPressed: () => context.push(AppRoutes.nurseEarningsAnalytics),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    _BalanceSection(
                      completedEarnings: completedEarnings == 0
                          ? NurseMockData.availableBalance
                          : completedEarnings,
                      pendingEarnings: pendingEarnings == 0
                          ? NurseMockData.pendingBalance
                          : pendingEarnings,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _HourlyRateSection(rateNotifier: _hourlyRateNotifier),
                    const SizedBox(height: AppSpacing.xl),
                    _TabHeader(tabController: _tabController),
                    const SizedBox(height: AppSpacing.lg),
                    _TabContent(
                      tabController: _tabController,
                      earnings: _earnings,
                      statusColorResolver: _earningStatusColor,
                      amountColorResolver: _earningAmountColor,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton.icon(
                      onPressed: () => _showComingSoon('Bank withdrawal'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      icon: const Icon(Icons.account_balance_rounded),
                      label: const Text('Withdraw to Bank'),
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

class _BalanceSection extends StatelessWidget {
  final double completedEarnings;
  final double pendingEarnings;

  const _BalanceSection({
    required this.completedEarnings,
    required this.pendingEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.darkBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Earnings',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'EGP ${NurseMockData.totalEarnings.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.successGreen,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '+12% vs last month',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _BalanceBox(
                  label: 'Available',
                  amount: completedEarnings,
                  color: AppColors.successGreen,
                  icon: Icons.payments_rounded,
                  tooltip: 'Ready to withdraw to your bank account',
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _BalanceBox(
                  label: 'Pending',
                  amount: pendingEarnings,
                  color: AppColors.warningOrange,
                  icon: Icons.pending_actions_rounded,
                  tooltip: 'Awaiting service completion before payout',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HourlyRateSection extends StatelessWidget {
  final ValueNotifier<double> rateNotifier;

  const _HourlyRateSection({
    required this.rateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: ValueListenableBuilder<double>(
          valueListenable: rateNotifier,
          builder: (context, hourlyRate, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Hourly Rate',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Current Rate',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'EGP',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      hourlyRate.toStringAsFixed(0),
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    Text(
                      '/hr',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                          ),
                    ),
                  ],
                ),
                Slider(
                  value: hourlyRate,
                  min: 20,
                  max: 100,
                  divisions: 80,
                  label: 'EGP ${hourlyRate.toStringAsFixed(0)}',
                  activeColor: AppColors.primaryBlue,
                  inactiveColor: AppColors.borderGray,
                  onChanged: (value) {
                    rateNotifier.value = value;
                  },
                ),
                const _RateRangeLabels(),
                const SizedBox(height: AppSpacing.lg),
                const _InfoNote(
                  text:
                      'Competitive rates increase visibility and booking chances.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RateRangeLabels extends StatelessWidget {
  const _RateRangeLabels();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'EGP 20',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 10,
                ),
          ),
          Text(
            'EGP 100',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _TabHeader extends StatelessWidget {
  final TabController tabController;

  const _TabHeader({
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textLight,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: AppColors.lightBlue,
        ),
        tabs: const [
          Tab(text: 'Earnings'),
          Tab(text: 'Withdrawals'),
        ],
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  final TabController tabController;
  final List<EarningModel> earnings;
  final Color Function(EarningStatus status) statusColorResolver;
  final Color Function(EarningStatus status) amountColorResolver;

  const _TabContent({
    required this.tabController,
    required this.earnings,
    required this.statusColorResolver,
    required this.amountColorResolver,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: TabBarView(
        controller: tabController,
        children: [
          earnings.isEmpty
              ? const _EmptyEarnings()
              : ListView.separated(
                  itemCount: earnings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final earning = earnings[index];

                    return _EarningRow(
                      earning: earning,
                      statusColor: statusColorResolver(earning.status),
                      amountColor: amountColorResolver(earning.status),
                    );
                  },
                ),
          const _EmptyWithdrawals(),
        ],
      ),
    );
  }
}

class _BalanceBox extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final String tooltip;

  const _BalanceBox({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _Decorations.card(withShadow: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
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
              Tooltip(
                message: tooltip,
                child: const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'EGP ${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final EarningModel earning;
  final Color statusColor;
  final Color amountColor;

  const _EarningRow({
    required this.earning,
    required this.statusColor,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(withShadow: false),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                earning.status == EarningStatus.withdrawn
                    ? Icons.account_balance_rounded
                    : Icons.receipt_long_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    earning.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppDateFormatters.mediumDate(earning.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'EGP ${earning.netAmount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: amountColor,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatusPill(
                  label: earning.status.label,
                  color: statusColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyEarnings extends StatelessWidget {
  const _EmptyEarnings();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No earnings yet',
        style: TextStyle(color: AppColors.textLight),
      ),
    );
  }
}

class _EmptyWithdrawals extends StatelessWidget {
  const _EmptyWithdrawals();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppColors.textLight,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No withdrawals yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Your withdrawals will appear here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final String text;

  const _InfoNote({
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
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
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
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
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