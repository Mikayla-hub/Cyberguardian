import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/agents/incident_response/incident_response_agent.dart';
import 'package:phishguard_ai/core/di/agent_providers.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';

enum IncidentStatus { initial, loading, loaded, error }

class IncidentState {
  final IncidentStatus status;
  final IncidentResponse? response;
  final List<EmergencyContact> emergencyContacts;
  final IncidentPhase selectedPhase;
  final bool showEscalation;
  final String? errorMessage;

  const IncidentState({
    this.status = IncidentStatus.initial,
    this.response,
    this.emergencyContacts = const [],
    this.selectedPhase = IncidentPhase.identification,
    this.showEscalation = false,
    this.errorMessage,
  });

  IncidentState copyWith({
    IncidentStatus? status,
    IncidentResponse? response,
    List<EmergencyContact>? emergencyContacts,
    IncidentPhase? selectedPhase,
    bool? showEscalation,
    String? errorMessage,
  }) {
    return IncidentState(
      status: status ?? this.status,
      response: response ?? this.response,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      selectedPhase: selectedPhase ?? this.selectedPhase,
      showEscalation: showEscalation ?? this.showEscalation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class IncidentNotifier extends StateNotifier<IncidentState> {
  final IncidentResponseAgent _agent;

  IncidentNotifier(this._agent) : super(const IncidentState());

  Future<void> loadResponsePlan({
    required String incidentType,
    required UserRole userRole,
  }) async {
    state = state.copyWith(status: IncidentStatus.loading);

    final result = await _agent.getResponsePlan(
      incidentType: incidentType,
      userRole: userRole,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: IncidentStatus.error,
        errorMessage: failure.message,
      ),
      (response) {
        final shouldEscalate = _agent.shouldEscalate(response);
        state = state.copyWith(
          status: IncidentStatus.loaded,
          response: response,
          showEscalation: shouldEscalate,
        );
      },
    );

    // Load emergency contacts in parallel
    final contactsResult = await _agent.getEmergencyContacts();
    contactsResult.fold(
      (_) {},
      (contacts) => state = state.copyWith(emergencyContacts: contacts),
    );
  }

  Future<void> completeStep(String stepId) async {
    final response = state.response;
    if (response == null) return;

    final result = await _agent.completeStep(
      responseId: response.id,
      stepId: stepId,
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (updated) => state = state.copyWith(response: updated),
    );
  }

  void selectPhase(IncidentPhase phase) {
    state = state.copyWith(selectedPhase: phase);
  }
}

final incidentProvider = StateNotifierProvider<IncidentNotifier, IncidentState>((ref) {
  return IncidentNotifier(ref.watch(incidentResponseAgentProvider));
});
