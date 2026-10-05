import 'package:driving_rule/app/routes/app_pages.dart';
import 'package:driving_rule/app/routes/app_routes.dart';
import 'package:driving_rule/app/themes/app_theme.dart';
import 'package:driving_rule/app/themes/theme_controller.dart';
import 'package:driving_rule/app/translations/app_translations.dart';
import 'package:driving_rule/app/translations/en_us.dart';
import 'package:driving_rule/app/translations/km_kh.dart';
import 'package:driving_rule/core/models/exam_result_model.dart';
import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/services/data_service.dart';
import 'package:driving_rule/core/services/storage_service.dart';
import 'package:driving_rule/modules/exam/exam_controller.dart';
import 'package:driving_rule/modules/exam/widgets/answer_option.dart';
import 'package:driving_rule/modules/study/study_controller.dart';
import 'package:driving_rule/modules/study/widgets/lesson_card.dart';
import 'package:driving_rule/shared/widgets/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _MemoryStorage extends StorageService {
  _MemoryStorage(this.theme);
  ThemeMode theme;
  ExamResult? result;
  int best = 0;
  @override
  ThemeMode? readThemeMode() => theme;
  @override
  Future<void> writeThemeMode(ThemeMode mode) async {
    theme = mode;
  }

  @override
  Future<void> writeLocale(Locale locale) async {}
  @override
  ExamResult? readLastResult() => result;
  @override
  int get bestScore => best;
  @override
  Future<void> writeLastResult(ExamResult r) async {
    result = r;
  }

  @override
  Future<void> updateBestScore(int score) async {
    if (score > best) best = score;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final entry in {
      'Kanit': 'Kanit-Regular.ttf',
      'NotoSansKhmer': 'NotoSansKhmer-Variable.ttf',
    }.entries) {
      await (FontLoader(
        entry.key,
      )..addFont(rootBundle.load('assets/fonts/${entry.value}'))).load();
    }
  });
  tearDown(() async {
    Get.reset();
  });

  test('English and Khmer cover the same UI strings', () {
    expect(enUS.keys.toSet(), kmKH.keys.toSet());
  });

  test('Reading text has strong contrast in both themes', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      for (final pair in [
        (
          theme.colorScheme.onPrimaryContainer,
          theme.colorScheme.primaryContainer,
        ),
        (theme.textTheme.bodyLarge!.color!, theme.cardColor),
        (theme.textTheme.bodySmall!.color!, theme.scaffoldBackgroundColor),
      ]) {
        final a = pair.$1.computeLuminance();
        final b = pair.$2.computeLuminance();
        final ratio = (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
        expect(ratio, greaterThanOrEqualTo(4.5));
      }
    }
  });

  testWidgets('Lessons show only the indexed correct answer without choices', (
    tester,
  ) async {
    for (var correct = 0; correct < 3; correct++) {
      final question = Question(
        id: 'single-answer-$correct',
        prompt: 'How should you drive?',
        options: const [
          'ក- First answer',
          'ខ- Second answer',
          'គ- Third answer',
        ],
        correctIndex: correct,
        category: Category.general,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              child: LessonCard(question: question, number: 1),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SelectableText), findsOneWidget);
      expect(
        tester.widget<SelectableText>(find.byType(SelectableText)).data,
        ['First answer', 'Second answer', 'Third answer'][correct],
      );
      expect(find.byType(AnswerOption), findsNothing);
      for (var option = 0; option < 3; option++) {
        if (option != correct) {
          expect(find.text(question.options[option]), findsNothing);
        }
      }
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Reduced motion shows final content immediately', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const MotionEntrance(child: AnimatedNumber(value: 249)),
        ),
      ),
    );
    expect(find.text('249'), findsOneWidget);
    expect(find.byType(Opacity), findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
  });

  for (final variant in [
    (width: 320.0, locale: Locale('en', 'US'), theme: ThemeMode.light),
    (width: 390.0, locale: Locale('km', 'KH'), theme: ThemeMode.light),
    (width: 390.0, locale: Locale('en', 'US'), theme: ThemeMode.dark),
    (width: 768.0, locale: Locale('km', 'KH'), theme: ThemeMode.dark),
    (width: 844.0, locale: Locale('km', 'KH'), theme: ThemeMode.light),
    (width: 1050.0, locale: Locale('km', 'KH'), theme: ThemeMode.light),
    (width: 1280.0, locale: Locale('km', 'KH'), theme: ThemeMode.light),
    (width: 1440.0, locale: Locale('en', 'US'), theme: ThemeMode.light),
    (width: 1440.0, locale: Locale('en', 'US'), theme: ThemeMode.dark),
    (width: 1920.0, locale: Locale('en', 'US'), theme: ThemeMode.light),
  ]) {
    testWidgets(
      'Learning flow at ${variant.width}px, ${variant.locale}, ${variant.theme}',
      (tester) async {
        final height = switch (variant.width) {
          320 => 568.0,
          844 => 390.0,
          _ => 900.0,
        };
        tester.view.physicalSize = Size(variant.width, height);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue =
            variant.width == 390 && variant.locale.languageCode == 'km'
            ? 1.25
            : 1;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Get.testMode = true;
        Get.put<StorageService>(_MemoryStorage(variant.theme));
        final data = Get.put(DataService());
        await tester.runAsync(data.loadAllCategories);
        expect(data.status.value, DataStatus.ready);
        Get.put(ThemeController());
        Get.put(LocaleController());
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: AppRoutes.splash,
            getPages: AppPages.routes,
            translations: AppTranslations(),
            locale: variant.locale,
            fallbackLocale: const Locale('en', 'US'),
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: variant.theme,
          ),
        );
        await tester.pump(const Duration(milliseconds: 1000));
        expect(
          tester.getRect(find.byType(LinearProgressIndicator)).bottom,
          lessThan(tester.getRect(find.text('made_for_cambodia'.tr)).top),
          reason: 'Splash content must stay above the footer on short screens',
        );
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pumpAndSettle();
        expect(Get.currentRoute, AppRoutes.home);
        expect(tester.takeException(), isNull);

        final learn = find.text('start_learning'.tr);
        await tester.ensureVisible(learn);
        await tester.pumpAndSettle();
        await tester.tap(learn);
        await tester.pumpAndSettle();
        expect(Get.currentRoute, AppRoutes.study);
        expect(tester.takeException(), isNull);

        await _scrollToFirst(tester, find.text('study_correct_answer'.tr));
        expect(
          find.byType(AnswerOption),
          findsNothing,
          reason: 'Learning shows answers directly; choices belong to practice',
        );
        final lesson = tester.widget<LessonCard>(find.byType(LessonCard).first);
        final displayedAnswer = tester.widget<SelectableText>(
          find.descendant(
            of: find.byType(LessonCard).first,
            matching: find.byType(SelectableText),
          ),
        );
        expect(
          displayedAnswer.data,
          lesson.question.correctAnswer
              .replaceFirst(RegExp(r'^[កខគ]\s*[-–—]\s*'), '')
              .trim(),
        );

        final search = find.byType(TextField);
        await tester.scrollUntilVisible(
          search,
          -300,
          scrollable: _studyScrollable,
        );
        await tester.enterText(search, 'no-such-question-xyz');
        await tester.pumpAndSettle();
        expect(find.text('no_results'.tr), findsOneWidget);
        await tester.tap(find.byTooltip('clear_search'.tr));
        await tester.pumpAndSettle();
        expect(Get.find<StudyController>().searchTerm.value, isEmpty);
        Get.find<StudyController>().changeCategory(Category.sign);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        final artwork = find.text('study_zoom_image'.tr);
        await _scrollToFirst(tester, artwork);
        await tester.tap(artwork.first);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
        await tester.tap(find.byTooltip('zoom_in'.tr));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('close'.tr));
        await tester.pumpAndSettle();

        Get.toNamed(AppRoutes.exam);
        await tester.pumpAndSettle();
        final exam = Get.find<ExamController>();
        expect(exam.questions.length, 45);
        expect(tester.takeException(), isNull);
        final answer = find.byType(AnswerOption).first;
        await tester.ensureVisible(answer);
        await tester.pumpAndSettle();
        await tester.tap(answer);
        await tester.pumpAndSettle();
        expect(exam.answerFor(0), 0);
        await tester.tap(find.text('exam_next'.tr));
        await tester.pumpAndSettle();
        expect(exam.currentIndex.value, 1);
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('exam_leave'.tr));
        await tester.pumpAndSettle();
        expect(find.text('exam_leave_confirm_title'.tr), findsOneWidget);
        await tester.tap(find.text('exam_leave_no'.tr));
        await tester.pumpAndSettle();
        expect(Get.currentRoute, AppRoutes.exam);
        if (variant.width == 320 || variant.width == 1280) {
          for (var i = 0; i < exam.questions.length; i++) {
            exam.selectedAnswers[i] = exam.questions[i].correctIndex;
          }
        }
        exam.finishExam(FinishReason.completed);
        await tester.pumpAndSettle();
        expect(Get.currentRoute, AppRoutes.result);
        expect(tester.takeException(), isNull);

        final review = find.text('result_review_answers'.tr);
        await tester.ensureVisible(review);
        await tester.pumpAndSettle();
        await tester.tap(review);
        await tester.pumpAndSettle();
        expect(Get.currentRoute, AppRoutes.review);
        expect(tester.takeException(), isNull);
        await Get.find<ThemeController>().toggle();
        await tester.pumpAndSettle();
        final label = exam.answerFor(0) == exam.questions[0].correctIndex
            ? 'review_your_correct_answer'.tr
            : 'review_correct_answer'.tr;
        final answerLabel = tester.widget<Text>(find.text(label).first);
        expect(
          answerLabel.style?.color,
          AppColors.contentColor(
            AppColors.accentGreen,
            variant.theme == ThemeMode.light
                ? Brightness.dark
                : Brightness.light,
          ),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }
}

/// Lazy lists on short screens build their first question after scrolling.
Future<void> _scrollToFirst(WidgetTester tester, Finder target) async {
  final scrollable = _studyScrollable;
  for (var i = 0; i < 20 && target.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pumpAndSettle();
  }
  expect(target, findsWidgets);
  await tester.ensureVisible(target.first);
  await tester.pumpAndSettle();
}

Finder get _studyScrollable => find
    .descendant(
      of: find.byKey(const ValueKey('study-questions')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    )
    .first;
