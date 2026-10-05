/// A custom, animated bottom navigation bar with an Apple-style floating pill.
///
/// [CustomBottomNav] renders six destinations — the five study categories
/// (general, emergency, technique, sign, priority) plus an exam tab — as a row
/// of icon-only items inside a rounded, softly-shadowed floating surface bar.
/// The active tab is shown as a compact gold circle, while inactive tabs stay
/// transparent with muted tint. (Req 16.1, 16.2, 4.3, 4.4)
///
/// The bar is intentionally stateless and unaware of exam state: while an exam
/// is in progress the parent simply omits this widget from the tree rather than
/// the bar hiding itself. (Req 16.3)
///
/// Index → destination mapping is exposed via the top-level [kNavTabs] list so
/// the parent (the Home scaffold) can translate a tapped index into the
/// corresponding [Category] (study route) or `null` (exam route).
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../core/utils/asset_paths.dart';

/// A single bottom-nav destination: its bilingual label key, icon asset path,
/// and the [Category] it opens in Study mode (`null` for the exam tab).
class NavTab {
  /// Translation key resolved with `.tr` to render the bilingual label.
  final String labelKey;

  /// Bundled PNG icon asset path for this tab.
  final String iconAsset;

  /// The study category this tab opens, or `null` for the exam tab.
  final Category? category;

  /// Creates a navigation tab descriptor.
  const NavTab(this.labelKey, this.iconAsset, this.category);
}

/// The six bottom-nav destinations, in display order.
///
/// This list is `final` (not `const`) because each [iconAsset] is resolved
/// through [AssetPaths.icon], a static method call that is not a constant
/// expression. The parent maps a tapped index to this list to decide whether
/// to open Study (with [NavTab.category]) or start an exam (`category == null`).
final List<NavTab> kNavTabs = [
  NavTab('nav_general', AssetPaths.icon('general'), Category.general),
  NavTab('nav_emergency', AssetPaths.icon('emergency'), Category.emergency),
  NavTab('nav_technique', AssetPaths.icon('technique'), Category.technique),
  NavTab('nav_sign', AssetPaths.icon('sign'), Category.sign),
  NavTab('nav_priority', AssetPaths.icon('priority'), Category.priority),
  NavTab('nav_exam', AssetPaths.icon('exam'), null),
];

/// Duration of the active-tab animations.
const Duration _kNavAnimDuration = Duration(milliseconds: 280);

/// Height of the interactive bar content (excluding outer padding).
const double _kBarHeight = 62;

/// An animated, floating bottom navigation bar.
class CustomBottomNav extends StatelessWidget {
  /// The index of the currently active tab (0..[kNavTabs].length - 1).
  final int currentIndex;

  /// Called with the tapped tab's index.
  final ValueChanged<int> onTap;

  /// Creates a custom bottom navigation bar.
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final tabs = kNavTabs;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isDark
                ? theme.cardColor
                : Color.alphaBlend(
                    AppColors.accentGold.withValues(alpha: 0.025),
                    theme.cardColor,
                  ),
            borderRadius: BorderRadius.circular(31),
            border: Border.all(
              color: colorScheme.outline.withValues(
                alpha: isDark ? 0.18 : 0.55,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(
                  alpha: isDark ? 0.22 : 0.10,
                ),
                blurRadius: isDark ? 22 : 18,
                spreadRadius: isDark ? 0 : -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            height: _kBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _NavTabItem(
                          tab: tabs[i],
                          selected: i == currentIndex,
                          onTap: () => onTap(i),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A single icon-only tab. The selected tab uses a compact circular highlight.
class _NavTabItem extends StatelessWidget {
  final NavTab tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor = AppColors.mutedFor(theme.brightness);
    final iconColor = selected ? AppColors.primaryDark : mutedColor;
    final materialIconColor = selected ? AppColors.primaryDark : mutedColor;
    final label = tab.labelKey.tr;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: AnimatedContainer(
            duration: _kNavAnimDuration,
            curve: Curves.easeOut,
            width: selected ? 42 : 40,
            height: selected ? 42 : 40,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accentGold.withValues(alpha: 0.95)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AnimatedScale(
                scale: selected ? 1.08 : 1.0,
                duration: _kNavAnimDuration,
                curve: Curves.easeOut,
                child: tab.category == Category.general
                    ? Icon(
                        Icons.home_rounded,
                        size: 24,
                        color: materialIconColor,
                      )
                    : Image.asset(
                        tab.iconAsset,
                        width: 24,
                        height: 24,
                        color: iconColor,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.circle_outlined,
                          size: 24,
                          color: materialIconColor,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
