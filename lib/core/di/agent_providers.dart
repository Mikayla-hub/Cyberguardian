import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/agents/incident_response/incident_response_agent.dart';
import 'package:phishguard_ai/agents/learning_personalisation/learning_personalisation_agent.dart';
import 'package:phishguard_ai/agents/phishing_detection/phishing_detection_agent.dart';
import 'package:phishguard_ai/agents/report_classification/report_classification_agent.dart';
import 'package:phishguard_ai/core/di/feature_providers.dart';
import 'package:phishguard_ai/core/di/providers.dart';

/// Riverpod providers for all AI agent services.
///
/// Each agent is injected with its domain repository, a retry policy,
/// and an audit logger. All agents are lazily instantiated and cached
/// for the lifetime of the ProviderContainer.

final phishingDetectionAgentProvider = Provider<PhishingDetectionAgent>((ref) {
  return PhishingDetectionAgent(
    scanRepository: ref.watch(scanRepositoryProvider),
    retryPolicy: ref.watch(retryPolicyProvider),
    auditLogger: ref.watch(auditLoggerProvider),
  );
});

final learningPersonalisationAgentProvider = Provider<LearningPersonalisationAgent>((ref) {
  return LearningPersonalisationAgent(
    learningRepository: ref.watch(learningRepositoryProvider),
    retryPolicy: ref.watch(retryPolicyProvider),
    auditLogger: ref.watch(auditLoggerProvider),
  );
});

final reportClassificationAgentProvider = Provider<ReportClassificationAgent>((ref) {
  return ReportClassificationAgent(
    reportRepository: ref.watch(reportRepositoryProvider),
    retryPolicy: ref.watch(retryPolicyProvider),
    auditLogger: ref.watch(auditLoggerProvider),
  );
});

final incidentResponseAgentProvider = Provider<IncidentResponseAgent>((ref) {
  return IncidentResponseAgent(
    incidentRepository: ref.watch(incidentRepositoryProvider),
    retryPolicy: ref.watch(retryPolicyProvider),
    auditLogger: ref.watch(auditLoggerProvider),
  );
});
