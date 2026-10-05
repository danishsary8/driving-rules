/// Core domain model for a single driving-rules question plus the [Category]
/// enum and its metadata.
///
/// Dynamic question/answer content (prompts and options) is stored and exposed
/// in Khmer exactly as it appears in the bundled JSON assets. Only the
/// originating [Category] is used to decide whether a prompt should be rendered
/// as text or as an image (see [Question.isImagePrompt]).
library;

/// The five question categories bundled with the app.
///
/// Sign and Priority are "image" categories: their stored `question` field is
/// an image filename rather than Khmer prompt text.
enum Category { general, emergency, sign, priority, technique }

/// Metadata derived from a [Category]: asset paths, search/labeling behavior,
/// and the expected ground-truth source counts.
extension CategoryMeta on Category {
  /// Lowercase file stem used to build asset paths, e.g. `general`.
  String get fileStem => switch (this) {
    Category.general => 'general',
    Category.emergency => 'emergency',
    Category.sign => 'sign',
    Category.priority => 'priority',
    Category.technique => 'technique',
  };

  /// JSON asset path, e.g. `driving_rules_data/general.json`.
  String get jsonAsset => 'driving_rules_data/$fileStem.json';

  /// Category icon asset path, e.g. `driving_rules_data/icon-general.png`.
  String get iconAsset => 'driving_rules_data/icon-$fileStem.png';

  /// True for Sign and Priority, whose prompt is an image filename.
  bool get isImageCategory =>
      this == Category.sign || this == Category.priority;

  /// Translation key for the bilingual nav/title label.
  String get navKey => switch (this) {
    Category.general => 'nav_general',
    Category.emergency => 'nav_emergency',
    Category.sign => 'nav_sign',
    Category.priority => 'nav_priority',
    Category.technique => 'nav_technique',
  };

  /// Expected loaded count per ground-truth data (used for reference/tests).
  int get sourceCount => switch (this) {
    Category.general => 72,
    Category.emergency => 15,
    Category.sign => 100,
    Category.priority => 31,
    Category.technique => 31,
  };
}

/// A single multiple-choice question with exactly three options.
///
/// Maps the raw JSON object (`"0"`, `"1"`, `"2"`, `"id"`, `"question"`,
/// `"answer"`) into a typed object. `answer` is a string index
/// `"0"|"1"|"2"` that becomes [correctIndex] (an int). [isImagePrompt] derives
/// from the owning [category], so the widget layer knows whether to render the
/// prompt as text or as an image.
class Question {
  /// Stable identifier from the source JSON (`id`).
  final String id;

  /// Khmer prompt text, or — for image categories — an image filename.
  final String prompt;

  /// The three answer options `[opt0, opt1, opt2]`, Khmer text preserved
  /// verbatim.
  final List<String> options;

  /// Index of the correct option, in the range `0..2`.
  final int correctIndex;

  /// The validated correct answer, preserving the original source text.
  String get correctAnswer => options[correctIndex];

  /// Originating category of this question.
  final Category category;

  const Question({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.category,
  });

  /// Whether the prompt should be rendered as an image (Sign/Priority).
  bool get isImagePrompt => category.isImageCategory;

  /// True if [answerRaw] is a valid `"0"|"1"|"2"` value.
  static bool isValidAnswer(Object? answerRaw) =>
      answerRaw == '0' || answerRaw == '1' || answerRaw == '2';

  /// Parses one JSON object for [category].
  ///
  /// Throws naturally (e.g. a [FormatException] from [int.parse] or a cast
  /// error) if a required key is missing or wrong-typed. Answer-range validity
  /// is checked separately via [isValidAnswer] so the loader can *exclude*
  /// (rather than crash on) out-of-range answers.
  factory Question.fromJson(Map<String, dynamic> json, Category category) {
    return Question(
      id: json['id'] as String,
      prompt: json['question'] as String,
      options: [json['0'] as String, json['1'] as String, json['2'] as String],
      correctIndex: int.parse(json['answer'] as String),
      category: category,
    );
  }

  /// Does any option text contain [term] (case-insensitive)? Used by search.
  bool optionsContain(String term) =>
      options.any((o) => o.toLowerCase().contains(term.toLowerCase()));

  /// Whether this question matches the search [term] (case-insensitive).
  ///
  /// Image categories match against their options only (the prompt is an image
  /// filename). Text categories match against the prompt or any option.
  bool matches(String term) {
    final t = term.toLowerCase();
    if (isImagePrompt) return optionsContain(t);
    return prompt.toLowerCase().contains(t) || optionsContain(t);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question && other.id == id && other.category == category;

  @override
  int get hashCode => Object.hash(id, category);

  @override
  String toString() => 'Question(id: $id, category: $category)';
}
