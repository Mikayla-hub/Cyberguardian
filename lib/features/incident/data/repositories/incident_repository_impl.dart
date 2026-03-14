import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/network_info.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/incident/data/datasources/incident_remote_datasource.dart';
import 'package:phishguard_ai/features/incident/domain/entities/incident_response.dart';
import 'package:phishguard_ai/features/incident/domain/repositories/incident_repository.dart';

class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  IncidentRepositoryImpl({
    required IncidentRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  ResultFuture<IncidentResponse> getIncidentResponse({
    required String incidentType,
    required UserRole userRole,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remoteDataSource.getIncidentResponse(
        incidentType: incidentType,
        userRole: userRole,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<IncidentResponse> updateStepCompletion({
    required String responseId,
    required String stepId,
    required bool isCompleted,
  }) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remoteDataSource.updateStepCompletion(
        responseId: responseId,
        stepId: stepId,
        isCompleted: isCompleted,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<EmergencyContact>> getEmergencyContacts() async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final result = await _remoteDataSource.getEmergencyContacts();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
