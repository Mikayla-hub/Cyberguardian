import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';

class SuspiciousElementModel extends SuspiciousElement {
  const SuspiciousElementModel({
    required super.element,
    required super.reason,
    required super.severity,
  });

  factory SuspiciousElementModel.fromJson(Map<String, dynamic> json) {
    return SuspiciousElementModel(
      element: json['element'] as String,
      reason: json['reason'] as String,
      severity: (json['severity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'element': element,
        'reason': reason,
        'severity': severity,
      };
}

class PhishingAnalysisModel extends PhishingAnalysis {
  const PhishingAnalysisModel({
    required super.id,
    required super.classification,
    required super.confidenceScore,
    required super.suspiciousElements,
    required super.explanation,
    required super.inputType,
    required super.inputContent,
    required super.analyzedAt,
  });

  factory PhishingAnalysisModel.fromJson(Map<String, dynamic> json) {
    return PhishingAnalysisModel(
      id: json['id'] as String,
      classification: ThreatClassification.values.firstWhere(
        (e) => e.name == json['classification'],
        orElse: () => ThreatClassification.suspicious,
      ),
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      suspiciousElements: (json['suspicious_elements'] as List<dynamic>?)
              ?.map((e) => SuspiciousElementModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      explanation: json['explanation'] as String,
      inputType: InputType.values.firstWhere(
        (e) => e.name == json['input_type'],
        orElse: () => InputType.email,
      ),
      inputContent: json['input_content'] as String? ?? '',
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'classification': classification.name,
        'confidence_score': confidenceScore,
        'suspicious_elements': suspiciousElements
            .map((e) => {
                  'element': e.element,
                  'reason': e.reason,
                  'severity': e.severity,
                })
            .toList(),
        'explanation': explanation,
        'input_type': inputType.name,
        'input_content': inputContent,
        'analyzed_at': analyzedAt.toIso8601String(),
      };
}
