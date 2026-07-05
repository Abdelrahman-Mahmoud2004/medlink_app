import 'package:equatable/equatable.dart';

class NurseModel extends Equatable {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String hourlyRate;
  final String experience;
  final bool isAvailable;
  final String availabilityStatus;
  final int patientsServed;
  final bool isCertified;
  final bool isOnline;

  const NurseModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.hourlyRate,
    required this.experience,
    required this.isAvailable,
    required this.availabilityStatus,
    required this.patientsServed,
    required this.isCertified,
    required this.isOnline,
  });

  double get hourlyRateValue {
    final value = hourlyRate.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(value) ?? 0.0;
  }

  double get safeRating {
    return rating.clamp(0.0, 5.0);
  }

  bool get hasImage {
    return imageUrl.trim().isNotEmpty;
  }

  bool get hasReviews {
    return reviewCount > 0;
  }

  String get displayName {
    final clean = name.trim();
    return clean.isEmpty ? 'Healthcare Provider' : clean;
  }

  String get displaySpecialty {
    final clean = specialty.trim();
    return clean.isEmpty ? 'Home Healthcare' : clean;
  }

  String get displayExperience {
    final clean = experience.trim();
    return clean.isEmpty ? 'Experience not specified' : clean;
  }

  String get displayAvailability {
    final clean = availabilityStatus.trim();

    if (clean.isNotEmpty) {
      return clean;
    }

    return isAvailable ? 'Available' : 'Unavailable';
  }

  NurseModel copyWith({
    String? id,
    String? name,
    String? specialty,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    String? hourlyRate,
    String? experience,
    bool? isAvailable,
    String? availabilityStatus,
    int? patientsServed,
    bool? isCertified,
    bool? isOnline,
  }) {
    return NurseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      experience: experience ?? this.experience,
      isAvailable: isAvailable ?? this.isAvailable,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      patientsServed: patientsServed ?? this.patientsServed,
      isCertified: isCertified ?? this.isCertified,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory NurseModel.empty() {
    return const NurseModel(
      id: '',
      name: '',
      specialty: '',
      imageUrl: '',
      rating: 0.0,
      reviewCount: 0,
      hourlyRate: 'EGP 0',
      experience: '',
      isAvailable: false,
      availabilityStatus: '',
      patientsServed: 0,
      isCertified: false,
      isOnline: false,
    );
  }

  factory NurseModel.fromJson(Map<String, dynamic> json) {
    return NurseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      specialty: json['specialty']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ??
          json['image_url']?.toString() ??
          '',
      rating: _toDouble(json['rating']),
      reviewCount: _toInt(json['reviewCount'] ?? json['review_count']),
      hourlyRate: json['hourlyRate']?.toString() ??
          json['hourly_rate']?.toString() ??
          'EGP 0',
      experience: json['experience']?.toString() ?? '',
      isAvailable: _toBool(json['isAvailable'] ?? json['is_available']),
      availabilityStatus: json['availabilityStatus']?.toString() ??
          json['availability_status']?.toString() ??
          '',
      patientsServed: _toInt(json['patientsServed'] ?? json['patients_served']),
      isCertified: _toBool(json['isCertified'] ?? json['is_certified']),
      isOnline: _toBool(json['isOnline'] ?? json['is_online']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'hourlyRate': hourlyRate,
      'experience': experience,
      'isAvailable': isAvailable,
      'availabilityStatus': availabilityStatus,
      'patientsServed': patientsServed,
      'isCertified': isCertified,
      'isOnline': isOnline,
    };
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(Object? value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
        name,
        specialty,
        imageUrl,
        rating,
        reviewCount,
        hourlyRate,
        experience,
        isAvailable,
        availabilityStatus,
        patientsServed,
        isCertified,
        isOnline,
      ];
}