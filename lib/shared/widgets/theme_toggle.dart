/// An icon button that toggles between light and dark themes.
///
/// [ThemeToggle] reflects the active theme via [ThemeController]: when the app
/// is in dark mode it shows a sun (tap to switch to light), and in light mode
/// it shows a moon (tap to switch to dark). The reactive [Obx] keeps the icon
/// in sync as the mode changes, and the tooltip is bilingual via translations.
/// (Req 14.5, 14.6)
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_theme.dart';
import '../../app/themes/theme_controller.dart';

/// A reactive theme-switching icon button.
class ThemeToggle extends StatelessWidget {
  /// Creates a theme toggle button.
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColors.textDark;
    return Obx(
      () => IconButton(
        icon: Icon(
          controller.isDark ? Icons.light_mode : Icons.dark_mode,
          color: iconColor,
        ),
        tooltip: 'theme_toggle_tooltip'.tr,
        onPressed: controller.toggle,
      ),
    );
  }
}
