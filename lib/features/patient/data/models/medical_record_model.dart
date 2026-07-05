import 'package:equatable/equatable.dart';

enum MedicalRecordType {
  general,
  diagnosis,
  labResult,
  prescription,
  surgery,
  allergy,
  vaccine,
  imaging;

  String get label {
    switch (this) {
      case MedicalRecordType.general:
        return 'General';
      case MedicalRecordType.diagnosis:
        return 'Diagnosis';
      case MedicalRecordType.labResult:
        return 'Lab Result';
      case MedicalRecordType.prescription:
        return 'Prescription';
      case MedicalRecordType.surgery:
        return 'Surgery';
      case MedicalRecordType.allergy:
        return 'Allergy';
      case MedicalRecordType.vaccine:
        return 'Vaccine';
      case MedicalRecordType.imaging:
        return 'Imaging';
    }
  }

  static MedicalRecordType fromJson(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'diagnosis':
        return MedicalRecordType.diagnosis;
      case 'labresult':
      case 'lab_result':
      case 'lab-result':
      case 'lab result':
        return MedicalRecordType.labResult;
      case 'prescription':
        return MedicalRecordType.prescription;
      case 'surgery':
        return MedicalRecordType.surgery;
      case 'allergy':
        return MedicalRecordType.allergy;
      case 'vaccine':
        return MedicalRecordType.vaccine;
      case 'imaging':
        return MedicalRecordType.imaging;
      case 'general':
      default:
        return MedicalRecordType.general;
    }
  }
}

class MedicalRecordModel extends Equatable {
  final String id;
  final String title;
  final String providerName;
  final MedicalRecordType type;
  final DateTime recordDate;
  final String summary;
  final String notes;
  final List<String> attachments;

  const MedicalRecordModel({
    required this.id,
    required this.title,
    required this.providerName,
    required this.type,
    required this.recordDate,
    required this.summary,
    required this.notes,
    this.attachments = const [],
  });

  bool get hasAttachments => attachments.isNotEmpty;

  String get displayTitle {
    final clean = title.trim();
    return clean.isEmpty ? 'Medical Record' : clean;
  }

  String get displayProvider {
    final clean = providerName.trim();
    return clean.isEmpty ? 'Healthcare Provider' : clean;
  }

  MedicalRecordModel copyWith({
    String? id,
    String? title,
    String? providerName,
    MedicalRecordType? type,
    DateTime? recordDate,
    String? summary,
    String? notes,
    List<String>? attachments,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      providerName: providerName ?? this.providerName,
      type: type ?? this.type,
      recordDate: recordDate ?? this.recordDate,
      summary: summary ?? this.summary,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }

  factory MedicalRecordModel.empty() {
    return MedicalRecordModel(
      id: '',
      title: '',
      providerName: '',
      type: MedicalRecordType.general,
      recordDate: DateTime.now(),
      summary: '',
      notes: '',
    );
  }

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      providerName: json['providerName']?.toString() ??
          json['provider_name']?.toString() ??
          '',
      type: MedicalRecordType.fromJson(json['type']?.toString()),
      recordDate: _toDateTime(json['recordDate'] ?? json['record_date']),
      summary: json['summary']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      attachments: _toStringList(json['attachments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'providerName': providerName,
      'type': type.name,
      'recordDate': recordDate.toIso8601String(),
      'summary': summary,
      'notes': notes,
      'attachments': attachments,
    };
  }

  static DateTime _toDateTime(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
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
        title,
        providerName,
        type,
        recordDate,
        summary,
        notes,
        attachments,
      ];
}