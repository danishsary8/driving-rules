import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/utils/app_haptics.dart';
import '../../shared/widgets/app_motion.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import 'mistakes_controller.dart';

/// Screen displaying the user's recorded mistake questions with drill mode
/// and mastery resolution tools.
class MistakesScreen extends GetView<MistakesController> {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppShell(
      title: 'mistakes_bank'.tr,
      showBack: true,
      child: PageContent(
        maxWidth: 960,
        children: [
          Eyebrow('mistakes_bank'.tr),
          const SizedBox(height: 8),
          Text(
            'questions_to_master'.tr,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: MediaQuery.sizeOf(context).width < 600 ? 28 : 36,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'mistakes_bank_desc'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedFor(theme.brightness),
            ),
          ),
          const SizedBox(height: 24),

          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (controller.questions.isEmpty) {
              return PremiumCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Color(0xFF10B981),
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'mistakes_empty_title'.tr,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'mistakes_empty_desc'.tr,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedFor(theme.brightness),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        AppHaptics.light();
                        Get.toNamed(AppRoutes.exam);
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text('start_real_exam'.tr),
                    ),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Action Header Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_fix_high_rounded,
                        color: Color(0xFFF59E0B),
                        size: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${controller.questions.length} ${'questions_to_master'.tr}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'mistakes_bank_desc'.tr,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedFor(theme.brightness),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final confirm = await Get.dialog<bool>(
                            AlertDialog(
                              title: Text('clear_all_mistakes'.tr),
                              content: Text('clear_all_confirm'.tr),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: Text('exam_leave_no'.tr),
                                ),
                                ElevatedButton(
                                  onPressed: () => Get.back(result: true),
                                  child: Text('exam_leave_yes'.tr),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            controller.clearAll();
                          }
                        },
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: Text('clear_all_mistakes'.tr),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // List of mistake question cards
                for (var i = 0; i < controller.questions.length; i++) ...[
                  MotionEntrance(
                    order: i,
                    child: _MistakeCard(
                      question: controller.questions[i],
                      index: i + 1,
                      isDark: isDark,
                      onMastered: () => controller.removeMistake(controller.questions[i].id),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _MistakeCard extends StatelessWidget {
  final dynamic question;
  final int index;
  final bool isDark;
  final VoidCallback onMastered;

  const _MistakeCard({
    required this.question,
    required this.index,
    required this.isDark,
    required this.onMastered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correctOption = question.options[question.correctIndex];

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusChip(
                question.category.navKey.tr,
                icon: question.category.icon,
                color: question.category.color,
              ),
              const Spacer(),
              Text(
                '#$index',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.mutedFor(theme.brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question Prompt
          Text(
            question.prompt,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Correct Answer Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    correctOption,
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onMastered,
                icon: const Icon(Icons.done_all_rounded, size: 17),
                label: Text('mistake_mastered'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
