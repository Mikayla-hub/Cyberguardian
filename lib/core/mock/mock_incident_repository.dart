import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';
import 'package:phishguard_ai/features/incident/domain/repositories/incident_repository.dart';
import 'package:uuid/uuid.dart';

class MockIncidentRepository implements IncidentRepository {
  final _uuid = const Uuid();
  IncidentResponse? _current;

  @override
  ResultFuture<IncidentResponse> getIncidentResponse({
    required String incidentType,
    required UserRole userRole,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final riskLevel = (incidentType == 'emailPhishing' || incidentType == 'socialEngineering')
        ? RiskLevel.high
        : RiskLevel.medium;

    final requiresEscalation = riskLevel == RiskLevel.high && userRole == UserRole.employee;

    _current = IncidentResponse(
      id: _uuid.v4(),
      incidentType: incidentType,
      riskLevel: riskLevel,
      userRole: userRole,
      requiresEscalation: requiresEscalation,
      escalationReason: requiresEscalation
          ? 'High-risk incident reported by employee. Escalating to IT department for investigation.'
          : null,
      generatedAt: DateTime.now(),
      emergencyContacts: const [
        EmergencyContact(name: 'IT Security Team', role: 'Security Operations', phone: '+1-555-SEC-TEAM', email: 'security@company.com'),
        EmergencyContact(name: 'Help Desk', role: 'IT Support', phone: '+1-555-HELP-NOW', email: 'helpdesk@company.com'),
        EmergencyContact(name: 'CISO Office', role: 'Chief Information Security', phone: '+1-555-CISO-001', email: 'ciso@company.com'),
      ],
      phases: {
        IncidentPhase.identification: [
          ResponseStep(
            id: 's1', order: 1, title: 'Document the incident',
            description: 'Record exactly what happened, when, and what you interacted with.',
            actionRequired: 'Take screenshots and note the time, sender, and any links clicked.',
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's2', order: 2, title: 'Identify the attack type',
            description: 'Determine if this is email phishing, website spoofing, SMS phishing, or social engineering.',
            actionRequired: 'Use the PhishGuard AI scanner to classify the threat.',
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's3', order: 3, title: 'Assess data exposure',
            description: 'Determine what information may have been compromised.',
            actionRequired: 'List any credentials entered, links clicked, or files downloaded.',
            applicableRoles: UserRole.values,
          ),
        ],
        IncidentPhase.containment: [
          ResponseStep(
            id: 's4', order: 1, title: 'Change compromised passwords',
            description: 'Immediately change passwords for any accounts that may be affected.',
            actionRequired: 'Change passwords on the official website. Enable 2FA if not already active.',
            estimatedDuration: Duration(minutes: 10),
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's5', order: 2, title: 'Disconnect if needed',
            description: 'If malware may have been downloaded, disconnect from the network.',
            actionRequired: 'Disable WiFi/ethernet. Do not power off the device (preserves evidence).',
            estimatedDuration: Duration(minutes: 2),
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's6', order: 3, title: 'Block the sender',
            description: 'Block the phishing source to prevent further attempts.',
            actionRequired: 'Block the sender address and report as phishing in your email client.',
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's7', order: 4, title: 'Quarantine affected systems',
            description: 'Isolate any systems that may have been compromised.',
            actionRequired: 'Work with IT to quarantine devices and run security scans.',
            estimatedDuration: Duration(minutes: 30),
            applicableRoles: [UserRole.admin, UserRole.it],
          ),
        ],
        IncidentPhase.reporting: [
          ResponseStep(
            id: 's8', order: 1, title: 'Report to IT Security',
            description: 'Notify the IT security team about the incident.',
            actionRequired: 'Use the PhishGuard AI report button or email security@company.com.',
            estimatedDuration: Duration(minutes: 5),
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's9', order: 2, title: 'File formal incident report',
            description: 'Complete the organization\'s incident report form.',
            actionRequired: 'Document the full timeline, actions taken, and potential impact.',
            estimatedDuration: Duration(minutes: 15),
            applicableRoles: [UserRole.admin, UserRole.it],
          ),
        ],
        IncidentPhase.recovery: [
          ResponseStep(
            id: 's10', order: 1, title: 'Verify account security',
            description: 'Confirm that compromised accounts are now secured.',
            actionRequired: 'Check login history, revoke suspicious sessions, verify recovery email/phone.',
            estimatedDuration: Duration(minutes: 15),
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's11', order: 2, title: 'Scan for malware',
            description: 'Run a full security scan on affected devices.',
            actionRequired: 'Use approved antivirus/EDR solution for a complete system scan.',
            estimatedDuration: Duration(minutes: 30),
            applicableRoles: UserRole.values,
          ),
        ],
        IncidentPhase.postIncidentReview: [
          ResponseStep(
            id: 's12', order: 1, title: 'Complete a phishing awareness lesson',
            description: 'Reinforce your knowledge by completing a related training module.',
            actionRequired: 'Navigate to the Learning Hub and complete the recommended lesson.',
            estimatedDuration: Duration(minutes: 15),
            applicableRoles: UserRole.values,
          ),
          ResponseStep(
            id: 's13', order: 2, title: 'Review and update security policies',
            description: 'Assess whether security policies need updating based on this incident.',
            actionRequired: 'Schedule a review meeting and update documentation if needed.',
            estimatedDuration: Duration(minutes: 60),
            applicableRoles: [UserRole.admin, UserRole.it],
          ),
        ],
      },
    );

    return Right(_current!);
  }

  @override
  ResultFuture<IncidentResponse> updateStepCompletion({
    required String responseId,
    required String stepId,
    required bool isCompleted,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_current == null) {
      return const Left(ServerFailure(message: 'No active incident response'));
    }

    // Rebuild phases with updated step
    final updatedPhases = <IncidentPhase, List<ResponseStep>>{};
    for (final entry in _current!.phases.entries) {
      updatedPhases[entry.key] = entry.value.map((step) {
        if (step.id == stepId) {
          return ResponseStep(
            id: step.id,
            order: step.order,
            title: step.title,
            description: step.description,
            actionRequired: step.actionRequired,
            isCompleted: isCompleted,
            estimatedDuration: step.estimatedDuration,
            applicableRoles: step.applicableRoles,
          );
        }
        return step;
      }).toList();
    }

    _current = IncidentResponse(
      id: _current!.id,
      incidentType: _current!.incidentType,
      riskLevel: _current!.riskLevel,
      userRole: _current!.userRole,
      phases: updatedPhases,
      emergencyContacts: _current!.emergencyContacts,
      requiresEscalation: _current!.requiresEscalation,
      escalationReason: _current!.escalationReason,
      generatedAt: _current!.generatedAt,
    );

    return Right(_current!);
  }

  @override
  ResultFuture<List<EmergencyContact>> getEmergencyContacts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const Right([
      EmergencyContact(name: 'IT Security Team', role: 'Security Operations', phone: '+1-555-SEC-TEAM', email: 'security@company.com'),
      EmergencyContact(name: 'Help Desk', role: 'IT Support', phone: '+1-555-HELP-NOW', email: 'helpdesk@company.com'),
      EmergencyContact(name: 'CISO Office', role: 'Chief Information Security', phone: '+1-555-CISO-001', email: 'ciso@company.com'),
    ]);
  }
}
