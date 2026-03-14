import 'dart:typed_data';

import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';

abstract class ScanRepository {
  ResultFuture<PhishingAnalysis> analyzeEmail(String emailContent);
  ResultFuture<PhishingAnalysis> analyzeUrl(String url);
  ResultFuture<PhishingAnalysis> analyzeScreenshot(Uint8List imageData);
  ResultFuture<List<PhishingAnalysis>> getScanHistory();
}
