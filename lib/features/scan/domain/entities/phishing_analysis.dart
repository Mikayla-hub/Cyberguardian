import 'package:equatable/equatable.dart';

enum ThreatClassification { safe, suspicious, phishing }

enum InputType { email, url, screenshot }

class SuspiciousElement extends Equatable {
  final String element;
  final String reason;
  final double severity;

  const SuspiciousElement({
    required this.element,
    required this.reason,
    required this.severity,
  });

  @override
  List<Object?> get props => [element, reason, severity];
}

class PhishingAnalysis extends Equatable {
  final String id;
  final ThreatClassification classification;
  final double confidenceScore;
  final List<SuspiciousElement> suspiciousElements;
  final String explanation;
  final InputType inputType;
  final String inputContent;
  final DateTime analyzedAt;

  const PhishingAnalysis({
    required this.id,
    required this.classification,
    required this.confidenceScore,
    required this.suspiciousElements,
    required this.explanation,
    required this.inputType,
    required this.inputContent,
    required this.analyzedAt,
  });

  bool get isSafe => classification == ThreatClassification.safe;
  bool get isPhishing => classification == ThreatClassification.phishing;
  bool get isSuspicious => classification == ThreatClassification.suspicious;

  String get classificationLabel {
    switch (classification) {
      case ThreatClassification.safe:
        return 'Safe';
      case ThreatClassification.suspicious:
        return 'Suspicious';
      case ThreatClassification.phishing:
        return 'Phishing Detected';
    }
  }

  @override
  List<Object?> get props => [
        id, classification, confidenceScore, suspiciousElements,
        explanation, inputType, inputContent, analyzedAt,
      ];
}
