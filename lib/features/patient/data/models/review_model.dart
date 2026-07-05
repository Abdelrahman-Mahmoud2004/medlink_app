import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String patientName;
  final String patientImage;
  final double rating;
  final String text;
  final DateTime createdAt;
  final List<String> photos;

  const ReviewModel({
    required this.id,
    required this.patientName,
    required this.patientImage,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.photos = const [],
  });

  double get safeRating {
    return rating.clamp(0.0, 5.0);
  }

  bool get hasPhotos {
    return photos.isNotEmpty;
  }

  String get displayPatientName {
    final clean = patientName.trim();
    return clean.isEmpty ? 'Patient' : clean;
  }

  ReviewModel copyWith({
    String? id,
    String? patientName,
    String? patientImage,
    double? rating,
    String? text,
    DateTime? createdAt,
    List<String>? photos,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      patientImage: patientImage ?? this.patientImage,
      rating: rating ?? this.rating,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      photos: photos ?? this.photos,
    );
  }

  factory ReviewModel.empty() {
    return ReviewModel(
      id: '',
      patientName: '',
      patientImage: '',
      rating: 0.0,
      text: '',
      createdAt: DateTime.now(),
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      patientName: json['patientName']?.toString() ??
          json['patient_name']?.toString() ??
          '',
      patientImage: json['patientImage']?.toString() ??
          json['patient_image']?.toString() ??
          '',
      rating: _toDouble(json['rating']),
      text: json['text']?.toString() ?? '',
      createdAt: _toDateTime(json['createdAt'] ?? json['created_at']),
      photos: _toStringList(json['photos']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'patientImage': patientImage,
      'rating': rating,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'photos': photos,
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

  static List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }

    return const [];
  }

  @override
  List<Object?> get props => [
        id,
        patientName,
        patientImage,
        rating,
        text,
        createdAt,
        photos,
      ];
}