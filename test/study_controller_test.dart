import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/services/data_service.dart';
import 'package:driving_rule/modules/study/study_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _LearningData extends DataService {
  @override
  List<Question> questionsFor(Category category) => switch (category) {
    Category.general => const [
      Question(
        id: 'turn',
        prompt: 'Turning safely',
        options: ['Accelerate', 'Give way', 'Stop suddenly'],
        correctIndex: 1,
        category: Category.general,
      ),
    ],
    Category.sign => const [
      Question(
        id: 'cafe',
        prompt: 'drink.png',
        options: ['Pottery shop', 'Cup factory', 'Café'],
        correctIndex: 2,
        category: Category.sign,
      ),
    ],
    _ => const [],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StudyController controller;
  setUp(() {
    Get.testMode = true;
    Get.put<DataService>(_LearningData());
    controller = Get.put(StudyController());
  });
  tearDown(Get.reset);

  test('Learning search matches prompts and correct answers only', () {
    controller.setSearch('  GIVE WAY  ');
    expect(controller.filtered.map((q) => q.id), ['turn']);
    controller.setSearch('turning');
    expect(controller.filtered.map((q) => q.id), ['turn']);
    controller.setSearch('Accelerate');
    expect(controller.filtered, isEmpty);
    controller.setSearch('  ');
    expect(controller.filtered.length, 1);
  });

  test('Image lessons exclude filenames and incorrect options from search', () {
    controller.setSearch('Turning');
    controller.changeCategory(Category.sign);
    expect(controller.searchTerm.value, isEmpty);
    controller.setSearch('CAFÉ');
    expect(controller.filtered.map((q) => q.id), ['cafe']);
    controller.setSearch('drink.png');
    expect(controller.filtered, isEmpty);
    controller.setSearch('Cup factory');
    expect(controller.filtered, isEmpty);
  });
}
