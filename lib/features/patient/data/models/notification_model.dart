import 'package:equatable/equatable.dart';

enum NotificationType {
  booking,
  message,
  payment,
  review,
  promotion,
  reminder,
  system;

  /// موجود مؤقتًا للتوافق مع NotificationsScreen الحالي.
  /// الأفضل لاحقًا نقل الأيقونات لطبقة الـ UI بدل الموديل.
  String get icon {
    switch (this) {
      case NotificationType.booking:
        return '📅';
      case NotificationType.message:
        return '💬';
      case NotificationType.payment:
        return '💳';
      case NotificationType.review:
        return '⭐';
      case NotificationType.promotion:
        return '🎉';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.system:
        return '🔔';
    }
  }

  String get label {
    switch (this) {
      case NotificationType.booking:
        return 'Booking';
      case NotificationType.message:
        return 'Message';
      case NotificationType.payment:
        return 'Payment';
      case NotificationType.review:
        return 'Review';
      case NotificationType.promotion:
        return 'Promotion';
      case NotificationType.reminder:
        return 'Reminder';
      case NotificationType.system:
        return 'System';
    }
  }

  static NotificationType fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'booking':
        return NotificationType.booking;
      case 'message':
        return NotificationType.message;
      case 'payment':
        return NotificationType.payment;
      case 'review':
        return NotificationType.review;
      case 'promotion':
        return NotificationType.promotion;
      case 'reminder':
        return NotificationType.reminder;
      case 'system':
      default:
        return NotificationType.system;
    }
  }
}

class NotificationModel extends Equatable {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
  });

  bool get isUnread => !isRead;

  NotificationModel copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  factory NotificationModel.empty() {
    return NotificationModel(
      id: '',
      type: NotificationType.system,
      title: '',
      body: '',
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      type: NotificationType.fromJson(json['type']?.toString()),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: _toDateTime(json['createdAt'] ?? json['created_at']),
      isRead: _toBool(json['isRead'] ?? json['is_read']),
      actionUrl: json['actionUrl']?.toString() ?? json['action_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
    };
  }

  static DateTime _toDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static bool _toBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final clean = value.trim().toLowerCase();
      return clean == 'true' || clean == '1' || clean == 'yes';
    }
    return false;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        body,
        createdAt,
        isRead,
        actionUrl,
      ];
}