import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../data/models/notification_model.dart';
import '../../../auth/presentation/providers/patient_provider.dart';

enum _NotificationFilter {
  all,
  unread,
  booking,
  message,
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  _NotificationFilter _filter = _NotificationFilter.all;

  List<NotificationModel> _applyFilter(List<NotificationModel> notifications) {
    switch (_filter) {
      case _NotificationFilter.all:
        return notifications;

      case _NotificationFilter.unread:
        return notifications.where((item) => !item.isRead).toList();

      case _NotificationFilter.booking:
        return notifications
            .where((item) => item.type == NotificationType.booking)
            .toList();

      case _NotificationFilter.message:
        return notifications
            .where((item) => item.type == NotificationType.message)
            .toList();
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  void _handleNotificationTap(NotificationModel notification) {
    final notifier = ref.read(notificationsProvider.notifier);

    notifier.markAsRead(notification.id);

    switch (notification.type) {
      case NotificationType.booking:
        context.push(AppRoutes.bookingHistory);
        break;

      case NotificationType.message:
        context.push(AppRoutes.patientMessages);
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allNotifications = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);

    final filteredNotifications = _applyFilter(allNotifications);
    final unreadCount =
        allNotifications.where((notification) => !notification.isRead).length;

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
              onPressed: notifier.markAllAsRead,
              child: Text(
                'Mark all read',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _FilterChips(
              selectedFilter: _filter,
              onFilterChanged: (filter) {
                setState(() => _filter = filter);
              },
            ),
            Expanded(
              child: filteredNotifications.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: filteredNotifications.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];

                        return Dismissible(
                          key: ValueKey(notification.id),
                          direction: DismissDirection.endToStart,
                          background: const _DismissBackground(),
                          onDismissed: (_) {
                            notifier.delete(notification.id);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Notification deleted'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    // TODO: Add restore notification in provider if needed.
                                  },
                                ),
                              ),
                            );
                          },
                          child: _NotificationCard(
                            notification: notification,
                            onTap: () => _handleNotificationTap(notification),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final _NotificationFilter selectedFilter;
  final ValueChanged<_NotificationFilter> onFilterChanged;

  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = {
      _NotificationFilter.all: 'All',
      _NotificationFilter.unread: 'Unread',
      _NotificationFilter.booking: 'Bookings',
      _NotificationFilter.message: 'Messages',
    };

    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final entry = options.entries.elementAt(index);
          final isSelected = selectedFilter == entry.key;

          return GestureDetector(
            onTap: () => onFilterChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryBlue : AppColors.borderGray,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.025),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                entry.value,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected ? AppColors.white : AppColors.textDark,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.errorRed,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.white,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  Color _typeColor(NotificationType type) {
    switch (type) {
      case NotificationType.booking:
        return AppColors.primaryBlue;

      case NotificationType.message:
        return AppColors.successGreen;

      default:
        return AppColors.warningOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(notification.type);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.white : AppColors.lightBlue,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.borderGray
                  : AppColors.primaryBlue.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: Text(
                    notification.type.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      notification.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textLight,
                            height: 1.45,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      AppDateFormatters.relative(notification.createdAt),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 10,
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w600,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 46,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "You're all caught up!",
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