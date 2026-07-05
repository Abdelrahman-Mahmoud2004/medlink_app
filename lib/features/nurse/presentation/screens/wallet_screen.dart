import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
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
  double _hourlyRate = 45.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _earnings = NurseMockData.earnings;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Wallet & Business'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: 'Earnings analytics',
            onPressed: () => context.push(AppRoutes.nurseEarningsAnalytics),
          ),
        ],
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
              _buildBalanceCards(context),
              const SizedBox(height: AppSpacing.xl),
              _buildHourlyRateSection(context),
              const SizedBox(height: AppSpacing.xl),
              _buildTabBar(context),
              const SizedBox(height: AppSpacing.lg),
              _buildTabContent(context),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => _showComingSoon('Bank withdrawal'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Was Icons.arrow_backward (a "go back" icon) — wrong
                    // direction entirely for money leaving the wallet.
                    Icon(Icons.account_balance),
                    SizedBox(width: AppSpacing.md),
                    Text('Withdraw to Bank'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCards(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.darkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Earnings',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'EGP ${NurseMockData.totalEarnings.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.trending_up,
                      color: AppColors.successGreen, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '+12% vs last month',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.successGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Row(
          children: [
            Expanded(
              child: _BalanceBox(
                label: 'Available',
                amount: NurseMockData.availableBalance,
                color: AppColors.successGreen,
                tooltip: 'Ready to withdraw to your bank account',
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _BalanceBox(
                label: 'Pending',
                amount: NurseMockData.pendingBalance,
                color: AppColors.warningOrange,
                tooltip: 'Awaiting service completion before payout',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHourlyRateSection(BuildContext context) {
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
            'Set Hourly Rate',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Current Rate',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textLight),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'EGP',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                _hourlyRate.toStringAsFixed(0),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '/hr',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Slider(
            value: _hourlyRate,
            min: 20,
            max: 100,
            divisions: 80,
            label: _hourlyRate.toStringAsFixed(0),
            activeColor: AppColors.primaryBlue,
            inactiveColor: AppColors.borderGray,
            onChanged: (value) => setState(() => _hourlyRate = value),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('EGP 20',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 10)),
                Text('EGP 100',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              'Setting your rate competitively increases your chances of '
              'getting hired. Most nurses in your area charge 40-55 EGP/hr.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryBlue,
        unselectedLabelColor: AppColors.textLight,
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

  Widget _buildTabContent(BuildContext context) {
    return SizedBox(
      // TabBarView needs a bounded height since it sits inside an outer
      // SingleChildScrollView — the inner list scrolls on its own.
      height: 400,
      child: TabBarView(
        controller: _tabController,
        children: [
          ListView.separated(
            itemCount: _earnings.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) =>
                _EarningRow(earning: _earnings[index]),
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
  final String tooltip;

  const _BalanceBox({
    required this.label,
    required this.amount,
    required this.color,
    required this.tooltip,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textLight),
              ),
              Tooltip(
                message: tooltip,
                child: const Icon(Icons.info_outline,
                    size: 16, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'EGP ${amount.toStringAsFixed(0)}',
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

class _EarningRow extends StatelessWidget {
  final EarningModel earning;

  const _EarningRow({required this.earning});

  Color get _statusColor => switch (earning.status) {
        EarningStatus.completed => AppColors.successGreen,
        EarningStatus.pending => AppColors.warningOrange,
        EarningStatus.withdrawn => AppColors.primaryBlue,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earning.description,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppDateFormatters.mediumDate(earning.date),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'EGP ${earning.netAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.successGreen,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  earning.status.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 10,
                        color: _statusColor,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyWithdrawals extends StatelessWidget {
  const _EmptyWithdrawals();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 48, color: AppColors.textLight),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No withdrawals yet',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textLight),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your withdrawals will appear here',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}