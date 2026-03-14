import 'package:phishguard_ai/core/constants/api_constants.dart';
import 'package:phishguard_ai/core/network/api_client.dart';
import 'package:phishguard_ai/features/learning/data/models/lesson_model.dart';
import 'package:phishguard_ai/features/learning/data/models/user_progress_model.dart';

abstract class LearningRemoteDataSource {
  Future<List<LessonModel>> getLessons();
  Future<LessonModel> getLessonById(String id);
  Future<UserProgressModel> getUserProgress();
  Future<UserProgressModel> completeLesson(String lessonId, int quizScore);
  Future<UserProgressModel> awardXp(int xpAmount);
  Future<List<LessonModel>> getRecommendedLessons(String userId);
}

class LearningRemoteDataSourceImpl implements LearningRemoteDataSource {
  final ApiClient _apiClient;

  LearningRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<List<LessonModel>> getLessons() async {
    final response = await _apiClient.get(ApiConstants.lessonsEndpoint);
    final list = response.data as List<dynamic>;
    return list.map((e) => LessonModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<LessonModel> getLessonById(String id) async {
    final response = await _apiClient.get('${ApiConstants.lessonsEndpoint}/$id');
    return LessonModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserProgressModel> getUserProgress() async {
    final response = await _apiClient.get(ApiConstants.progressEndpoint);
    return UserProgressModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserProgressModel> completeLesson(String lessonId, int quizScore) async {
    final response = await _apiClient.post(
      '${ApiConstants.lessonsEndpoint}/$lessonId/complete',
      data: {'quiz_score': quizScore},
    );
    return UserProgressModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserProgressModel> awardXp(int xpAmount) async {
    final response = await _apiClient.post(
      '${ApiConstants.progressEndpoint}/xp',
      data: {'amount': xpAmount},
    );
    return UserProgressModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<LessonModel>> getRecommendedLessons(String userId) async {
    final response = await _apiClient.get(
      '${ApiConstants.lessonsEndpoint}/recommended',
      queryParameters: {'user_id': userId},
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => LessonModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
