import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../core/models/sign_category.dart';
import '../../core/utils/asset_paths.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import 'flashcards_controller.dart';

/// Interactive 3D flip-card study screen for Road Signs.
class FlashcardsScreen extends GetView<FlashcardsController> {
  const FlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppShell(
      title: 'flashcards_title'.tr,
      showBack: true,
      child: Obx(() {
        final q = controller.currentQuestion;
        if (q == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final currentIndex = controller.currentIndex.value;
        final total = controller.totalCount;
        final isFlipped = controller.isFlipped.value;
        final isBookmarked = controller.isCurrentBookmarked;
        final masteredCount = controller.masteredIds.length;
        final reviewCount = controller.reviewIds.length;

        return PageContent(
          maxWidth: 680,
          children: [
            // Top Header: Title & Stats
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('flashcards_title'.tr),
                    const SizedBox(height: 4),
                    Text(
                      '${'flashcards_progress'.tr} ${currentIndex + 1} / $total',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Mastered Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFF16A34A,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$masteredCount',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Needs Review Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(
                            0xFFF59E0B,
                          ).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.replay_rounded,
                            size: 15,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$reviewCount',
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bookmark Star Button
                    IconButton(
                      icon: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isBookmarked
                            ? const Color(0xFFEAB308)
                            : theme.hintColor,
                        size: 24,
                      ),
                      tooltip: isBookmarked
                          ? 'bookmark_remove'.tr
                          : 'bookmark_add'.tr,
                      onPressed: controller.toggleCurrentBookmark,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: controller.progress,
                minHeight: 6,
                backgroundColor: theme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Road Sign Sub-category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final type in SignType.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(
                          type.icon,
                          size: 15,
                          color: controller.selectedType.value == type
                              ? Colors.white
                              : type.color,
                        ),
                        label: Text(type.labelKey.tr),
                        selected: controller.selectedType.value == type,
                        selectedColor: type.color,
                        labelStyle: TextStyle(
                          color: controller.selectedType.value == type
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: controller.selectedType.value == type
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                        showCheckmark: false,
                        onSelected: (_) => controller.filterByType(type),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3D Flip Card Container
            Center(
              child: GestureDetector(
                onTap: controller.flip,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (context, angle, _) {
                    final isUnder = angle >= 90;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY((angle * math.pi) / 180),
                      child: isUnder
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _BackCard(question: q),
                            )
                          : _FrontCard(question: q),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Flip Helper Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: AppColors.mutedFor(theme.brightness),
                ),
                const SizedBox(width: 6),
                Text(
                  'flashcards_flip_hint'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedFor(theme.brightness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons: Mastered vs Needs Review
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD97706),
                      side: const BorderSide(
                        color: Color(0xFFD97706),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: controller.markReview,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(
                      'flashcards_needs_review'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: controller.markMastered,
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(
                      'flashcards_mastered'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Navigation Row: Prev / Shuffle / Reset / Next
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: currentIndex > 0 ? controller.prevCard : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  tooltip: 'exam_nav_prev'.tr,
                ),
                Wrap(
                  spacing: 10,
                  children: [
                    TextButton.icon(
                      onPressed: controller.shuffleCards,
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: Text('flashcards_shuffle'.tr),
                    ),
                    TextButton.icon(
                      onPressed: controller.resetDeck,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text('flashcards_reset'.tr),
                    ),
                  ],
                ),
                IconButton.filledTonal(
                  onPressed:
                      currentIndex < total - 1 ? controller.nextCard : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  tooltip: 'exam_nav_next'.tr,
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        );
      }),
    );
  }
}

class _FrontCard extends StatelessWidget {
  final Question question;
  const _FrontCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signType = SignTypeMeta.classify(question);
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(
                signType.labelKey.tr,
                icon: signType.icon,
                color: signType.color,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flip_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ចុចបង្វិល',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.5),
                ),
              ),
              child: RepaintBoundary(
                child: Image.asset(
                  AssetPaths.promptImage(question.prompt),
                  fit: BoxFit.contain,
                  cacheHeight: 440,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_rounded,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'តើស្លាកសញ្ញានេះមានអត្ថន័យដូចម្តេច?',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  final Question question;
  const _BackCard({required this.question});

  static final _optionPrefix = RegExp(r'^[កខគ]\s*[-–—]\s*');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleanAnswer = question.correctAnswer
        .replaceFirst(_optionPrefix, '')
        .trim();

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusChip(
                'អត្ថន័យផ្លូវការ',
                icon: Icons.verified_rounded,
                color: Color(0xFF16A34A),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flip_rounded,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ចុចបង្វិល',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF16A34A).withValues(alpha: 0.28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ចម្លើយត្រឹមត្រូវ',
                      style: AppTextStyles.body2.copyWith(
                        color: const Color(0xFF16A34A),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  cleanAnswer,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: Color(0xFFEAB308),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'គន្លឹះ៖ ចងចាំរូបរាង និងពណ៌នៃសញ្ញា (ក្រហម=ហាមឃាត់/គ្រោះថ្នាក់, ខៀវ=បញ្ជា/ផ្តល់ដំណឹង, លឿង=ប្រុងប្រយ័ត្ន)។',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
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
