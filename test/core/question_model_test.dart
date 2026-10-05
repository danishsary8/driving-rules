/// Property-based tests for the [Question] model.
///
/// Feature: driving-rules-app
///   - Property 1: Question parsing preserves all fields (including Khmer text)
///   - Property 2: Answer-value validity predicate
///
/// Each property runs at least 100 iterations with a seeded [Random] so any
/// failure is reproducible from the printed seed.
library;

import 'dart:math';

import 'package:driving_rule/core/models/question_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/generators.dart';

void main() {
  group('Question model properties', () {
    test(
      'Feature: driving-rules-app, Property 1: Question parsing preserves all '
      'fields (including Khmer text)',
      () {
        const seed = 42;
        final rng = Random(seed);
        const iterations = 200;

        for (var i = 0; i < iterations; i++) {
          // Pick a category (covers both text and image categories).
          final category = Category.values[rng.nextInt(Category.values.length)];
          final answerInt = rng.nextInt(3); // 0..2
          final raw = makeRawJson(
            id: 'id_$i',
            answer: '$answerInt',
            rng: rng,
          );

          final reason = 'seed=$seed iteration=$i raw=$raw';
          final q = Question.fromJson(raw, category);

          // id / prompt / options preserved verbatim (including unicode).
          expect(q.id, raw['id'], reason: 'id mismatch: $reason');
          expect(q.prompt, raw['question'], reason: 'prompt mismatch: $reason');
          expect(
            q.options,
            <String>[raw['0'] as String, raw['1'] as String, raw['2'] as String],
            reason: 'options mismatch: $reason',
          );
          // correctIndex == int.parse(answer).
          expect(
            q.correctIndex,
            int.parse(raw['answer'] as String),
            reason: 'correctIndex mismatch: $reason',
          );
          // Category set correctly.
          expect(q.category, category, reason: 'category mismatch: $reason');

          // Verify unicode is preserved byte-for-byte by comparing runes.
          expect(
            q.prompt.runes.toList(),
            (raw['question'] as String).runes.toList(),
            reason: 'unicode prompt not preserved: $reason',
          );
        }
      },
    );

    test(
      'Feature: driving-rules-app, Property 2: Answer-value validity predicate',
      () {
        const seed = 7;
        final rng = Random(seed);
        const iterations = 300;
        const valid = <String>{'0', '1', '2'};

        // Candidate pool mixes valid values with a variety of invalid ones.
        final candidates = <String>[
          '0',
          '1',
          '2',
          '3',
          '4',
          '-1',
          '',
          ' ',
          '00',
          '01',
          'x',
          'abc',
          '10',
          '1.0',
          ' 1',
          '1 ',
        ];

        for (var i = 0; i < iterations; i++) {
          final s = candidates[rng.nextInt(candidates.length)];
          final reason = 'seed=$seed iteration=$i value="$s"';
          expect(
            Question.isValidAnswer(s),
            valid.contains(s),
            reason: 'isValidAnswer disagreed with membership: $reason',
          );
        }

        // Explicit anchors for the exact accepted set.
        expect(Question.isValidAnswer('0'), isTrue);
        expect(Question.isValidAnswer('1'), isTrue);
        expect(Question.isValidAnswer('2'), isTrue);
        expect(Question.isValidAnswer('3'), isFalse);
        expect(Question.isValidAnswer(''), isFalse);
        expect(Question.isValidAnswer(null), isFalse);
      },
    );
  });
}
