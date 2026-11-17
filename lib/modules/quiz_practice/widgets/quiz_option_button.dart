import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/themes/app_theme.dart';
import '../../../shared/widgets/press_scale.dart';

/// Game arcade styled answer option card with tactile press and rewarding animations.
class QuizOptionButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isAnswerChecked;
  final bool isCorrectAnswer;
  final VoidCallback onTap;

  const QuizOptionButton({
    super.key,
    required this.text,
    required this.index,
    required this.isSelected,
    required this.isAnswerChecked,
    required this.isCorrectAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // State styling determination
    Color backgroundColor;
    Color borderColor;
    Color badgeColor;
    Color badgeTextColor;
    Widget? trailingIcon;

    if (!isAnswerChecked) {
      backgroundColor = isDark ? const Color(0xFF1E3029) : theme.cardColor;
      borderColor = theme.dividerColor.withValues(alpha: 0.6);
      badgeColor = theme.colorScheme.surfaceContainerHighest;
      badgeTextColor = AppColors.mutedFor(theme.brightness);
      trailingIcon = null;
    } else if (isCorrectAnswer) {
      // Highlight correct answer in emerald
      backgroundColor = isDark ? const Color(0xFF1B3D30) : const Color(0xFFE9F8F0);
      borderColor = AppColors.accentGreen;
      badgeColor = AppColors.accentGreen;
      badgeTextColor = Colors.white;
      trailingIcon = const Icon(
        Icons.check_circle_rounded,
        color: AppColors.accentGreen,
        size: 22,
      );
    } else if (isSelected && !isCorrectAnswer) {
      // Wrong selection in red
      backgroundColor = isDark ? const Color(0xFF381F22) : const Color(0xFFFFF0ED);
      borderColor = AppColors.accentRed;
      badgeColor = AppColors.accentRed;
      badgeTextColor = Colors.white;
      trailingIcon = const Icon(
        Icons.cancel_rounded,
        color: AppColors.accentRed,
        size: 22,
      );
    } else {
      // Muted unselected option
      backgroundColor = isDark ? const Color(0xFF182621) : const Color(0xFFF9FBF9);
      borderColor = theme.dividerColor.withValues(alpha: 0.3);
      badgeColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      badgeTextColor = AppColors.mutedFor(theme.brightness).withValues(alpha: 0.5);
      trailingIcon = null;
    }

    final cardContent = PressScale(
      onTap: isAnswerChecked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected || (isAnswerChecked && isCorrectAnswer) ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (isAnswerChecked && isCorrectAnswer)
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Option letter badge (A, B, C, D)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                String.fromCharCode(65 + index),
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: badgeTextColor,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Answer text in Khmer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'NotoSansKhmer',
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),

            if (trailingIcon != null) ...[
              const SizedBox(width: 10),
              trailingIcon,
            ],
          ],
        ),
      ),
    );

    // Apply shake animation if wrong, or bounce scale if correct
    if (isAnswerChecked && isSelected && !isCorrectAnswer) {
      return cardContent.animate().shake(
            duration: 400.ms,
            hz: 4,
            curve: Curves.easeInOut,
          );
    } else if (isAnswerChecked && isCorrectAnswer) {
      return cardContent.animate().scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1.0, 1.0),
            curve: Curves.elasticOut,
            duration: 500.ms,
          );
    }

    return cardContent;
  }
}
