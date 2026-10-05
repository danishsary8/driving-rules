/// Shared, pure-Dart test data generators for the driving-rules-app property
/// tests.
///
/// These helpers build random [Question]s, category pools, and raw JSON maps
/// using an injectable [Random] so that property tests are fully reproducible
/// from a fixed seed. Option/prompt strings deliberately mix Khmer/unicode and
/// latin tokens so that parsing- and search-related properties are meaningful.
library;

import 'dart:math';

import 'package:driving_rule/core/models/question_model.dart';

/// Khmer (unicode) tokens used to populate option/prompt text.
const List<String> kKhmerWords = <String>[
  'សញ្ញា', // sign
  'ចរាចរណ៍', // traffic
  'ហាមឃាត់', // forbidden
  'ល្បឿន', // speed
  'គ្រោះថ្នាក់', // danger
  'អនុញ្ញាត', // allowed
  'បត់ឆ្វេង', // turn left
  'បត់ស្ដាំ', // turn right
];

/// Latin tokens used to populate option/prompt text.
const List<String> kLatinWords = <String>[
  'stop',
  'yield',
  'speed',
  'turn',
  'lane',
  'signal',
  'road',
  'brake',
];

/// Required unique counts per category for a well-composed 45-question exam.
const Map<Category, int> kRequiredCounts = <Category, int>{
  Category.general: 20,
  Category.sign: 10,
  Category.priority: 5,
  Category.technique: 5,
  Category.emergency: 5,
};

/// Builds a single option string mixing a Khmer word, a latin word, and a
/// numeric [salt] so generated options are unicode-bearing and distinguishable.
String _option(Random rng, int salt) {
  final k = kKhmerWords[rng.nextInt(kKhmerWords.length)];
  final l = kLatinWords[rng.nextInt(kLatinWords.length)];
  return '$k $l #$salt';
}

/// Builds a [Question] for [category].
///
/// - `id` is `'$index'`.
/// - three option strings mix Khmer/unicode + latin text (so search/parsing
///   properties are meaningful).
/// - [correctIndex] defaults to a random value in `0..2`.
/// - `prompt` is an image filename (`'img$index.png'`) for image categories
///   (Sign/Priority), otherwise text containing recognizable tokens.
Question makeQuestion({
  required Category category,
  required int index,
  int? correctIndex,
  Random? rng,
}) {
  final r = rng ?? Random();
  final ci = (correctIndex ?? r.nextInt(3)).clamp(0, 2);
  final options = <String>[
    _option(r, index * 3),
    _option(r, index * 3 + 1),
    _option(r, index * 3 + 2),
  ];
  final prompt = category.isImageCategory
      ? 'img$index.png'
      : 'សំណួរ ${kKhmerWords[r.nextInt(kKhmerWords.length)]} '
            '${kLatinWords[r.nextInt(kLatinWords.length)]} token$index';
  return Question(
    id: '$index',
    prompt: prompt,
    options: options,
    correctIndex: ci,
    category: category,
  );
}

/// Generates [count] distinct questions for [category] with unique ids.
///
/// [idStart] offsets the numeric ids so callers can guarantee globally unique
/// ids across multiple category pools.
List<Question> makePool(
  Category category,
  int count,
  Random rng, {
  int idStart = 0,
}) {
  return List<Question>.generate(
    count,
    (i) => makeQuestion(category: category, index: idStart + i, rng: rng),
  );
}

/// Generates pools that MEET (and exceed) the required exam counts, mirroring
/// the real ground-truth data sizes. Each category uses a disjoint id range so
/// that every generated question has a globally unique id.
Map<Category, List<Question>> makeSufficientPools(Random rng) {
  return <Category, List<Question>>{
    Category.general: makePool(Category.general, 72, rng, idStart: 0),
    Category.sign: makePool(Category.sign, 100, rng, idStart: 1000),
    Category.priority: makePool(Category.priority, 31, rng, idStart: 3000),
    Category.technique: makePool(Category.technique, 31, rng, idStart: 5000),
    Category.emergency: makePool(Category.emergency, 15, rng, idStart: 7000),
  };
}

/// Builds a well-formed raw JSON map with the keys produced by the bundled
/// dataset: `"0"`, `"1"`, `"2"`, `"id"`, `"question"`, `"answer"`.
///
/// [answer] is typed as `Object?` so tests can inject invalid/null answers when
/// exercising the loader's exclusion logic.
Map<String, dynamic> makeRawJson({
  required String id,
  required Object? answer,
  Random? rng,
}) {
  final r = rng ?? Random();
  return <String, dynamic>{
    '0': _option(r, 0),
    '1': _option(r, 1),
    '2': _option(r, 2),
    'id': id,
    'question':
        'សំណួរ ${kKhmerWords[r.nextInt(kKhmerWords.length)]} '
            'question ${kLatinWords[r.nextInt(kLatinWords.length)]}',
    'answer': answer,
  };
}

/// Returns a random *invalid* answer value (anything not exactly "0"/"1"/"2"),
/// including the `null` case.
Object? invalidAnswer(Random rng) {
  const opts = <Object?>[
    '3',
    'x',
    '',
    '4',
    '-1',
    '12',
    'abc',
    '9',
    null,
    '00',
    '1.0',
    ' 1',
  ];
  return opts[rng.nextInt(opts.length)];
}
