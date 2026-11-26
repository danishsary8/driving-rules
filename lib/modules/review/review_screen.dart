import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/question_model.dart';
import '../../core/utils/app_haptics.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import 'review_controller.dart';
import 'widgets/question_matrix_sheet.dart';
import 'widgets/review_filter_bar.dart';
import 'widgets/review_question_card.dart';

/// Post-exam answer review: filterable list of every question with the
/// learner's answer, the correct answer and an explanation.
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

  List<int> get _visibleIndices => [
    for (var i = 0; i < controller.questions.length; i++)
      if (_activeFilter == ReviewFilter.all ||
          (_activeFilter == ReviewFilter.mistakesOnly &&
              !controller.isCorrect(i)) ||
          (_activeFilter == ReviewFilter.priorityOnly &&
              controller.questions[i].category == Category.priority))
        i,
  ];

  void _jumpTo(int i) {
    setState(() => _focusedIndex = i);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetContext = _itemKeys[i]?.currentContext;
      if (targetContext != null) {
        Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          alignment: 0.05,
        );
      }
    });
  }

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
        builder: (context, scroll) => QuestionMatrixSheet(
          indices: indices,
          controller: controller,
          selectedIndex: _focusedIndex,
          scrollController: scroll,
          onSelect: (i) {
            Navigator.pop(sheetContext);
            _jumpTo(i);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priorityCount = controller.questions
        .where((q) => q.category == Category.priority)
        .length;
    final indices = _visibleIndices;

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
                      ReviewFilterBar(
                        activeFilter: _activeFilter,
                        totalCount: controller.questions.length,
                        wrongCount: controller.wrongCount,
                        priorityCount: priorityCount,
                        onFilterChanged: (f) =>
                            setState(() => _activeFilter = f),
                        onOpenMatrix: () => _openMatrixSheet(context, indices),
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
                return KeyedSubtree(
                  key: _keyFor(i),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: ReviewQuestionCard(
                      index: i,
                      question: controller.questions[i],
                      correct: controller.isCorrect(i),
                      selected: controller.selectedAnswerFor(i),
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
