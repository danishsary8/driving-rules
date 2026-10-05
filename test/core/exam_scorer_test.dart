/// Property-based tests for [ExamScorer.score].
///
/// Feature: driving-rules-app
///   - Property 9: Scoring counts correct answers and builds a consistent
///     breakdown
///   - Property 10: Pass/fail determination
///   - Property 11: Finish reason is preserved in the result
///
/// Each property runs at least 100 iterations with a seeded [Random] for
/// reproducibility.
library;

import 'dart:math';

import 'package:driving_rule/core/models/exam_result_model.dart';
import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/utils/exam_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/generators.dart';

/// Returns an option index that is NOT [correctIndex] (options are 0..2).
int _wrongOption(int correctIndex) => (correctIndex + 1) % 3;

void main() {
  group('ExamScorer.score properties', () {
    test(
      'Feature: driving-rules-app, Property 9: Scoring counts correct answers '
      'and builds a consistent breakdown',
      () {
        const seed = 5150;
        final rng = Random(seed);
        const iterations = 150;

        for (var iter = 0; iter < iterations; iter++) {
          final exam = ExamBuilder.buildExam(
            makeSufficientPools(rng),
            rng: Random(rng.nextInt(1 << 30)),
          );

          // Build a random partial answer map: correct / wrong / unanswered.
          final answers = <int, int>{};
          var expectedCorrect = 0;
          final expectedBreakdown = <Category, int>{
            for (final c in Category.values) c: 0,
          };

          for (var i = 0; i < exam.length; i++) {
            final roll = rng.nextInt(3); // 0 correct, 1 wrong, 2 unanswered
            final correctIndex = exam[i].correctIndex;
            if (roll == 0) {
              answers[i] = correctIndex;
              expectedCorrect++;
              final block = ExamScorer.blockOf(i);
              expectedBreakdown[block] = expectedBreakdown[block]! + 1;
            } else if (roll == 1) {
              answers[i] = _wrongOption(correctIndex);
            } // roll == 2 => leave unanswered
          }

          final result = ExamScorer.score(
            exam,
            answers,
            FinishReason.completed,
          );
          final reason = 'seed=$seed iteration=$iter';

          expect(
            result.totalCorrect,
            expectedCorrect,
            reason: 'totalCorrect mismatch: $reason',
          );
          expect(result.total, 45, reason: 'total != 45: $reason');
          expect(
            result.categoryBreakdown,
            expectedBreakdown,
            reason: 'breakdown mismatch: $reason',
          );

          // Sum of breakdown values equals totalCorrect.
          final sum = result.categoryBreakdown.values
              .fold<int>(0, (a, b) => a + b);
          expect(
            sum,
            result.totalCorrect,
            reason: 'breakdown sum != totalCorrect: $reason',
          );
        }
      },
    );

    test(
      'Feature: driving-rules-app, Property 10: Pass/fail determination',
      () {
        const seed = 3800;
        final rng = Random(seed);
        const iterations = 150;
        final reasons = FinishReason.values;

        // Helper: answer exactly [k] questions correctly, the rest wrong.
        Map<int, int> answerExactly(List<Question> exam, int k) {
          final answers = <int, int>{};
          for (var i = 0; i < exam.length; i++) {
            final ci = exam[i].correctIndex;
            answers[i] = i < k ? ci : _wrongOption(ci);
          }
          return answers;
        }

        for (var iter = 0; iter < iterations; iter++) {
          final exam = ExamBuilder.buildExam(
            makeSufficientPools(rng),
            rng: Random(rng.nextInt(1 << 30)),
          );
          final k = rng.nextInt(46); // target correct count 0..45
          final answers = answerExactly(exam, k);

          for (final reason in reasons) {
            final result = ExamScorer.score(exam, answers, reason);
            final ctx = 'seed=$seed iteration=$iter k=$k reason=$reason';

            // Sanity: we actually achieved k correct answers.
            expect(result.totalCorrect, k, reason: 'k not achieved: $ctx');

            final expectedPass =
                reason != FinishReason.priorityFail && k >= 38;
            expect(
              result.passed,
              expectedPass,
              reason: 'pass/fail determination wrong: $ctx',
            );
          }
        }

        // Explicit boundary checks: k=37 fails, k=38 passes (completed).
        final boundaryExam = ExamBuilder.buildExam(
          makeSufficientPools(rng),
          rng: Random(12345),
        );
        final at37 = ExamScorer.score(
          boundaryExam,
          answerExactly(boundaryExam, 37),
          FinishReason.completed,
        );
        expect(at37.passed, isFalse, reason: 'k=37 should fail');
        final at38 = ExamScorer.score(
          boundaryExam,
          answerExactly(boundaryExam, 38),
          FinishReason.completed,
        );
        expect(at38.passed, isTrue, reason: 'k=38 should pass');

        // priorityFail always fails even with a perfect score.
        final perfect = ExamScorer.score(
          boundaryExam,
          answerExactly(boundaryExam, 45),
          FinishReason.priorityFail,
        );
        expect(perfect.passed, isFalse, reason: 'priorityFail must fail');
      },
    );

    test(
      'Feature: driving-rules-app, Property 11: Finish reason is preserved in '
      'the result',
      () {
        const seed = 1101;
        final rng = Random(seed);
        const iterations = 150;
        final reasons = FinishReason.values;

        for (var iter = 0; iter < iterations; iter++) {
          final exam = ExamBuilder.buildExam(
            makeSufficientPools(rng),
            rng: Random(rng.nextInt(1 << 30)),
          );

          // Random partial answers (content does not affect reason preservation).
          final answers = <int, int>{};
          for (var i = 0; i < exam.length; i++) {
            if (rng.nextBool()) answers[i] = rng.nextInt(3);
          }

          // Iterate over every FinishReason each iteration.
          for (final reason in reasons) {
            final result = ExamScorer.score(exam, answers, reason);
            expect(
              result.finishReason,
              reason,
              reason: 'finishReason not preserved: seed=$seed iteration=$iter '
                  'reason=$reason',
            );
          }
        }
      },
    );
  });
}
