import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/question_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../exam/widgets/answer_option.dart';
import '../../exam/widgets/question_card.dart';

/// One reviewed exam question: header (number, bookmark, correct/wrong), the
/// question, the learner's and correct answers, the explanation, and an
/// "add to mistakes" action for wrong answers.
///
/// Owns its bookmark state so toggling a bookmark rebuilds only this card.
class ReviewQuestionCard extends StatefulWidget {
  const ReviewQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.correct,
    required this.selected,
  });

  /// 0-based position in the exam (shown as `index + 1`).
  final int index;
  final Question question;

  /// Whether the learner answered this question correctly.
  final bool correct;

  /// The option the learner chose, or `null` when unanswered.
  final int? selected;

  @override
  State<ReviewQuestionCard> createState() => _ReviewQuestionCardState();
}

class _ReviewQuestionCardState extends State<ReviewQuestionCard> {
  StorageService get _storage => Get.find<StorageService>();

  Future<void> _toggleBookmark() async {
    await _storage.toggleBookmark(widget.question.id);
    AppHaptics.selection();
    if (mounted) setState(() {});
  }

  void _addToMistakes() {
    AppHaptics.success();
    _storage.addMistakeId(widget.question.id);
    Get.snackbar(
      'mistakes_bank'.tr,
      'added_to_mistakes'.tr,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final selected = widget.selected;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewCardHeader(
            index: widget.index,
            question: question,
            correct: widget.correct,
            bookmarked: _storage.isBookmarked(question.id),
            onToggleBookmark: _toggleBookmark,
          ),
          const SizedBox(height: 22),
          QuestionCard(question: question),
          const SizedBox(height: 24),
          if (selected == null) ...[
            Text(
              'review_no_answer'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.contentColor(
                  AppColors.accentRed,
                  Theme.of(context).brightness,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          for (var n = 0; n < question.options.length; n++)
            _ReviewAnswer(
              question: question,
              optionIndex: n,
              selected: selected,
            ),
          const SizedBox(height: 12),
          _ExplanationBox(question: question),
          if (!widget.correct) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD97706),
                    side: const BorderSide(color: Color(0xFFD97706)),
                  ),
                  onPressed: _addToMistakes,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 17),
                  label: Text('add_to_mistakes'.tr),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// "Question 07 · Category" label, bookmark toggle and correct/wrong chip.
class _ReviewCardHeader extends StatelessWidget {
  const _ReviewCardHeader({
    required this.index,
    required this.question,
    required this.correct,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  final int index;
  final Question question;
  final bool correct;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            '${'exam_question_progress'.tr} ${(index + 1).toString().padLeft(2, '0')} · ${question.category.navKey.tr}',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: bookmarked ? const Color(0xFFEAB308) : theme.hintColor,
            size: 22,
          ),
          tooltip: 'bookmark_add'.tr,
          onPressed: onToggleBookmark,
          splashRadius: 20,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(width: 8),
        StatusChip(
          (correct ? 'review_correct' : 'review_wrong').tr,
          icon: correct ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: correct ? AppColors.accentGreen : AppColors.accentRed,
        ),
      ],
    );
  }
}

/// One answer option, marked correct/wrong and captioned when it is the
/// correct answer or the learner's choice.
class _ReviewAnswer extends StatelessWidget {
  const _ReviewAnswer({
    required this.question,
    required this.optionIndex,
    required this.selected,
  });

  final Question question;
  final int optionIndex;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final n = optionIndex;
    final isCorrectOption = n == question.correctIndex;
    final isSelected = n == selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnswerOption(
            text: question.options[n],
            index: n,
            selected: isSelected,
            correct: isCorrectOption || isSelected ? isCorrectOption : null,
            onTap: null,
          ),
          if (isCorrectOption || isSelected)
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 8),
              child: Text(
                (isCorrectOption
                        ? isSelected
                              ? 'review_your_correct_answer'
                              : 'review_correct_answer'
                        : 'review_your_answer')
                    .tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.contentColor(
                    isCorrectOption
                        ? AppColors.accentGreen
                        : AppColors.accentRed,
                    Theme.of(context).brightness,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lightbulb box with the explanation in the current UI language.
class _ExplanationBox extends StatelessWidget {
  const _ExplanationBox({required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 19,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'explanation_title'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Get.locale?.languageCode == 'en'
                      ? question.explanationTipEn
                      : question.explanationTipKh,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    fontSize: 13,
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
