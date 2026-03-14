import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:phishguard_ai/core/constants/api_constants.dart';
import 'package:phishguard_ai/core/network/api_client.dart';
import 'package:phishguard_ai/features/scan/data/models/phishing_analysis_model.dart';

abstract class ScanRemoteDataSource {
  Future<PhishingAnalysisModel> analyzeEmail(String emailContent);
  Future<PhishingAnalysisModel> analyzeUrl(String url);
  Future<PhishingAnalysisModel> analyzeScreenshot(Uint8List imageData);
  Future<List<PhishingAnalysisModel>> getScanHistory();
}

class ScanRemoteDataSourceImpl implements ScanRemoteDataSource {
  final ApiClient _apiClient;

  ScanRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<PhishingAnalysisModel> analyzeEmail(String emailContent) async {
    final response = await _apiClient.post(
      ApiConstants.analyzeEndpoint,
      data: {'type': 'email', 'content': emailContent},
    );
    return PhishingAnalysisModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PhishingAnalysisModel> analyzeUrl(String url) async {
    final response = await _apiClient.post(
      ApiConstants.analyzeEndpoint,
      data: {'type': 'url', 'content': url},
    );
    return PhishingAnalysisModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PhishingAnalysisModel> analyzeScreenshot(Uint8List imageData) async {
    final formData = FormData.fromMap({
      'type': 'screenshot',
      'file': MultipartFile.fromBytes(imageData, filename: 'screenshot.png'),
    });
    final response = await _apiClient.postMultipart(
      ApiConstants.analyzeEndpoint,
      formData: formData,
    );
    return PhishingAnalysisModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<PhishingAnalysisModel>> getScanHistory() async {
    final response = await _apiClient.get('${ApiConstants.analyzeEndpoint}/history');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PhishingAnalysisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
