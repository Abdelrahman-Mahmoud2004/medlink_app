import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/constants.dart';

enum KycStatus {
  none,
  pending,
  approved,
  rejected;

  String toJson() => name;

  static KycStatus fromJson(String? value) {
    if (value == null || value.trim().isEmpty) {
      return KycStatus.none;
    }

    final cleanValue = value.trim().toLowerCase();

    for (final status in KycStatus.values) {
      if (status.name == cleanValue) {
        return status;
      }
    }

    return KycStatus.none;
  }
}

final class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  bool get isInitialized => _prefs != null;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _preferences {
    final prefs = _prefs;

    if (prefs == null) {
      throw StateError(
        'StorageService is not initialized. '
        'Call await StorageService.instance.init() before using it.',
      );
    }

    return prefs;
  }

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  bool get isOnboardingShown {
    return _prefs?.getBool(AppConstants.keyOnboardingShown) ?? false;
  }

  Future<void> setOnboardingShown({bool value = true}) async {
    await init();
    await _preferences.setBool(AppConstants.keyOnboardingShown, value);
  }

  Future<void> resetOnboarding() async {
    await init();
    await _preferences.remove(AppConstants.keyOnboardingShown);
  }

  // ---------------------------------------------------------------------------
  // Auth Token
  // ---------------------------------------------------------------------------

  String? get authToken {
    final token = _prefs?.getString(AppConstants.keyAuthToken);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token;
  }

  String? get refreshToken {
    final token = _prefs?.getString(AppConstants.keyRefreshToken);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token;
  }

  bool get isAuthenticated {
    return authToken != null;
  }

  Future<void> setAuthSession({
    required String authToken,
    String? refreshToken,
    required UserType userType,
    String? userId,
    KycStatus? kycStatus,
  }) async {
    await init();

    await _preferences.setString(AppConstants.keyAuthToken, authToken);
    await _preferences.setString(AppConstants.keyUserType, userType.name);

    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await _preferences.setString(
        AppConstants.keyRefreshToken,
        refreshToken.trim(),
      );
    }

    if (userId != null && userId.trim().isNotEmpty) {
      await _preferences.setString(
        AppConstants.keyUserId,
        userId.trim(),
      );
    }

    if (kycStatus != null) {
      await setKycStatus(kycStatus);
    }
  }

  Future<void> setAuthenticated({
    required bool value,
    UserType? userType,
  }) async {
    await init();

    if (value) {
      await _preferences.setString(
        AppConstants.keyAuthToken,
        'local_mock_token',
      );

      if (userType != null) {
        await _preferences.setString(AppConstants.keyUserType, userType.name);
      }

      return;
    }

    await clearAuth();
  }

  Future<void> setUserType(UserType userType) async {
    await init();
    await _preferences.setString(AppConstants.keyUserType, userType.name);
  }

  UserType? getUserType() {
    final value = _prefs?.getString(AppConstants.keyUserType);
    return UserType.fromJson(value);
  }

  String? get userId {
    final id = _prefs?.getString(AppConstants.keyUserId);

    if (id == null || id.trim().isEmpty) {
      return null;
    }

    return id;
  }

  Future<void> clearAuth() async {
    await init();

    await _preferences.remove(AppConstants.keyAuthToken);
    await _preferences.remove(AppConstants.keyRefreshToken);
    await _preferences.remove(AppConstants.keyUserType);
    await _preferences.remove(AppConstants.keyUserId);
    await _preferences.remove(AppConstants.keyUserData);
    await _preferences.remove(AppConstants.keyKycStatus);
  }

  // ---------------------------------------------------------------------------
  // KYC
  // ---------------------------------------------------------------------------

  KycStatus get kycStatus {
    final value = _prefs?.getString(AppConstants.keyKycStatus);
    return KycStatus.fromJson(value);
  }

  bool get isKycApproved => kycStatus == KycStatus.approved;

  bool get isKycPending => kycStatus == KycStatus.pending;

  Future<void> setKycStatus(KycStatus status) async {
    await init();
    await _preferences.setString(AppConstants.keyKycStatus, status.toJson());
  }

  Future<void> clearKycStatus() async {
    await init();
    await _preferences.remove(AppConstants.keyKycStatus);
  }

  // ---------------------------------------------------------------------------
  // Language
  // ---------------------------------------------------------------------------

  String get languageCode {
    return _prefs?.getString(AppConstants.keyLanguage) ?? 'en';
  }

  Future<void> setLanguageCode(String languageCode) async {
    await init();

    final cleanCode = languageCode.trim().toLowerCase();

    if (cleanCode.isEmpty) {
      return;
    }

    await _preferences.setString(AppConstants.keyLanguage, cleanCode);
  }

  Future<void> clearLanguage() async {
    await init();
    await _preferences.remove(AppConstants.keyLanguage);
  }

  // ---------------------------------------------------------------------------
  // General
  // ---------------------------------------------------------------------------

  Future<void> clearAll() async {
    await init();
    await _preferences.clear();
  }
}