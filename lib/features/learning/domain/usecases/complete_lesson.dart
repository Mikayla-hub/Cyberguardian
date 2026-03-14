import 'package:phishguard_ai/core/utils/typedefs.dart';
import 'package:phishguard_ai/features/learning/domain/entities/user_progress.dart';
import 'package:phishguard_ai/features/learning/domain/repositories/learning_repository.dart';

class CompleteLesson {
  final LearningRepository _repository;

  const CompleteLesson(this._repository);

  ResultFuture<UserProgress> call({required String lessonId, required int quizScore}) {
    return _repository.completeLesson(lessonId, quizScore);
  }
}
