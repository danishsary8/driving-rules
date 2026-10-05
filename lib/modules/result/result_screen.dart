import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/exam_result_model.dart';
import '../../core/models/question_model.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import '../../shared/widgets/app_motion.dart';
import 'result_controller.dart';

class ResultScreen extends GetView<ResultController> {
  const ResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final result = controller.result;
    final color = controller.passed
        ? AppColors.accentGreen
        : const Color(0xFFAD822B);
    return AppShell(
      title: 'result_score'.tr,
      child: PageContent(
        maxWidth: 1040,
        children: [
          Eyebrow('result_eyebrow'.tr),
          const SizedBox(height: 8),
          Text(
            (controller.passed ? 'result_pass_heading' : 'result_fail_heading')
                .tr,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: MediaQuery.sizeOf(context).width < 600 ? 28 : 36,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            (controller.passed
                    ? 'result_pass_description'
                    : 'result_fail_description')
                .tr,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedFor(Theme.of(context).brightness),
            ),
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final score = PremiumCard(
                child: Column(
                  children: [
                    StatusChip(
                      (controller.passed ? 'result_passed' : 'result_failed')
                          .tr,
                      icon: controller.passed
                          ? Icons.verified_outlined
                          : Icons.school_outlined,
                      color: color,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 186,
                      height: 186,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: result.totalCorrect / result.total,
                              ),
                              duration: AppMotion.duration(
                                context,
                                const Duration(milliseconds: 1000),
                              ),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) =>
                                  CircularProgressIndicator(
                                    value: value,
                                    strokeWidth: 10,
                                    strokeCap: StrokeCap.round,
                                    color: color,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).dividerColor,
                                  ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedNumber(
                                value: result.totalCorrect,
                                style: Theme.of(context).textTheme.displayLarge
                                    ?.copyWith(fontSize: 64),
                              ),
                              Text(
                                '${'result_score_out_of'.tr} ${result.total}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'result_score'.tr,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (controller.failReasonKey != null) ...[
                      const SizedBox(height: 12),
                      StatusChip(
                        controller.failReasonKey!.tr,
                        icon: Icons.info_outline_rounded,
                        color: AppColors.accentRed,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Divider(color: Theme.of(context).dividerColor),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ResultMetric(
                            '${result.totalCorrect}',
                            'result_correct'.tr,
                            AppColors.accentGreen,
                          ),
                        ),
                        Expanded(
                          child: _ResultMetric(
                            '${result.total - result.totalCorrect}',
                            'result_wrong'.tr,
                            AppColors.accentRed,
                          ),
                        ),
                        Expanded(
                          child: _ResultMetric(
                            '${(result.totalCorrect / result.total * 100).round()}%',
                            'result_accuracy'.tr,
                            color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
              final breakdown = PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionHeading(
                      'result_breakdown_title'.tr,
                      subtitle: 'progress_subtitle'.tr,
                    ),
                    const SizedBox(height: 28),
                    for (final c in learningCategories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(c.icon, size: 20, color: c.color),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    c.navKey.tr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelLarge,
                                  ),
                                ),
                                Text(
                                  '${result.categoryBreakdown[c] ?? 0} / ${ExamResult.blockMax[c]}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value:
                                  (result.categoryBreakdown[c] ?? 0) /
                                  ExamResult.blockMax[c]!,
                              color: c.color,
                              minHeight: 7,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'exam_rules'.tr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
              if (constraints.maxWidth >= 720) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: score),
                    const SizedBox(width: 20),
                    Expanded(flex: 5, child: breakdown),
                  ],
                );
              }
              return Column(
                children: [score, const SizedBox(height: 20), breakdown],
              );
            },
          ),
          const SizedBox(height: 22),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeading(
                  'result_next_step'.tr,
                  subtitle: 'result_review_hint'.tr,
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (controller.reviewData?.canReview ?? false)
                      ElevatedButton.icon(
                        onPressed: controller.reviewAnswers,
                        icon: const Icon(Icons.fact_check_outlined, size: 19),
                        label: Text('result_review_answers'.tr),
                      ),
                    OutlinedButton.icon(
                      onPressed: controller.tryAgain,
                      icon: const Icon(Icons.refresh_rounded, size: 19),
                      label: Text('result_try_again'.tr),
                    ),
                    TextButton(
                      onPressed: controller.backToHome,
                      child: Text('result_back_home'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final String value, label;
  final Color color;
  const _ResultMetric(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.contentColor(color, Theme.of(context).brightness),
          fontSize: 24,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
