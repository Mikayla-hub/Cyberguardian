import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';

abstract class LearningRepository {
  ResultFuture<List<Lesson>> getLessons();
  ResultFuture<Lesson> getLessonById(String id);
  ResultFuture<UserProgress> getUserProgress();
  ResultFuture<UserProgress> completeLesson(String lessonId, int quizScore);
  ResultFuture<UserProgress> awardXp(int xpAmount);
  ResultFuture<List<Lesson>> getRecommendedLessons(String userId);
  ResultFuture<void> cacheLessonsLocally(List<Lesson> lessons);
  ResultFuture<List<Lesson>> getCachedLessons();
}
