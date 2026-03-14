import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/network_info.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/report/data/datasources/report_remote_datasource.dart';
import 'package:phishguard_ai/features/report/domain/entities/phishing_report.dart';
import 'package:phishguard_ai/features/report/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ReportRepositoryImpl({
    required ReportRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  ResultFuture<PhishingReport> submitReport({
    required String contentText,
    String? url,
    Uint8List? screenshot,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remoteDataSource.submitReport(
        contentText: contentText,
        url: url,
        screenshot: screenshot,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<PhishingReport>> getUserReports() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remoteDataSource.getUserReports();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<PhishingReport> getReportByCaseId(String caseId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remoteDataSource.getReportByCaseId(caseId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
