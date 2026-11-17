import 'package:flutter/services.dart';

/// Centralized tactile haptic feedback service providing consistent,
/// responsive physical sensations across user interactions (taps, option
/// selections, warning triggers, speed quiz combos, and errors).
abstract final class AppHaptics {
  /// Subtle click for selecting an answer option, switching tabs, or toggling a filter.
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Light tap for buttons, chips, and small navigation events.
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Medium pulse for successful actions, passing an exam, or scoring in quiz.
  static Future<void> success() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Heavy warning pulse when entering critical priority questions or time running low.
  static Future<void> warning() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Multi-pulse or vibrate for losing a heart, priority disqualification, or timeout.
  static Future<void> error() async {
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }
}
