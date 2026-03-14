import 'package:phishguard_ai/core/constants/api_constants.dart';
import 'package:phishguard_ai/core/network/api_client.dart';
import 'package:phishguard_ai/features/incident/data/models/incident_response_model.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';

abstract class IncidentRemoteDataSource {
  Future<IncidentResponseModel> getIncidentResponse({
    required String incidentType,
    required UserRole userRole,
  });
  Future<IncidentResponseModel> updateStepCompletion({
    required String responseId,
    required String stepId,
    required bool isCompleted,
  });
  Future<List<EmergencyContactModel>> getEmergencyContacts();
}

class IncidentRemoteDataSourceImpl implements IncidentRemoteDataSource {
  final ApiClient _apiClient;

  IncidentRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<IncidentResponseModel> getIncidentResponse({
    required String incidentType,
    required UserRole userRole,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.incidentResponseEndpoint,
      queryParameters: {
        'incident_type': incidentType,
        'user_role': userRole.name,
      },
    );
    return IncidentResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<IncidentResponseModel> updateStepCompletion({
    required String responseId,
    required String stepId,
    required bool isCompleted,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.incidentResponseEndpoint}/$responseId/steps/$stepId',
      data: {'is_completed': isCompleted},
    );
    return IncidentResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<EmergencyContactModel>> getEmergencyContacts() async {
    final response = await _apiClient.get(
      '${ApiConstants.incidentResponseEndpoint}/emergency-contacts',
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => EmergencyContactModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
