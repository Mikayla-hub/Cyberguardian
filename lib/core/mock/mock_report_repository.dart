import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';
import 'package:phishguard_ai/features/report/domain/repositories/report_repository.dart';

class MockReportRepository implements ReportRepository {
  final List<PhishingReport> _reports = [];

  ReportCategory _classify(String content, String? url) {
    final lower = content.toLowerCase();
    if (url != null && url.isNotEmpty) return ReportCategory.websiteSpoofing;
    if (lower.contains('sms') || lower.contains('text message') || lower.contains('whatsapp')) {
      return ReportCategory.smsPhishing;
    }
    if (lower.contains('call') || lower.contains('impersonat') || lower.contains('pretend')) {
      return ReportCategory.socialEngineering;
    }
    return ReportCategory.emailPhishing;
  }

  @override
  ResultFuture<PhishingReport> submitReport({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final category = _classify(contentText, url);
    final caseId = 'PG-2026-${(_reports.length + 1).toString().padLeft(4, '0')}';

    final report = PhishingReport(
      caseId: caseId,
      category: category,
      status: ReportStatus.submitted,
      contentText: contentText,
      url: url,
      aiConfidence: 0.87,
      aiExplanation: 'AI classified this report as ${category.name} based on content analysis. '
          'Key indicators include language patterns and submission context.',
      submittedAt: DateTime.now(),
    );

    _reports.insert(0, report);
    return Right(report);
  }

  @override
  ResultFuture<List<PhishingReport>> getUserReports() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Right(_reports);
  }

  @override
  ResultFuture<PhishingReport> getReportByCaseId(String caseId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final report = _reports.firstWhere((r) => r.caseId == caseId, orElse: () => _reports.first);
    return Right(report);
  }
}
