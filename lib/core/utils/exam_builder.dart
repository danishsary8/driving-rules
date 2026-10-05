/// Pure exam-engine logic: composition ([ExamBuilder.buildExam]) and scoring
/// ([ExamScorer.score]).
///
/// Both classes are intentionally free of any Flutter/GetX dependency and are
/// deterministic given an injected [Random], which is what makes the
/// correctness-critical exam logic directly unit- and property-testable.
///
/// ### Exam composition (the 45-question layout)
///
/// | Indices | Count | Category  | Notes                               |
/// |---------|-------|-----------|-------------------------------------|
/// | 0–14    | 15    | General   | random, unique                      |
/// | 15–24   | 10    | Sign      | random, unique                      |
/// | 25–29   | 5     | Priority  | Priority block (hard auto-fail)     |
/// | 30–34   | 5     | General   | disjoint from the General at 0–14   |
/// | 35–39   | 5     | Technique | random, unique                      |
/// | 40–44   | 5     | Emergency | random, unique                      |
///
/// Across the whole exam: General 20, Sign 10, Priority 5, Technique 5,
/// Emergency 5 = 45.
library;

import 'dart:math';

import '../models/exam_result_model.dart';
import '../models/question_model.dart';

/// Thrown by [ExamBuilder.buildExam] when a category pool does not contain
/// enough unique questions to satisfy the exam composition.
class InsufficientQuestionsException implements Exception {
  /// The category whose pool was too small.
  final Category category;

  /// The number of unique questions the composition requires for [category].
  final int required;

  /// The number of questions actually available in the pool for [category].
  final int available;

  const InsufficientQuestionsException(
    this.category,
    this.required,
    this.available,
  );

  @override
  String toString() =>
      'InsufficientQuestionsException: ${category.name} requires $required '
      'unique question(s) but only $available available.';
}

/// Builds a fresh, well-composed 45-question exam from category pools.
class ExamBuilder {
  /// Required unique counts that must be drawn *without repetition* from each
  /// pool. General needs 20 unique (15 at indices 0–14 plus 5 at 30–34); the
  /// other categories need their single-block count.
  static const Map<Category, int> _required = {
    Category.general: 20,
    Category.sign: 10,
    Category.priority: 5,
    Category.technique: 5,
    Category.emergency: 5,
  };

  /// Builds a fresh 45-question exam following the exam composition.
  ///
  /// [rng] is injectable for deterministic tests; defaults to [Random].
  ///
  /// Throws [InsufficientQuestionsException] if any category pool has fewer
  /// than its required unique count.
  static List<Question> buildExam(
    Map<Category, List<Question>> pools, {
    Random? rng,
  }) {
    final r = rng ?? Random();

    // Guard: every category must have enough unique questions.
    _required.forEach((cat, need) {
      final have = pools[cat]?.length ?? 0;
      if (have < need) {
        throw InsufficientQuestionsException(cat, need, have);
      }
    });

    // Draw unique samples per category.
    final general = _sample(
      pools[Category.general]!,
      20,
      r,
    ); // 15 + 5, no repeats
    final sign = _sample(pools[Category.sign]!, 10, r);
    final priority = _sample(pools[Category.priority]!, 5, r);
    final technique = _sample(pools[Category.technique]!, 5, r);
    final emergency = _sample(pools[Category.emergency]!, 5, r);

    // Assemble in fixed positional order.
    return <Question>[
      ...general.sublist(0, 15), // 0–14
      ...sign, // 15–24
      ...priority, // 25–29
      ...general.sublist(15, 20), // 30–34 (disjoint from 0–14 by construction)
      ...technique, // 35–39
      ...emergency, // 40–44
    ];
  }

  /// Returns [n] distinct elements drawn uniformly without replacement.
  static List<Question> _sample(List<Question> pool, int n, Random r) {
    final copy = List<Question>.of(pool)..shuffle(r);
    return copy.sublist(0, n);
  }
}

/// Scores a completed (or terminated) exam and computes its per-block
/// category breakdown.
class ExamScorer {
  /// Maps an exam index (0..44) to the originating category block used for the
  /// breakdown. General spans both {0–14} and {30–34}.
  static Category blockOf(int index) {
    if ((index >= 0 && index <= 14) || (index >= 30 && index <= 34)) {
      return Category.general;
    }
    if (index >= 15 && index <= 24) return Category.sign;
    if (index >= 25 && index <= 29) return Category.priority;
    if (index >= 35 && index <= 39) return Category.technique;
    return Category.emergency; // 40..44
  }

  /// Scores [questions] against the recorded [answers] (question index → chosen
  /// option), producing an [ExamResult].
  ///
  /// Unanswered questions count as incorrect. When [reason] is
  /// [FinishReason.priorityFail] the breakdown is still computed (so the UI can
  /// display it) but `passed` is forced `false` regardless of the score.
  static ExamResult score(
    List<Question> questions,
    Map<int, int> answers,
    FinishReason reason,
  ) {
    final breakdown = <Category, int>{
      Category.general: 0,
      Category.sign: 0,
      Category.priority: 0,
      Category.technique: 0,
      Category.emergency: 0,
    };
    var totalCorrect = 0;

    for (var i = 0; i < questions.length; i++) {
      final chosen = answers[i]; // null => unanswered => incorrect
      if (chosen != null && chosen == questions[i].correctIndex) {
        totalCorrect++;
        final block = blockOf(i);
        breakdown[block] = breakdown[block]! + 1;
      }
    }

    final passed = reason != FinishReason.priorityFail && totalCorrect >= 38;
    return ExamResult(
      totalCorrect: totalCorrect,
      total: 45,
      categoryBreakdown: breakdown,
      finishReason: reason,
      passed: passed,
    );
  }
}
