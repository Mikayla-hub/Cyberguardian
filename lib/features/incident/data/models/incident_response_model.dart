import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';

class ResponseStepModel extends ResponseStep {
  const ResponseStepModel({
    required super.id,
    required super.order,
    required super.title,
    required super.description,
    required super.actionRequired,
    super.isCompleted,
    super.estimatedDuration,
    required super.applicableRoles,
  });

  factory ResponseStepModel.fromJson(Map<String, dynamic> json) {
    return ResponseStepModel(
      id: json['id'] as String,
      order: json['order'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      actionRequired: json['action_required'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      estimatedDuration: json['estimated_duration_minutes'] != null
          ? Duration(minutes: json['estimated_duration_minutes'] as int)
          : null,
      applicableRoles: (json['applicable_roles'] as List<dynamic>)
          .map((e) => UserRole.values.firstWhere((r) => r.name == e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order': order,
        'title': title,
        'description': description,
        'action_required': actionRequired,
        'is_completed': isCompleted,
        'estimated_duration_minutes': estimatedDuration?.inMinutes,
        'applicable_roles': applicableRoles.map((e) => e.name).toList(),
      };
}

class EmergencyContactModel extends EmergencyContact {
  const EmergencyContactModel({
    required super.name,
    required super.role,
    required super.phone,
    required super.email,
  });

  factory EmergencyContactModel.fromJson(Map<String, dynamic> json) {
    return EmergencyContactModel(
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
    );
  }
}

class IncidentResponseModel extends IncidentResponse {
  const IncidentResponseModel({
    required super.id,
    required super.incidentType,
    required super.riskLevel,
    required super.userRole,
    required super.phases,
    required super.emergencyContacts,
    required super.requiresEscalation,
    super.escalationReason,
    required super.generatedAt,
  });

  factory IncidentResponseModel.fromJson(Map<String, dynamic> json) {
    final phasesMap = <IncidentPhase, List<ResponseStep>>{};
    final phasesJson = json['phases'] as Map<String, dynamic>? ?? {};
    for (final entry in phasesJson.entries) {
      final phase = IncidentPhase.values.firstWhere((p) => p.name == entry.key);
      final steps = (entry.value as List<dynamic>)
          .map((e) => ResponseStepModel.fromJson(e as Map<String, dynamic>))
          .toList();
      phasesMap[phase] = steps;
    }

    return IncidentResponseModel(
      id: json['id'] as String,
      incidentType: json['incident_type'] as String,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['risk_level'],
        orElse: () => RiskLevel.medium,
      ),
      userRole: UserRole.values.firstWhere(
        (e) => e.name == json['user_role'],
        orElse: () => UserRole.employee,
      ),
      phases: phasesMap,
      emergencyContacts: (json['emergency_contacts'] as List<dynamic>?)
              ?.map((e) => EmergencyContactModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requiresEscalation: json['requires_escalation'] as bool? ?? false,
      escalationReason: json['escalation_reason'] as String?,
      generatedAt: DateTime.parse(json['generated_at'] as String),
    );
  }
}
