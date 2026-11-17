import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../shared/widgets/app_motion.dart';
import '../../shared/widgets/design_components.dart';
import '../exam/widgets/question_image.dart';
import 'quiz_practice_controller.dart';
import 'widgets/quiz_game_dialog.dart';
import 'widgets/quiz_hud.dart';
import 'widgets/quiz_option_button.dart';

class QuizPracticeScreen extends StatefulWidget {
  const QuizPracticeScreen({super.key});

  @override
  State<QuizPracticeScreen> createState() => _QuizPracticeScreenState();
}

class _QuizPracticeScreenState extends State<QuizPracticeScreen> {
  QuizPracticeController get controller => Get.find<QuizPracticeController>();
  final _scroll = ScrollController();
  Worker? _gameOverWorker;
  Worker? _gameWonWorker;

  @override
  void initState() {
    super.initState();
    _gameOverWorker = ever(controller.isGameOver, (isOver) {
      if (isOver && mounted) {
        QuizGameDialog.show(context, controller: controller);
      }
    });
    _gameWonWorker = ever(controller.isGameWon, (isWon) {
      if (isWon && mounted) {
        QuizGameDialog.show(context, controller: controller);
      }
    });
  }

  @override
  void dispose() {
    _gameOverWorker?.dispose();
    _gameWonWorker?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final leave = await Get.dialog<bool>(
      AlertDialog(
        scrollable: true,
        title: Text('exam_leave_confirm_title'.tr),
        content: Text('exam_leave_confirm_body'.tr),
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
    if (leave == true && mounted) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        body: SafeArea(
          child: Obx(() {
            if (controller.questions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final qIndex = controller.currentIndex.value;
            final question = controller.currentQuestion;
            final isChecked = controller.isAnswerChecked.value;
            final isCorrect = controller.isCorrect.value;
            final selected = controller.selectedOption.value;
            final bonus = controller.latestBonus.value;

            return Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'close'.tr,
                        icon: const Icon(Icons.close_rounded, size: 22),
                        onPressed: _leave,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'quiz_game_title'.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: 'Kanit',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${qIndex + 1} / ${controller.questions.length} ${'practice_questions'.tr}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedFor(theme.brightness),
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        question.category.navKey.tr,
                        icon: question.category.icon,
                        color: question.category.color,
                      ),
                    ],
                  ),
                ),

                // Main game scroll area
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Game HUD (Lives, 15s Timer, Score & Streak)
                            QuizHud(controller: controller),
                            const SizedBox(height: 18),

                            // Question Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.6),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (question.isImagePrompt) ...[
                                    QuestionImage(filename: question.prompt),
                                    const SizedBox(height: 16),
                                  ],
                                  MotionSwitcher(
                                    child: Align(
                                      key: ValueKey(qIndex),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        question.isImagePrompt
                                            ? 'study_image_hint'.tr
                                            : question.prompt,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontFamily: 'NotoSansKhmer',
                                          fontSize: 17,
                                          height: 1.7,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Options List with staggered entrance
                            for (var n = 0; n < question.options.length; n++)
                              QuizOptionButton(
                                text: question.options[n],
                                index: n,
                                isSelected: selected == n,
                                isAnswerChecked: isChecked,
                                isCorrectAnswer: n == question.correctIndex,
                                onTap: () => controller.submitAnswer(n),
                              )
                                  .animate(key: ValueKey('opt_${qIndex}_$n'))
                                  .fadeIn(
                                    duration: 220.ms,
                                    delay: (n * 35).ms,
                                  )
                                  .slideY(
                                    begin: 0.08,
                                    end: 0,
                                    curve: Curves.easeOutCubic,
                                  ),

                            // Answer Feedback Banner
                            if (isChecked) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? AppColors.accentGreen.withValues(
                                          alpha: 0.12,
                                        )
                                      : AppColors.accentRed.withValues(
                                          alpha: 0.12,
                                        ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCorrect
                                        ? AppColors.accentGreen.withValues(
                                            alpha: 0.45,
                                          )
                                        : AppColors.accentRed.withValues(
                                            alpha: 0.45,
                                          ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isCorrect
                                          ? Icons.check_circle_rounded
                                          : Icons.info_outline_rounded,
                                      color: isCorrect
                                          ? AppColors.accentGreen
                                          : AppColors.accentRed,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        isCorrect
                                            ? '${'quiz_correct_feedback'.tr} (+$bonus XP)'
                                            : 'quiz_wrong_feedback'.tr,
                                        style: TextStyle(
                                          color: isCorrect
                                              ? AppColors.accentGreen
                                              : AppColors.accentRed,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 250.ms)
                                  .slideY(begin: 0.15, end: 0),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Sticky Navigation (Next Question button)
                if (isChecked &&
                    !controller.isGameOver.value &&
                    !controller.isGameWon.value)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      border: Border(
                        top: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            controller.nextQuestion();
                            if (_scroll.hasClients) _scroll.jumpTo(0);
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: Text(
                            (qIndex == controller.questions.length - 1
                                    ? 'exam_finish'
                                    : 'quiz_continue')
                                .tr,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 200.ms)
                      .slideY(begin: 0.2, end: 0),
              ],
            );
          }),
        ),
      ),
    );
  }
}
