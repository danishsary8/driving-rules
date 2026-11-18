import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_haptics.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import '../exam/widgets/answer_option.dart';
import '../exam/widgets/question_card.dart';
import 'review_controller.dart';

enum ReviewFilter { all, mistakesOnly, priorityOnly }

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewFilter _activeFilter = ReviewFilter.all;
  ReviewController get controller => Get.find<ReviewController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityCount = controller.questions
        .where((q) => q.category == Category.priority)
        .length;

    final indices = [
      for (var i = 0; i < controller.questions.length; i++)
        if (_activeFilter == ReviewFilter.all ||
            (_activeFilter == ReviewFilter.mistakesOnly &&
                !controller.isCorrect(i)) ||
            (_activeFilter == ReviewFilter.priorityOnly &&
                controller.questions[i].category == Category.priority))
          i,
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
                            selected: _activeFilter == ReviewFilter.all,
                            selectedColor: AppColors.accentGold.withValues(
                              alpha: .3,
                            ),
                            onSelected: (_) {
                              AppHaptics.selection();
                              setState(() => _activeFilter = ReviewFilter.all);
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              '${'review_mistakes'.tr} (${controller.wrongCount})',
                            ),
                            selected: _activeFilter == ReviewFilter.mistakesOnly,
                            selectedColor: AppColors.accentRed.withValues(
                              alpha: .2,
                            ),
                            onSelected: (_) {
                              AppHaptics.selection();
                              setState(
                                () => _activeFilter = ReviewFilter.mistakesOnly,
                              );
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              '${'review_priority'.tr} ($priorityCount)',
                            ),
                            selected: _activeFilter == ReviewFilter.priorityOnly,
                            selectedColor: const Color(0xFFD4AF37).withValues(
                              alpha: .25,
                            ),
                            onSelected: (_) {
                              AppHaptics.selection();
                              setState(
                                () => _activeFilter = ReviewFilter.priorityOnly,
                              );
                            },
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
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Get.find<StorageService>().isBookmarked(
                                      question.id,
                                    )
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: Get.find<StorageService>().isBookmarked(
                                      question.id,
                                    )
                                    ? const Color(0xFFEAB308)
                                    : theme.hintColor,
                                size: 22,
                              ),
                              tooltip: 'bookmark_add'.tr,
                              onPressed: () async {
                                await Get.find<StorageService>().toggleBookmark(
                                  question.id,
                                );
                                AppHaptics.selection();
                                if (mounted) setState(() {});
                              },
                              splashRadius: 20,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 8),
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
                        if (!correct) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD97706),
                                  side: const BorderSide(
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                onPressed: () {
                                  AppHaptics.success();
                                  final storage = Get.find<StorageService>();
                                  storage.addMistakeId(question.id);
                                  Get.snackbar(
                                    'mistakes_bank'.tr,
                                    'added_to_mistakes'.tr,
                                    snackPosition: SnackPosition.BOTTOM,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                                icon: const Icon(
                                  Icons.bookmark_add_outlined,
                                  size: 17,
                                ),
                                label: Text('add_to_mistakes'.tr),
                              ),
                            ],
                          ),
                        ],
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
