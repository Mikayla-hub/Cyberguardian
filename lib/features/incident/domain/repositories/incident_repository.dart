import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';

abstract class IncidentRepository {
  ResultFuture<IncidentResponse> getIncidentResponse({
    required String incidentType,
    required UserRole userRole,
  });
  ResultFuture<IncidentResponse> updateStepCompletion({
    required String responseId,
    required String stepId,
    required bool isCompleted,
  });
  ResultFuture<List<EmergencyContact>> getEmergencyContacts();
}
