/// App-lifetime service that loads, parses, and validates the five bundled
/// category JSON files once at startup.
///
/// Questions are grouped by [Category] and exposed read-only. Entries whose
/// `answer` value is not `"0"|"1"|"2"` are *excluded* (not fatal) and their ids
/// recorded for auditing. Read/parse failures are reported per affected
/// category and the load is retryable.
library;

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

import '../models/question_model.dart';
import '../utils/asset_paths.dart';

/// Lifecycle status of the data load used to drive UI (shimmer/error/content).
enum DataStatus { idle, loading, ready, error }

/// Describes a failure to load a single [Category].
///
/// [isParseError] is `true` when decoding/parsing the JSON failed, and `false`
/// when the underlying asset could not be read.
class CategoryLoadError {
  /// The category whose load failed.
  final Category category;

  /// Human-readable description of what went wrong.
  final String message;

  /// `true` => decode/format error; `false` => read/load error.
  final bool isParseError;

  const CategoryLoadError(
    this.category,
    this.message, {
    this.isParseError = false,
  });
}

/// Loads + parses all five category JSON files once and exposes the grouped,
/// validated questions plus a reactive load [status] and any [errors].
class DataService extends GetxService {
  /// Reactive load status; observed by the Home screen.
  final status = DataStatus.idle.obs;

  /// Populated when one or more categories fail to load/parse.
  final errors = <CategoryLoadError>[].obs;

  /// Audit trail of excluded (invalid-answer) question ids per category.
  final excludedIds = <Category, List<String>>{}.obs;

  final Map<Category, List<Question>> _byCategory = {};

  /// Questions loaded for [c] (empty when none/failed). Read-only.
  List<Question> questionsFor(Category c) =>
      List.unmodifiable(_byCategory[c] ?? const []);

  /// All loaded questions grouped by category. Read-only.
  Map<Category, List<Question>> get all => Map.unmodifiable(_byCategory);

  /// Loads + parses all five files.
  ///
  /// Sets [status] to [DataStatus.ready] when every category loads without
  /// error, otherwise [DataStatus.error] with the affected categories recorded
  /// in [errors]. A failure on one category does not prevent the others from
  /// loading.
  Future<void> loadAllCategories() async {
    status.value = DataStatus.loading;
    errors.clear();
    excludedIds.clear();
    _byCategory.clear();

    for (final category in Category.values) {
      String raw;
      try {
        raw = await rootBundle.loadString(AssetPaths.categoryJson(category));
      } catch (e) {
        errors.add(
          CategoryLoadError(
            category,
            'Failed to read ${AssetPaths.categoryJson(category)}: $e',
            isParseError: false,
          ),
        );
        continue;
      }

      try {
        final decoded = json.decode(raw);
        if (decoded is! List) {
          throw const FormatException('Expected a top-level JSON list');
        }
        final result = parseCategory(decoded, category);
        _byCategory[category] = result.questions;
        excludedIds[category] = result.excludedIds;
      } catch (e) {
        errors.add(
          CategoryLoadError(
            category,
            'Failed to parse ${AssetPaths.categoryJson(category)}: $e',
            isParseError: true,
          ),
        );
        continue;
      }
    }

    status.value = errors.isEmpty ? DataStatus.ready : DataStatus.error;
  }

  /// Parses a decoded JSON [rawList] into [Question]s for [category].
  ///
  /// Pure function (no Flutter/GetX calls) so it is directly unit/property
  /// testable. Entries whose `answer` is not `"0"|"1"|"2"` are excluded and
  /// their ids collected; all other entries are built via [Question.fromJson]
  /// (which throws on missing/wrong-typed required keys).
  static ({List<Question> questions, List<String> excludedIds}) parseCategory(
    List<dynamic> rawList,
    Category category,
  ) {
    final questions = <Question>[];
    final excluded = <String>[];

    for (final element in rawList) {
      final map = (element as Map).cast<String, dynamic>();
      if (!Question.isValidAnswer(map['answer'])) {
        excluded.add(map['id']?.toString() ?? 'unknown');
        continue;
      }
      questions.add(Question.fromJson(map, category));
    }

    return (questions: questions, excludedIds: excluded);
  }

  /// Retry entry point bound to the error-state retry control.
  Future<void> retry() => loadAllCategories();
}
