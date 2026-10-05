/// Property-based test for [DataService.parseCategory] partitioning.
///
/// Feature: driving-rules-app
///   - Property 3: Parsing partitions valid and invalid questions
///
/// Runs at least 100 iterations with a seeded [Random] for reproducibility.
library;

import 'dart:math';

import 'package:driving_rule/core/models/question_model.dart';
import 'package:driving_rule/core/services/data_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/generators.dart';

void main() {
  group('DataService.parseCategory properties', () {
    test(
      'Feature: driving-rules-app, Property 3: Parsing partitions valid and '
      'invalid questions',
      () {
        const seed = 2024;
        final rng = Random(seed);
        const iterations = 200;

        for (var iter = 0; iter < iterations; iter++) {
          final category =
              Category.values[rng.nextInt(Category.values.length)];
          final total = rng.nextInt(20); // 0..19 entries

          final rawList = <Map<String, dynamic>>[];
          final expectedValidIds = <String>[];
          final expectedInvalidIds = <String>[];

          for (var n = 0; n < total; n++) {
            final id = 'q_${iter}_$n'; // unique within this list
            final makeValid = rng.nextBool();
            if (makeValid) {
              final answer = '${rng.nextInt(3)}'; // "0"|"1"|"2"
              rawList.add(makeRawJson(id: id, answer: answer, rng: rng));
              expectedValidIds.add(id);
            } else {
              rawList.add(makeRawJson(id: id, answer: invalidAnswer(rng), rng: rng));
              expectedInvalidIds.add(id);
            }
          }

          final result = DataService.parseCategory(rawList, category);
          final reason = 'seed=$seed iteration=$iter total=$total';

          // Returned questions correspond EXACTLY to valid-answer entries.
          final returnedIds = result.questions.map((q) => q.id).toList();
          expect(
            returnedIds,
            expectedValidIds,
            reason: 'valid questions mismatch: $reason',
          );
          expect(
            result.questions.length,
            expectedValidIds.length,
            reason: 'valid count mismatch: $reason',
          );

          // excludedIds equals EXACTLY the ids of invalid entries.
          expect(
            result.excludedIds,
            expectedInvalidIds,
            reason: 'excluded ids mismatch: $reason',
          );

          // No overlap between valid and excluded id sets.
          final validSet = returnedIds.toSet();
          final excludedSet = result.excludedIds.toSet();
          expect(
            validSet.intersection(excludedSet),
            isEmpty,
            reason: 'valid/excluded overlap: $reason',
          );

          // None lost: valid + excluded == all ids.
          final allIds = rawList.map((m) => m['id'] as String).toList()..sort();
          final combined = <String>[...returnedIds, ...result.excludedIds]..sort();
          expect(
            combined,
            allIds,
            reason: 'partition lost or duplicated ids: $reason',
          );

          // Every returned question carries the requested category.
          for (final q in result.questions) {
            expect(q.category, category, reason: 'category mismatch: $reason');
          }
        }
      },
    );
  });
}
