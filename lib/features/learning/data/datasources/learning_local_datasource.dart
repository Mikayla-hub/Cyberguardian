import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:phishguard_ai/core/constants/app_constants.dart';
import 'package:phishguard_ai/core/errors/exceptions.dart';
import 'package:phishguard_ai/features/learning/data/models/lesson_model.dart';
import 'package:phishguard_ai/features/learning/data/models/user_progress_model.dart';

abstract class LearningLocalDataSource {
  Future<List<LessonModel>> getCachedLessons();
  Future<void> cacheLessons(List<LessonModel> lessons);
  Future<UserProgressModel?> getCachedProgress();
  Future<void> cacheProgress(UserProgressModel progress);
}

class LearningLocalDataSourceImpl implements LearningLocalDataSource {
  final Box<String> _box;

  LearningLocalDataSourceImpl({required Box<String> box}) : _box = box;

  @override
  Future<List<LessonModel>> getCachedLessons() async {
    final jsonString = _box.get(AppConstants.lessonsCacheKey);
    if (jsonString == null) {
      throw const CacheException(message: 'No cached lessons found');
    }
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((e) => LessonModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> cacheLessons(List<LessonModel> lessons) async {
    final jsonString = jsonEncode(lessons.map((e) => e.toJson()).toList());
    await _box.put(AppConstants.lessonsCacheKey, jsonString);
  }

  @override
  Future<UserProgressModel?> getCachedProgress() async {
    final jsonString = _box.get(AppConstants.progressCacheKey);
    if (jsonString == null) return null;
    return UserProgressModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheProgress(UserProgressModel progress) async {
    final jsonString = jsonEncode(progress.toJson());
    await _box.put(AppConstants.progressCacheKey, jsonString);
  }
}
