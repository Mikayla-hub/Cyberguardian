import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/agents/phishing_detection/phishing_detection_agent.dart';
import 'package:phishguard_ai/core/di/agent_providers.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';

enum ScanStatus { idle, scanning, completed, error }

class ScanState {
  final ScanStatus status;
  final PhishingAnalysis? result;
  final String? errorMessage;
  final List<PhishingAnalysis> history;

  const ScanState({
    this.status = ScanStatus.idle,
    this.result,
    this.errorMessage,
    this.history = const [],
  });

  ScanState copyWith({
    ScanStatus? status,
    PhishingAnalysis? result,
    String? errorMessage,
    List<PhishingAnalysis>? history,
  }) {
    return ScanState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      history: history ?? this.history,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final PhishingDetectionAgent _agent;

  ScanNotifier(this._agent) : super(const ScanState());

  Future<void> scanEmail(String content) async {
    state = state.copyWith(status: ScanStatus.scanning, errorMessage: null);
    final result = await _agent.analyzeEmail(content);
    result.fold(
      (failure) => state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: failure.message,
      ),
      (analysis) => state = state.copyWith(
        status: ScanStatus.completed,
        result: analysis,
        history: [analysis, ...state.history],
      ),
    );
  }

  Future<void> scanUrl(String url) async {
    state = state.copyWith(status: ScanStatus.scanning, errorMessage: null);
    final result = await _agent.analyzeUrl(url);
    result.fold(
      (failure) => state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: failure.message,
      ),
      (analysis) => state = state.copyWith(
        status: ScanStatus.completed,
        result: analysis,
        history: [analysis, ...state.history],
      ),
    );
  }

  Future<void> scanScreenshot(Uint8List imageData) async {
    state = state.copyWith(status: ScanStatus.scanning, errorMessage: null);
    final result = await _agent.analyzeScreenshot(imageData);
    result.fold(
      (failure) => state = state.copyWith(
        status: ScanStatus.error,
        errorMessage: failure.message,
      ),
      (analysis) => state = state.copyWith(
        status: ScanStatus.completed,
        result: analysis,
        history: [analysis, ...state.history],
      ),
    );
  }

  void reset() {
    state = const ScanState();
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  return ScanNotifier(ref.watch(phishingDetectionAgentProvider));
});
