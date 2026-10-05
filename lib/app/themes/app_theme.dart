import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();
  static const primaryDark = Color(0xFF13231F);
  static const surfaceDark = Color(0xFF1D302A);
  static const surfaceDarkElevated = Color(0xFF294039);
  static const textPrimary = Color(0xFFF2FAF6);
  static const textMuted = Color(0xFFB4C9BF);
  static const primaryLight = Color(0xFFF3F7F5);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceLightElevated = Color(0xFFE9F2ED);
  static const textDark = Color(0xFF1B3029);
  static const textMutedLight = Color(0xFF4D655B);
  static const outlineLight = Color(0xFFD5E3DC);
  static const accentGold = Color(0xFFF3C66B);
  static const accentRed = Color(0xFFC75448);
  static const accentGreen = Color(0xFF1F6D61);
  static const heroTop = Color(0xFF245D50);
  static const heroBottom = Color(0xFF133C32);
  static Color mutedFor(Brightness brightness) =>
      brightness == Brightness.dark ? textMuted : textMutedLight;

  /// Keeps colored status text readable on the active surface.
  static Color contentColor(Color color, Brightness brightness) {
    if (brightness == Brightness.dark) {
      return Color.lerp(color, Colors.white, .4)!;
    }
    if (color.computeLuminance() > .22) {
      final hsl = HSLColor.fromColor(color);
      return hsl.withLightness(hsl.lightness * .68).toColor();
    }
    return color;
  }
}

class ExamColors {
  ExamColors._();
  static const navyTop = AppColors.primaryDark;
  static const navyBottom = AppColors.surfaceDark;
  static const answerCard = AppColors.surfaceDarkElevated;
  static const answerSelected = AppColors.accentGreen;
  static const timerTrack = AppColors.outlineLight;
}

class AppTextStyles {
  AppTextStyles._();
  static TextStyle get headline1 => const TextStyle(
    fontFamily: 'Kanit',
    fontFamilyFallback: ['NotoSansKhmer'],
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.8,
  );
  static TextStyle get headline2 =>
      headline1.copyWith(fontSize: 23, letterSpacing: -0.4);
  static TextStyle get body1 =>
      const TextStyle(fontFamily: 'NotoSansKhmer', fontSize: 16, height: 1.7);
  static TextStyle get body2 => body1.copyWith(fontSize: 14);
  static TextStyle get caption => body1.copyWith(fontSize: 13, height: 1.6);
}

class AppTheme {
  AppTheme._();
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final text = dark ? AppColors.textPrimary : AppColors.textDark;
    final muted = AppColors.mutedFor(brightness);
    final surface = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final border = dark ? const Color(0xFF3C574C) : AppColors.outlineLight;
    final background = dark ? AppColors.primaryDark : AppColors.primaryLight;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentGreen,
      brightness: brightness,
      primary: dark ? const Color(0xFF9AD8BD) : AppColors.accentGreen,
      onPrimary: dark ? AppColors.textDark : Colors.white,
      primaryContainer: dark
          ? const Color(0xFF25463B)
          : const Color(0xFFE5F3EB),
      onPrimaryContainer: dark
          ? const Color(0xFFD5F3E3)
          : const Color(0xFF174C3F),
      secondary: AppColors.accentGold,
      onSecondary: AppColors.textDark,
      surface: surface,
      onSurface: text,
      outline: border,
      surfaceContainerHighest: dark
          ? AppColors.surfaceDarkElevated
          : AppColors.surfaceLightElevated,
      error: AppColors.accentRed,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: surface,
      dividerColor: border,
      fontFamily: 'NotoSansKhmer',
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1.copyWith(
          color: text,
          fontSize: 52,
        ),
        headlineLarge: AppTextStyles.headline1.copyWith(color: text),
        headlineMedium: AppTextStyles.headline2.copyWith(color: text),
        titleLarge: AppTextStyles.headline2.copyWith(color: text),
        titleMedium: AppTextStyles.body1.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: AppTextStyles.body1.copyWith(color: text),
        bodyMedium: AppTextStyles.body2.copyWith(color: text),
        bodySmall: AppTextStyles.caption.copyWith(color: muted),
        labelLarge: AppTextStyles.body2.copyWith(
          color: text,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: AppTextStyles.caption.copyWith(color: muted),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.headline2.copyWith(color: text),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(elevation: 0, color: surface, shape: shape),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          textStyle: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700),
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          minimumSize: const Size(48, 50),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.all(18),
        hintStyle: AppTextStyles.body2.copyWith(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.accentGreen,
            width: 1.5,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.accentGreen,
        linearTrackColor: border,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: AppTextStyles.body2.copyWith(color: Colors.white),
        decoration: BoxDecoration(
          color: AppColors.textDark,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.caption.copyWith(
            color: text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: AppTextStyles.body2.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
