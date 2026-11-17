import 'exam_result_model.dart';
import 'question_model.dart';

/// Performance tiers for official driving exam readiness.
enum ReadinessLevel {
  unrated,
  needsPractice,
  moderate,
  ready;

  String get labelKey {
    switch (this) {
      case ReadinessLevel.ready:
        return 'readiness_ready';
      case ReadinessLevel.moderate:
        return 'readiness_moderate';
      case ReadinessLevel.needsPractice:
        return 'readiness_practice';
      case ReadinessLevel.unrated:
        return 'readiness_unrated';
    }
  }
}

/// Comprehensive exam readiness score model computed from past exam simulations.
class ExamReadiness {
  /// Overall readiness score between 0 and 100.
  final int score;

  /// Qualitative readiness tier.
  final ReadinessLevel level;

  /// Total number of exam attempts analyzed.
  final int totalAttempts;

  /// Number of passing exam attempts.
  final int passCount;

  /// Ratio of passed attempts (0.0 to 1.0).
  final double passRate;

  /// Accuracy across the fatal Priority questions (0.0 to 1.0).
  final double priorityAccuracy;

  /// Localized recommendation string key.
  final String recommendationKey;

  /// Whether the most recent attempt suffered a priority failure.
  final bool hasRecentPriorityFailure;

  const ExamReadiness({
    required this.score,
    required this.level,
    required this.totalAttempts,
    required this.passCount,
    required this.passRate,
    required this.priorityAccuracy,
    required this.recommendationKey,
    required this.hasRecentPriorityFailure,
  });

  /// Unrated initial state before user takes any mock exams.
  factory ExamReadiness.unrated() => const ExamReadiness(
    score: 0,
    level: ReadinessLevel.unrated,
    totalAttempts: 0,
    passCount: 0,
    passRate: 0.0,
    priorityAccuracy: 0.0,
    recommendationKey: 'readiness_unrated_tip',
    hasRecentPriorityFailure: false,
  );
}

/// Category-specific mastery breakdown across past exams.
class CategoryMastery {
  final Category category;
  final int correct;
  final int total;
  final double accuracy;
  final String statusKey;

  const CategoryMastery({
    required this.category,
    required this.correct,
    required this.total,
    required this.accuracy,
    required this.statusKey,
  });
}

/// Analytical calculations for driver license exam preparation.
abstract final class ExamAnalytics {
  /// Calculates the 0-100 exam readiness score based on recent exam attempts.
  static ExamReadiness calculateReadiness(
    List<ExamResult> history, {
    int maxSample = 5,
  }) {
    if (history.isEmpty) {
      return ExamReadiness.unrated();
    }

    final sample = history.length > maxSample
        ? history.sublist(history.length - maxSample)
        : history;

    final passCount = sample.where((r) => r.passed).length;
    final passRate = passCount / sample.length;

    final totalCorrect = sample.fold<int>(0, (sum, r) => sum + r.totalCorrect);
    final totalQuestions = sample.fold<int>(0, (sum, r) => sum + r.total);
    final scoreRate = totalQuestions > 0 ? (totalCorrect / totalQuestions) : 0.0;

    final priorityCorrect = sample.fold<int>(
      0,
      (sum, r) => sum + (r.categoryBreakdown[Category.priority] ?? 0),
    );
    final priorityMaxPerExam = ExamResult.blockMax[Category.priority] ?? 5;
    final priorityTotal = sample.length * priorityMaxPerExam;
    final priorityAccuracy = priorityTotal > 0
        ? (priorityCorrect / priorityTotal).clamp(0.0, 1.0)
        : 0.0;

    final hasRecentPriorityFailure =
        sample.isNotEmpty && sample.last.finishReason == FinishReason.priorityFail;

    // Weighted score: 40% Pass Rate + 35% Score Accuracy + 25% Priority Accuracy
    double raw = (passRate * 40.0) + (scoreRate * 35.0) + (priorityAccuracy * 25.0);

    // Apply safety deduction if latest attempt was an instant priority failure
    if (hasRecentPriorityFailure) {
      raw = (raw - 15.0).clamp(0.0, 100.0);
    }

    final score = raw.round().clamp(0, 100);

    final ReadinessLevel level;
    final String recommendationKey;
    if (score >= 85) {
      level = ReadinessLevel.ready;
      recommendationKey = 'readiness_ready_tip';
    } else if (score >= 60) {
      level = ReadinessLevel.moderate;
      recommendationKey = 'readiness_moderate_tip';
    } else {
      level = ReadinessLevel.needsPractice;
      recommendationKey = 'readiness_practice_tip';
    }

    return ExamReadiness(
      score: score,
      level: level,
      totalAttempts: history.length,
      passCount: history.where((r) => r.passed).length,
      passRate: passRate,
      priorityAccuracy: priorityAccuracy,
      recommendationKey: recommendationKey,
      hasRecentPriorityFailure: hasRecentPriorityFailure,
    );
  }

  /// Calculates mastery breakdown for all 5 categories across historical exams.
  static Map<Category, CategoryMastery> calculateCategoryMastery(
    List<ExamResult> history,
  ) {
    final mastery = <Category, CategoryMastery>{};

    for (final category in Category.values) {
      final perExamMax = ExamResult.blockMax[category] ?? 5;
      final totalPossible = history.length * perExamMax;

      int totalCorrect = 0;
      for (final result in history) {
        totalCorrect += result.categoryBreakdown[category] ?? 0;
      }

      final double accuracy = totalPossible > 0
          ? (totalCorrect / totalPossible).clamp(0.0, 1.0)
          : 0.0;

      final String statusKey;
      if (accuracy >= 0.80) {
        statusKey = 'mastery_strong';
      } else if (accuracy >= 0.60) {
        statusKey = 'mastery_moderate';
      } else {
        statusKey = 'mastery_weak';
      }

      mastery[category] = CategoryMastery(
        category: category,
        correct: totalCorrect,
        total: totalPossible,
        accuracy: accuracy,
        statusKey: statusKey,
      );
    }

    return mastery;
  }
}
