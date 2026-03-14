import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/retry_policy.dart';
import 'package:phishguard_ai/core/security/audit_logger.dart';
import 'package:phishguard_ai/core/utils/input_sanitizer.dart';
import 'package:phishguard_ai/core/utils/secure_logger.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';
import 'package:phishguard_ai/features/scan/domain/repositories/scan_repository.dart';

/// Agent responsible for analyzing potential phishing attempts.
///
/// Accepts email text, URLs, or screenshots and returns a structured
/// analysis including classification, confidence score, suspicious
/// elements, and human-readable explanation.
class PhishingDetectionAgent {
  final ScanRepository _scanRepository;
  final RetryPolicy _retryPolicy;
  final AuditLogger _auditLogger;

  static const String agentName = 'PhishingDetectionAgent';

  PhishingDetectionAgent({
    required ScanRepository scanRepository,
    required RetryPolicy retryPolicy,
    required AuditLogger auditLogger,
  })  : _scanRepository = scanRepository,
        _retryPolicy = retryPolicy,
        _auditLogger = auditLogger;

  /// Analyze email content for phishing indicators.
  ResultFuture<PhishingAnalysis> analyzeEmail(String emailContent) async {
    if (!InputSanitizer.isValidInput(emailContent)) {
      return const Left(ValidationFailure(message: 'Invalid email content provided'));
    }

    final sanitized = InputSanitizer.sanitizeText(emailContent);

    try {
      final result = await _retryPolicy.execute(
        () => _scanRepository.analyzeEmail(sanitized),
        operationName: '$agentName.analyzeEmail',
      );

      await _logAudit(result, InputType.email);
      return result;
    } catch (e) {
      SecureLogger.error('$agentName email analysis failed', e);
      return Left(AgentFailure(
        message: 'Email analysis failed: ${e.toString()}',
        agentName: agentName,
      ));
    }
  }

  /// Analyze a URL for phishing indicators.
  ResultFuture<PhishingAnalysis> analyzeUrl(String url) async {
    final sanitizedUrl = InputSanitizer.sanitizeUrl(url);
    if (sanitizedUrl.isEmpty) {
      return const Left(ValidationFailure(message: 'Invalid URL provided'));
    }

    try {
      final result = await _retryPolicy.execute(
        () => _scanRepository.analyzeUrl(sanitizedUrl),
        operationName: '$agentName.analyzeUrl',
      );

      await _logAudit(result, InputType.url);
      return result;
    } catch (e) {
      SecureLogger.error('$agentName URL analysis failed', e);
      return Left(AgentFailure(
        message: 'URL analysis failed: ${e.toString()}',
        agentName: agentName,
      ));
    }
  }

  /// Analyze a screenshot for phishing indicators.
  ResultFuture<PhishingAnalysis> analyzeScreenshot(Uint8List imageData) async {
    if (imageData.isEmpty) {
      return const Left(ValidationFailure(message: 'Empty image data provided'));
    }

    try {
      final result = await _retryPolicy.execute(
        () => _scanRepository.analyzeScreenshot(imageData),
        operationName: '$agentName.analyzeScreenshot',
      );

      await _logAudit(result, InputType.screenshot);
      return result;
    } catch (e) {
      SecureLogger.error('$agentName screenshot analysis failed', e);
      return Left(AgentFailure(
        message: 'Screenshot analysis failed: ${e.toString()}',
        agentName: agentName,
      ));
    }
  }

  Future<void> _logAudit(Either<Failure, PhishingAnalysis> result, InputType type) async {
    result.fold(
      (failure) => _auditLogger.log(AuditEntry(
        action: AuditAction.scanCompleted,
        description: 'Scan failed for $type: ${failure.message}',
      )),
      (analysis) => _auditLogger.log(AuditEntry(
        action: AuditAction.scanCompleted,
        description: 'Scan completed: ${analysis.classificationLabel} '
            '(${(analysis.confidenceScore * 100).toStringAsFixed(1)}%)',
        metadata: {
          'classification': analysis.classification.name,
          'confidence': analysis.confidenceScore,
          'inputType': type.name,
        },
      )),
    );
  }
}
