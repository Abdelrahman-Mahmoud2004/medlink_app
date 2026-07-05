import 'package:equatable/equatable.dart';

enum RequestStatus {
  active,
  scheduled,
  completed,
  cancelled,
  unknown;

  String get label {
    switch (this) {
      case RequestStatus.active:
        return 'ACTIVE';
      case RequestStatus.scheduled:
        return 'SCHEDULED';
      case RequestStatus.completed:
        return 'COMPLETED';
      case RequestStatus.cancelled:
        return 'CANCELLED';
      case RequestStatus.unknown:
        return 'UNKNOWN';
    }
  }

  static RequestStatus fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'active':
        return RequestStatus.active;
      case 'scheduled':
        return RequestStatus.scheduled;
      case 'completed':
        return RequestStatus.completed;
      case 'cancelled':
      case 'canceled':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.unknown;
    }
  }
}

extension RequestStatusX on RequestStatus {
  String get displayName => label;
}

class RequestModel extends Equatable {
  final String id;
  final String patientName;
  final String patientImage;
  final String serviceType;
  final String specialty;
  final double calculatedPay;
  final double distance;
  final double duration;
  final RequestStatus status;
  final DateTime requestedTime;
  final String location;
  final String notes;

  const RequestModel({
    required this.id,
    required this.patientName,
    required this.patientImage,
    required this.serviceType,
    required this.specialty,
    required this.calculatedPay,
    required this.distance,
    required this.duration,
    required this.status,
    required this.requestedTime,
    required this.location,
    required this.notes,
  });

  bool get isActive => status == RequestStatus.active;
  bool get isScheduled => status == RequestStatus.scheduled;
  bool get isCompleted => status == RequestStatus.completed;
  bool get isCancelled => status == RequestStatus.cancelled;

  RequestModel copyWith({
    String? id,
    String? patientName,
    String? patientImage,
    String? serviceType,
    String? specialty,
    double? calculatedPay,
    double? distance,
    double? duration,
    RequestStatus? status,
    DateTime? requestedTime,
    String? location,
    String? notes,
  }) {
    return RequestModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientImage: patientImage ?? this.patientImage,
      serviceType: serviceType ?? this.serviceType,
      specialty: specialty ?? this.specialty,
      calculatedPay: calculatedPay ?? this.calculatedPay,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      requestedTime: requestedTime ?? this.requestedTime,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  factory RequestModel.empty() {
    return RequestModel(
      id: '',
      patientName: '',
      patientImage: '',
      serviceType: '',
      specialty: '',
      calculatedPay: 0.0,
      distance: 0.0,
      duration: 0.0,
      status: RequestStatus.scheduled,
      requestedTime: DateTime.now(),
      location: '',
      notes: '',
    );
  }

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName']?.toString() ??
          json['patient_name']?.toString() ??
          '',
      patientImage: json['patientImage']?.toString() ??
          json['patient_image']?.toString() ??
          '',
      serviceType: json['serviceType']?.toString() ??
          json['service_type']?.toString() ??
          '',
      specialty: json['specialty']?.toString() ?? '',
      calculatedPay: _toDouble(json['calculatedPay'] ?? json['calculated_pay']),
      distance: _toDouble(json['distance']),
      duration: _toDouble(json['duration']),
      status: RequestStatus.fromJson(json['status']?.toString()),
      requestedTime: _toDateTime(json['requestedTime'] ?? json['requested_time']),
      location: json['location']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'patientImage': patientImage,
      'serviceType': serviceType,
      'specialty': specialty,
      'calculatedPay': calculatedPay,
      'distance': distance,
      'duration': duration,
      'status': status.name,
      'requestedTime': requestedTime.toIso8601String(),
      'location': location,
      'notes': notes,
    };
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _toDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  List<Object?> get props => [
        id,
        patientName,
        patientImage,
        serviceType,
        specialty,
        calculatedPay,
        distance,
        duration,
        status,
        requestedTime,
        location,
        notes,
      ];
}