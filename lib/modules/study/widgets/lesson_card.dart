import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/models/question_model.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../exam/widgets/question_card.dart';

/// A reading card with one correct answer. Quiz options belong to practice.
class LessonCard extends StatelessWidget {
  final Question question;
  final int number;
  const LessonCard({super.key, required this.question, required this.number});

  static final _optionPrefix = RegExp(r'^[កខគ]\s*[-–—]\s*');

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      final prompt = QuestionCard(
        question: question,
        imageHint: 'study_image_read_hint'.tr,
      );
      final answer = _CorrectAnswer(
        text: question.correctAnswer.replaceFirst(_optionPrefix, '').trim(),
      );
      return PremiumCard(
        padding: EdgeInsets.all(compact ? 20 : 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                StatusChip(
                  '${'exam_question_progress'.tr} ${number.toString().padLeft(2, '0')}',
                  color: question.category.color,
                ),
                Text(
                  question.category.navKey.tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (question.isImagePrompt && constraints.maxWidth >= 680)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: prompt),
                  const SizedBox(width: 28),
                  Expanded(flex: 6, child: answer),
                ],
              )
            else ...[
              prompt,
              const SizedBox(height: 22),
              answer,
            ],
          ],
        ),
      );
    },
  );
}

class _CorrectAnswer extends StatelessWidget {
  final String text;
  const _CorrectAnswer({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: .22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, size: 22, color: scheme.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'study_correct_answer'.tr,
                  style: AppTextStyles.body2.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectionArea(
            child: Text(
              text,
              key: const ValueKey('lesson-answer'),
              style: AppTextStyles.body1.copyWith(
                color: scheme.onPrimaryContainer,
                fontSize: 18,
                height: 1.85,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
