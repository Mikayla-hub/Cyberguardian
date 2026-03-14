import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/repositories/learning_repository.dart';

class GetRecommendedLessons {
  final LearningRepository _repository;

  const GetRecommendedLessons(this._repository);

  ResultFuture<List<Lesson>> call(String userId) {
    return _repository.getRecommendedLessons(userId);
  }
}
