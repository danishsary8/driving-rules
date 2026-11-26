import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../core/models/question_model.dart';
import '../review_controller.dart';

/// Bottom-sheet body listing every reviewed question as a tappable chip, so
/// the learner can jump straight to one.
class QuestionMatrixSheet extends StatelessWidget {
  const QuestionMatrixSheet({
    super.key,
    required this.indices,
    required this.controller,
    required this.selectedIndex,
    required this.scrollController,
    required this.onSelect,
  });

  final List<int> indices;
  final ReviewController controller;
  final int? selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: _QuestionMatrixBar(
                indices: indices,
                controller: controller,
                selectedIndex: selectedIndex,
                onSelect: onSelect,
              ),
            ),
          ),
        ],
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
              const Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: Color(0xFF2563EB),
              ),
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
                  isPriority:
                      controller.questions[i].category == Category.priority,
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
          color: isSelected ? baseColor : baseColor.withValues(alpha: 0.14),
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
