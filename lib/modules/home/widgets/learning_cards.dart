import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/question_model.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../exam/widgets/exam_rules_dialog.dart';

/// Card for studying a specific category of driving rules.
class LearningCategoryCard extends StatelessWidget {
  final Category category;
  final int number, count;
  final VoidCallback onTap;

  const LearningCategoryCard({
    super.key,
    required this.category,
    required this.number,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PremiumCard(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      accentColor: category.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: category.color.withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  category.icon,
                  size: 26,
                  color: AppColors.contentColor(category.color, theme.brightness),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  number.toString().padLeft(2, '0'),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            category.navKey.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Kanit',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'category_${category.fileStem}_description'.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedFor(theme.brightness),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$count ${'study_question_count'.tr}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.contentColor(category.color, theme.brightness),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Official Real Exam Simulation Card with Gold/Amber styling, Shield icon,
/// pass criteria, and the critical auto-fail rule highlighted.
class RealExamCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const RealExamCard({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2D27) : const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: isDark ? 0.45 : 0.75),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: isDark ? 0.12 : 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.6),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 28,
                  color: Color(0xFFB58316),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'official_simulation'.tr.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB58316),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'real_exam'.tr,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'real_exam_desc'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedFor(theme.brightness),
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 16),

          // Feature chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeatureChip(
                icon: Icons.timer_outlined,
                label: '45 Mins · 45 Qs',
                color: const Color(0xFF286AA8),
              ),
              _FeatureChip(
                icon: Icons.check_circle_outline,
                label: '38+ to Pass',
                color: AppColors.accentGreen,
              ),
              _FeatureChip(
                icon: Icons.warning_amber_rounded,
                label: 'Priority: 0 Error',
                color: AppColors.accentRed,
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Button with rule popup reminder
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC99726),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              onPressed: enabled
                  ? () {
                      AppHaptics.light();
                      ExamRulesDialog.show(
                        context,
                        onStart: onTap,
                        isRevisit: false,
                      );
                    }
                  : null,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                'start_real_exam'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Free Practice Mode Card with Emerald styling, Compass/Route icon,
/// and stress-free learning description.
class PracticeModeCard extends StatelessWidget {
  final VoidCallback onTap;

  const PracticeModeCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2C26) : const Color(0xFFF3FAF6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.accentGreen.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.explore_outlined,
                  size: 26,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'free_practice'.tr.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentGreen,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'practice_mode'.tr,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'Kanit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'practice_mode_desc'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedFor(theme.brightness),
              height: 1.5,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 16),

          // Feature chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FeatureChip(
                icon: Icons.all_inclusive_rounded,
                label: 'Untimed',
                color: AppColors.accentGreen,
              ),
              _FeatureChip(
                icon: Icons.lightbulb_outline_rounded,
                label: 'Direct Answers',
                color: const Color(0xFFB58316),
              ),
              _FeatureChip(
                icon: Icons.security_rounded,
                label: 'No Auto-Fail',
                color: AppColors.accentGreen,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons: Speed Quiz Game + Study Lessons
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 350;
              final gameBtn = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Get.toNamed(AppRoutes.quizPractice),
                icon: const Icon(Icons.sports_esports_rounded, size: 20),
                label: Text(
                  'quiz_mode_blitz'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );

              final studyBtn = OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentGreen,
                  side: const BorderSide(
                    color: AppColors.accentGreen,
                    width: 1.2,
                  ),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: onTap,
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(
                  'lessons'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );

              if (isSmall) {
                return Column(
                  children: [
                    gameBtn,
                    const SizedBox(height: 8),
                    studyBtn,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 6, child: gameBtn),
                  const SizedBox(width: 10),
                  Expanded(flex: 5, child: studyBtn),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Backward compatible alias for PracticeExamCard, mapped to RealExamCard.
class PracticeExamCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const PracticeExamCard({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => RealExamCard(
    enabled: enabled,
    onTap: onTap,
  );
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool highlight;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: highlight ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: highlight ? 0.6 : 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
