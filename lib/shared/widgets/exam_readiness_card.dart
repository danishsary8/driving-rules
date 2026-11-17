import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/exam_analytics_model.dart';
import '../../core/models/exam_result_model.dart';
import '../../core/models/question_model.dart';
import '../../core/utils/app_haptics.dart';
import 'design_components.dart';
import 'premium_card.dart';

/// Interactive Bento Box card displaying real-time Exam Readiness Score,
/// recent attempt trends, coaching guidance, and category mastery breakdown.
class ExamReadinessCard extends StatelessWidget {
  final ExamReadiness readiness;
  final List<ExamResult> history;
  final Map<Category, CategoryMastery> mastery;
  final bool compact;
  final VoidCallback? onTakeExam;

  const ExamReadinessCard({
    super.key,
    required this.readiness,
    required this.history,
    required this.mastery,
    this.compact = false,
    this.onTakeExam,
  });

  Color _tierColor(ReadinessLevel level) {
    switch (level) {
      case ReadinessLevel.ready:
        return const Color(0xFF10B981); // Emerald
      case ReadinessLevel.moderate:
        return const Color(0xFFF59E0B); // Amber
      case ReadinessLevel.needsPractice:
        return const Color(0xFFEF4444); // Crimson
      case ReadinessLevel.unrated:
        return const Color(0xFF64748B); // Slate
    }
  }

  IconData _tierIcon(ReadinessLevel level) {
    switch (level) {
      case ReadinessLevel.ready:
        return Icons.verified_rounded;
      case ReadinessLevel.moderate:
        return Icons.trending_up_rounded;
      case ReadinessLevel.needsPractice:
        return Icons.warning_amber_rounded;
      case ReadinessLevel.unrated:
        return Icons.analytics_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _tierColor(readiness.level);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return PremiumCard(
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Readiness badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: color.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(_tierIcon(readiness.level), color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow('exam_readiness'.tr),
                        const SizedBox(height: 4),
                        Text(
                          readiness.level.labelKey.tr,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Score circle pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          readiness.level == ReadinessLevel.unrated
                              ? '—'
                              : '${readiness.score}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress gauge bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: readiness.score / 100.0,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 16),

              // Key Stats Bento Row
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'attempts_count'.tr,
                      value: '${readiness.totalAttempts}',
                      icon: Icons.history_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'pass_rate'.tr,
                      value: '${(readiness.passRate * 100).round()}%',
                      icon: Icons.check_circle_outline_rounded,
                      isDark: isDark,
                      accentColor: readiness.passRate >= 0.8
                          ? const Color(0xFF10B981)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStat(
                      label: 'nav_priority'.tr,
                      value: '${(readiness.priorityAccuracy * 100).round()}%',
                      icon: Icons.shield_outlined,
                      isDark: isDark,
                      accentColor: readiness.priorityAccuracy == 1.0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),

              // Coaching tip banner
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      readiness.hasRecentPriorityFailure
                          ? Icons.priority_high_rounded
                          : Icons.lightbulb_outline_rounded,
                      size: 18,
                      color: readiness.hasRecentPriorityFailure
                          ? const Color(0xFFEF4444)
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        readiness.hasRecentPriorityFailure
                            ? 'priority_warning_banner'.tr
                            : readiness.recommendationKey.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: readiness.hasRecentPriorityFailure
                              ? const Color(0xFFEF4444)
                              : AppColors.mutedFor(theme.brightness),
                          height: 1.4,
                          fontWeight: readiness.hasRecentPriorityFailure
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!compact && history.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  'recent_attempts'.tr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < history.length; i++) ...[
                        _AttemptChip(
                          index: i + 1,
                          result: history[i],
                          onTap: () {
                            AppHaptics.light();
                            Get.toNamed(AppRoutes.result, arguments: history[i]);
                          },
                        ),
                        if (i < history.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
              ],

              if (!compact && mastery.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  'category_mastery'.tr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final entry in mastery.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MasteryRow(
                      mastery: entry.value,
                      isDark: isDark,
                    ),
                  ),
              ],

              if (onTakeExam != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    AppHaptics.light();
                    onTakeExam!();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text('start_real_exam'.tr),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color? accentColor;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: accentColor ?? AppColors.mutedFor(theme.brightness),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.mutedFor(theme.brightness),
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttemptChip extends StatelessWidget {
  final int index;
  final ExamResult result;
  final VoidCallback onTap;

  const _AttemptChip({
    required this.index,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final passed = result.passed;
    final isPriorityFail = result.finishReason == FinishReason.priorityFail;
    final color = passed
        ? const Color(0xFF10B981)
        : (isPriorityFail ? const Color(0xFFEF4444) : const Color(0xFFF59E0B));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#$index',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${result.totalCorrect}/45',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              passed
                  ? Icons.check_rounded
                  : (isPriorityFail ? Icons.cancel_rounded : Icons.close_rounded),
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  final CategoryMastery mastery;
  final bool isDark;

  const _MasteryRow({
    required this.mastery,
    required this.isDark,
  });

  Color _statusColor(String key) {
    switch (key) {
      case 'mastery_strong':
        return const Color(0xFF10B981);
      case 'mastery_moderate':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(mastery.statusKey);
    final percentage = (mastery.accuracy * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(mastery.category.icon, size: 16, color: mastery.category.color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mastery.category.navKey.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mastery.statusKey.tr,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: mastery.accuracy,
            minHeight: 5,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
