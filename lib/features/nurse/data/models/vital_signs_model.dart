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
