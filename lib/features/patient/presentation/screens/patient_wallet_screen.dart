import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/widgets/custom_button.dart';

class PatientWalletScreen extends StatelessWidget {
  const PatientWalletScreen({super.key});

  String _money(double value) {
    return 'EGP ${value.toStringAsFixed(2)}';
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _mockTransactions;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _WalletBalanceCard(
              balance: _money(450.00),
              cashback: _money(25.00),
              refunds: _money(100.00),
            ),

            const SizedBox(height: AppSpacing.xl),

            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Top Up',
                    onPressed: () => _showComingSoon(context, 'Top Up'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomButton(
                    label: 'Withdraw',
                    isOutlined: true,
                    onPressed: () => _showComingSoon(context, 'Withdraw'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'Wallet Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.replay_rounded,
                    title: 'Refunds',
                    value: _money(100.00),
                    color: AppColors.successGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MiniStatCard(
                    icon: Icons.card_giftcard_rounded,
                    title: 'Cashback',
                    value: _money(25.00),
                    color: AppColors.warningOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                ),
                TextButton(
                  onPressed: () => _showComingSoon(context, 'All transactions'),
                  child: const Text('See all'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            if (transactions.isEmpty)
              const _EmptyWalletState()
            else
              ...transactions.map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _TransactionTile(transaction: transaction),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Mock Data
// -----------------------------------------------------------------------------

final List<_WalletTransaction> _mockTransactions = [
  const _WalletTransaction(
    id: '1',
    title: 'Booking Payment',
    subtitle: 'Post-Surgery Care with Sara Ahmed',
    amount: -285.00,
    date: 'Today, 10:35 AM',
    type: _WalletTransactionType.payment,
  ),
  const _WalletTransaction(
    id: '2',
    title: 'Refund',
    subtitle: 'Cancelled booking refund',
    amount: 100.00,
    date: 'Yesterday, 04:10 PM',
    type: _WalletTransactionType.refund,
  ),
  const _WalletTransaction(
    id: '3',
    title: 'Cashback Reward',
    subtitle: 'MedLink loyalty cashback',
    amount: 25.00,
    date: 'Jun 20, 01:45 PM',
    type: _WalletTransactionType.cashback,
  ),
  const _WalletTransaction(
    id: '4',
    title: 'Wallet Top Up',
    subtitle: 'Added balance using card',
    amount: 250.00,
    date: 'Jun 18, 09:20 AM',
    type: _WalletTransactionType.topUp,
  ),
];

enum _WalletTransactionType {
  payment,
  refund,
  cashback,
  topUp,
}

class _WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final _WalletTransactionType type;

  const _WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });

  bool get isCredit => amount >= 0;
}

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------

class _WalletBalanceCard extends StatelessWidget {
  final String balance;
  final String cashback;
  final String refunds;

  const _WalletBalanceCard({
    required this.balance,
    required this.cashback,
    required this.refunds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.darkBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: AppColors.white,
            size: 42,
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Available Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            balance,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Row(
            children: [
              Expanded(
                child: _WalletInfoPill(
                  label: 'Cashback',
                  value: cashback,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _WalletInfoPill(
                  label: 'Refunds',
                  value: refunds,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletInfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _WalletInfoPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _TransactionTile extends StatelessWidget {
  final _WalletTransaction transaction;

  const _TransactionTile({
    required this.transaction,
  });

  Color get _color {
    switch (transaction.type) {
      case _WalletTransactionType.payment:
        return AppColors.errorRed;
      case _WalletTransactionType.refund:
        return AppColors.successGreen;
      case _WalletTransactionType.cashback:
        return AppColors.warningOrange;
      case _WalletTransactionType.topUp:
        return AppColors.primaryBlue;
    }
  }

  IconData get _icon {
    switch (transaction.type) {
      case _WalletTransactionType.payment:
        return Icons.arrow_upward_rounded;
      case _WalletTransactionType.refund:
        return Icons.replay_rounded;
      case _WalletTransactionType.cashback:
        return Icons.card_giftcard_rounded;
      case _WalletTransactionType.topUp:
        return Icons.add_rounded;
    }
  }

  String _money(double value) {
    final sign = value >= 0 ? '+' : '-';
    return '$sign EGP ${value.abs().toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              _icon,
              color: _color,
              size: 23,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  transaction.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textLight,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  transaction.date,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textLight,
                        fontSize: 10.5,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            _money(transaction.amount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWalletState extends StatelessWidget {
  const _EmptyWalletState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.textLight.withValues(alpha: 0.7),
              size: 70,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your wallet transactions will appear here.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}