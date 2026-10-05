/// Property-based tests for [ExamBuilder.buildExam].
///
/// Feature: driving-rules-app
///   - Property 4: buildExam always produces a valid, well-composed exam
///   - Property 5: buildExam reports insufficient questions
///
/// Each property runs at least 100 iterations with a seeded [Random] for
/// reproducibility.
library;

import 'dart:math';

import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/utils/exam_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/generators.dart';

/// Expected originating category for each exam index (per the fixed
/// 45-question composition).
Category _expectedBlock(int index) {
  if ((index >= 0 && index <= 14) || (index >= 30 && index <= 34)) {
    return Category.general;
  }
  if (index >= 15 && index <= 24) return Category.sign;
  if (index >= 25 && index <= 29) return Category.priority;
  if (index >= 35 && index <= 39) return Category.technique;
  return Category.emergency; // 40..44
}

void main() {
  group('ExamBuilder.buildExam properties', () {
    test(
      'Feature: driving-rules-app, Property 4: buildExam always produces a '
      'valid, well-composed exam',
      () {
        const seed = 808;
        final rng = Random(seed);
        const iterations = 150;

        for (var iter = 0; iter < iterations; iter++) {
          final pools = makeSufficientPools(rng);
          // Use a per-iteration seeded Random for the builder so failures
          // remain reproducible.
          final examSeed = rng.nextInt(1 << 30);
          final exam = ExamBuilder.buildExam(pools, rng: Random(examSeed));
          final reason = 'seed=$seed iteration=$iter examSeed=$examSeed';

          // Exactly 45 questions.
          expect(exam.length, 45, reason: 'length != 45: $reason');

          // Each index originates from the expected category block.
          for (var i = 0; i < exam.length; i++) {
            expect(
              exam[i].category,
              _expectedBlock(i),
              reason: 'wrong category at index $i: $reason',
            );
            // Cross-check against the scorer's blockOf mapping.
            expect(
              ExamScorer.blockOf(i),
              _expectedBlock(i),
              reason: 'blockOf disagreed at index $i: $reason',
            );
          }

          // All 45 ids distinct (no duplicates anywhere, incl. 30-34 vs 0-14).
          final ids = exam.map((q) => q.id).toList();
          expect(
            ids.toSet().length,
            45,
            reason: 'duplicate question ids in exam: $reason ids=$ids',
          );

          // Explicitly: the General block at 30-34 does not repeat 0-14.
          final generalHead = exam.sublist(0, 15).map((q) => q.id).toSet();
          final generalTail = exam.sublist(30, 35).map((q) => q.id).toSet();
          expect(
            generalHead.intersection(generalTail),
            isEmpty,
            reason: 'General 30-34 repeats General 0-14: $reason',
          );
        }
      },
    );

    test(
      'Feature: driving-rules-app, Property 5: buildExam reports insufficient '
      'questions',
      () {
        const seed = 999;
        final rng = Random(seed);
        const iterations = 150;
        final categories = Category.values;

        for (var iter = 0; iter < iterations; iter++) {
          final pools = makeSufficientPools(rng);

          // Randomly pick at least one category to make deficient.
          final deficient = <Category>{};
          // Always shrink one chosen category below its required count.
          final primary = categories[rng.nextInt(categories.length)];
          deficient.add(primary);
          // Optionally shrink additional categories.
          for (final c in categories) {
            if (c != primary && rng.nextInt(4) == 0) deficient.add(c);
          }

          for (final c in deficient) {
            final required = kRequiredCounts[c]!;
            // Truncate to a length strictly less than required (0..required-1).
            final newLen = rng.nextInt(required); // 0..required-1
            pools[c] = pools[c]!.sublist(0, newLen);
          }

          final reason = 'seed=$seed iteration=$iter deficient=$deficient';

          expect(
            () => ExamBuilder.buildExam(pools, rng: Random(iter)),
            throwsA(
              predicate((e) {
                if (e is! InsufficientQuestionsException) return false;
                // The reported category must be one of the deficient ones.
                return deficient.contains(e.category);
              }),
            ),
            reason: 'expected InsufficientQuestionsException for a deficient '
                'category: $reason',
          );
        }
      },
    );
  });
}
