import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';

class PhishingReportModel extends PhishingReport {
  const PhishingReportModel({
    required super.caseId,
    required super.category,
    required super.status,
    required super.contentText,
    super.url,
    super.screenshotPath,
    required super.aiConfidence,
    required super.aiExplanation,
    required super.submittedAt,
    super.resolvedAt,
  });

  factory PhishingReportModel.fromJson(Map<String, dynamic> json) {
    return PhishingReportModel(
      caseId: json['case_id'] as String,
      category: ReportCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ReportCategory.emailPhishing,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.submitted,
      ),
      contentText: json['content_text'] as String,
      url: json['url'] as String?,
      screenshotPath: json['screenshot_path'] as String?,
      aiConfidence: (json['ai_confidence'] as num).toDouble(),
      aiExplanation: json['ai_explanation'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'case_id': caseId,
        'category': category.name,
        'status': status.name,
        'content_text': contentText,
        'url': url,
        'screenshot_path': screenshotPath,
        'ai_confidence': aiConfidence,
        'ai_explanation': aiExplanation,
        'submitted_at': submittedAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
      };
}
