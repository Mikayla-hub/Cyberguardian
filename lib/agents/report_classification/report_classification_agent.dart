import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/retry_policy.dart';
import 'package:phishguard_ai/core/security/audit_logger.dart';
import 'package:phishguard_ai/core/utils/input_sanitizer.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';
import 'package:phishguard_ai/features/report/domain/repositories/report_repository.dart';

/// Agent responsible for classifying and submitting phishing reports.
///
/// Automatically categorises reports into: Email Phishing, Website Spoofing,
/// SMS Phishing, or Social Engineering. Generates Case IDs, logs incidents,
/// and submits securely to the backend.
class ReportClassificationAgent {
  final ReportRepository _reportRepository;
  final RetryPolicy _retryPolicy;
  final AuditLogger _auditLogger;

  static const String agentName = 'ReportClassificationAgent';

  ReportClassificationAgent({
    required ReportRepository reportRepository,
    required RetryPolicy retryPolicy,
    required AuditLogger auditLogger,
  })  : _reportRepository = reportRepository,
        _retryPolicy = retryPolicy,
        _auditLogger = auditLogger;

  /// Submit a phishing report with auto-classification.
  ResultFuture<PhishingReport> submitReport({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  }) async {
    if (!InputSanitizer.isValidInput(contentText)) {
      return const Left(ValidationFailure(message: 'Invalid report content'));
    }

    final sanitizedContent = InputSanitizer.sanitizeText(contentText);
    final sanitizedUrl = url != null ? InputSanitizer.sanitizeUrl(url) : null;

    try {
      final result = await _retryPolicy.execute(
        () => _reportRepository.submitReport(
          contentText: sanitizedContent,
          url: sanitizedUrl,
          screenshot: screenshot,
        ),
        operationName: '$agentName.submitReport',
      );

      result.fold(
        (failure) => _auditLogger.log(AuditEntry(
          action: AuditAction.reportSubmitted,
          description: 'Report submission failed: ${failure.message}',
        )),
        (report) => _auditLogger.log(AuditEntry(
          action: AuditAction.reportSubmitted,
          description: 'Report submitted: Case ${report.caseId} '
              'Category: ${report.categoryLabel}',
          metadata: {
            'caseId': report.caseId,
            'category': report.category.name,
            'aiConfidence': report.aiConfidence,
          },
        )),
      );

      return result;
    } catch (e) {
      SecureLogger.error('$agentName report submission failed', e);
      return Left(AgentFailure(
        message: 'Report submission failed: ${e.toString()}',
        agentName: agentName,
      ));
    }
  }

  /// Retrieve all reports for the current user.
  ResultFuture<List<PhishingReport>> getUserReports() async {
    try {
      return await _retryPolicy.execute(
        () => _reportRepository.getUserReports(),
        operationName: '$agentName.getUserReports',
      );
    } catch (e) {
      SecureLogger.error('$agentName failed to fetch reports', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Look up a specific report by Case ID.
  ResultFuture<PhishingReport> getReportByCaseId(String caseId) async {
    try {
      return await _retryPolicy.execute(
        () => _reportRepository.getReportByCaseId(caseId),
        operationName: '$agentName.getReportByCaseId',
      );
    } catch (e) {
      SecureLogger.error('$agentName failed to fetch report $caseId', e);
      return Left(AgentFailure(message: e.toString(), agentName: agentName));
    }
  }

  /// Pre-classify content locally before sending to backend.
  ReportCategory preClassify(String content, {String? url}) {
    final lowerContent = content.toLowerCase();

    if (url != null && url.isNotEmpty) {
      return ReportCategory.websiteSpoofing;
    }

    if (lowerContent.contains('sms') ||
        lowerContent.contains('text message') ||
        lowerContent.contains('whatsapp') ||
        RegExp(r'\+?\d{10,}').hasMatch(content)) {
      return ReportCategory.smsPhishing;
    }

    if (lowerContent.contains('call') ||
        lowerContent.contains('pretend') ||
        lowerContent.contains('impersonat') ||
        lowerContent.contains('social')) {
      return ReportCategory.socialEngineering;
    }

    return ReportCategory.emailPhishing;
  }
}
