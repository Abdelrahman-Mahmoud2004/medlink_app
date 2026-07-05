import 'package:equatable/equatable.dart';

enum BookingStatus {
  upcoming,
  confirmed,
  pending,
  completed,
  cancelled,
  unknown;

  String get label {
    switch (this) {
      case BookingStatus.upcoming:
        return 'Upcoming';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.unknown:
        return 'Unknown';
    }
  }

  static BookingStatus fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'upcoming':
        return BookingStatus.upcoming;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'pending':
        return BookingStatus.pending;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
      case 'canceled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.unknown;
    }
  }
}

class BookingModel extends Equatable {
  final String id;
  final String nurseName;
  final String nurseImage;
  final String serviceType;
  final DateTime dateTime;
  final String address;

  /// Kept as String to avoid breaking current UI code.
  final String status;

  final double amount;
  final String specialty;

  const BookingModel({
    required this.id,
    required this.nurseName,
    required this.nurseImage,
    required this.serviceType,
    required this.dateTime,
    required this.address,
    required this.status,
    required this.amount,
    required this.specialty,
  });

  BookingStatus get bookingStatus {
    return BookingStatus.fromJson(status);
  }

  String get statusLabel {
    if (bookingStatus != BookingStatus.unknown) {
      return bookingStatus.label;
    }

    final clean = status.trim();

    if (clean.isEmpty) {
      return 'Pending';
    }

    return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
  }

  bool get isActive {
    return bookingStatus == BookingStatus.upcoming ||
        bookingStatus == BookingStatus.confirmed ||
        bookingStatus == BookingStatus.pending;
  }

  bool get canCancel {
    return isActive;
  }

  bool get isCompleted {
    return bookingStatus == BookingStatus.completed;
  }

  bool get isCancelled {
    return bookingStatus == BookingStatus.cancelled;
  }

  String get displayNurseName {
    final clean = nurseName.trim();
    return clean.isEmpty ? 'Healthcare Provider' : clean;
  }

  String get displaySpecialty {
    final clean = specialty.trim();
    return clean.isEmpty ? serviceType : clean;
  }

  BookingModel copyWith({
    String? id,
    String? nurseName,
    String? nurseImage,
    String? serviceType,
    DateTime? dateTime,
    String? address,
    String? status,
    double? amount,
    String? specialty,
  }) {
    return BookingModel(
      id: id ?? this.id,
      nurseName: nurseName ?? this.nurseName,
      nurseImage: nurseImage ?? this.nurseImage,
      serviceType: serviceType ?? this.serviceType,
      dateTime: dateTime ?? this.dateTime,
      address: address ?? this.address,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      specialty: specialty ?? this.specialty,
    );
  }

  factory BookingModel.empty() {
    return BookingModel(
      id: '',
      nurseName: '',
      nurseImage: '',
      serviceType: '',
      dateTime: DateTime.now(),
      address: '',
      status: 'pending',
      amount: 0.0,
      specialty: '',
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
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
      dateTime: _toDateTime(json['dateTime'] ?? json['date_time']),
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      amount: _toDouble(json['amount']),
      specialty: json['specialty']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nurseName': nurseName,
      'nurseImage': nurseImage,
      'serviceType': serviceType,
      'dateTime': dateTime.toIso8601String(),
      'address': address,
      'status': status,
      'amount': amount,
      'specialty': specialty,
    };
  }

  static DateTime _toDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [
        id,
        nurseName,
        nurseImage,
        serviceType,
        dateTime,
        address,
        status,
        amount,
        specialty,
      ];
}