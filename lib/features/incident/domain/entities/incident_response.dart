import 'package:equatable/equatable.dart';

enum IncidentPhase { identification, containment, reporting, recovery, postIncidentReview }

enum UserRole { employee, admin, it }

enum RiskLevel { low, medium, high, critical }

class ResponseStep extends Equatable {
  final String id;
  final int order;
  final String title;
  final String description;
  final String actionRequired;
  final bool isCompleted;
  final Duration? estimatedDuration;
  final List<UserRole> applicableRoles;

  const ResponseStep({
    required this.id,
    required this.order,
    required this.title,
    required this.description,
    required this.actionRequired,
    this.isCompleted = false,
    this.estimatedDuration,
    required this.applicableRoles,
  });

  @override
  List<Object?> get props => [id, order, title, isCompleted];
}

class EmergencyContact extends Equatable {
  final String name;
  final String role;
  final String phone;
  final String email;

  const EmergencyContact({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [name, role, phone, email];
}

class IncidentResponse extends Equatable {
  final String id;
  final String incidentType;
  final RiskLevel riskLevel;
  final UserRole userRole;
  final Map<IncidentPhase, List<ResponseStep>> phases;
  final List<EmergencyContact> emergencyContacts;
  final bool requiresEscalation;
  final String? escalationReason;
  final DateTime generatedAt;

  const IncidentResponse({
    required this.id,
    required this.incidentType,
    required this.riskLevel,
    required this.userRole,
    required this.phases,
    required this.emergencyContacts,
    required this.requiresEscalation,
    this.escalationReason,
    required this.generatedAt,
  });

  List<ResponseStep> getStepsForPhase(IncidentPhase phase) {
    return phases[phase] ?? [];
  }

  int get totalSteps => phases.values.fold(0, (sum, steps) => sum + steps.length);
  int get completedSteps => phases.values.fold(
        0,
        (sum, steps) => sum + steps.where((s) => s.isCompleted).length,
      );
  double get completionPercentage =>
      totalSteps > 0 ? completedSteps / totalSteps : 0.0;

  String get phaseLabel {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
      case RiskLevel.critical:
        return 'Critical';
    }
  }

  @override
  List<Object?> get props => [id, incidentType, riskLevel, userRole];
}
