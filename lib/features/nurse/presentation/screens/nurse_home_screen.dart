import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
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
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _activeRequests = List.of(NurseMockData.activeRequests);
    _recentEarnings = NurseMockData.earnings
        .where((e) => e.status == EarningStatus.completed)
        .take(3)
        .toList();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  void _handleAccept(RequestModel request) {
    setState(() => _activeRequests.removeWhere((r) => r.id == request.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Accepted ${request.patientName}'s request"),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  void _handleDecline(RequestModel request) {
    setState(() => _activeRequests.removeWhere((r) => r.id == request.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Declined ${request.patientName}'s request")),
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
        _pushTab(4, AppRoutes.profile);
        break;
    }
  }

  /// Pushes [route] and, once the user comes back, resets the nav
  /// selection to Home — since this uses push/pop rather than persistent
  /// tabs, the highlighted item should reflect where you actually are.
  void _pushTab(int index, String route) {
    setState(() => _selectedNavIndex = index);
    context.push(route).then((_) {
      if (mounted) setState(() => _selectedNavIndex = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickStats(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildActiveRequestsSection(context),
                    const SizedBox(height: AppSpacing.xl),
                    _buildRecentEarningsSection(context),
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
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textLight),
          ),
          Text(
            'MedLink Provider',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
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
                  const Icon(Icons.notifications_outlined,
                      color: AppColors.primaryBlue, size: 28),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.errorRed,
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

  Widget _buildQuickStats(BuildContext context) {
    return const Column(
      children: [
        _DailyEarningsCard(amount: NurseMockData.dailyEarnings),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _StatBox(
                // Was hardcoded '142' — now actually reflects the data.
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

  Widget _buildActiveRequestsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Active Requests',
          actionLabel: 'See all',
          onAction: () => context.push(AppRoutes.nurseSchedule),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_activeRequests.isEmpty)
          const _EmptyNotice(text: 'No active requests right now')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _activeRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
            itemBuilder: (context, index) => _RequestCard(
              request: _activeRequests[index],
              onAccept: () => _handleAccept(_activeRequests[index]),
              onDecline: () => _handleDecline(_activeRequests[index]),
              onStartTravel: () => _showComingSoon('Navigation'),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentEarningsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Recent Visits',
          actionLabel: 'View all',
          onAction: () => context.push(AppRoutes.nurseWallet),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentEarnings.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
          itemBuilder: (context, index) =>
              _EarningItem(earning: _recentEarnings[index]),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _DailyEarningsCard extends StatelessWidget {
  final double amount;

  const _DailyEarningsCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.white.withValues(alpha: 0.9)),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'EGP ${amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
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
            child: const Icon(Icons.trending_up,
                color: AppColors.white, size: 28),
          ),
        ],
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
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
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
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.primaryBlue),
          ),
        ),
      ],
    );
  }
}

class _EmptyNotice extends StatelessWidget {
  final String text;

  const _EmptyNotice({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.textLight),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onStartTravel;

  const _RequestCard({
    required this.request,
    required this.onAccept,
    required this.onDecline,
    required this.onStartTravel,
  });

  Color get _statusColor => switch (request.status) {
        RequestStatus.active => AppColors.successGreen,
        RequestStatus.scheduled => AppColors.warningOrange,
        RequestStatus.completed => AppColors.primaryBlue,
        RequestStatus.cancelled => AppColors.errorRed,
      };

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
          style: FilledButton.styleFrom(backgroundColor: AppColors.primaryBlue),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigation),
              SizedBox(width: AppSpacing.md),
              Text('Start Travel'),
            ],
          ),
        ),
      RequestStatus.completed ||
      RequestStatus.cancelled =>
        const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person),
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
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            request.specialty,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  request.status.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _statusColor,
                        fontSize: 11,
                      ),
                ),
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
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.primaryBlue),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontSize: 12,
                  color: color ?? AppColors.textDark,
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

  const _EarningItem({required this.earning});

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
                  AppDateFormatters.relative(earning.date),
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
                  // Was hardcoded 'Completed' text regardless of the real
                  // status — now reflects earning.status honestly.
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

class _NurseBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NurseBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  // Icons.calendar_today_filled and Icons.person_filled don't exist in
  // Flutter's Icons class (only a handful of icons like home_filled have a
  // "_filled" alias) — that was a compile error in the original. Using the
  // base icon (already filled-style) for active + "_outlined" for inactive
  // is the safe, well-established pattern used elsewhere in this codebase.
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
        border: Border(top: BorderSide(color: AppColors.borderGray)),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        onTap: onTap,
        items: _items
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  activeIcon:
                      Icon(item.activeIcon, color: AppColors.primaryBlue),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}