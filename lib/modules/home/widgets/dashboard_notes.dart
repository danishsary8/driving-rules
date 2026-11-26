import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/exam_analytics_model.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../home_controller.dart';

class DashboardNotes extends StatelessWidget {
  final HomeController controller;
  const DashboardNotes({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final readiness = controller.readiness;
    final tip = _Note(
      icon: Icons.lightbulb_outline_rounded,
      eyebrow: 'learning_tip'.tr,
      title: 'tip_title'.tr,
      description: 'tip_description'.tr,
    );
    final progress = _Note(
      icon: readiness.level == ReadinessLevel.ready
          ? Icons.verified_rounded
          : (readiness.level == ReadinessLevel.moderate
                ? Icons.trending_up_rounded
                : Icons.insights_rounded),
      eyebrow: 'exam_readiness'.tr,
      title: readiness.level == ReadinessLevel.unrated
          ? (controller.lastResult == null
                ? 'progress_first_step'.tr
                : '${'last_score'.tr}: ${controller.lastResult!.totalCorrect}/45')
          : '${readiness.score}% · ${readiness.level.labelKey.tr}',
      description: readiness.level == ReadinessLevel.unrated
          ? 'readiness_unrated_tip'.tr
          : readiness.recommendationKey.tr,
      onTap: () {
        AppHaptics.light();
        showProgress(context);
      },
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 850
          ? Column(children: [tip, const SizedBox(height: 16), progress])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: tip),
                const SizedBox(width: 18),
                Expanded(child: progress),
              ],
            ),
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title, description;
  final VoidCallback? onTap;
  const _Note({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => PremiumCard(
    onTap: onTap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 27, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(eyebrow),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (onTap != null) const Icon(Icons.arrow_forward_rounded, size: 19),
      ],
    ),
  );
}
