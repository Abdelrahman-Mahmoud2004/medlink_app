import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final String id;
  final String title;
  final String address;
  final String city;
  final String postalCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.title,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  String get fullAddress {
    final parts = [
      address,
      city,
      if (postalCode.trim().isNotEmpty) postalCode,
    ];

    return parts.where((part) => part.trim().isNotEmpty).join(', ');
  }

  bool get hasCoordinates {
    return latitude != 0.0 || longitude != 0.0;
  }

  bool get isHome {
    return title.trim().toLowerCase() == 'home';
  }

  bool get isWork {
    return title.trim().toLowerCase() == 'work';
  }

  String get displayTitle {
    final cleanTitle = title.trim();

    if (cleanTitle.isEmpty) {
      return 'Address';
    }

    return cleanTitle;
  }

  AddressModel copyWith({
    String? id,
    String? title,
    String? address,
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory AddressModel.empty() {
    return const AddressModel(
      id: '',
      title: '',
      address: '',
      city: '',
      postalCode: '',
      latitude: 0.0,
      longitude: 0.0,
      isDefault: false,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      postalCode: json['postalCode']?.toString() ??
          json['postal_code']?.toString() ??
          '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      isDefault: _toBool(json['isDefault'] ?? json['is_default']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
        title,
        address,
        city,
        postalCode,
        latitude,
        longitude,
        isDefault,
      ];
}