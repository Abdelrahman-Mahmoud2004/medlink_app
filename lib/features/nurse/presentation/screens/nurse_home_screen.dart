import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../patient/data/models/earning_model.dart';
import '../../../patient/data/models/request_model.dart';
import '../../data/mock/nurse_mock_data.dart';

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  late List<RequestModel> _activeRequests;
  late final List<EarningModel> _recentEarnings;

  final ValueNotifier<bool> _isOnlineNotifier = ValueNotifier<bool>(true);

  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();

    _activeRequests = List<RequestModel>.of(NurseMockData.activeRequests);
    _recentEarnings = NurseMockData.earnings
        .where((earning) => earning.status == EarningStatus.completed)
        .take(3)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _isOnlineNotifier.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  void _handleAccept(RequestModel request) {
    setState(() {
      _activeRequests.removeWhere((item) => item.id == request.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Accepted ${request.patientName}'s request"),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _handleDecline(RequestModel request) {
    setState(() {
      _activeRequests.removeWhere((item) => item.id == request.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Declined ${request.patientName}'s request"),
      ),
    );
  }

  void _handleNavTap(int index) {
    switch (index) {
      case 0:
        setState(() => _selectedNavIndex = 0);
        break;
      case 1:
        _pushTab(1, AppRoutes.nurseSchedule);
        break;
      case 2:
        _pushTab(2, AppRoutes.nurseWallet);
        break;
      case 3:
        _showComingSoon('Messages');
        break;
      case 4:
        _pushTab(4, AppRoutes.nurseSettings);
        break;
    }
  }

  Future<void> _pushTab(int index, String route) async {
    setState(() => _selectedNavIndex = index);

    await context.push(route);

    if (!mounted) return;

    setState(() => _selectedNavIndex = 0);
  }

  Color _requestStatusColor(RequestStatus status) {
    return switch (status) {
      RequestStatus.active => AppColors.successGreen,
      RequestStatus.scheduled => AppColors.warningOrange,
      RequestStatus.completed => AppColors.primaryBlue,
      RequestStatus.cancelled => AppColors.errorRed,
      RequestStatus.unknown => AppColors.textLight,
    };
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed(
                  [
                    _OnlineStatusCard(
                      isOnlineNotifier: _isOnlineNotifier,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _QuickStats(),
                    const SizedBox(height: AppSpacing.xl),
                    _ActiveRequestsSection(
                      requests: _activeRequests,
                      statusColorResolver: _requestStatusColor,
                      onSeeAll: () => context.push(AppRoutes.nurseSchedule),
                      onAccept: _handleAccept,
                      onDecline: _handleDecline,
                      onStartTravel: () => _showComingSoon('Navigation'),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _RecentEarningsSection(
                      earnings: _recentEarnings,
                      statusColorResolver: _earningStatusColor,
                      amountColorResolver: _earningAmountColor,
                      onViewAll: () => context.push(AppRoutes.nurseWallet),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _NurseBottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _handleNavTap,
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.bgGray,
      elevation: 0,
      pinned: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, Fatima',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                ),
          ),
          Text(
            'MedLink Provider',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: GestureDetector(
              onTap: () => _showComingSoon('Notifications'),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        border: Border.all(
                          color: AppColors.white,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnlineStatusCard extends StatelessWidget {
  final ValueNotifier<bool> isOnlineNotifier;

  const _OnlineStatusCard({
    required this.isOnlineNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isOnlineNotifier,
      builder: (context, isOnline, _) {
        final statusColor =
            isOnline ? AppColors.successGreen : AppColors.textLight;

        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: _Decorations.card(),
            child: Row(
              children: [
                _IconBox(
                  icon: isOnline
                      ? Icons.wifi_tethering_rounded
                      : Icons.wifi_tethering_off_rounded,
                  color: statusColor,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOnline ? 'You are online' : 'You are offline',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isOnline
                            ? 'Available to receive new patient requests.'
                            : 'You will not receive new patient requests.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isOnline,
                  activeThumbColor: AppColors.primaryBlue,
                  onChanged: (value) {
                    isOnlineNotifier.value = value;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _DailyEarningsCard(amount: NurseMockData.dailyEarnings),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                value: '${NurseMockData.completedVisits}',
                label: 'Completed Visits',
                icon: Icons.check_circle_outline,
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _StatBox(
                value: '${NurseMockData.rating}',
                label: 'Rating',
                icon: Icons.star_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActiveRequestsSection extends StatelessWidget {
  final List<RequestModel> requests;
  final Color Function(RequestStatus status) statusColorResolver;
  final VoidCallback onSeeAll;
  final ValueChanged<RequestModel> onAccept;
  final ValueChanged<RequestModel> onDecline;
  final VoidCallback onStartTravel;

  const _ActiveRequestsSection({
    required this.requests,
    required this.statusColorResolver,
    required this.onSeeAll,
    required this.onAccept,
    required this.onDecline,
    required this.onStartTravel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Active Requests',
          actionLabel: 'See all',
          onAction: onSeeAll,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (requests.isEmpty)
          const _EmptyNotice(text: 'No active requests right now')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              final request = requests[index];

              return _RequestCard(
                request: request,
                statusColor: statusColorResolver(request.status),
                onAccept: () => onAccept(request),
                onDecline: () => onDecline(request),
                onStartTravel: onStartTravel,
              );
            },
          ),
      ],
    );
  }
}

class _RecentEarningsSection extends StatelessWidget {
  final List<EarningModel> earnings;
  final Color Function(EarningStatus status) statusColorResolver;
  final Color Function(EarningStatus status) amountColorResolver;
  final VoidCallback onViewAll;

  const _RecentEarningsSection({
    required this.earnings,
    required this.statusColorResolver,
    required this.amountColorResolver,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Recent Visits',
          actionLabel: 'View all',
          onAction: onViewAll,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (earnings.isEmpty)
          const _EmptyNotice(text: 'No recent visits yet')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: earnings.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) {
              final earning = earnings[index];

              return _EarningItem(
                earning: earning,
                statusColor: statusColorResolver(earning.status),
                amountColor: amountColorResolver(earning.status),
              );
            },
          ),
      ],
    );
  }
}

class _DailyEarningsCard extends StatelessWidget {
  final double amount;

  const _DailyEarningsCard({
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
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
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Earnings',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'EGP ${amount.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
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
            Icon(icon, color: AppColors.primaryBlue, size: 24),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  final String text;

  const _EmptyNotice({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      decoration: _Decorations.card(),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  final Color statusColor;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onStartTravel;

  const _RequestCard({
    required this.request,
    required this.statusColor,
    required this.onAccept,
    required this.onDecline,
    required this.onStartTravel,
  });

  Widget _buildActions() {
    return switch (request.status) {
      RequestStatus.active => Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDecline,
                child: const Text('Decline'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: onAccept,
                child: const Text('Accept'),
              ),
            ),
          ],
        ),
      RequestStatus.scheduled => FilledButton(
          onPressed: onStartTravel,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigation_rounded),
              SizedBox(width: AppSpacing.md),
              Text('Start Travel'),
            ],
          ),
        ),
      RequestStatus.completed ||
      RequestStatus.cancelled ||
      RequestStatus.unknown =>
        const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: _Decorations.card(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.lightBlue,
                  child: ClipOval(
                    child: Image.network(
                      request.patientImage,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.patientName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        request.specialty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                            ),
                      ),
                    ],
                  ),
                ),
                _StatusPill(
                  label: request.status.label,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _RequestDetailChip(
                    icon: Icons.location_on_outlined,
                    text: '${request.distance} km away',
                  ),
                ),
                Expanded(
                  child: _RequestDetailChip(
                    icon: Icons.access_time_outlined,
                    text: '${request.duration} hrs',
                  ),
                ),
                Expanded(
                  child: _RequestDetailChip(
                    icon: Icons.attach_money_outlined,
                    text: 'EGP ${request.calculatedPay.toStringAsFixed(0)}',
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildActions(),
          ],
        ),
      ),
    );
  }
}

class _RequestDetailChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const _RequestDetailChip({
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryBlue;

    return Row(
      children: [
        Icon(icon, size: 16, color: chipColor),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  color: color ?? AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _EarningItem extends StatelessWidget {
  final EarningModel earning;
  final Color statusColor;
  final Color amountColor;

  const _EarningItem({
    required this.earning,
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
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    AppDateFormatters.relative(earning.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textLight,
                        ),
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

class _NurseBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NurseBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    (
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      label: 'Schedule',
    ),
    (
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Wallet',
    ),
    (
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Messages',
    ),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        onTap: onTap,
        items: _items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: Icon(
              item.activeIcon,
              color: AppColors.primaryBlue,
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBox({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Icon(icon, color: color),
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