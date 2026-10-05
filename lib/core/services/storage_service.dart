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
  final GetStorage _box = GetStorage();

  static const _kThemeMode = 'theme_mode'; // 'light' | 'dark'
  static const _kLocale = 'ui_locale'; // 'en_US' | 'km_KH'
  static const _kLastResult = 'last_result'; // JSON map
  static const _kBestScore = 'best_score'; // int

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

  /// Persists [r] as its JSON map representation.
  Future<void> writeLastResult(ExamResult r) async {
    await _box.write(_kLastResult, r.toJson());
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
}
