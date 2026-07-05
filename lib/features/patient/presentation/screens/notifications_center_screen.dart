import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../data/models/notification_model.dart';
import '../../providers/patient_provider.dart';

enum _NotificationFilter {
  all,
  unread,
  booking,
  message,
}

extension _NotificationFilterX on _NotificationFilter {
  String get label {
    switch (this) {
      case _NotificationFilter.all:
        return 'All';
      case _NotificationFilter.unread:
        return 'Unread';
      case _NotificationFilter.booking:
        return 'Bookings';
      case _NotificationFilter.message:
        return 'Messages';
    }
  }

  String get emptyTitle {
    switch (this) {
      case _NotificationFilter.all:
        return 'No notifications';
      case _NotificationFilter.unread:
        return 'No unread notifications';
      case _NotificationFilter.booking:
        return 'No booking notifications';
      case _NotificationFilter.message:
        return 'No message notifications';
    }
  }

  String get emptySubtitle {
    switch (this) {
      case _NotificationFilter.all:
        return "You're all caught up!";
      case _NotificationFilter.unread:
        return 'All notifications have been read.';
      case _NotificationFilter.booking:
        return 'Booking updates will appear here.';
      case _NotificationFilter.message:
        return 'Message notifications will appear here.';
    }
  }

  IconData get emptyIcon {
    switch (this) {
      case _NotificationFilter.all:
        return Icons.notifications_off_outlined;
      case _NotificationFilter.unread:
        return Icons.mark_email_read_outlined;
      case _NotificationFilter.booking:
        return Icons.event_busy_rounded;
      case _NotificationFilter.message:
        return Icons.chat_bubble_outline_rounded;
    }
  }
}

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

final _notificationFilterProvider =
    StateProvider.autoDispose<_NotificationFilter>(
  (ref) => _NotificationFilter.all,
);

final _notificationsCenterDataProvider =
    Provider.autoDispose<_NotificationsCenterData>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return _NotificationsCenterData.fromNotifications(notifications);
});

final _visibleNotificationsProvider =
    Provider.autoDispose<List<NotificationModel>>((ref) {
  final filter = ref.watch(_notificationFilterProvider);
  final data = ref.watch(_notificationsCenterDataProvider);

  return data.listFor(filter);
});

final _unreadNotificationsCountProvider = Provider.autoDispose<int>((ref) {
  final data = ref.watch(_notificationsCenterDataProvider);
  return data.unreadCount;
});

// -----------------------------------------------------------------------------
// Optimized computed data
// -----------------------------------------------------------------------------

class _NotificationsCenterData {
  final List<NotificationModel> all;
  final List<NotificationModel> unread;
  final List<NotificationModel> booking;
  final List<NotificationModel> message;
  final int unreadCount;

  const _NotificationsCenterData({
    required this.all,
    required this.unread,
    required this.booking,
    required this.message,
    required this.unreadCount,
  });

  factory _NotificationsCenterData.fromNotifications(
    List<NotificationModel> notifications,
  ) {
    final allNotifications = List<NotificationModel>.from(notifications);
    final unreadNotifications = <NotificationModel>[];
    final bookingNotifications = <NotificationModel>[];
    final messageNotifications = <NotificationModel>[];

    for (final notification in notifications) {
      if (!notification.isRead) {
        unreadNotifications.add(notification);
      }

      switch (notification.type) {
        case NotificationType.booking:
          bookingNotifications.add(notification);
          break;

        case NotificationType.message:
          messageNotifications.add(notification);
          break;

        default:
          break;
      }
    }

    allNotifications.sort(_compareNotificationNewestFirst);
    unreadNotifications.sort(_compareNotificationNewestFirst);
    bookingNotifications.sort(_compareNotificationNewestFirst);
    messageNotifications.sort(_compareNotificationNewestFirst);

    return _NotificationsCenterData(
      all: List.unmodifiable(allNotifications),
      unread: List.unmodifiable(unreadNotifications),
      booking: List.unmodifiable(bookingNotifications),
      message: List.unmodifiable(messageNotifications),
      unreadCount: unreadNotifications.length,
    );
  }

  List<NotificationModel> listFor(_NotificationFilter filter) {
    switch (filter) {
      case _NotificationFilter.all:
        return all;
      case _NotificationFilter.unread:
        return unread;
      case _NotificationFilter.booking:
        return booking;
      case _NotificationFilter.message:
        return message;
    }
  }
}

int _compareNotificationNewestFirst(
  NotificationModel a,
  NotificationModel b,
) {
  final dateCompare = b.createdAt.compareTo(a.createdAt);

  if (dateCompare != 0) {
    return dateCompare;
  }

  return a.id.compareTo(b.id);
}

// -----------------------------------------------------------------------------
// Screen
// -----------------------------------------------------------------------------

class NotificationsCenterScreen extends StatelessWidget {
  const NotificationsCenterScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.patientHome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
        actions: const [
          _MarkAllReadAction(),
        ],
      ),
      body: const SafeArea(
        child: Column(
          children: [
            _FilterChipsConsumer(),
            Expanded(
              child: _NotificationsListConsumer(),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// AppBar action
// -----------------------------------------------------------------------------

class _MarkAllReadAction extends ConsumerWidget {
  const _MarkAllReadAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(_unreadNotificationsCountProvider);

    if (unreadCount <= 0) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: () {
        ref.read(notificationsProvider.notifier).markAllAsRead();
      },
      child: Text(
        'Mark all read',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Filter chips
// -----------------------------------------------------------------------------

class _FilterChipsConsumer extends ConsumerWidget {
  const _FilterChipsConsumer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(_notificationFilterProvider);

    return _FilterChips(
      selectedFilter: selectedFilter,
      onFilterChanged: (filter) {
        ref.read(_notificationFilterProvider.notifier).state = filter;
      },
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
    const filters = _NotificationFilter.values;

    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.full),
              onTap: isSelected ? null : () => onFilterChanged(filter),
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
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.borderGray,
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
                  filter.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            isSelected ? AppColors.white : AppColors.textDark,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Notifications list consumer
// -----------------------------------------------------------------------------

class _NotificationsListConsumer extends ConsumerWidget {
  const _NotificationsListConsumer();

  void _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    final notifier = ref.read(notificationsProvider.notifier);

    if (!notification.isRead) {
      notifier.markAsRead(notification.id);
    }

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

  void _deleteNotification(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) {
    final notifier = ref.read(notificationsProvider.notifier);

    notifier.delete(notification.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Notification deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              notifier.restore(notification);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(_notificationFilterProvider);
    final visibleNotifications = ref.watch(_visibleNotificationsProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: visibleNotifications.isEmpty
          ? _EmptyState(
              key: ValueKey<String>('empty-${selectedFilter.name}'),
              filter: selectedFilter,
            )
          : _NotificationsList(
              key: ValueKey<String>(
                'list-${selectedFilter.name}-${visibleNotifications.length}',
              ),
              notifications: visibleNotifications,
              onNotificationTap: (notification) {
                _handleNotificationTap(context, ref, notification);
              },
              onNotificationDismissed: (notification) {
                _deleteNotification(context, ref, notification);
              },
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// Notifications list
// -----------------------------------------------------------------------------

class _NotificationsList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final ValueChanged<NotificationModel> onNotificationTap;
  final ValueChanged<NotificationModel> onNotificationDismissed;

  const _NotificationsList({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
    required this.onNotificationDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return RepaintBoundary(
          child: Dismissible(
            key: ValueKey<String>(
              notification.id.isNotEmpty
                  ? notification.id
                  : '${notification.createdAt.millisecondsSinceEpoch}-$index',
            ),
            direction: DismissDirection.endToStart,
            background: const _DismissBackground(),
            onDismissed: (_) => onNotificationDismissed(notification),
            child: _NotificationCard(
              notification: notification,
              onTap: () => onNotificationTap(notification),
            ),
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Dismiss background
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Notification card
// -----------------------------------------------------------------------------

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

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final _NotificationFilter filter;

  const _EmptyState({
    super.key,
    required this.filter,
  });

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
              child: Icon(
                filter.emptyIcon,
                size: 46,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              filter.emptyTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              filter.emptySubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textLight,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}