import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/utils/app_haptics.dart';

/// Which questions the review list shows.
enum ReviewFilter { all, mistakesOnly, priorityOnly }

/// Filter chips (all / mistakes / priority) plus the question-matrix button.
class ReviewFilterBar extends StatelessWidget {
  const ReviewFilterBar({
    super.key,
    required this.activeFilter,
    required this.totalCount,
    required this.wrongCount,
    required this.priorityCount,
    required this.onFilterChanged,
    required this.onOpenMatrix,
  });

  final ReviewFilter activeFilter;
  final int totalCount;
  final int wrongCount;
  final int priorityCount;
  final ValueChanged<ReviewFilter> onFilterChanged;
  final VoidCallback onOpenMatrix;

  void _select(ReviewFilter filter) {
    AppHaptics.selection();
    onFilterChanged(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ChoiceChip(
          label: Text('${'review_all'.tr} ($totalCount)'),
          selected: activeFilter == ReviewFilter.all,
          selectedColor: AppColors.accentGold.withValues(alpha: .3),
          onSelected: (_) => _select(ReviewFilter.all),
        ),
        ChoiceChip(
          label: Text('${'review_mistakes'.tr} ($wrongCount)'),
          selected: activeFilter == ReviewFilter.mistakesOnly,
          selectedColor: AppColors.accentRed.withValues(alpha: .2),
          onSelected: (_) => _select(ReviewFilter.mistakesOnly),
        ),
        ChoiceChip(
          label: Text('${'review_priority'.tr} ($priorityCount)'),
          selected: activeFilter == ReviewFilter.priorityOnly,
          selectedColor: const Color(0xFFD4AF37).withValues(alpha: .25),
          onSelected: (_) => _select(ReviewFilter.priorityOnly),
        ),
        ActionChip(
          avatar: const Icon(
            Icons.grid_view_rounded,
            size: 16,
            color: Color(0xFF2563EB),
          ),
          label: Text('question_matrix_title'.tr),
          onPressed: onOpenMatrix,
        ),
      ],
    );
  }
}
