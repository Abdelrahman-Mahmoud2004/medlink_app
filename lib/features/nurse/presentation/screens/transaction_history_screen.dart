import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../patient/data/models/earning_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late final List<EarningModel> _transactions;

  final ValueNotifier<String> _filterNotifier = ValueNotifier<String>('All');

  @override
  void initState() {
    super.initState();
    _transactions = NurseMockData.earnings;
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.nurseWallet);
  }

  List<EarningModel> _filtered(String filter) {
    if (filter == 'All') return _transactions;

    if (filter == 'Completed') {
      return _transactions
          .where((item) => item.status == EarningStatus.completed)
          .toList(growable: false);
    }

    if (filter == 'Pending') {
      return _transactions
          .where((item) => item.status == EarningStatus.pending)
          .toList(growable: false);
    }

    if (filter == 'Withdrawn') {
      return _transactions
          .where((item) => item.status == EarningStatus.withdrawn)
          .toList(growable: false);
    }

    return _transactions;
  }

  Color _statusColor(EarningStatus status) {
    return switch (status) {
      EarningStatus.completed => AppColors.successGreen,
      EarningStatus.pending => AppColors.warningOrange,
      EarningStatus.withdrawn => AppColors.primaryBlue,
      EarningStatus.cancelled => AppColors.errorRed,
      EarningStatus.unknown => AppColors.textLight,
    };
  }

  Color _amountColor(EarningStatus status) {
    return switch (status) {
      EarningStatus.completed => AppColors.successGreen,
      EarningStatus.withdrawn => AppColors.primaryBlue,
      EarningStatus.pending => AppColors.warningOrange,
      EarningStatus.cancelled => AppColors.errorRed,
      EarningStatus.unknown => AppColors.textLight,
    };
  }

  double get _totalCompleted {
    return _transactions
        .where((item) => item.status == EarningStatus.completed)
        .fold<double>(0.0, (sum, item) => sum + item.netAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Transaction History'),
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
                    _SummaryCard(
                      totalCompleted: _totalCompleted,
                      transactionCount: _transactions.length,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _FilterChips(filterNotifier: _filterNotifier),
                    const SizedBox(height: AppSpacing.lg),
                    ValueListenableBuilder<String>(
                      valueListenable: _filterNotifier,
                      builder: (context, filter, _) {
                        final items = _filtered(filter);

                        if (items.isEmpty) {
                          return const _EmptyTransactions();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.lg),
                          itemBuilder: (context, index) {
                            final transaction = items[index];

                            return _TransactionTile(
                              transaction: transaction,
                              statusColor: _statusColor(transaction.status),
                              amountColor: _amountColor(transaction.status),
                            );
                          },
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

class _SummaryCard extends StatelessWidget {
  final double totalCompleted;
  final int transactionCount;

  const _SummaryCard({
    required this.totalCompleted,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.white,
                size: 34,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EGP ${totalCompleted.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$transactionCount transactions recorded',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ValueNotifier<String> filterNotifier;

  const _FilterChips({
    required this.filterNotifier,
  });

  static const filters = ['All', 'Completed', 'Pending', 'Withdrawn'];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: filterNotifier,
      builder: (context, selected, _) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final filter = filters[index];
              final selectedFilter = selected == filter;

              return GestureDetector(
                onTap: () => filterNotifier.value = filter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedFilter
                        ? AppColors.primaryBlue
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: selectedFilter
                          ? AppColors.primaryBlue
                          : AppColors.borderGray,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selectedFilter
                              ? AppColors.white
                              : AppColors.textDark,
                          fontWeight: selectedFilter
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final EarningModel transaction;
  final Color statusColor;
  final Color amountColor;

  const _TransactionTile({
    required this.transaction,
    required this.statusColor,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                transaction.status == EarningStatus.withdrawn
                    ? Icons.account_balance_rounded
                    : Icons.payments_outlined,
                color: statusColor,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppDateFormatters.mediumDate(transaction.date),
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
                  'EGP ${transaction.netAmount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _StatusPill(
                  label: transaction.status.label,
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

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _Decorations.card(),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textLight.withValues(alpha: 0.75),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w700,
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
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.borderGray),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}