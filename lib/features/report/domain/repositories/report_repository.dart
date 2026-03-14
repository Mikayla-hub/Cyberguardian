import 'dart:typed_data';

import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';

abstract class ReportRepository {
  ResultFuture<PhishingReport> submitReport({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  });
  ResultFuture<List<PhishingReport>> getUserReports();
  ResultFuture<PhishingReport> getReportByCaseId(String caseId);
}
