import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';
import 'package:phishguard_ai/features/report/domain/repositories/report_repository.dart';

class GetUserReports {
  final ReportRepository _repository;

  const GetUserReports(this._repository);

  ResultFuture<List<PhishingReport>> call() {
    return _repository.getUserReports();
  }
}
