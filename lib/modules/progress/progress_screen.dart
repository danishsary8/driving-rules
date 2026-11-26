import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/exam_analytics_model.dart';
import '../../core/models/question_model.dart';
import '../../core/utils/app_haptics.dart';
import '../../modules/exam/widgets/exam_rules_dialog.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import 'progress_controller.dart';

/// Full-page interactive Analytics & Readiness Dashboard screen.
class ProgressScreen extends GetView<ProgressController> {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppShell(
      title: 'my_progress'.tr,
      showBack: true,
      child: Obx(() {
        final readiness = controller.readiness.value;
        final history = controller.history;
        final mastery = controller.mastery;

        return PageContent(
          maxWidth: 960,
          children: [
            // Top Header
            Eyebrow('your_progress'.tr),
            const SizedBox(height: 6),
            Text(
              'my_progress'.tr,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: MediaQuery.sizeOf(context).width < 600 ? 26 : 34,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'progress_subtitle'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.mutedFor(theme.brightness),
              ),
            ),
            const SizedBox(height: 24),

            // 1. Overall Readiness Hero Card
            if (readiness != null)
              _ReadinessHeroCard(readiness: readiness, controller: controller),
            const SizedBox(height: 24),

            // 2. Score History Bar Chart
            if (history.isNotEmpty)
              _ScoreHistoryChart(history: history)
            else
              _EmptyHistoryCard(),
            const SizedBox(height: 24),

            // 3. Category Mastery Breakdown
            if (mastery.isNotEmpty) _CategoryMasterySection(mastery: mastery),
            const SizedBox(height: 24),

            // 4. Quick Action Hub (Mistakes, Bookmarks, Flashcards)
            _QuickActionHub(controller: controller),
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }
}

class _ReadinessHeroCard extends StatelessWidget {
  final ExamReadiness readiness;
  final ProgressController controller;

  const _ReadinessHeroCard({required this.readiness, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color tierColor = switch (readiness.level) {
      ReadinessLevel.ready => const Color(0xFF10B981),
      ReadinessLevel.moderate => const Color(0xFFF59E0B),
      ReadinessLevel.needsPractice => const Color(0xFFEF4444),
      ReadinessLevel.unrated => const Color(0xFF64748B),
    };

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(
                readiness.level.labelKey.tr,
                icon: Icons.speed_rounded,
                color: tierColor,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'progress_ready_pct'.trParams({'pct': '${readiness.score}'}),
                  style: TextStyle(
                    color: tierColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 600;
              final gauge = SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: readiness.score / 100,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        color: tierColor,
                        backgroundColor: theme.dividerColor,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${readiness.score}%',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: tierColor,
                          ),
                        ),
                        Text(
                          'readiness_label'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: AppColors.mutedFor(theme.brightness),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final pills = [
                _MetricPill(
                  label: 'attempts_count'.tr,
                  value: '${readiness.totalAttempts}',
                  icon: Icons.history_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                _MetricPill(
                  label: 'pass_rate'.tr,
                  value: '${(readiness.passRate * 100).round()}%',
                  icon: Icons.verified_rounded,
                  color: const Color(0xFF10B981),
                ),
                _MetricPill(
                  label: 'best_score'.tr,
                  value: '${controller.bestScore}/45',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ];

              if (isSmall) {
                // Three equal-width tiles in one row, so they never wrap
                // unevenly (2 + 1) on phones.
                return Column(
                  children: [
                    gauge,
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < pills.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: pills[i].stacked()),
                        ],
                      ],
                    ),
                  ],
                );
              }
              final metrics = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: pills,
              );

              return Row(
                children: [
                  gauge,
                  const SizedBox(width: 28),
                  Expanded(child: metrics),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Tip Callout
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 20,
                  color: tierColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    readiness.recommendationKey.tr,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
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

/// Small tinted stat tile (icon, value, label). [stacked] lays the content out
/// vertically so three tiles fit side by side on a phone.
class _MetricPill extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isStacked;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isStacked = false,
  });

  /// A copy of this tile with its content stacked vertically.
  _MetricPill stacked() => _MetricPill(
    label: label,
    value: value,
    icon: icon,
    color: color,
    isStacked: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isStacked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreHistoryChart extends StatelessWidget {
  final List<dynamic> history;
  const _ScoreHistoryChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = history.length <= 10
        ? history
        : history.sublist(history.length - 10);

    return PremiumCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionHeading(
                  'score_history_title'.tr,
                  subtitle: 'score_history_desc'.tr,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'progress_pass_line'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Chart Bars
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _ChartBar(result: recent[i], number: i + 1),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'progress_first_exam'.tr,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
              Text(
                'progress_latest_exam'.tr,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final dynamic result;
  final int number;

  const _ChartBar({required this.result, required this.number});

  @override
  Widget build(BuildContext context) {
    final correct = result.totalCorrect as int;
    final total = result.total as int;
    final passed = result.passed as bool;
    final fraction = (correct / total).clamp(0.0, 1.0);
    final color = passed ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Tooltip(
      message: 'progress_attempt_tip'.trParams({
        'n': '$number',
        'c': '$correct',
        't': '$total',
        's': (passed ? 'progress_passed' : 'progress_failed').tr,
      }),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$correct',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: Container(height: 110 * fraction, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            '#$number',
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _CategoryMasterySection extends StatelessWidget {
  final List<CategoryMastery> mastery;
  const _CategoryMasterySection({required this.mastery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeading(
            'category_mastery_title'.tr,
            subtitle: 'category_mastery_desc'.tr,
          ),
          const SizedBox(height: 18),
          for (final item in mastery) ...[
            Builder(
              builder: (context) {
                final statusColor = item.accuracy >= 0.8
                    ? const Color(0xFF10B981)
                    : (item.accuracy >= 0.6
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFEF4444));

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item.category.icon,
                                size: 18,
                                color: item.category.color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.category.navKey.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${(item.accuracy * 100).round()}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: item.category.color,
                                ),
                              ),
                              const SizedBox(width: 8),
                              StatusChip(item.statusKey.tr, color: statusColor),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.accuracy,
                          minHeight: 6,
                          backgroundColor: theme.dividerColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            item.category.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionHub extends StatelessWidget {
  final ProgressController controller;
  const _QuickActionHub({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 600;
        final buttons = [
          _HubActionCard(
            title: 'mistakes_bank'.tr,
            count: controller.mistakeCount,
            icon: Icons.auto_fix_high_rounded,
            color: const Color(0xFFD97706),
            onTap: () => Get.toNamed(AppRoutes.mistakes),
          ),
          _HubActionCard(
            title: 'study_bookmarks'.tr,
            count: controller.bookmarkCount,
            icon: Icons.bookmark_rounded,
            color: const Color(0xFFCA8A04),
            onTap: () =>
                Get.toNamed(AppRoutes.study, arguments: Category.general),
          ),
          _HubActionCard(
            title: 'flashcards_title'.tr,
            count: 100,
            icon: Icons.style_rounded,
            color: const Color(0xFF2563EB),
            onTap: () => Get.toNamed(AppRoutes.flashcards),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Row(
                children: [
                  for (final b in buttons) ...[
                    Expanded(child: b),
                    if (b != buttons.last) const SizedBox(width: 14),
                  ],
                ],
              )
            else
              for (final b in buttons) ...[
                b,
                if (b != buttons.last) const SizedBox(height: 12),
              ],
            const SizedBox(height: 22),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                AppHaptics.selection();
                ExamRulesDialog.show(
                  context,
                  onStart: () => Get.toNamed(
                    AppRoutes.exam,
                    arguments: {'skipRules': true},
                  ),
                  isRevisit: false,
                );
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                'real_exam'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HubActionCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HubActionCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: color,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'progress_items'.trParams({'n': '$count'}),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistoryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(
            Icons.insights_rounded,
            size: 48,
            color: AppColors.mutedFor(theme.brightness),
          ),
          const SizedBox(height: 14),
          Text(
            'progress_empty'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'progress_first_step'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedFor(theme.brightness),
            ),
          ),
        ],
      ),
    );
  }
}
