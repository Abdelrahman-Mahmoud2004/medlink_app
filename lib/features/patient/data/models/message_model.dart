import 'package:equatable/equatable.dart';

enum MessageType {
  text,
  image,
  file,
  system;

  static MessageType fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'image':
        return MessageType.image;
      case 'file':
        return MessageType.file;
      case 'system':
        return MessageType.system;
      case 'text':
      default:
        return MessageType.text;
    }
  }
}

class MessageModel extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final List<String> attachmentUrls;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.attachmentUrls = const [],
  });

  bool isFromUser(String userId) => senderId == userId;

  bool get hasAttachments => attachmentUrls.isNotEmpty;
  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isFile => type == MessageType.file;
  bool get isSystem => type == MessageType.system;

  String get displaySenderName {
    final clean = senderName.trim();
    return clean.isEmpty ? 'User' : clean;
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    List<String>? attachmentUrls,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
    );
  }

  factory MessageModel.empty() {
    return MessageModel(
      id: '',
      senderId: '',
      senderName: '',
      senderImage: '',
      content: '',
      type: MessageType.text,
      timestamp: DateTime.now(),
      isRead: false,
    );
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ??
          json['sender_id']?.toString() ??
          '',
      senderName: json['senderName']?.toString() ??
          json['sender_name']?.toString() ??
          '',
      senderImage: json['senderImage']?.toString() ??
          json['sender_image']?.toString() ??
          '',
      content: json['content']?.toString() ?? '',
      type: MessageType.fromJson(json['type']?.toString()),
      timestamp: _toDateTime(json['timestamp']),
      isRead: _toBool(json['isRead'] ?? json['is_read']),
      attachmentUrls: _toStringList(json['attachmentUrls'] ?? json['attachment_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'attachmentUrls': attachmentUrls,
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

  static List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }

    return const [];
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        senderImage,
        content,
        type,
        timestamp,
        isRead,
        attachmentUrls,
      ];
}