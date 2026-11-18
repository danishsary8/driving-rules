import 'package:driving_rule/app/translations/app_translations.dart';
import 'package:driving_rule/modules/exam/widgets/exam_rules_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.clearTranslations();
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('km', 'KH');
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('ExamRulesDialog renders first slide and advances via carousel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool started = false;

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('km', 'KH'),
        translations: AppTranslations(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ExamRulesDialog.show(
                    context,
                    onStart: () => started = true,
                    isRevisit: false,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog and step counter render
    expect(find.byType(ExamRulesDialog), findsOneWidget);
    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.text('STRICT · ហាមខុសដាច់ខាត'), findsOneWidget);

    // Next button advances to slide 2
    final nextBtn = find.text('exam_next'.tr);
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(find.text('2 / 4'), findsOneWidget);
    expect(find.text('លក្ខខណ្ឌជាប់ជាស្ថាពរ'), findsOneWidget);

    // Advance to slide 3
    await tester.tap(find.text('exam_next'.tr));
    await tester.pumpAndSettle();
    expect(find.text('3 / 4'), findsOneWidget);

    // Advance to slide 4 (Final slide)
    await tester.tap(find.text('exam_next'.tr));
    await tester.pumpAndSettle();
    expect(find.text('4 / 4'), findsOneWidget);

    // On final slide, confirm start exam button is visible
    final confirmBtn = find.text('exam_rules_confirm'.tr);
    expect(confirmBtn, findsOneWidget);

    // Tap confirm -> dialog pops and onStart is triggered
    await tester.tap(confirmBtn);
    await tester.pumpAndSettle();

    expect(find.byType(ExamRulesDialog), findsNothing);
    expect(started, isTrue);
  });

  testWidgets('ExamRulesDialog direct start triggers onStart immediately', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 2.0, 780 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    bool started = false;

    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('km', 'KH'),
        translations: AppTranslations(),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ExamRulesDialog.show(
                    context,
                    onStart: () => started = true,
                    isRevisit: false,
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap skip button on slide 1
    final skipBtn = find.text('exam_rules_skip'.tr);
    expect(skipBtn, findsOneWidget);
    await tester.tap(skipBtn);
    await tester.pumpAndSettle();

    expect(find.byType(ExamRulesDialog), findsNothing);
    expect(started, isTrue);
  });
}
