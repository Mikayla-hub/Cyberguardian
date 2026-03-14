import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phishguard_ai/core/config/env_config.dart';
import 'package:phishguard_ai/core/di/feature_providers.dart';
import 'package:phishguard_ai/core/di/providers.dart';
import 'package:phishguard_ai/core/mock/mock_auth_repository.dart';
import 'package:phishguard_ai/core/mock/mock_incident_repository.dart';
import 'package:phishguard_ai/core/mock/mock_learning_repository.dart';
import 'package:phishguard_ai/core/mock/mock_report_repository.dart';
import 'package:phishguard_ai/core/mock/mock_scan_repository.dart';
import 'package:phishguard_ai/core/security/audit_logger.dart';
import 'package:phishguard_ai/core/theme/app_theme.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';
import 'package:phishguard_ai/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Backend is running — use development mode
  const config = EnvConfig.development;

  // Initialize secure logger
  SecureLogger.init(config);
  SecureLogger.info('PhishGuard AI starting...');

  // Initialize Hive for local caching
  await Hive.initFlutter();
  final cacheBox = await Hive.openBox<String>('phishguard_cache');

  // Initialize audit logger
  final auditLogger = AuditLogger();
  await auditLogger.init();

  // Screenshot blocking on Android
  if (Platform.isAndroid) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // Lock orientation for consistency
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        envConfigProvider.overrideWithValue(config),
        hiveCacheBoxProvider.overrideWithValue(cacheBox),
        auditLoggerProvider.overrideWithValue(auditLogger),
        // Mock repository overrides for demo mode
        if (config.useMockData) ...[
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
          scanRepositoryProvider.overrideWithValue(MockScanRepository()),
          learningRepositoryProvider.overrideWithValue(MockLearningRepository()),
          reportRepositoryProvider.overrideWithValue(MockReportRepository()),
          incidentRepositoryProvider.overrideWithValue(MockIncidentRepository()),
        ],
      ],
      child: const PhishGuardApp(),
    ),
  );
}

class PhishGuardApp extends ConsumerStatefulWidget {
  const PhishGuardApp({super.key});

  @override
  ConsumerState<PhishGuardApp> createState() => _PhishGuardAppState();
}

class _PhishGuardAppState extends ConsumerState<PhishGuardApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _performStartupChecks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check security on app resume
      _performStartupChecks();
    }
  }

  Future<void> _performStartupChecks() async {
    try {
      final securityService = ref.read(securityServiceProvider);
      await securityService.performSecurityCheck();
      await securityService.enableScreenshotBlocking();
    } catch (e) {
      SecureLogger.error('Startup security check failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PhishGuard AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
