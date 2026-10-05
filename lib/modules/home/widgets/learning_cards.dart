import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/question_model.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';

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
  Widget build(BuildContext context) => PremiumCard(
    onTap: onTap,
    accentColor: category.color,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                category.icon,
                size: 29,
                color: AppColors.contentColor(
                  category.color,
                  Theme.of(context).brightness,
                ),
              ),
            ),
            const Spacer(),
            Eyebrow(number.toString().padLeft(2, '0')),
          ],
        ),
        const SizedBox(height: 22),
        Text(category.navKey.tr, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          'category_${category.fileStem}_description'.tr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedFor(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                '$count ${'study_question_count'.tr}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: .12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class PracticeExamCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const PracticeExamCard({
    super.key,
    required this.enabled,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => PremiumCard(
    accentColor: AppColors.accentGold,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: .25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.route_outlined,
                size: 29,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            StatusChip('practice'.tr, color: const Color(0xFF8C6A22)),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'ready_for_test'.tr,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'exam_card_description'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enabled ? onTap : null,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: Text('exam_start'.tr),
          ),
        ),
      ],
    ),
  );
}
