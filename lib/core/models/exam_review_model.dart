/// In-memory payload used to review a completed exam session.
///
/// [ExamReviewData] is passed through navigation after an exam finishes. It is
/// intentionally not persisted: GetStorage keeps only the compact [ExamResult],
/// while this payload carries the full question list and selected answers for
/// the immediate post-exam review screen.
library;

import 'exam_result_model.dart';
import 'question_model.dart';

/// Completed exam data needed by Result and Review screens.
class ExamReviewData {
  /// The scored exam result.
  final ExamResult result;

  /// The exact 45-question exam shown to the user, in order.
  final List<Question> questions;

  /// User answers by question index. Missing index means unanswered.
  final Map<int, int> selectedAnswers;

  /// Creates immutable review data for a completed exam.
  ExamReviewData({
    required this.result,
    required List<Question> questions,
    required Map<int, int> selectedAnswers,
  }) : questions = List.unmodifiable(questions),
       selectedAnswers = Map.unmodifiable(selectedAnswers);

  /// Whether this payload has the full data needed for question-by-question
  /// review.
  bool get canReview => questions.isNotEmpty;
}
