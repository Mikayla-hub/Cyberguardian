import 'package:equatable/equatable.dart';

enum ReportCategory { emailPhishing, websiteSpoofing, smsPhishing, socialEngineering }

enum ReportStatus { submitted, underReview, confirmed, dismissed }

class PhishingReport extends Equatable {
  final String caseId;
  final ReportCategory category;
  final ReportStatus status;
  final String contentText;
  final String? url;
  final String? screenshotPath;
  final double aiConfidence;
  final String aiExplanation;
  final DateTime submittedAt;
  final DateTime? resolvedAt;

  const PhishingReport({
    required this.caseId,
    required this.category,
    required this.status,
    required this.contentText,
    this.url,
    this.screenshotPath,
    required this.aiConfidence,
    required this.aiExplanation,
    required this.submittedAt,
    this.resolvedAt,
  });

  String get categoryLabel {
    switch (category) {
      case ReportCategory.emailPhishing:
        return 'Email Phishing';
      case ReportCategory.websiteSpoofing:
        return 'Website Spoofing';
      case ReportCategory.smsPhishing:
        return 'SMS Phishing';
      case ReportCategory.socialEngineering:
        return 'Social Engineering';
    }
  }

  String get statusLabel {
    switch (status) {
      case ReportStatus.submitted:
        return 'Submitted';
      case ReportStatus.underReview:
        return 'Under Review';
      case ReportStatus.confirmed:
        return 'Confirmed Threat';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  @override
  List<Object?> get props => [caseId, category, status, submittedAt];
}
