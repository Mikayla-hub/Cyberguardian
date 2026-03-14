import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/learning/domain/entities/lesson.dart';
import 'package:phishguard_ai/features/learning/domain/repositories/learning_repository.dart';

class GetLessons {
  final LearningRepository _repository;

  const GetLessons(this._repository);

  ResultFuture<List<Lesson>> call() {
    return _repository.getLessons();
  }
}
