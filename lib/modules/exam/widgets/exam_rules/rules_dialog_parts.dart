import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_theme.dart';

/// Title row with the step counter ("2 / 4") and close button.
class RulesDialogHeader extends StatelessWidget {
  const RulesDialogHeader({
    super.key,
    required this.compact,
    required this.accentColor,
    required this.currentIndex,
  });

  final bool compact;
  final Color accentColor;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 14 : 20, 14, 10, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2623) : const Color(0xFFF4F7F5),
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFFB58316),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'exam_rules_title'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Kanit',
                    fontSize: compact ? 15 : 16.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'exam_rules_subtitle'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedFor(theme.brightness),
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ],
            ),
          ),
          // Step Indicator Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withValues(alpha: 0.35)),
            ),
            child: Text(
              '${currentIndex + 1} / 4',
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ),
          const SizedBox(width: 2),
          IconButton(
            tooltip: 'close'.tr,
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Tappable page indicator; the active page is a wider pill.
class RulesPageDots extends StatelessWidget {
  const RulesPageDots({
    super.key,
    required this.total,
    required this.currentIndex,
    required this.accentColor,
    required this.onDotTap,
  });

  final int total;
  final int currentIndex;
  final Color accentColor;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (idx) {
          final isActive = idx == currentIndex;
          return InkWell(
            onTap: () => onDotTap(idx),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3.5),
              width: isActive ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? accentColor
                    : theme.dividerColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Bottom buttons: skip/back on the left, next/start/close on the right.
class RulesDialogActions extends StatelessWidget {
  const RulesDialogActions({
    super.key,
    required this.compact,
    required this.isRevisit,
    required this.currentIndex,
    required this.total,
    required this.accentColor,
    required this.onBack,
    required this.onNext,
    required this.onConfirm,
  });

  final bool compact;
  final bool isRevisit;
  final int currentIndex;
  final int total;
  final Color accentColor;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 10 : 16, 8, compact ? 10 : 16, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // Left Action Button
          if (isRevisit) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('close'.tr),
            ),
            const SizedBox(width: 8),
          ] else if (currentIndex == 0) ...[
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                foregroundColor: AppColors.mutedFor(theme.brightness),
              ),
              onPressed: onConfirm,
              icon: const Icon(Icons.flash_on_rounded, size: 15),
              label: Text(
                'exam_rules_skip'.tr,
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
            const SizedBox(width: 6),
          ] else ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 14,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, size: 15),
              label: Text(
                'exam_back'.tr,
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Right Action Button (Expanded so it always fits without overflow!)
          Expanded(
            child: isRevisit
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('close'.tr),
                    ),
                  )
                : currentIndex < total - 1
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      elevation: 1.5,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 14 : 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'exam_next'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 12 : 18,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onConfirm,
                    icon: const Icon(Icons.play_arrow_rounded, size: 19),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'exam_rules_confirm'.tr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
