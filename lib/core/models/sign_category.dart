import 'package:flutter/material.dart';
import 'question_model.dart';

/// The 4 official Cambodian road sign sub-classifications.
enum SignType {
  all,
  prohibitory, // សញ្ញាហាមឃាត់ (Red circle)
  danger, // សញ្ញាគ្រោះថ្នាក់ / ប្រុងប្រយ័ត្ន (Yellow/Red triangle)
  mandatory, // សញ្ញាបញ្ជា (Blue circle)
  informative, // សញ្ញាផ្តល់ដំណឹង (Blue/Green rectangle)
}

extension SignTypeMeta on SignType {
  /// Translation key for the sign sub-category.
  String get labelKey => switch (this) {
    SignType.all => 'sign_filter_all',
    SignType.prohibitory => 'sign_filter_prohibitory',
    SignType.danger => 'sign_filter_danger',
    SignType.mandatory => 'sign_filter_mandatory',
    SignType.informative => 'sign_filter_informative',
  };

  /// Accent color matching real-world road sign palettes.
  Color get color => switch (this) {
    SignType.all => const Color(0xFF64748B),
    SignType.prohibitory => const Color(0xFFDC2626), // Crimson Red
    SignType.danger => const Color(0xFFD97706), // Amber / Caution Orange
    SignType.mandatory => const Color(0xFF2563EB), // Royal Blue
    SignType.informative => const Color(0xFF059669), // Emerald Green
  };

  /// Distinctive icon per sign type.
  IconData get icon => switch (this) {
    SignType.all => Icons.grid_view_rounded,
    SignType.prohibitory => Icons.do_not_disturb_on_rounded,
    SignType.danger => Icons.warning_amber_rounded,
    SignType.mandatory => Icons.arrow_circle_right_rounded,
    SignType.informative => Icons.info_outline_rounded,
  };

  /// Classifies a sign question into its official road sign sub-type.
  static SignType classify(Question q) {
    if (q.category != Category.sign) return SignType.informative;

    final file = q.prompt.toLowerCase();
    final ans = q.correctAnswer;

    if (file.startsWith('no-') ||
        file.contains('ban') ||
        file.contains('stop') ||
        file.contains('no_') ||
        ans.contains('ហាម') ||
        ans.contains('ឈប់') ||
        ans.contains('មិនអនុញ្ញាត')) {
      return SignType.prohibitory;
    }
    if (file.startsWith('warn-') ||
        file.startsWith('danger-') ||
        ans.contains('ប្រយ័ត្ន') ||
        ans.contains('គ្រោះថ្នាក់') ||
        ans.contains('កោង') ||
        ans.contains('ផ្លូវបំបែក')) {
      return SignType.danger;
    }
    if (file.startsWith('only-') ||
        file.startsWith('must-') ||
        file.startsWith('end-') ||
        ans.contains('សំរាប់តែ') ||
        ans.contains('សម្រាប់តែ') ||
        ans.contains('ត្រូវ')) {
      return SignType.mandatory;
    }
    return SignType.informative;
  }
}
