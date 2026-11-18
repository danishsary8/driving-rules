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
  final bool isBookmarked;
  final VoidCallback? onToggleBookmark;

  const LessonCard({
    super.key,
    required this.question,
    required this.number,
    this.isBookmarked = false,
    this.onToggleBookmark,
  });

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
        question: question,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusChip(
                      '${'exam_question_progress'.tr} ${number.toString().padLeft(2, '0')}',
                      color: question.category.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      question.category.navKey.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                if (onToggleBookmark != null)
                  IconButton(
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isBookmarked
                          ? const Color(0xFFEAB308)
                          : Theme.of(context).hintColor,
                      size: 24,
                    ),
                    tooltip: isBookmarked
                        ? 'bookmark_remove'.tr
                        : 'bookmark_add'.tr,
                    onPressed: onToggleBookmark,
                    splashRadius: 20,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
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
  final Question question;
  final String text;
  const _CorrectAnswer({required this.question, required this.text});

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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Get.locale?.languageCode == 'en'
                        ? question.explanationTipEn
                        : question.explanationTipKh,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurface.withValues(alpha: 0.8),
                      height: 1.45,
                    ),
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
