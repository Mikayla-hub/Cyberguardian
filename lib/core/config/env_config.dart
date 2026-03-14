enum Environment { development, staging, production, demo }

class EnvConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableCertificatePinning;
  final bool useMockData;
  final List<String> certificateFingerprints;

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.enableLogging = false,
    this.enableCertificatePinning = true,
    this.useMockData = false,
    this.certificateFingerprints = const [],
  });

  static const EnvConfig demo = EnvConfig(
    environment: Environment.demo,
    apiBaseUrl: '',
    enableLogging: true,
    enableCertificatePinning: false,
    useMockData: true,
  );

  static const EnvConfig development = EnvConfig(
    environment: Environment.development,
    apiBaseUrl: 'http://localhost:8000',
    enableLogging: true,
    enableCertificatePinning: false,
  );

  static const EnvConfig staging = EnvConfig(
    environment: Environment.staging,
    apiBaseUrl: 'https://staging-api.phishguard.ai/v1',
    enableLogging: true,
    enableCertificatePinning: true,
    certificateFingerprints: ['SHA256_STAGING_FINGERPRINT'],
  );

  static const EnvConfig production = EnvConfig(
    environment: Environment.production,
    apiBaseUrl: 'https://api.phishguard.ai/v1',
    enableLogging: false,
    enableCertificatePinning: true,
    certificateFingerprints: [
      'SHA256_PRIMARY_FINGERPRINT',
      'SHA256_BACKUP_FINGERPRINT',
    ],
  );

  bool get isDevelopment => environment == Environment.development;
  bool get isProduction => environment == Environment.production;
  bool get isDemo => environment == Environment.demo;
}
