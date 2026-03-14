import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/core/di/providers.dart';
import 'package:phishguard_ai/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:phishguard_ai/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:phishguard_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:phishguard_ai/features/auth/domain/usecases/register.dart';
import 'package:phishguard_ai/features/auth/domain/usecases/login.dart';
import 'package:phishguard_ai/features/auth/domain/usecases/logout.dart';
import 'package:phishguard_ai/features/incident/data/datasources/incident_remote_datasource.dart';
import 'package:phishguard_ai/features/incident/data/repositories/incident_repository_impl.dart';
import 'package:phishguard_ai/features/incident/domain/repositories/incident_repository.dart';
import 'package:phishguard_ai/features/incident/domain/usecases/get_incident_response.dart';
import 'package:phishguard_ai/features/learning/data/datasources/learning_local_datasource.dart';
import 'package:phishguard_ai/features/learning/data/datasources/learning_remote_datasource.dart';
import 'package:phishguard_ai/features/learning/data/repositories/learning_repository_impl.dart';
import 'package:phishguard_ai/features/learning/domain/repositories/learning_repository.dart';
import 'package:phishguard_ai/features/learning/domain/usecases/complete_lesson.dart';
import 'package:phishguard_ai/features/learning/domain/usecases/get_lessons.dart';
import 'package:phishguard_ai/features/learning/domain/usecases/get_recommended_lessons.dart';
import 'package:phishguard_ai/features/report/data/datasources/report_remote_datasource.dart';
import 'package:phishguard_ai/features/report/data/repositories/report_repository_impl.dart';
import 'package:phishguard_ai/features/report/domain/repositories/report_repository.dart';
import 'package:phishguard_ai/features/report/domain/usecases/get_user_reports.dart';
import 'package:phishguard_ai/features/report/domain/usecases/submit_report.dart';
import 'package:phishguard_ai/features/scan/data/datasources/scan_remote_datasource.dart';
import 'package:phishguard_ai/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:phishguard_ai/features/scan/domain/repositories/scan_repository.dart';
import 'package:phishguard_ai/features/scan/domain/usecases/analyze_phishing_attempt.dart';
import 'package:phishguard_ai/features/scan/domain/usecases/get_scan_history.dart';

// ─── Data Sources ────────────────────────────────────────────────

final scanRemoteDataSourceProvider = Provider<ScanRemoteDataSource>((ref) {
  return ScanRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final learningRemoteDataSourceProvider = Provider<LearningRemoteDataSource>((ref) {
  return LearningRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final learningLocalDataSourceProvider = Provider<LearningLocalDataSource>((ref) {
  return LearningLocalDataSourceImpl(box: ref.watch(hiveCacheBoxProvider));
});

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  return ReportRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final incidentRemoteDataSourceProvider = Provider<IncidentRemoteDataSource>((ref) {
  return IncidentRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

// ─── Repositories ────────────────────────────────────────────────

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepositoryImpl(
    remoteDataSource: ref.watch(scanRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  return LearningRepositoryImpl(
    remoteDataSource: ref.watch(learningRemoteDataSourceProvider),
    localDataSource: ref.watch(learningLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    remoteDataSource: ref.watch(reportRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final incidentRepositoryProvider = Provider<IncidentRepository>((ref) {
  return IncidentRepositoryImpl(
    remoteDataSource: ref.watch(incidentRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    securityService: ref.watch(securityServiceProvider),
  );
});

// ─── Use Cases ───────────────────────────────────────────────────

final analyzePhishingAttemptProvider = Provider<AnalyzePhishingAttempt>((ref) {
  return AnalyzePhishingAttempt(ref.watch(scanRepositoryProvider));
});

final getScanHistoryProvider = Provider<GetScanHistory>((ref) {
  return GetScanHistory(ref.watch(scanRepositoryProvider));
});

final getLessonsProvider = Provider<GetLessons>((ref) {
  return GetLessons(ref.watch(learningRepositoryProvider));
});

final completeLessonProvider = Provider<CompleteLesson>((ref) {
  return CompleteLesson(ref.watch(learningRepositoryProvider));
});

final getRecommendedLessonsProvider = Provider<GetRecommendedLessons>((ref) {
  return GetRecommendedLessons(ref.watch(learningRepositoryProvider));
});

final submitReportProvider = Provider<SubmitReport>((ref) {
  return SubmitReport(ref.watch(reportRepositoryProvider));
});

final getUserReportsProvider = Provider<GetUserReports>((ref) {
  return GetUserReports(ref.watch(reportRepositoryProvider));
});

final getIncidentResponseProvider = Provider<GetIncidentResponse>((ref) {
  return GetIncidentResponse(ref.watch(incidentRepositoryProvider));
});

final loginUseCaseProvider = Provider<Login>((ref) {
  return Login(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<Logout>((ref) {
  return Logout(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<Register>((ref) {
  return Register(ref.watch(authRepositoryProvider));
});
