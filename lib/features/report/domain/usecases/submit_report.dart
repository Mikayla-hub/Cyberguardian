import 'dart:typed_data';

import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';
import 'package:phishguard_ai/features/report/domain/repositories/report_repository.dart';

class SubmitReport {
  final ReportRepository _repository;

  const SubmitReport(this._repository);

  ResultFuture<PhishingReport> call({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  }) {
    return _repository.submitReport(
      contentText: contentText,
      url: url,
      screenshot: screenshot,
    );
  }
}
