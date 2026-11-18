import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/question_model.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../home_controller.dart';
import '../../exam/widgets/exam_rules_dialog.dart';

class LearningJourney extends StatelessWidget {
  final HomeController controller;
  const LearningJourney({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeading('journey_title'.tr, subtitle: 'journey_description'.tr),
      const SizedBox(height: 18),
      LayoutBuilder(
        builder: (context, constraints) {
          final steps = [
            _JourneyStep(
              number: '01',
              icon: Icons.menu_book_outlined,
              title: 'journey_learn'.tr,
              description: 'journey_learn_hint'.tr,
              onTap: () => controller.openStudy(Category.general),
            ),
            _JourneyStep(
              number: '02',
              icon: Icons.sports_esports_outlined,
              title: 'quiz_mode_blitz'.tr,
              description: 'quiz_game_subtitle'.tr,
              onTap: () => Get.toNamed(AppRoutes.quizPractice),
            ),
            Obx(
              () => _JourneyStep(
                number: '03',
                icon: Icons.workspace_premium_rounded,
                title: 'real_exam'.tr,
                description: 'journey_exam_hint'.tr,
                isHighlight: true,
                onTap: controller.canStartExam
                    ? () {
                        ExamRulesDialog.show(
                          context,
                          onStart: () => controller.startExam(skipRules: true),
                          isRevisit: false,
                        );
                      }
                    : null,
              ),
            ),
            _JourneyStep(
              number: '04',
              icon: Icons.insights_outlined,
              title: 'progress'.tr,
              description: 'journey_progress_hint'.tr,
              onTap: () => showProgress(context),
            ),
          ];

          if (constraints.maxWidth < 900) {
            return Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  steps[i],
                ],
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  Expanded(child: steps[i]),
                ],
              ],
            ),
          );
        },
      ),
    ],
  );
}

class _JourneyStep extends StatelessWidget {
  final String number, title, description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isHighlight;

  const _JourneyStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      accentColor: isHighlight ? AppColors.accentGold : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isHighlight
                  ? AppColors.accentGold.withValues(alpha: 0.22)
                  : theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: isHighlight
                  ? Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.6),
                    )
                  : null,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isHighlight
                  ? const Color(0xFFB58316)
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isHighlight
                            ? const Color(0xFFB58316)
                            : AppColors.mutedFor(theme.brightness),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedFor(theme.brightness),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.mutedFor(theme.brightness),
          ),
        ],
      ),
    );
  }
}
