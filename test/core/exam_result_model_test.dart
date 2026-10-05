/// Property-based test for [ExamResult] serialization.
///
/// Feature: driving-rules-app
///   - Property 14: ExamResult serialization round-trip
///
/// Runs at least 100 iterations with a seeded [Random] for reproducibility.
library;

import 'dart:math';

import 'package:driving_rule/core/models/exam_result_model.dart';
import 'package:driving_rule/core/models/question_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExamResult model properties', () {
    test(
      'Feature: driving-rules-app, Property 14: ExamResult serialization '
      'round-trip',
      () {
        const seed = 1914;
        final rng = Random(seed);
        const iterations = 200;
        final reasons = FinishReason.values;

        for (var i = 0; i < iterations; i++) {
          final totalCorrect = rng.nextInt(46); // 0..45

          // Random per-block correct counts within each block's max.
          final breakdown = <Category, int>{
            for (final entry in ExamResult.blockMax.entries)
              entry.key: rng.nextInt(entry.value + 1),
          };

          final result = ExamResult(
            totalCorrect: totalCorrect,
            total: 45,
            categoryBreakdown: breakdown,
            finishReason: reasons[rng.nextInt(reasons.length)],
            passed: rng.nextBool(),
          );

          final roundTripped = ExamResult.fromJson(result.toJson());
          final reason = 'seed=$seed iteration=$i original=$result '
              'json=${result.toJson()}';

          expect(
            roundTripped,
            result,
            reason: 'round-trip not equal: $reason',
          );
          // Equality implies equal hashCodes for use in collections.
          expect(
            roundTripped.hashCode,
            result.hashCode,
            reason: 'hashCode mismatch after round-trip: $reason',
          );
          // Spot-check individual scalar fields too.
          expect(roundTripped.totalCorrect, result.totalCorrect, reason: reason);
          expect(roundTripped.total, result.total, reason: reason);
          expect(roundTripped.finishReason, result.finishReason, reason: reason);
          expect(roundTripped.passed, result.passed, reason: reason);
          expect(
            roundTripped.categoryBreakdown,
            result.categoryBreakdown,
            reason: reason,
          );
        }
      },
    );
  });
}
