import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';
import 'package:phishguard_ai/features/incident/domain/repositories/incident_repository.dart';

class GetIncidentResponse {
  final IncidentRepository _repository;

  const GetIncidentResponse(this._repository);

  ResultFuture<IncidentResponse> call({
    required String incidentType,
    required UserRole userRole,
  }) {
    return _repository.getIncidentResponse(
      incidentType: incidentType,
      userRole: userRole,
    );
  }
}
