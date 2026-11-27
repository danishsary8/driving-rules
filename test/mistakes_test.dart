import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:driving_rule/core/models/exam_result_model.dart';
import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/services/data_service.dart';
import 'package:driving_rule/core/services/storage_service.dart';
import 'package:driving_rule/app/themes/theme_controller.dart';
import 'package:driving_rule/app/translations/app_translations.dart';
import 'package:driving_rule/modules/mistakes/mistakes_controller.dart';
import 'package:driving_rule/modules/mistakes/mistakes_screen.dart';
import 'package:driving_rule/modules/result/widgets/driver_certificate_dialog.dart';
import 'package:flutter/material.dart';

class _MockDataService extends DataService {
  final List<Question> mockList = [
    const Question(
      id: 'test-q-1',
      prompt: 'Prompt 1',
      options: ['A', 'B'],
      correctIndex: 0,
      category: Category.general,
    ),
    const Question(
      id: 'test-q-2',
      prompt: 'Prompt 2',
      options: ['A', 'B'],
      correctIndex: 1,
      category: Category.sign,
    ),
  ];

  @override
  Map<Category, List<Question>> get all => {
        Category.general: mockList,
      };

  @override
  List<Question> questionsFor(Category c) => mockList;
}

class _MockStorageService extends StorageService {
  final Set<String> _mistakes = {};

  @override
  Set<String> readMistakeIds() => Set.from(_mistakes);

  @override
  Future<void> addMistakeId(String id) async => _mistakes.add(id);

  @override
  Future<void> addMistakeIds(Iterable<String> ids) async => _mistakes.addAll(ids);

  @override
  Future<void> removeMistakeId(String id) async => _mistakes.remove(id);

  @override
  Future<void> clearAllMistakes() async => _mistakes.clear();

  @override
  int get mistakeCount => _mistakes.length;

  @override
  ThemeMode? readThemeMode() => ThemeMode.light;

  @override
  Locale? readLocale() => const Locale('en', 'US');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockDataService dataService;
  late _MockStorageService storageService;

  setUp(() {
    Get.reset();
    dataService = Get.put<_MockDataService>(_MockDataService());
    storageService = Get.put<_MockStorageService>(_MockStorageService());
    Get.put<DataService>(dataService);
    Get.put<StorageService>(storageService);
  });

  group('Mistakes Bank tests', () {
    test('MistakesController correctly loads matching questions', () async {
      await storageService.addMistakeId('test-q-1');

      final controller = MistakesController();
      controller.loadMistakes();

      expect(controller.questions.length, 1);
      expect(controller.questions.first.id, 'test-q-1');

      // Test remove mistake
      await controller.removeMistake('test-q-1');
      expect(controller.questions.isEmpty, isTrue);
      expect(storageService.mistakeCount, 0);
    });

    test('MistakesController clearAll clears all mistakes', () async {
      await storageService.addMistakeIds(['test-q-1', 'test-q-2']);
      expect(storageService.mistakeCount, 2);

      final controller = MistakesController();
      await controller.clearAll();

      expect(storageService.mistakeCount, 0);
      expect(controller.questions.isEmpty, isTrue);
    });
  });

  group('DriverCertificateDialog tests', () {
    testWidgets('DriverCertificateDialog renders pass credential details', (tester) async {
      const result = ExamResult(
        totalCorrect: 42,
        total: 45,
        passed: true,
        finishReason: FinishReason.completed,
        categoryBreakdown: {
          Category.general: 19,
          Category.sign: 9,
          Category.priority: 5,
          Category.technique: 5,
          Category.emergency: 4,
        },
      );

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: DriverCertificateDialog(result: result),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverCertificateDialog), findsOneWidget);
      expect(find.text('42 / 45'), findsOneWidget);
      expect(find.text('93%'), findsOneWidget);
    });
  });

  testWidgets('MistakesScreen renders a card for each saved mistake', (
    tester,
  ) async {
    // Regression: the card's question was typed `dynamic`, so the category
    // extension getters threw and every card rendered as a grey error box.
    Get.reset(); // drop the group setUp's services; this test brings its own
    Get.testMode = true;
    final storage = _MockStorageService();
    await storage.addMistakeIds(['test-q-1']);
    Get.put<StorageService>(storage);
    final data = _MockDataService()..status.value = DataStatus.ready;
    Get.put<DataService>(data);
    Get.put(ThemeController());
    Get.put(LocaleController());
    Get.put(MistakesController());

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const MistakesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Prompt 1'), findsOneWidget);
    expect(find.text('A'), findsOneWidget); // the correct answer is shown
    Get.reset();
  });
}
