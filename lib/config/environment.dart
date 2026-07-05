enum AppEnvironment {
  development,
  staging,
  production,
}

final class Environment {
  Environment._();

  static const String _environmentName = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static AppEnvironment get current {
    switch (_environmentName.trim().toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;

      case 'staging':
      case 'stage':
        return AppEnvironment.staging;

      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }

  static bool get isDevelopment => current == AppEnvironment.development;

  static bool get isStaging => current == AppEnvironment.staging;

  static bool get isProduction => current == AppEnvironment.production;

  static String get name {
    switch (current) {
      case AppEnvironment.development:
        return 'Development';
      case AppEnvironment.staging:
        return 'Staging';
      case AppEnvironment.production:
        return 'Production';
    }
  }

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.development:
        return 'https://dev-api.medlink.com/v1';

      case AppEnvironment.staging:
        return 'https://staging-api.medlink.com/v1';

      case AppEnvironment.production:
        return 'https://api.medlink.com/v1';
    }
  }

  static bool get enableLogs => !isProduction;

  static bool get enableDebugBanner => isDevelopment;

  static Duration get connectionTimeout => const Duration(seconds: 30);

  static Duration get receiveTimeout => const Duration(seconds: 30);

  static int get maxUploadSize => 10 * 1024 * 1024; // 10MB

  static int get maxProfileImageSize => 5 * 1024 * 1024; // 5MB
}