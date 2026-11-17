import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/services/data_service.dart';
import 'package:driving_rule/core/services/storage_service.dart';
import 'package:driving_rule/modules/quiz_practice/quiz_practice_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _MockStorageService extends StorageService {
  final Set<String> _mistakes = {};
  @override
  Set<String> readMistakeIds() => Set.from(_mistakes);
  @override
  Future<void> addMistakeId(String id) async => _mistakes.add(id);
}

class _MockDataService extends DataService {
  @override
  List<Question> questionsFor(Category c) => List.generate(
        15,
        (i) => Question(
          id: 'mock-$i',
          prompt: 'Mock question $i',
          options: const ['Option 0', 'Option 1', 'Option 2'],
          correctIndex: 1,
          category: c,
        ),
      );

  @override
  Map<Category, List<Question>> get all => {
        Category.general: questionsFor(Category.general),
      };
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<DataService>(_MockDataService());
    Get.put<StorageService>(_MockStorageService());
  });

  tearDown(() {
    Get.reset();
  });

  test('QuizPracticeController initializes round with 10 questions and 3 lives', () {
    final controller = QuizPracticeController();
    controller.onInit();

    expect(controller.questions.length, 10);
    expect(controller.hearts.value, 3);
    expect(controller.score.value, 0);
    expect(controller.streak.value, 0);
    expect(controller.isGameOver.value, isFalse);
    expect(controller.isGameWon.value, isFalse);

    controller.onClose();
  });

  test('QuizPracticeController correct answer increments score and streak', () {
    final controller = QuizPracticeController();
    controller.onInit();

    // Option 1 is the correctIndex in our mock
    controller.submitAnswer(1);

    expect(controller.isCorrect.value, isTrue);
    expect(controller.isAnswerChecked.value, isTrue);
    expect(controller.streak.value, 1);
    expect(controller.score.value, greaterThan(100)); // base 100 + speed bonus
    expect(controller.hearts.value, 3);

    controller.onClose();
  });

  test('QuizPracticeController wrong answer decrements hearts and resets streak', () {
    final controller = QuizPracticeController();
    controller.onInit();

    // First give one correct answer
    controller.submitAnswer(1);
    expect(controller.streak.value, 1);

    // Advance to question 2
    controller.nextQuestion();

    // Choose wrong option 0
    controller.submitAnswer(0);

    expect(controller.isCorrect.value, isFalse);
    expect(controller.isAnswerChecked.value, isTrue);
    expect(controller.streak.value, 0);
    expect(controller.hearts.value, 2);

    // Lose remaining 2 hearts
    controller.nextQuestion();
    controller.submitAnswer(0);
    expect(controller.hearts.value, 1);

    controller.nextQuestion();
    controller.submitAnswer(0);
    expect(controller.hearts.value, 0);
    expect(controller.isGameOver.value, isTrue);

    controller.onClose();
  });
}
