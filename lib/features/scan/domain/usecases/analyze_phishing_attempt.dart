import 'dart:typed_data';

import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';
import 'package:phishguard_ai/features/scan/domain/repositories/scan_repository.dart';

class AnalyzePhishingAttempt {
  final ScanRepository _repository;

  const AnalyzePhishingAttempt(this._repository);

  ResultFuture<PhishingAnalysis> callEmail(String emailContent) {
    return _repository.analyzeEmail(emailContent);
  }

  ResultFuture<PhishingAnalysis> callUrl(String url) {
    return _repository.analyzeUrl(url);
  }

  ResultFuture<PhishingAnalysis> callScreenshot(Uint8List imageData) {
    return _repository.analyzeScreenshot(imageData);
  }
}
