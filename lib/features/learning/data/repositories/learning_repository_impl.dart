import 'package:dartz/dartz.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/core/errors/failures.dart';
import 'package:phishguard_ai/core/network/network_info.dart';
import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/learning/data/datasources/learning_local_datasource.dart';
import 'package:phishguard_ai/features/learning/data/datasources/learning_remote_datasource.dart';
import 'package:phishguard_ai/features/learning/data/models/lesson_model.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';
import 'package:phishguard_ai/features/learning/domain/repositories/learning_repository.dart';

class LearningRepositoryImpl implements LearningRepository {
  final LearningRemoteDataSource _remoteDataSource;
  final LearningLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  LearningRepositoryImpl({
    required LearningRemoteDataSource remoteDataSource,
    required LearningLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  ResultFuture<List<Lesson>> getLessons() async {
    if (await _networkInfo.isConnected) {
      try {
        final lessons = await _remoteDataSource.getLessons();
        await _localDataSource.cacheLessons(lessons);
        return Right(lessons);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      try {
        final cached = await _localDataSource.getCachedLessons();
        return Right(cached);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  ResultFuture<Lesson> getLessonById(String id) async {
    try {
      final lesson = await _remoteDataSource.getLessonById(id);
      return Right(lesson);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<UserProgress> getUserProgress() async {
    if (await _networkInfo.isConnected) {
      try {
        final progress = await _remoteDataSource.getUserProgress();
        await _localDataSource.cacheProgress(progress);
        return Right(progress);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
      }
    } else {
      final cached = await _localDataSource.getCachedProgress();
      if (cached != null) return Right(cached);
      return const Left(CacheFailure(message: 'No cached progress available'));
    }
  }

  @override
  ResultFuture<UserProgress> completeLesson(String lessonId, int quizScore) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final progress = await _remoteDataSource.completeLesson(lessonId, quizScore);
      await _localDataSource.cacheProgress(progress);
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<UserProgress> awardXp(int xpAmount) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final progress = await _remoteDataSource.awardXp(xpAmount);
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<List<Lesson>> getRecommendedLessons(String userId) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final lessons = await _remoteDataSource.getRecommendedLessons(userId);
      return Right(lessons);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<void> cacheLessonsLocally(List<Lesson> lessons) async {
    try {
      final models = lessons.map((l) => LessonModel(
            id: l.id,
            title: l.title,
            description: l.description,
            category: l.category,
            difficulty: l.difficulty,
            durationMinutes: l.durationMinutes,
            contents: l.contents,
            quiz: l.quiz,
            xpReward: l.xpReward,
            badgeId: l.badgeId,
          )).toList();
      await _localDataSource.cacheLessons(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  ResultFuture<List<Lesson>> getCachedLessons() async {
    try {
      final cached = await _localDataSource.getCachedLessons();
      return Right(cached);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
