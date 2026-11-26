import 'package:driving_rule/core/models/exam_result_model.dart';
import 'package:driving_rule/core/services/storage_service.dart';
import 'package:driving_rule/modules/result/result_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _NoSavedResult extends StorageService {
  @override
  ExamResult? readLastResult() => null;
}

ResultController _controllerFor(ExamResult result) {
  Get.routing.args = result;
  return ResultController()..onInit();
}

ExamResult _result(int correct, FinishReason reason) => ExamResult(
  totalCorrect: correct,
  total: 45,
  categoryBreakdown: const {},
  finishReason: reason,
  passed: reason != FinishReason.priorityFail && correct >= 38,
);

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<StorageService>(_NoSavedResult());
  });
  tearDown(() {
    Get.routing.args = null;
    Get.reset();
  });

  test('below the pass mark reports how many answers were missing', () {
    final c = _controllerFor(_result(30, FinishReason.completed));
    expect(c.passed, isFalse);
    expect(c.answersShortOfPass, ResultController.passMark - 30);
  });

  test('a pass is never short of the pass mark', () {
    final c = _controllerFor(_result(40, FinishReason.completed));
    expect(c.passed, isTrue);
    expect(c.answersShortOfPass, 0);
  });

  test('priority fail with a passing score is not "short"', () {
    final c = _controllerFor(_result(40, FinishReason.priorityFail));
    expect(c.passed, isFalse);
    expect(c.answersShortOfPass, 0);
    expect(c.failReasonKey, 'fail_reason_priority');
  });

  test('zero correct needs the full pass mark', () {
    final c = _controllerFor(_result(0, FinishReason.timeout));
    expect(c.answersShortOfPass, ResultController.passMark);
  });
}
