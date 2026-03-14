import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/network_info.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/scan/data/datasources/scan_remote_datasource.dart';
import 'package:phishguard_ai/features/scan/domain/entities/phishing_analysis.dart';
import 'package:phishguard_ai/features/scan/domain/repositories/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ScanRepositoryImpl({
    required ScanRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  ResultFuture<PhishingAnalysis> analyzeEmail(String emailContent) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await _remoteDataSource.analyzeEmail(emailContent);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  ResultFuture<PhishingAnalysis> analyzeUrl(String url) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await _remoteDataSource.analyzeUrl(url);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  ResultFuture<PhishingAnalysis> analyzeScreenshot(Uint8List imageData) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await _remoteDataSource.analyzeScreenshot(imageData);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  ResultFuture<List<PhishingAnalysis>> getScanHistory() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await _remoteDataSource.getScanHistory();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
