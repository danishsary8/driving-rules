/// Controller owning a single, timed exam session.
///
/// [ExamController] is created fresh by [ExamBinding] each time the exam route
/// is opened, so every entry is a brand-new session (Req 8.9, 10.6). In
/// `onInit` it builds the fixed 45-question exam via [ExamBuilder] and starts
/// the 45-minute countdown; if the pools are too small to compose a valid exam
/// it records the [InsufficientQuestionsException] in [buildError] instead of
/// crashing, so the screen can render an error state (Req 8.10).
///
/// It tracks recorded answers, the current question index, and the seconds
/// remaining, and owns finish handling: the priority auto-fail gate
/// (Req 9.6, 11.1, 11.2), last-question submission (Req 9.8), timeout
/// auto-submit (Req 10.3, 10.4), scoring + persistence, and navigation to the
/// result screen (Req 12.1, 19.1, 19.2).
library;

import 'dart:async';

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/models/exam_result_model.dart';
import '../../core/models/exam_review_model.dart';
import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/exam_builder.dart';

/// Reactive state + session logic for the exam screen, scoped per route entry
/// by [ExamBinding].
class ExamController extends GetxController {
  /// App-lifetime data service providing the loaded, validated question pools.
  final DataService data = Get.find();

  /// App-lifetime persistence for the last result and best score.
  final StorageService storage = Get.find();

  /// The composed 45-question exam (fixed composition; Req 8). Empty when the
  /// exam could not be built (see [buildError]).
  late final List<Question> questions;

  /// Recorded answers: question index → chosen option index (Req 9.3, 9.4).
  final selectedAnswers = <int, int>{}.obs;

  /// Index of the currently displayed question.
  final currentIndex = 0.obs;

  /// Seconds remaining in the 45-minute countdown (Req 10.1).
  final secondsLeft = 2700.obs;

  /// Records the build failure (too few questions) so the screen can show an
  /// error instead of crashing (Req 8.10). `null` when the exam built fine.
  final buildError = Rxn<InsufficientQuestionsException>();

  Timer? _ticker;
  bool _finished = false;

  /// Whether the exam failed to build and the screen should show an error.
  bool get hasBuildError => buildError.value != null;

  @override
  void onInit() {
    super.onInit();
    try {
      questions = ExamBuilder.buildExam(data.all);
      startTimer();
    } on InsufficientQuestionsException catch (e) {
      // Do not start the timer; the screen renders an error state (Req 8.10).
      questions = const [];
      buildError.value = e;
    }
  }

  /// The question currently displayed.
  Question get current => questions[currentIndex.value];

  /// The chosen option for question [i], or `null` when unanswered (Req 9.10).
  int? answerFor(int i) => selectedAnswers[i];

  /// Whether the current question is the first one.
  bool get isFirst => currentIndex.value == 0;

  /// Whether the current question is the last one.
  bool get isLast => currentIndex.value == questions.length - 1;

  /// Whether index [i] falls in the Priority block (25–29), which is subject to
  /// the hard auto-fail rule (Req 9.6, 11.1).
  bool isPriorityIndex(int i) => i >= 25 && i <= 29;

  /// `secondsLeft` formatted as `mm:ss` for the timer widget.
  String get formattedTime {
    final s = secondsLeft.value;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  /// Starts the 1 Hz countdown; auto-submits with [FinishReason.timeout] when
  /// it reaches zero (Req 10.1, 10.3, 10.4).
  void startTimer() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsLeft.value <= 0) {
        finishExam(FinishReason.timeout);
      } else {
        secondsLeft.value--;
      }
    });
  }

  /// Records (or replaces) the selected option for the current question
  /// (Req 9.3, 9.4).
  void selectAnswer(int optionIndex) =>
      selectedAnswers[currentIndex.value] = optionIndex;

  /// Forward navigation with the priority gate + last-question submission
  /// (Req 9.6, 9.7, 9.8, 11.1, 11.2).
  void goNext() {
    final i = currentIndex.value;
    if (isPriorityIndex(i)) {
      final ans = selectedAnswers[i];
      if (ans == null || ans != questions[i].correctIndex) {
        finishExam(FinishReason.priorityFail);
        return;
      }
    }
    if (isLast) {
      finishExam(FinishReason.completed);
      return;
    }
    currentIndex.value = i + 1;
  }

  /// Moves back one question, unless already at the first (Req 9.9).
  void goBack() {
    if (!isFirst) currentIndex.value -= 1;
  }

  /// Stops the timer, scores the session, persists the result + best score, and
  /// routes to the result screen. Idempotent: repeated calls are no-ops once a
  /// session has finished (Req 10.5, 11.x, 12.1, 19.1, 19.2).
  void finishExam(FinishReason reason) {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    final result = ExamScorer.score(questions, selectedAnswers, reason);
    // Fire-and-forget persistence: GetStorage writes complete promptly and
    // must not block navigation to the result screen.
    storage.writeLastResult(result);
    storage.updateBestScore(result.totalCorrect);
    Get.offNamed(
      AppRoutes.result,
      arguments: ExamReviewData(
        result: result,
        questions: questions,
        selectedAnswers: selectedAnswers,
      ),
    );
  }

  @override
  void onClose() {
    // Leaving the screen discards the in-progress session (Req 10.6).
    _ticker?.cancel();
    super.onClose();
  }
}
