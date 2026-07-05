import 'package:equatable/equatable.dart';

enum VisitStatus {
  started,
  inProgress,
  completed,
  cancelled,
  unknown;

  String get displayName {
    switch (this) {
      case VisitStatus.started:
        return 'Started';
      case VisitStatus.inProgress:
        return 'In Progress';
      case VisitStatus.completed:
        return 'Completed';
      case VisitStatus.cancelled:
        return 'Cancelled';
      case VisitStatus.unknown:
        return 'Unknown';
    }
  }

  static VisitStatus fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'started':
        return VisitStatus.started;
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
      case 'in progress':
        return VisitStatus.inProgress;
      case 'completed':
        return VisitStatus.completed;
      case 'cancelled':
      case 'canceled':
        return VisitStatus.cancelled;
      default:
        return VisitStatus.unknown;
    }
  }
}

class VisitModel extends Equatable {
  final String id;
  final String nurseName;
  final String nurseImage;
  final String serviceType;
  final String patientName;
  final String location;
  final DateTime startTime;
  final DateTime? endTime;
  final VisitStatus status;
  final double durationInHours;
  final String notes;
  final List<String> attachments;

  const VisitModel({
    required this.id,
    required this.nurseName,
    required this.nurseImage,
    required this.serviceType,
    required this.patientName,
    required this.location,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.durationInHours,
    this.notes = '',
    this.attachments = const [],
  });

  Duration get plannedDuration {
    return Duration(minutes: (durationInHours * 60).round());
  }

  bool get isActive {
    return status == VisitStatus.started || status == VisitStatus.inProgress;
  }

  bool get isCompleted {
    return status == VisitStatus.completed;
  }

  bool get isCancelled {
    return status == VisitStatus.cancelled;
  }

  VisitModel copyWith({
    String? id,
    String? nurseName,
    String? nurseImage,
    String? serviceType,
    String? patientName,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    VisitStatus? status,
    double? durationInHours,
    String? notes,
    List<String>? attachments,
  }) {
    return VisitModel(
      id: id ?? this.id,
      nurseName: nurseName ?? this.nurseName,
      nurseImage: nurseImage ?? this.nurseImage,
      serviceType: serviceType ?? this.serviceType,
      patientName: patientName ?? this.patientName,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      durationInHours: durationInHours ?? this.durationInHours,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }

  factory VisitModel.empty() {
    return VisitModel(
      id: '',
      nurseName: '',
      nurseImage: '',
      serviceType: '',
      patientName: '',
      location: '',
      startTime: DateTime.now(),
      status: VisitStatus.started,
      durationInHours: 1.0,
    );
  }

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    return VisitModel(
      id: json['id']?.toString() ?? '',
      nurseName: json['nurseName']?.toString() ??
          json['nurse_name']?.toString() ??
          '',
      nurseImage: json['nurseImage']?.toString() ??
          json['nurse_image']?.toString() ??
          '',
      serviceType: json['serviceType']?.toString() ??
          json['service_type']?.toString() ??
          '',
      patientName: json['patientName']?.toString() ??
          json['patient_name']?.toString() ??
          '',
      location: json['location']?.toString() ?? '',
      startTime: _toDateTime(json['startTime'] ?? json['start_time']),
      endTime: _toNullableDateTime(json['endTime'] ?? json['end_time']),
      status: VisitStatus.fromJson(json['status']?.toString()),
      durationInHours:
          _toDouble(json['durationInHours'] ?? json['duration_in_hours']),
      notes: json['notes']?.toString() ?? '',
      attachments: _toStringList(json['attachments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nurseName': nurseName,
      'nurseImage': nurseImage,
      'serviceType': serviceType,
      'patientName': patientName,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.name,
      'durationInHours': durationInHours,
      'notes': notes,
      'attachments': attachments,
    };
  }

  static DateTime _toDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _toNullableDateTime(Object? value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
        nurseName,
        nurseImage,
        serviceType,
        patientName,
        location,
        startTime,
        endTime,
        status,
        durationInHours,
        notes,
        attachments,
      ];
}