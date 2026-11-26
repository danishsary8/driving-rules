// Opening the exam directly by URL (e.g. refreshing the page on /#/exam)
// creates the exam before the startup data load has finished. These tests pin
// down that the exam waits for the data instead of showing an error.
import 'package:driving_rule/core/services/data_service.dart';
import 'package:driving_rule/core/services/storage_service.dart';
import 'package:driving_rule/modules/exam/exam_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// In-memory storage: no ongoing session, no bookmarks.
class _FakeStorage extends StorageService {
  @override
  Set<String> readBookmarkIds() => <String>{};
  @override
  bool get hasOngoingExam => false;
  @override
  Future<void> saveOngoingExam({
    required List<String> questionIds,
    required int currentIndex,
    required int remainingSeconds,
    required Map<int, int> selectedAnswers,
  }) async {}
  @override
  Future<void> clearOngoingExam() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('concurrent loads share one in-flight load', () async {
    final data = DataService();
    final first = data.loadAllCategories();
    final second = data.loadAllCategories();
    expect(identical(first, second), isTrue);
    await first;
    expect(data.status.value, DataStatus.ready);
  });

  test('ensureLoaded loads when idle and is a no-op when ready', () async {
    final data = DataService();
    expect(data.status.value, DataStatus.idle);
    await data.ensureLoaded();
    expect(data.status.value, DataStatus.ready);
    final count = data.allQuestions.length;
    await data.ensureLoaded();
    expect(data.allQuestions.length, count);
  });

  test('exam opened before data is ready waits, then builds', () async {
    Get.put<StorageService>(_FakeStorage());
    final data = Get.put(DataService());
    expect(data.status.value, DataStatus.idle);

    final exam = Get.put(ExamController());
    expect(exam.isPreparing.value, isTrue);
    expect(exam.questions, isEmpty);
    expect(exam.hasBuildError, isFalse);

    await data.ensureLoaded();
    await Future<void>.delayed(Duration.zero);

    expect(exam.isPreparing.value, isFalse);
    expect(exam.questions.length, 45);
    expect(exam.hasBuildError, isFalse);
    Get.delete<ExamController>();
  });

  test('exam opened after data is ready builds synchronously', () async {
    Get.put<StorageService>(_FakeStorage());
    final data = Get.put(DataService());
    await data.ensureLoaded();

    final exam = Get.put(ExamController());
    expect(exam.isPreparing.value, isFalse);
    expect(exam.questions.length, 45);
    Get.delete<ExamController>();
  });
}
