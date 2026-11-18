/// GetStorage-backed persistence for user preferences and exam results.
///
/// [StorageService] is a thin wrapper over a single [GetStorage] box that
/// persists the active theme mode, UI locale, the last completed exam result,
/// and the best score ever achieved. Read methods return `null` when a
/// preference has never been set, leaving defaults to the calling layer
/// (ThemeController for theme, app startup for locale).
///
/// `GetStorage.init()` is expected to have been awaited in `main()` before this
/// service is constructed; this service only uses `GetStorage()`.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/exam_result_model.dart';

/// App-lifetime service wrapping GetStorage for preferences and results.
class StorageService extends GetxService {
  final GetStorage? _customBox;
  StorageService({GetStorage? box}) : _customBox = box;
  GetStorage get _box => _customBox ?? GetStorage();

  static const _kThemeMode = 'theme_mode'; // 'light' | 'dark'
  static const _kLocale = 'ui_locale'; // 'en_US' | 'km_KH'
  static const _kLastResult = 'last_result'; // JSON map
  static const _kBestScore = 'best_score'; // int
  static const _kExamHistory = 'exam_history'; // List of JSON maps
  static const _kMistakes = 'mistake_question_ids'; // List of String IDs
  static const _kBookmarks = 'bookmarked_question_ids'; // List of String IDs

  /// Reads the persisted [ThemeMode], or `null` when unset/unrecognized so the
  /// caller can apply its own default.
  ThemeMode? readThemeMode() {
    final value = _box.read<String>(_kThemeMode);
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return null;
    }
  }

  /// Persists [mode] as `'dark'` or `'light'`. [ThemeMode.system] is ignored.
  Future<void> writeThemeMode(ThemeMode mode) async {
    switch (mode) {
      case ThemeMode.dark:
        await _box.write(_kThemeMode, 'dark');
        break;
      case ThemeMode.light:
        await _box.write(_kThemeMode, 'light');
        break;
      case ThemeMode.system:
        // Intentionally ignored: the app only persists explicit light/dark.
        break;
    }
  }

  /// Reads the persisted UI [Locale], or `null` when unset/unrecognized.
  Locale? readLocale() {
    final value = _box.read<String>(_kLocale);
    switch (value) {
      case 'en_US':
        return const Locale('en', 'US');
      case 'km_KH':
        return const Locale('km', 'KH');
      default:
        return null;
    }
  }

  /// Persists [locale] as `'${languageCode}_${countryCode}'`, e.g. `'km_KH'`.
  Future<void> writeLocale(Locale locale) async {
    await _box.write(_kLocale, '${locale.languageCode}_${locale.countryCode}');
  }

  /// Reads the last persisted [ExamResult], or `null` when none is stored.
  ///
  /// GetStorage may return the stored map as a `Map<dynamic, dynamic>`, so the
  /// value is defensively re-typed to `Map<String, dynamic>` before parsing.
  ExamResult? readLastResult() {
    final stored = _box.read(_kLastResult);
    if (stored == null) return null;
    if (stored is! Map) return null;
    return ExamResult.fromJson(Map<String, dynamic>.from(stored));
  }

  /// Reads up to the last 10 completed [ExamResult] records in chronological order.
  List<ExamResult> readExamHistory() {
    final stored = _box.read(_kExamHistory);
    if (stored is List) {
      final results = <ExamResult>[];
      for (final item in stored) {
        if (item is Map) {
          try {
            results.add(ExamResult.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
      if (results.isNotEmpty) return results;
    }
    // Fallback: if history is empty but lastResult exists, seed it
    final last = readLastResult();
    if (last != null) return [last];
    return const [];
  }

  /// Appends [r] to the exam history, keeping at most [maxItems] (default 10) records.
  Future<void> addExamToHistory(ExamResult r, {int maxItems = 10}) async {
    final history = readExamHistory().toList();
    history.add(r);
    if (history.length > maxItems) {
      history.removeRange(0, history.length - maxItems);
    }
    await _box.write(
      _kExamHistory,
      history.map((item) => item.toJson()).toList(),
    );
  }

  /// Persists [r] as its JSON map representation and records it to [readExamHistory].
  Future<void> writeLastResult(ExamResult r) async {
    await _box.write(_kLastResult, r.toJson());
    await addExamToHistory(r);
  }

  /// The best (highest) correct-answer count persisted so far; `0` if none.
  int get bestScore => _box.read<int>(_kBestScore) ?? 0;

  /// Persists [score] only when it exceeds the current [bestScore]; no-op
  /// otherwise.
  Future<void> updateBestScore(int score) async {
    if (score > bestScore) {
      await _box.write(_kBestScore, score);
    }
  }

  /// Reads all question IDs currently recorded in the Mistakes Bank.
  Set<String> readMistakeIds() {
    final list = _box.read<List>(_kMistakes);
    if (list == null) return <String>{};
    return list.map((e) => e.toString()).toSet();
  }

  /// Adds a single question ID to the Mistakes Bank.
  Future<void> addMistakeId(String id) async {
    final set = readMistakeIds()..add(id);
    await _box.write(_kMistakes, set.toList());
  }

  /// Adds multiple question IDs to the Mistakes Bank in batch.
  Future<void> addMistakeIds(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final set = readMistakeIds()..addAll(ids);
    await _box.write(_kMistakes, set.toList());
  }

  /// Removes a question ID from the Mistakes Bank after user masters it.
  Future<void> removeMistakeId(String id) async {
    final set = readMistakeIds()..remove(id);
    await _box.write(_kMistakes, set.toList());
  }

  /// Clears all recorded mistakes from the bank.
  Future<void> clearAllMistakes() async {
    await _box.remove(_kMistakes);
  }

  /// Total number of unique questions currently in the Mistakes Bank.
  int get mistakeCount => readMistakeIds().length;

  // ---------------------------------------------------------------------------
  // Bookmarks (Saved Questions)
  // ---------------------------------------------------------------------------

  /// Reads all question IDs currently bookmarked by the user.
  Set<String> readBookmarkIds() {
    final list = _box.read<List>(_kBookmarks);
    if (list == null) return <String>{};
    return list.map((e) => e.toString()).toSet();
  }

  /// Checks if [id] is in the user's bookmarks.
  bool isBookmarked(String id) => readBookmarkIds().contains(id);

  /// Toggles the bookmark status of [id] and returns the new status (`true` if saved).
  Future<bool> toggleBookmark(String id) async {
    final set = readBookmarkIds();
    final wasBookmarked = set.contains(id);
    if (wasBookmarked) {
      set.remove(id);
    } else {
      set.add(id);
    }
    await _box.write(_kBookmarks, set.toList());
    return !wasBookmarked;
  }

  /// Clears all saved bookmarks.
  Future<void> clearAllBookmarks() async {
    await _box.remove(_kBookmarks);
  }

  /// Total count of saved bookmarked questions.
  int get bookmarkCount => readBookmarkIds().length;
}
