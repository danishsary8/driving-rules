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
  final Map<int, GlobalKey> _itemKeys = {};
  int? _focusedIndex;

  GlobalKey _keyFor(int i) => _itemKeys.putIfAbsent(i, () => GlobalKey());

  void _openMatrixSheet(BuildContext context, List<int> indices) {
    AppHaptics.selection();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scroll) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.grid_view_rounded,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'question_matrix_title'.tr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scroll,
                  child: Column(
                    children: [
                      _QuestionMatrixBar(
                        indices: indices,
                        controller: controller,
                        selectedIndex: _focusedIndex,
                        onSelect: (i) {
                          Navigator.pop(sheetContext);
                          setState(() => _focusedIndex = i);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final targetKey = _itemKeys[i];
                            if (targetKey?.currentContext != null) {
                              Scrollable.ensureVisible(
                                targetKey!.currentContext!,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic,
                                alignment: 0.05,
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                          ActionChip(
                            avatar: const Icon(
                              Icons.grid_view_rounded,
                              size: 16,
                              color: Color(0xFF2563EB),
                            ),
                            label: Text('question_matrix_title'.tr),
                            onPressed: () => _openMatrixSheet(context, indices),
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
                return KeyedSubtree(
                  key: _keyFor(i),
                  child: Padding(
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
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 0.8,
                            ),
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

class _QuestionMatrixBar extends StatelessWidget {
  final List<int> indices;
  final ReviewController controller;
  final ValueChanged<int> onSelect;
  final int? selectedIndex;

  const _QuestionMatrixBar({
    required this.indices,
    required this.controller,
    required this.onSelect,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'question_matrix_title'.tr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const _LegendDot(
                color: Color(0xFF10B981),
                labelKey: 'review_correct',
              ),
              const SizedBox(width: 10),
              const _LegendDot(
                color: Color(0xFFEF4444),
                labelKey: 'review_wrong',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final i in indices)
                _MatrixChip(
                  number: i + 1,
                  isCorrect: controller.isCorrect(i),
                  isPriority: controller.questions[i].category == Category.priority,
                  isSelected: selectedIndex == i,
                  onTap: () => onSelect(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String labelKey;

  const _LegendDot({required this.color, required this.labelKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          labelKey.tr,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _MatrixChip extends StatelessWidget {
  final int number;
  final bool isCorrect;
  final bool isPriority;
  final bool isSelected;
  final VoidCallback onTap;

  const _MatrixChip({
    required this.number,
    required this.isCorrect,
    required this.isPriority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isCorrect
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? baseColor
              : baseColor.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPriority
                ? const Color(0xFFD97706)
                : (isSelected ? baseColor : baseColor.withValues(alpha: 0.45)),
            width: isPriority || isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : baseColor,
          ),
        ),
      ),
    );
  }
}
