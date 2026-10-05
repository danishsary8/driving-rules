/// Result model for a completed (or terminated) exam session, plus the
/// [FinishReason] enum describing how the session ended.
///
/// [ExamResult] is a value type: equality compares all scoring-relevant fields
/// (including a deep comparison of [categoryBreakdown]) so that serialization
/// round-trips and best-score comparisons behave correctly.
library;

import 'question_model.dart';

/// How an exam session ended.
///
/// - [completed]: the user answered through the final question (scored against
///   the pass threshold).
/// - [timeout]: the countdown timer reached zero before completion.
/// - [priorityFail]: a Priority-block question was answered incorrectly (or
///   left unanswered when advancing), triggering the hard auto-fail rule.
enum FinishReason { completed, timeout, priorityFail }

/// The outcome of one exam session.
class ExamResult {
  /// Number of questions answered correctly across the whole exam.
  final int totalCorrect;

  /// Total number of questions in the exam (always 45 for the standard exam).
  final int total;

  /// Correct-answer count per category block.
  final Map<Category, int> categoryBreakdown;

  /// How the exam session finished.
  final FinishReason finishReason;

  /// Whether the session is a pass.
  final bool passed;

  const ExamResult({
    required this.totalCorrect,
    this.total = 45,
    required this.categoryBreakdown,
    required this.finishReason,
    required this.passed,
  });

  /// Maximum correct answers per block, used as UI denominators:
  /// general 20, sign 10, priority 5, technique 5, emergency 5.
  static const Map<Category, int> blockMax = {
    Category.general: 20,
    Category.sign: 10,
    Category.priority: 5,
    Category.technique: 5,
    Category.emergency: 5,
  };

  /// Serializes this result to a JSON-compatible map for persistence.
  ///
  /// [finishReason] is stored by its enum `name`. [categoryBreakdown] is stored
  /// with each [Category]'s `name` as the string key, e.g.
  /// `{'general': 12, 'sign': 8, ...}`.
  Map<String, dynamic> toJson() => {
    'totalCorrect': totalCorrect,
    'total': total,
    'finishReason': finishReason.name,
    'passed': passed,
    'categoryBreakdown': {
      for (final entry in categoryBreakdown.entries)
        entry.key.name: entry.value,
    },
  };

  /// Rebuilds an [ExamResult] from a map produced by [toJson].
  ///
  /// Robust to missing keys: numeric fields default to `0`/`45`, [passed]
  /// defaults to `false`, [finishReason] defaults to [FinishReason.completed],
  /// and unknown breakdown keys are skipped.
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    final breakdownRaw = json['categoryBreakdown'];
    final breakdown = <Category, int>{};
    if (breakdownRaw is Map) {
      breakdownRaw.forEach((key, value) {
        final category = _categoryByName(key);
        if (category != null) {
          breakdown[category] = (value as num?)?.toInt() ?? 0;
        }
      });
    }

    return ExamResult(
      totalCorrect: (json['totalCorrect'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 45,
      categoryBreakdown: breakdown,
      finishReason: _finishReasonByName(json['finishReason']),
      passed: json['passed'] as bool? ?? false,
    );
  }

  /// Parses a [FinishReason] from its enum `name`, defaulting to
  /// [FinishReason.completed] when missing or unrecognized.
  static FinishReason _finishReasonByName(Object? name) {
    return FinishReason.values.firstWhere(
      (r) => r.name == name,
      orElse: () => FinishReason.completed,
    );
  }

  /// Parses a [Category] from its enum `name`, returning `null` when missing or
  /// unrecognized so the caller can skip the entry.
  static Category? _categoryByName(Object? name) {
    for (final c in Category.values) {
      if (c.name == name) return c;
    }
    return null;
  }

  /// Deep equality for two `Map<Category, int>` values: same length and every
  /// key maps to the same value.
  static bool _mapEquals(Map<Category, int> a, Map<Category, int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamResult &&
          other.totalCorrect == totalCorrect &&
          other.total == total &&
          other.finishReason == finishReason &&
          other.passed == passed &&
          _mapEquals(other.categoryBreakdown, categoryBreakdown);

  @override
  int get hashCode {
    // Combine field hashes with an order-independent breakdown hash so equal
    // maps (regardless of entry order) produce equal hash codes.
    var breakdownHash = 0;
    for (final entry in categoryBreakdown.entries) {
      breakdownHash ^= Object.hash(entry.key, entry.value);
    }
    return Object.hash(
      totalCorrect,
      total,
      finishReason,
      passed,
      breakdownHash,
    );
  }

  @override
  String toString() =>
      'ExamResult(totalCorrect: $totalCorrect, total: $total, '
      'finishReason: $finishReason, passed: $passed, '
      'categoryBreakdown: $categoryBreakdown)';
}
