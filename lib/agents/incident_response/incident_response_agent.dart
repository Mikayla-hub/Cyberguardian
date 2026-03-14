import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/retry_policy.dart';
import 'package:phishguard_ai/core/security/audit_logger.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';
import 'package:phishguard_ai/features/incident/domain/repositories/incident_repository.dart';

/// Agent responsible for providing incident response guidance.
///
/// Determines appropriate response steps based on phishing type and user role.
/// Provides step-by-step response plans dynamically, with escalation logic
/// for high-risk incidents.
class IncidentResponseAgent {
  final IncidentRepository _incidentRepository;
  final RetryPolicy _retryPolicy;
  final AuditLogger _auditLogger;

  static const String agentName = 'IncidentResponseAgent';

  IncidentResponseAgent({
    required IncidentRepository incidentRepository,
    required RetryPolicy retryPolicy,
    required AuditLogger auditLogger,
  })  : _incidentRepository = incidentRepository,
        _retryPolicy = retryPolicy,
        _auditLogger = auditLogger;

  /// Get the full incident response plan for a given incident type and user role.
  ResultFuture<IncidentResponse> getResponsePlan({
    required String incidentType,
    required UserRole userRole,
  }) async {
    try {
      final result = await _retryPolicy.execute(
        () => _incidentRepository.getIncidentResponse(
          incidentType: incidentType,
          userRole: userRole,
        ),
        operationName: '$agentName.getResponsePlan',
      );

      result.fold(
        (failure) => SecureLogger.error('$agentName failed: ${failure.message}'),
        (response) {
          _auditLogger.log(AuditEntry(
            action: AuditAction.incidentViewed,
            description: 'Incident response viewed: ${response.incidentType} '
                '(${response.phaseLabel})',
            metadata: {
              'incidentType': response.incidentType,
              'riskLevel': response.riskLevel.name,
              'userRole': response.userRole.name,
              'requiresEscalation': response.requiresEscalation,
            },
          ));
        },
      );

      return result;
    } catch (e) {
      SecureLogger.error('$agentName failed to get response plan', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Mark a response step as completed.
  ResultFuture<IncidentResponse> completeStep({
    required String responseId,
    required String stepId,
  }) async {
    try {
      return await _retryPolicy.execute(
        () => _incidentRepository.updateStepCompletion(
          responseId: responseId,
          stepId: stepId,
          isCompleted: true,
        ),
        operationName: '$agentName.completeStep',
      );
    } catch (e) {
      SecureLogger.error('$agentName failed to complete step', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Determine if the incident requires escalation.
  bool shouldEscalate(IncidentResponse response) {
    if (response.riskLevel == RiskLevel.critical) return true;
    if (response.riskLevel == RiskLevel.high &&
        response.userRole == UserRole.employee) {
      return true;
    }
    return false;
  }

  /// Get the appropriate escalation reason.
  String getEscalationReason(IncidentResponse response) {
    if (response.riskLevel == RiskLevel.critical) {
      return 'Critical risk level detected. Immediate IT security team involvement required.';
    }
    if (response.riskLevel == RiskLevel.high &&
        response.userRole == UserRole.employee) {
      return 'High-risk incident reported by employee. Escalating to IT department for investigation.';
    }
    return 'Standard escalation procedure.';
  }

  /// Get emergency contacts.
  ResultFuture<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      return await _retryPolicy.execute(
        () => _incidentRepository.getEmergencyContacts(),
        operationName: '$agentName.getEmergencyContacts',
      );
    } catch (e) {
      SecureLogger.error('$agentName failed to get emergency contacts', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Filter response steps by user role.
  List<ResponseStep> filterStepsForRole(
    List<ResponseStep> steps,
    UserRole role,
  ) {
    return steps
        .where((step) => step.applicableRoles.contains(role))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Get the next incomplete step in a phase.
  ResponseStep? getNextStep(IncidentResponse response, IncidentPhase phase) {
    final steps = response.getStepsForPhase(phase);
    try {
      return steps.firstWhere((step) => !step.isCompleted);
    } catch (_) {
      return null;
    }
  }
}
