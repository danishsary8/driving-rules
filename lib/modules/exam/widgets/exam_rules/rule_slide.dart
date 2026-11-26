import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';

/// Content of one rules slide: copy, accent colour and optional graphic.
class RuleSlideData {
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final String title;
  final String highlightText;
  final String description;
  final String tipText;
  final bool isStrict;
  final Widget? visualGraphic;

  const RuleSlideData({
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    required this.title,
    required this.highlightText,
    required this.description,
    required this.tipText,
    this.isStrict = false,
    this.visualGraphic,
  });
}

/// One page of the rules carousel.
class RuleCarouselSlide extends StatelessWidget {
  final RuleSlideData data;
  final bool compact;
  final bool isDark;

  const RuleCarouselSlide({
    super.key,
    required this.data,
    required this.compact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(compact ? 14 : 20, 14, compact ? 14 : 20, 8),
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          color: data.accentColor.withValues(alpha: isDark ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: data.accentColor.withValues(alpha: 0.35),
            width: data.isStrict ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Badge + Icon
            Row(
              children: [
                Container(
                  width: compact ? 36 : 40,
                  height: compact ? 36 : 40,
                  decoration: BoxDecoration(
                    color: data.accentColor.withValues(
                      alpha: isDark ? 0.28 : 0.16,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    color: data.accentColor,
                    size: compact ? 20 : 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: data.isStrict
                            ? AppColors.accentRed
                            : data.accentColor.withValues(
                                alpha: isDark ? 0.24 : 0.12,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data.badgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: data.isStrict
                              ? Colors.white
                              : data.accentColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              data.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Kanit',
                color: data.isStrict
                    ? AppColors.accentRed
                    : theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 15 : 16.5,
              ),
            ),
            const SizedBox(height: 6),

            // Highlight Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.7,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                data.highlightText,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.contentColor(
                    data.accentColor,
                    theme.brightness,
                  ),
                  fontSize: compact ? 11.5 : 12.5,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Visual Graphic (if present)
            if (data.visualGraphic != null) ...[
              data.visualGraphic!,
              const SizedBox(height: 10),
            ],

            // Full Description
            Text(
              data.description,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.55,
                fontSize: compact ? 12 : 12.8,
              ),
            ),
            const SizedBox(height: 10),

            // Actionable Pro-Tip Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262624)
                    : const Color(0xFFFEF9C3).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEAB308).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFFCA8A04),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data.tipText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1.4,
                        color: isDark
                            ? const Color(0xFFFDE047)
                            : const Color(0xFF854D0E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
