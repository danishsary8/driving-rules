/// Resolves the real bundled asset paths for the app.
///
/// All assets live at the project root under `driving_rules_data/` (not an
/// `assets/` folder). The category JSON files and icon PNGs sit at the top
/// level of that folder, while sign *and* priority prompt images both live in
/// `driving_rules_data/sign/`.
library;

import '../models/question_model.dart';

/// Static helpers that map domain values (categories, image filenames, icon
/// names) to their real bundled asset paths.
class AssetPaths {
  AssetPaths._();

  /// Root data folder bundled with the app.
  static const String root = 'driving_rules_data';

  /// Directory holding sign + priority prompt images.
  static const String signDir = '$root/sign';

  // ---------------------------------------------------------------------------
  // JSON
  // ---------------------------------------------------------------------------

  /// JSON asset path for [c], e.g. `driving_rules_data/general.json`.
  static String categoryJson(Category c) => c.jsonAsset;

  // ---------------------------------------------------------------------------
  // Prompt images (sign + priority; filename is stored in the question prompt)
  // ---------------------------------------------------------------------------

  /// Full path to a sign/priority prompt image given its [filename].
  static String promptImage(String filename) => '$signDir/$filename';

  // ---------------------------------------------------------------------------
  // Icons (top-level PNGs)
  // ---------------------------------------------------------------------------

  /// Resolves a top-level icon PNG, e.g. `icon('general')`.
  static String icon(String name) => '$root/icon-$name.png';

  /// Icon for an unselected answer option.
  static const String iconDefault = '$root/icon-default.png';

  /// Icon for a selected answer option.
  static const String iconChoose = '$root/icon-choose.png';

  /// Search icon.
  static const String iconSearch = '$root/icon-search.png';

  /// Back-navigation icon.
  static const String iconBack = '$root/icon-back.png';

  /// Next-navigation icon.
  static const String iconNext = '$root/icon-next.png';

  /// Exam icon.
  static const String iconExam = '$root/icon-exam.png';

  /// Info icon.
  static const String iconInfo = '$root/icon-info.png';

  /// Placeholder shown when a prompt image filename is not bundled (Req 6.4).
  static const String placeholderImage = '$root/icon-default.png';
}
