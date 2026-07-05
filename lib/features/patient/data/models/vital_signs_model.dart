import 'package:equatable/equatable.dart';

class VitalSignsModel extends Equatable {
  final String id;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final int heartRate;
  final double temperature;
  final int respiratoryRate;
  final double oxygenSaturation;
  final DateTime recordedAt;
  final String notes;

  const VitalSignsModel({
    required this.id,
    required this.bloodPressureSystolic,
    required this.bloodPressureDiastolic,
    required this.heartRate,
    required this.temperature,
    required this.respiratoryRate,
    required this.oxygenSaturation,
    required this.recordedAt,
    this.notes = '',
  });

  String get bloodPressureText {
    return '$bloodPressureSystolic/$bloodPressureDiastolic mmHg';
  }

  String get heartRateText {
    return '$heartRate bpm';
  }

  String get temperatureText {
    return '${temperature.toStringAsFixed(1)} °C';
  }

  String get respiratoryRateText {
    return '$respiratoryRate rpm';
  }

  String get oxygenSaturationText {
    return '${oxygenSaturation.toStringAsFixed(0)}%';
  }

  bool get hasNotes {
    return notes.trim().isNotEmpty;
  }

  VitalSignsModel copyWith({
    String? id,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    int? heartRate,
    double? temperature,
    int? respiratoryRate,
    double? oxygenSaturation,
    DateTime? recordedAt,
    String? notes,
  }) {
    return VitalSignsModel(
      id: id ?? this.id,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      heartRate: heartRate ?? this.heartRate,
      temperature: temperature ?? this.temperature,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
    );
  }

  factory VitalSignsModel.empty() {
    return VitalSignsModel(
      id: '',
      bloodPressureSystolic: 0,
      bloodPressureDiastolic: 0,
      heartRate: 0,
      temperature: 0.0,
      respiratoryRate: 0,
      oxygenSaturation: 0.0,
      recordedAt: DateTime.now(),
    );
  }

  factory VitalSignsModel.fromJson(Map<String, dynamic> json) {
    return VitalSignsModel(
      id: json['id']?.toString() ?? '',
      bloodPressureSystolic: _toInt(
        json['bloodPressureSystolic'] ?? json['blood_pressure_systolic'],
      ),
      bloodPressureDiastolic: _toInt(
        json['bloodPressureDiastolic'] ?? json['blood_pressure_diastolic'],
      ),
      heartRate: _toInt(json['heartRate'] ?? json['heart_rate']),
      temperature: _toDouble(json['temperature']),
      respiratoryRate:
          _toInt(json['respiratoryRate'] ?? json['respiratory_rate']),
      oxygenSaturation:
          _toDouble(json['oxygenSaturation'] ?? json['oxygen_saturation']),
      recordedAt: _toDateTime(json['recordedAt'] ?? json['recorded_at']),
      notes: json['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'heartRate': heartRate,
      'temperature': temperature,
      'respiratoryRate': respiratoryRate,
      'oxygenSaturation': oxygenSaturation,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
        bloodPressureSystolic,
        bloodPressureDiastolic,
        heartRate,
        temperature,
        respiratoryRate,
        oxygenSaturation,
        recordedAt,
        notes,
      ];
}