import 'package:equatable/equatable.dart';

class MedicationModel extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final List<String> times;
  final DateTime startDate;
  final DateTime? endDate;
  final String notes;
  final bool isActive;

  const MedicationModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.notes = '',
    this.isActive = true,
  });

  String get displayName {
    final clean = name.trim();
    return clean.isEmpty ? 'Medication' : clean;
  }

  String get displayDosage {
    final clean = dosage.trim();
    return clean.isEmpty ? 'Dosage not specified' : clean;
  }

  String get displayFrequency {
    final clean = frequency.trim();
    return clean.isEmpty ? 'Frequency not specified' : clean;
  }

  bool get hasEndDate => endDate != null;

  MedicationModel copyWith({
    String? id,
    String? name,
    String? dosage,
    String? frequency,
    List<String>? times,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    bool? isActive,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  factory MedicationModel.empty() {
    return MedicationModel(
      id: '',
      name: '',
      dosage: '',
      frequency: '',
      times: const [],
      startDate: DateTime.now(),
    );
  }

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      dosage: json['dosage']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
      times: _toStringList(json['times']),
      startDate: _toDateTime(json['startDate'] ?? json['start_date']),
      endDate: _toNullableDateTime(json['endDate'] ?? json['end_date']),
      notes: json['notes']?.toString() ?? '',
      isActive: _toBool(json['isActive'] ?? json['is_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'times': times,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
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

  static List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    return const [];
  }

  static bool _toBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final clean = value.trim().toLowerCase();
      return clean == 'true' || clean == '1' || clean == 'yes';
    }

    return true;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        dosage,
        frequency,
        times,
        startDate,
        endDate,
        notes,
        isActive,
      ];
}