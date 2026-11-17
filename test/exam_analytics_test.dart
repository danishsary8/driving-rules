import 'package:flutter_test/flutter_test.dart';
import 'package:driving_rule/core/models/exam_analytics_model.dart';
import 'package:driving_rule/core/models/exam_result_model.dart';
import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/utils/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExamAnalytics Readiness Calculations', () {
    test('Empty history returns unrated readiness state', () {
      final readiness = ExamAnalytics.calculateReadiness(const []);
      expect(readiness.score, 0);
      expect(readiness.level, ReadinessLevel.unrated);
      expect(readiness.totalAttempts, 0);
      expect(readiness.passCount, 0);
      expect(readiness.passRate, 0.0);
      expect(readiness.hasRecentPriorityFailure, isFalse);
      expect(readiness.recommendationKey, 'readiness_unrated_tip');
    });

    test('Consistently passing exams with 100% priority yields ready tier', () {
      final passingResults = List.generate(
        5,
        (i) => const ExamResult(
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
        ),
      );

      final readiness = ExamAnalytics.calculateReadiness(passingResults);
      expect(readiness.score, greaterThanOrEqualTo(85));
      expect(readiness.level, ReadinessLevel.ready);
      expect(readiness.passCount, 5);
      expect(readiness.passRate, 1.0);
      expect(readiness.priorityAccuracy, 1.0);
      expect(readiness.hasRecentPriorityFailure, isFalse);
      expect(readiness.recommendationKey, 'readiness_ready_tip');
    });

    test('Recent priority failure triggers safety penalty and warning flag', () {
      final historyWithPriorityFail = [
        const ExamResult(
          totalCorrect: 40,
          total: 45,
          passed: true,
          finishReason: FinishReason.completed,
          categoryBreakdown: {
            Category.general: 18,
            Category.sign: 8,
            Category.priority: 5,
            Category.technique: 5,
            Category.emergency: 4,
          },
        ),
        const ExamResult(
          totalCorrect: 26,
          total: 45,
          passed: false,
          finishReason: FinishReason.priorityFail,
          categoryBreakdown: {
            Category.general: 18,
            Category.sign: 8,
            Category.priority: 0,
            Category.technique: 0,
            Category.emergency: 0,
          },
        ),
      ];

      final readiness = ExamAnalytics.calculateReadiness(historyWithPriorityFail);
      expect(readiness.hasRecentPriorityFailure, isTrue);
      expect(readiness.level, isNot(ReadinessLevel.ready));
    });

    test('Category mastery accurately computes accuracy and performance status', () {
      final history = [
        const ExamResult(
          totalCorrect: 40,
          total: 45,
          passed: true,
          finishReason: FinishReason.completed,
          categoryBreakdown: {
            Category.general: 20,
            Category.sign: 10,
            Category.priority: 5,
            Category.technique: 3,
            Category.emergency: 2,
          },
        ),
      ];

      final mastery = ExamAnalytics.calculateCategoryMastery(history);
      expect(mastery.length, 5);

      // General: 20/20 = 100%
      expect(mastery[Category.general]?.accuracy, 1.0);
      expect(mastery[Category.general]?.statusKey, 'mastery_strong');

      // Sign: 10/10 = 100%
      expect(mastery[Category.sign]?.accuracy, 1.0);
      expect(mastery[Category.sign]?.statusKey, 'mastery_strong');

      // Priority: 5/5 = 100%
      expect(mastery[Category.priority]?.accuracy, 1.0);
      expect(mastery[Category.priority]?.statusKey, 'mastery_strong');

      // Technique: 3/5 = 60%
      expect(mastery[Category.technique]?.accuracy, 0.6);
      expect(mastery[Category.technique]?.statusKey, 'mastery_moderate');

      // Emergency: 2/5 = 40%
      expect(mastery[Category.emergency]?.accuracy, 0.4);
      expect(mastery[Category.emergency]?.statusKey, 'mastery_weak');
    });
  });

  group('AppHaptics tactile feedback', () {
    test('AppHaptics methods execute without exceptions', () async {
      await expectLater(AppHaptics.selection(), completes);
      await expectLater(AppHaptics.light(), completes);
      await expectLater(AppHaptics.success(), completes);
      await expectLater(AppHaptics.warning(), completes);
      await expectLater(AppHaptics.error(), completes);
    });
  });
}
