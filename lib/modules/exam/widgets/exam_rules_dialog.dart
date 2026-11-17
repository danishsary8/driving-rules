import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';

/// A prominent, beautifully styled popup modal that explains the official driving
/// exam rules in detail before starting the exam, and can be re-opened anytime
/// during the session via the in-exam reminder pill.
class ExamRulesDialog extends StatelessWidget {
  final VoidCallback onStart;
  final bool isRevisit;

  const ExamRulesDialog({
    super.key,
    required this.onStart,
    this.isRevisit = false,
  });

  /// Shows the rules modal dialog.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onStart,
    bool isRevisit = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => ExamRulesDialog(
        onStart: onStart,
        isRevisit: isRevisit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 480;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 16 : 24,
        vertical: 20,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with decorative gold accent
            Container(
              padding: EdgeInsets.fromLTRB(compact ? 16 : 22, 18, 14, 18),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF22362F)
                    : const Color(0xFFF3F7F4),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: compact ? 42 : 48,
                    height: compact ? 42 : 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFB58316),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'exam_rules_title'.tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Kanit',
                            fontSize: compact ? 16 : 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'exam_rules_subtitle'.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedFor(theme.brightness),
                            fontSize: compact ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'close'.tr,
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable rules content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(compact ? 16 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CRITICAL PRIORITY RULE CARD (Top prominence)
                    _RuleCard(
                      icon: Icons.error_outline_rounded,
                      iconColor: AppColors.accentRed,
                      badgeColor: AppColors.accentRed.withValues(alpha: 0.12),
                      borderColor: AppColors.accentRed.withValues(alpha: 0.4),
                      backgroundColor: isDark
                          ? const Color(0xFF331F20)
                          : const Color(0xFFFFF4F2),
                      title: 'rule_priority_title'.tr,
                      description: 'rule_priority_desc'.tr,
                      titleColor: AppColors.accentRed,
                      isCrucial: true,
                    ),
                    const SizedBox(height: 12),

                    // PASSING SCORE CARD
                    _RuleCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.accentGreen,
                      badgeColor: AppColors.accentGreen.withValues(alpha: 0.12),
                      borderColor: AppColors.accentGreen.withValues(alpha: 0.35),
                      backgroundColor: isDark
                          ? const Color(0xFF1E332C)
                          : const Color(0xFFF2F8F5),
                      title: 'rule_pass_title'.tr,
                      description: 'rule_pass_desc'.tr,
                    ),
                    const SizedBox(height: 12),

                    // TIME LIMIT CARD
                    _RuleCard(
                      icon: Icons.timer_outlined,
                      iconColor: const Color(0xFF286AA8),
                      badgeColor: const Color(0xFF286AA8).withValues(alpha: 0.12),
                      borderColor: const Color(0xFF286AA8).withValues(alpha: 0.3),
                      backgroundColor: isDark
                          ? const Color(0xFF1C2D3D)
                          : const Color(0xFFF2F6FB),
                      title: 'rule_time_title'.tr,
                      description: 'rule_time_desc'.tr,
                    ),
                    const SizedBox(height: 12),

                    // NAVIGATION & REVIEW CARD
                    _RuleCard(
                      icon: Icons.swap_horiz_rounded,
                      iconColor: AppColors.mutedFor(theme.brightness),
                      badgeColor: theme.colorScheme.surfaceContainerHighest,
                      borderColor: theme.dividerColor,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      title: 'rule_nav_title'.tr,
                      description: 'rule_nav_desc'.tr,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom action bar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 16 : 22,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (!isRevisit) ...[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('close'.tr),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onStart();
                      },
                      icon: Icon(
                        isRevisit
                            ? Icons.check_circle_outline
                            : Icons.play_arrow_rounded,
                        size: 20,
                      ),
                      label: Text(
                        isRevisit ? 'close'.tr : 'exam_rules_confirm'.tr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
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

class _RuleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor, badgeColor, borderColor, backgroundColor;
  final String title, description;
  final Color? titleColor;
  final bool isCrucial;

  const _RuleCard({
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.title,
    required this.description,
    this.titleColor,
    this.isCrucial = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCrucial ? 1.5 : 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: titleColor ?? theme.textTheme.titleSmall?.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (isCrucial)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'STRICT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.55,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
