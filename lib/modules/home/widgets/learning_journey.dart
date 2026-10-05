import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/question_model.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../home_controller.dart';

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
            Obx(
              () => _JourneyStep(
                number: '02',
                icon: Icons.route_outlined,
                title: 'practice'.tr,
                description: 'journey_practice_hint'.tr,
                onTap: controller.canStartExam ? controller.startExam : null,
              ),
            ),
            _JourneyStep(
              number: '03',
              icon: Icons.insights_outlined,
              title: 'progress'.tr,
              description: 'journey_progress_hint'.tr,
              onTap: () => showProgress(context),
            ),
          ];
          if (constraints.maxWidth < 850) {
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
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
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
  const _JourneyStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => PremiumCard(
    onTap: onTap,
    padding: const EdgeInsets.all(18),
    borderRadius: 17,
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$number · $title',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 5),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    ),
  );
}
