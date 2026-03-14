import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phishguard_ai/agents/report_classification/report_classification_agent.dart';
import 'package:phishguard_ai/core/di/agent_providers.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';

enum ReportSubmissionStatus { idle, classifying, submitting, submitted, error }

class ReportState {
  final ReportSubmissionStatus status;
  final ReportCategory? preClassification;
  final PhishingReport? submittedReport;
  final List<PhishingReport> userReports;
  final String? errorMessage;

  const ReportState({
    this.status = ReportSubmissionStatus.idle,
    this.preClassification,
    this.submittedReport,
    this.userReports = const [],
    this.errorMessage,
  });

  ReportState copyWith({
    ReportSubmissionStatus? status,
    ReportCategory? preClassification,
    PhishingReport? submittedReport,
    List<PhishingReport>? userReports,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      preClassification: preClassification ?? this.preClassification,
      submittedReport: submittedReport ?? this.submittedReport,
      userReports: userReports ?? this.userReports,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportClassificationAgent _agent;

  ReportNotifier(this._agent) : super(const ReportState());

  void preClassify(String content, {String? url}) {
    final category = _agent.preClassify(content, url: url);
    state = state.copyWith(
      status: ReportSubmissionStatus.classifying,
      preClassification: category,
    );
  }

  Future<void> submitReport({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  }) async {
    state = state.copyWith(status: ReportSubmissionStatus.submitting, errorMessage: null);

    final result = await _agent.submitReport(
      contentText: contentText,
      url: url,
      screenshot: screenshot,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: ReportSubmissionStatus.error,
        errorMessage: failure.message,
      ),
      (report) => state = state.copyWith(
        status: ReportSubmissionStatus.submitted,
        submittedReport: report,
      ),
    );
  }

  Future<void> loadUserReports() async {
    final result = await _agent.getUserReports();
    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (reports) => state = state.copyWith(userReports: reports),
    );
  }

  void reset() {
    state = const ReportState();
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.watch(reportClassificationAgentProvider));
});
