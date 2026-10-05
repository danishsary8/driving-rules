/// An icon button that toggles the UI language between Khmer and English.
///
/// [LanguageToggle] shows a globe icon alongside a short label for the current
/// locale (`EN` for English, `ខ្មែរ` for Khmer) and calls
/// [LocaleController.toggle] when pressed. The whole app rebuilds on
/// `Get.updateLocale`, so the label stays in sync with the active locale. The
/// tooltip is bilingual via translations. (Req 13.3, 13.4)
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_theme.dart';
import '../../app/translations/app_translations.dart';

/// A language-switching icon button with a current-locale label.
class LanguageToggle extends StatelessWidget {
  /// Creates a language toggle button.
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocaleController>();
    final theme = Theme.of(context);
    final isKhmer = controller.current == LocaleController.km;
    final label = isKhmer ? 'ខ្មែរ' : 'EN';
    final color = theme.brightness == Brightness.dark
        ? AppColors.textPrimary
        : AppColors.textDark;

    return IconButton(
      tooltip: 'language_toggle_tooltip'.tr,
      onPressed: controller.toggle,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
