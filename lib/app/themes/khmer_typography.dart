import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Typography adjustments that keep Khmer text readable.
///
/// Khmer stacks consonant subscripts (*coeng*) and vowels above and below the
/// base line, so it needs more room than Latin text at the same point size:
///
/// * very small sizes (10–12 px) blur stacked marks together, so
///   [ReadableTextScaler] lifts them towards a readable floor;
/// * negative letter-spacing squeezes clusters until marks touch, so
///   [KhmerTypography.wrap] resets tracking to zero in the theme and
///   [KhmerTypography.tracking] does the same for hand-written styles.
///
/// English (and any non-Khmer locale) is left exactly as designed.
abstract final class KhmerTypography {
  /// Whether [locale] uses the Khmer script.
  static bool isKhmer(Locale? locale) => locale?.languageCode == 'km';

  /// The UI locale chosen in the app.
  ///
  /// Read from GetX rather than [Localizations]: the app ships its own
  /// translations and does not register Khmer with Flutter's localization
  /// delegates, so [Localizations.localeOf] would always resolve to English.
  static Locale? get activeLocale => Get.locale;

  /// Letter-spacing to use for a hand-written style: [latin] for Latin
  /// locales, `0` for Khmer.
  static double tracking(BuildContext context, double latin) =>
      isKhmer(activeLocale) ? 0 : latin;

  /// `MaterialApp.builder` hook: wraps [child] with Khmer-friendly text
  /// scaling and tracking when the active locale is Khmer.
  static Widget builder(BuildContext context, Widget? child) =>
      wrap(context, child ?? const SizedBox.shrink());

  /// Applies the Khmer adjustments to [child] when the locale is Khmer, and
  /// returns [child] unchanged otherwise.
  static Widget wrap(BuildContext context, Widget child) {
    if (!isKhmer(activeLocale)) return child;
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: ReadableTextScaler(base: media.textScaler),
      ),
      child: Theme(
        data: theme.copyWith(textTheme: _withoutTracking(theme.textTheme)),
        child: child,
      ),
    );
  }

  static TextTheme _withoutTracking(TextTheme t) {
    TextStyle? z(TextStyle? s) => s?.copyWith(letterSpacing: 0);
    return t.copyWith(
      displayLarge: z(t.displayLarge),
      displayMedium: z(t.displayMedium),
      displaySmall: z(t.displaySmall),
      headlineLarge: z(t.headlineLarge),
      headlineMedium: z(t.headlineMedium),
      headlineSmall: z(t.headlineSmall),
      titleLarge: z(t.titleLarge),
      titleMedium: z(t.titleMedium),
      titleSmall: z(t.titleSmall),
      bodyLarge: z(t.bodyLarge),
      bodyMedium: z(t.bodyMedium),
      bodySmall: z(t.bodySmall),
      labelLarge: z(t.labelLarge),
      labelMedium: z(t.labelMedium),
      labelSmall: z(t.labelSmall),
    );
  }
}

/// A [TextScaler] that raises small font sizes towards a readable floor while
/// leaving body text and headings alone.
///
/// Sizes at or above [threshold] pass through unchanged. Below it, sizes are
/// compressed towards [threshold] linearly so that [referenceSize] maps to
/// [floor]; e.g. with the defaults 10 px → 12.4 px, 12 px → 13.2 px,
/// 14 px → 14 px. The mapping is monotonic, so relative hierarchy between
/// small labels is preserved. The user's own text-size setting ([base]) is
/// applied on top.
@immutable
class ReadableTextScaler extends TextScaler {
  const ReadableTextScaler({
    this.base = TextScaler.noScaling,
    this.floor = 12,
    this.threshold = 14,
    this.referenceSize = 9,
  }) : assert(floor <= threshold),
       assert(referenceSize < floor);

  /// The scaler being wrapped, usually the platform's.
  final TextScaler base;

  /// Size that [referenceSize] is lifted to.
  final double floor;

  /// Sizes at or above this are not adjusted.
  final double threshold;

  /// The smallest size the app is designed with.
  final double referenceSize;

  /// Size before the platform scaler is applied.
  double lift(double fontSize) {
    if (fontSize >= threshold) return fontSize;
    final ratio = (threshold - floor) / (threshold - referenceSize);
    return threshold - (threshold - fontSize) * ratio;
  }

  @override
  double scale(double fontSize) => base.scale(lift(fontSize));

  @override
  // Required override of a deprecated member; reports the platform factor.
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor;

  @override
  bool operator ==(Object other) =>
      other is ReadableTextScaler &&
      other.base == base &&
      other.floor == floor &&
      other.threshold == threshold &&
      other.referenceSize == referenceSize;

  @override
  int get hashCode => Object.hash(base, floor, threshold, referenceSize);

  @override
  String toString() =>
      'ReadableTextScaler(floor: $floor, threshold: $threshold, base: $base)';
}
