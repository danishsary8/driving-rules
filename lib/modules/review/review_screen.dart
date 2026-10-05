import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import '../exam/widgets/answer_option.dart';
import '../exam/widgets/question_card.dart';
import 'review_controller.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _mistakesOnly = false;
  ReviewController get controller => Get.find<ReviewController>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indices = [
      for (var i = 0; i < controller.questions.length; i++)
        if (!_mistakesOnly || !controller.isCorrect(i)) i,
    ];
    return AppShell(
      title: 'review_title'.tr,
      showBack: true,
      child: LayoutBuilder(
        builder: (context, constraints) => Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 1040,
            child: ListView.builder(
              padding: EdgeInsets.all(constraints.maxWidth < 600 ? 20 : 36),
              itemCount: indices.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Eyebrow('result_eyebrow'.tr),
                      const SizedBox(height: 8),
                      SectionHeading(
                        'review_title'.tr,
                        subtitle: 'review_intro'.tr,
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ChoiceChip(
                            label: Text(
                              '${'review_all'.tr} (${controller.questions.length})',
                            ),
                            selected: !_mistakesOnly,
                            selectedColor: AppColors.accentGold.withValues(
                              alpha: .3,
                            ),
                            onSelected: (_) =>
                                setState(() => _mistakesOnly = false),
                          ),
                          ChoiceChip(
                            label: Text(
                              '${'review_mistakes'.tr} (${controller.wrongCount})',
                            ),
                            selected: _mistakesOnly,
                            selectedColor: AppColors.accentGold.withValues(
                              alpha: .3,
                            ),
                            onSelected: (_) =>
                                setState(() => _mistakesOnly = true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (indices.isEmpty)
                        PremiumCard(
                          child: Text(
                            (controller.questions.isEmpty
                                    ? 'review_empty'
                                    : 'review_no_mistakes')
                                .tr,
                          ),
                        ),
                    ],
                  );
                }
                final i = indices[index - 1];
                final question = controller.questions[i];
                final correct = controller.isCorrect(i);
                final selected = controller.selectedAnswerFor(i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${'exam_question_progress'.tr} ${(i + 1).toString().padLeft(2, '0')} · ${question.category.navKey.tr}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 10),
                            StatusChip(
                              (correct ? 'review_correct' : 'review_wrong').tr,
                              icon: correct
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              color: correct
                                  ? AppColors.accentGreen
                                  : AppColors.accentRed,
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        QuestionCard(question: question),
                        const SizedBox(height: 24),
                        if (selected == null) ...[
                          Text(
                            'review_no_answer'.tr,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppColors.contentColor(
                                    AppColors.accentRed,
                                    Theme.of(context).brightness,
                                  ),
                                ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        for (var n = 0; n < question.options.length; n++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AnswerOption(
                                  text: question.options[n],
                                  index: n,
                                  selected: selected == n,
                                  correct:
                                      n == question.correctIndex ||
                                          n == selected
                                      ? n == question.correctIndex
                                      : null,
                                  onTap: null,
                                ),
                                if (n == question.correctIndex || n == selected)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 5,
                                      left: 8,
                                    ),
                                    child: Text(
                                      (n == question.correctIndex
                                              ? n == selected
                                                    ? 'review_your_correct_answer'
                                                    : 'review_correct_answer'
                                              : 'review_your_answer')
                                          .tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.contentColor(
                                              n == question.correctIndex
                                                  ? AppColors.accentGreen
                                                  : AppColors.accentRed,
                                              Theme.of(context).brightness,
                                            ),
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
