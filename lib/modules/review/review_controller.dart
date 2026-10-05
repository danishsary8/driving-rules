/// Controller for the completed-exam answer review screen.
library;

import 'package:get/get.dart';

import '../../core/models/exam_result_model.dart';
import '../../core/models/exam_review_model.dart';
import '../../core/models/question_model.dart';

/// Read-only view model for reviewing each answer from a completed exam.
class ReviewController extends GetxController {
  /// Full completed-exam payload.
  late final ExamReviewData data;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    data = args is ExamReviewData
        ? args
        : ExamReviewData(
            result: const ExamResult(
              totalCorrect: 0,
              total: 45,
              categoryBreakdown: {},
              finishReason: FinishReason.completed,
              passed: false,
            ),
            questions: const [],
            selectedAnswers: const {},
          );
  }

  /// Questions in the original exam order.
  List<Question> get questions => data.questions;

  /// Number of questions answered correctly.
  int get correctCount => data.result.totalCorrect;

  /// Number of questions answered incorrectly or left unanswered.
  int get wrongCount => data.result.total - data.result.totalCorrect;

  /// Selected option for question [index], or null when unanswered.
  int? selectedAnswerFor(int index) => data.selectedAnswers[index];

  /// Whether question [index] was answered correctly.
  bool isCorrect(int index) {
    final selected = selectedAnswerFor(index);
    return selected != null && selected == questions[index].correctIndex;
  }

  /// Whether question [index] was left unanswered.
  bool isUnanswered(int index) => selectedAnswerFor(index) == null;
}
