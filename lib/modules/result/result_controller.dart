/// Controller backing the exam Result screen.
///
/// [ResultController] is created fresh by [ResultBinding] each time the result
/// route is opened. It reads the [ExamResult] handed over via `Get.arguments`
/// (with a defensive default when none is provided), and exposes the
/// pass/fail state, the bilingual fail-reason translation key, and the two
/// navigation actions wired to the screen's buttons (Req 12.1, 12.6, 12.7,
/// 12.8, 12.12, 12.13).
library;

import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/models/exam_result_model.dart';
import '../../core/models/exam_review_model.dart';

/// Reactive-free view-model for the result screen, scoped per route entry by
/// [ResultBinding].
class ResultController extends GetxController {
  /// The result being displayed. Populated from `Get.arguments` in [onInit],
  /// falling back to a safe empty result when no arguments were supplied.
  late final ExamResult result;

  /// Full question/answer review payload when the result came from a just
  /// completed exam. Null when Result is opened with only a stored summary.
  ExamReviewData? reviewData;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ExamReviewData) {
      reviewData = args;
      result = args.result;
      return;
    }
    result = args is ExamResult
        ? args
        : const ExamResult(
            totalCorrect: 0,
            total: 45,
            categoryBreakdown: {},
            finishReason: FinishReason.completed,
            passed: false,
          );
  }

  /// Whether the session is a pass (Req 12.2, 12.3).
  bool get passed => result.passed;

  /// The bilingual fail-reason translation key, or `null` when [passed].
  ///
  /// Maps the [FinishReason] to its message key (Req 12.6, 12.7, 12.8):
  /// priorityFail → `fail_reason_priority`, timeout → `fail_reason_timeout`,
  /// completed (but below threshold) → `fail_reason_below_38`.
  String? get failReasonKey {
    if (passed) return null;
    return switch (result.finishReason) {
      FinishReason.priorityFail => 'fail_reason_priority',
      FinishReason.timeout => 'fail_reason_timeout',
      FinishReason.completed => 'fail_reason_below_38',
    };
  }

  /// Starts a fresh exam, replacing the result screen (Req 12.12).
  void tryAgain() => Get.offNamed(AppRoutes.exam);

  /// Opens the question-by-question answer review when full review data exists.
  void reviewAnswers() {
    final data = reviewData;
    if (data == null || !data.canReview) return;
    Get.toNamed(AppRoutes.review, arguments: data);
  }

  /// Returns to Home, clearing the navigation stack (Req 12.13).
  void backToHome() => Get.offAllNamed(AppRoutes.home);
}
