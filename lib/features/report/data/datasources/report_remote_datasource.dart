import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:phishguard_ai/core/constants/api_constants.dart';
import 'package:phishguard_ai/core/network/api_client.dart';
import 'package:phishguard_ai/features/report/data/models/phishing_report_model.dart';

abstract class ReportRemoteDataSource {
  Future<PhishingReportModel> submitReport({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  });
  Future<List<PhishingReportModel>> getUserReports();
  Future<PhishingReportModel> getReportByCaseId(String caseId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiClient _apiClient;

  ReportRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<PhishingReportModel> submitReport({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  }) async {
    if (screenshot != null) {
      final formData = FormData.fromMap({
        'content_text': contentText,
        if (url != null) 'url': url,
        'screenshot': MultipartFile.fromBytes(screenshot, filename: 'report.png'),
      });
      final response = await _apiClient.postMultipart(
        ApiConstants.reportEndpoint,
        formData: formData,
      );
      return PhishingReportModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      final response = await _apiClient.post(
        ApiConstants.reportEndpoint,
        data: {
          'content_text': contentText,
          if (url != null) 'url': url,
        },
      );
      return PhishingReportModel.fromJson(response.data as Map<String, dynamic>);
    }
  }

  @override
  Future<List<PhishingReportModel>> getUserReports() async {
    final response = await _apiClient.get(ApiConstants.reportEndpoint);
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PhishingReportModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PhishingReportModel> getReportByCaseId(String caseId) async {
    final response = await _apiClient.get('${ApiConstants.reportEndpoint}/$caseId');
    return PhishingReportModel.fromJson(response.data as Map<String, dynamic>);
  }
}
