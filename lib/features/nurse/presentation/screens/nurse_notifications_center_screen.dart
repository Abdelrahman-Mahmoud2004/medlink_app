import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';

class NurseNotificationsCenterScreen extends StatefulWidget {
  const NurseNotificationsCenterScreen({super.key});

  @override
  State<NurseNotificationsCenterScreen> createState() =>
      _NurseNotificationsCenterScreenState();
}

class _NurseNotificationsCenterScreenState
    extends State<NurseNotificationsCenterScreen> {
  final ValueNotifier<String> _filterNotifier = ValueNotifier<String>('All');

  late List<_NurseNotification> _notifications;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _notifications = [
      _NurseNotification(
        title: 'New request available',
        body: 'A patient needs post-surgery care near you.',
        type: 'Request',
        createdAt: now.subtract(const Duration(minutes: 18)),
      ),
      _NurseNotification(
        title: 'Payout update',
        body: 'Your completed visit earning is now available.',
        type: 'Wallet',
        createdAt: now.subtract(const Duration(hours: 2)),
        read: true,
      ),
      _NurseNotification(
        title: 'KYC review pending',
        body: 'Your experience documents are still under review.',
        type: 'KYC',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
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

    context.go(AppRoutes.nurseHome);
  }

  List<_NurseNotification> _filtered(String filter) {
    if (filter == 'All') return _notifications;

    if (filter == 'Unread') {
      return _notifications.where((item) => !item.read).toList(growable: false);
    }

    return _notifications
        .where((item) => item.type == filter)
        .toList(growable: false);
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((item) => item.copyWith(read: true))
          .toList(growable: false);
    });
  }

  void _markRead(int index) {
    setState(() {
      _notifications[index] = _notifications[index].copyWith(read: true);
    });
  }

  Color _typeColor(String type) {
    return switch (type) {
      'Request' => AppColors.primaryBlue,
      'Wallet' => AppColors.successGreen,
      'KYC' => AppColors.warningOrange,
      _ => AppColors.textLight,
    };
  }

  IconData _typeIcon(String type) {
    return switch (type) {
      'Request' => Icons.local_hospital_outlined,
      'Wallet' => Icons.account_balance_wallet_outlined,
      'KYC' => Icons.verified_user_outlined,
      _ => Icons.notifications_none_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((item) => !item.read).length;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _goBack,
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
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
                    _NotificationSummary(unreadCount: unreadCount),
                    const SizedBox(height: AppSpacing.xl),
                    _FilterChips(filterNotifier: _filterNotifier),
                    const SizedBox(height: AppSpacing.lg),
                    ValueListenableBuilder<String>(
                      valueListenable: _filterNotifier,
                      builder: (context, filter, _) {
                        final items = _filtered(filter);

                        if (items.isEmpty) {
                          return const _EmptyNotifications();
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final realIndex = _notifications.indexOf(item);

                            return _NotificationTile(
                              notification: item,
                              color: _typeColor(item.type),
                              icon: _typeIcon(item.type),
                              onTap: () {
                                if (realIndex >= 0) _markRead(realIndex);
                              },
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

class _NurseNotification {
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool read;

  const _NurseNotification({
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.read = false,
  });

  _NurseNotification copyWith({
    String? title,
    String? body,
    String? type,
    DateTime? createdAt,
    bool? read,
  }) {
    return _NurseNotification(
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }
}

class _NotificationSummary extends StatelessWidget {
  final int unreadCount;

  const _NotificationSummary({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.darkBlue],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: AppColors.white,
            size: 42,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unreadCount unread notifications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Stay updated about requests, visits and payouts.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.85),
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

class _FilterChips extends StatelessWidget {
  final ValueNotifier<String> filterNotifier;

  const _FilterChips({required this.filterNotifier});

  static const filters = ['All', 'Unread', 'Request', 'Wallet', 'KYC'];

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
              final isSelected = selected == filter;

              return GestureDetector(
                onTap: () => filterNotifier.value = filter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.borderGray,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textDark,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
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

class _NotificationTile extends StatelessWidget {
  final _NurseNotification notification;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _Decorations.card(
        bgColor: notification.read ? AppColors.white : AppColors.lightBlue,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textLight,
                              height: 1.35,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppDateFormatters.relative(notification.createdAt),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppColors.textLight,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!notification.read)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: _Decorations.card(),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: AppColors.textLight.withValues(alpha: 0.75),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No notifications',
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

final class _Decorations {
  const _Decorations._();

  static BoxDecoration card({Color bgColor = AppColors.white}) {
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: AppColors.borderGray),
    );
  }
}