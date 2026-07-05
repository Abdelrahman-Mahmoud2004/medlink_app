import 'package:equatable/equatable.dart';

class FamilyMemberModel extends Equatable {
  final String id;
  final String fullName;
  final String relationship;
  final String phone;
  final String bloodType;
  final String allergies;
  final String chronicConditions;
  final bool isPrimary;

  const FamilyMemberModel({
    required this.id,
    required this.fullName,
    required this.relationship,
    required this.phone,
    required this.bloodType,
    required this.allergies,
    required this.chronicConditions,
    this.isPrimary = false,
  });

  String get displayName {
    final clean = fullName.trim();
    return clean.isEmpty ? 'Family Member' : clean;
  }

  String get displayRelationship {
    final clean = relationship.trim();
    return clean.isEmpty ? 'Dependent' : clean;
  }

  bool get hasMedicalNotes {
    return allergies.trim().isNotEmpty || chronicConditions.trim().isNotEmpty;
  }

  FamilyMemberModel copyWith({
    String? id,
    String? fullName,
    String? relationship,
    String? phone,
    String? bloodType,
    String? allergies,
    String? chronicConditions,
    bool? isPrimary,
  }) {
    return FamilyMemberModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory FamilyMemberModel.empty() {
    return const FamilyMemberModel(
      id: '',
      fullName: '',
      relationship: '',
      phone: '',
      bloodType: '',
      allergies: '',
      chronicConditions: '',
    );
  }

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id']?.toString() ?? '',
      fullName:
          json['fullName']?.toString() ?? json['full_name']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bloodType:
          json['bloodType']?.toString() ?? json['blood_type']?.toString() ?? '',
      allergies: json['allergies']?.toString() ?? '',
      chronicConditions: json['chronicConditions']?.toString() ??
          json['chronic_conditions']?.toString() ??
          '',
      isPrimary: _toBool(json['isPrimary'] ?? json['is_primary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'relationship': relationship,
      'phone': phone,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'isPrimary': isPrimary,
    };
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
        fullName,
        relationship,
        phone,
        bloodType,
        allergies,
        chronicConditions,
        isPrimary,
      ];
}