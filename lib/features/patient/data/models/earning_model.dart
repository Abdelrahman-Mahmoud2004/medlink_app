import 'package:equatable/equatable.dart';

enum EarningStatus {
  completed,
  pending,
  withdrawn,
  cancelled,
  unknown;

  String get label {
    switch (this) {
      case EarningStatus.completed:
        return 'COMPLETED';
      case EarningStatus.pending:
        return 'PENDING';
      case EarningStatus.withdrawn:
        return 'WITHDRAWN';
      case EarningStatus.cancelled:
        return 'CANCELLED';
      case EarningStatus.unknown:
        return 'UNKNOWN';
    }
  }

  static EarningStatus fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'completed':
        return EarningStatus.completed;
      case 'pending':
        return EarningStatus.pending;
      case 'withdrawn':
        return EarningStatus.withdrawn;
      case 'cancelled':
      case 'canceled':
        return EarningStatus.cancelled;
      default:
        return EarningStatus.unknown;
    }
  }
}

extension EarningStatusX on EarningStatus {
  String get displayName => label;
}

class EarningModel extends Equatable {
  final String id;
  final String description;
  final double amount;
  final double serviceCharge;
  final double platformFee;
  final double netAmount;
  final DateTime date;
  final EarningStatus status;

  const EarningModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.serviceCharge,
    required this.platformFee,
    required this.netAmount,
    required this.date,
    required this.status,
  });

  bool get isCompleted => status == EarningStatus.completed;
  bool get isPending => status == EarningStatus.pending;
  bool get isWithdrawn => status == EarningStatus.withdrawn;

  EarningModel copyWith({
    String? id,
    String? description,
    double? amount,
    double? serviceCharge,
    double? platformFee,
    double? netAmount,
    DateTime? date,
    EarningStatus? status,
  }) {
    return EarningModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      platformFee: platformFee ?? this.platformFee,
      netAmount: netAmount ?? this.netAmount,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  factory EarningModel.empty() {
    return EarningModel(
      id: '',
      description: '',
      amount: 0.0,
      serviceCharge: 0.0,
      platformFee: 0.0,
      netAmount: 0.0,
      date: DateTime.now(),
      status: EarningStatus.pending,
    );
  }

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      serviceCharge: _toDouble(json['serviceCharge'] ?? json['service_charge']),
      platformFee: _toDouble(json['platformFee'] ?? json['platform_fee']),
      netAmount: _toDouble(json['netAmount'] ?? json['net_amount']),
      date: _toDateTime(json['date']),
      status: EarningStatus.fromJson(json['status']?.toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'serviceCharge': serviceCharge,
      'platformFee': platformFee,
      'netAmount': netAmount,
      'date': date.toIso8601String(),
      'status': status.name,
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
        description,
        amount,
        serviceCharge,
        platformFee,
        netAmount,
        date,
        status,
      ];
}