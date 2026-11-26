import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/data_service.dart';
import '../../../shared/widgets/app_motion.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../home_controller.dart';

class DashboardStats extends StatelessWidget {
  final HomeController controller;
  const DashboardStats({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => Obx(() {
    final ready = controller.data.status.value == DataStatus.ready;
    final count = ready
        ? learningCategories.fold<int>(
            0,
            (sum, c) => sum + controller.data.questionsFor(c).length,
          )
        : 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.menu_book_outlined,
                  value: count,
                  label: 'practice_questions'.tr,
                  compact: compact,
                ),
              ),
              SizedBox(width: compact ? 8 : 16),
              Expanded(
                child: _Metric(
                  icon: Icons.layers_outlined,
                  value: learningCategories.length,
                  label: 'learning_categories'.tr,
                  compact: compact,
                ),
              ),
              SizedBox(width: compact ? 8 : 16),
              Expanded(
                child: _Metric(
                  icon: Icons.emoji_events_outlined,
                  value: controller.bestScore,
                  suffix: '/45',
                  empty: controller.lastResult == null,
                  label: 'best_score'.tr,
                  compact: compact,
                ),
              ),
            ],
          ),
        );
      },
    );
  });
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label, suffix;
  final bool compact, empty;
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.compact,
    this.suffix = '',
    this.empty = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (empty)
          Text('—', style: theme.textTheme.headlineMedium)
        else
          AnimatedNumber(
            value: value,
            suffix: suffix,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: compact ? 27 : 31,
            ),
          ),
        const SizedBox(height: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: compact ? 12 : 14,
          ),
        ),
      ],
    );
    return PremiumCard(
      padding: EdgeInsets.all(compact ? 12 : 22),
      borderRadius: 18,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 22, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                content,
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 25, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 17),
                Expanded(child: content),
              ],
            ),
    );
  }
}
