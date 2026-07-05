import 'environment.dart';

final class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // App
  // ---------------------------------------------------------------------------

  static const String appName = 'MedLink';

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------

  static String get baseUrl => Environment.baseUrl;

  static int get connectionTimeout =>
      Environment.connectionTimeout.inMilliseconds;

  static int get receiveTimeout => Environment.receiveTimeout.inMilliseconds;

  // ---------------------------------------------------------------------------
  // Storage Keys
  // ---------------------------------------------------------------------------

  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserType = 'user_type';
  static const String keyUserId = 'user_id';
  static const String keyUserData = 'user_data';
  static const String keyLanguage = 'language';
  static const String keyOnboardingShown = 'onboarding_shown';
  static const String keyKycStatus = 'kyc_status';

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  static const int minPasswordLength = 8;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 11;
  static const int otpLength = 6;

  // ---------------------------------------------------------------------------
  // Durations
  // ---------------------------------------------------------------------------

  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounce = Duration(milliseconds: 500);
  static const Duration splashDelay = Duration(seconds: 3);

  // ---------------------------------------------------------------------------
  // Upload Limits
  // ---------------------------------------------------------------------------

  static int get maxUploadSize => Environment.maxUploadSize;

  static int get maxProfileImageSize => Environment.maxProfileImageSize;
}

enum UserType {
  patient,
  nurse;

  String get displayName {
    switch (this) {
      case UserType.patient:
        return 'Patient';
      case UserType.nurse:
        return 'Nurse';
    }
  }

  String get routeName {
    switch (this) {
      case UserType.patient:
        return 'patient';
      case UserType.nurse:
        return 'nurse';
    }
  }

  bool get isPatient => this == UserType.patient;

  bool get isNurse => this == UserType.nurse;

  String toJson() => name;

  static UserType? fromJson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final cleanValue = value.trim().toLowerCase();

    for (final type in UserType.values) {
      if (type.name == cleanValue || type.routeName == cleanValue) {
        return type;
      }
    }

    return null;
  }
}