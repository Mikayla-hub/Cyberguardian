import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';
import 'package:phishguard_ai/features/scan/domain/repositories/scan_repository.dart';

class GetScanHistory {
  final ScanRepository _repository;

  const GetScanHistory(this._repository);

  ResultFuture<List<PhishingAnalysis>> call() {
    return _repository.getScanHistory();
  }
}
