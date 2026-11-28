import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../quiz_practice_controller.dart';

/// Modal dialog presented when a Speed Quiz round finishes (either Won or Game Over).
class QuizGameDialog extends StatelessWidget {
  final QuizPracticeController controller;

  const QuizGameDialog({super.key, required this.controller});

  static Future<void> show(
    BuildContext context, {
    required QuizPracticeController controller,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuizGameDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWon = controller.isGameWon.value;
    final score = controller.score.value;
    final bestStreak = controller.bestStreak.value;

    final primaryColor = isWon ? AppColors.accentGold : AppColors.accentRed;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon container
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isWon ? Icons.emoji_events_rounded : Icons.favorite_border_rounded,
                  size: 42,
                  color: primaryColor,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.0, 1.0),
                    curve: Curves.elasticOut,
                    duration: 600.ms,
                  ),

              const SizedBox(height: 18),

              // Title
              Text(
                (isWon ? 'quiz_victory' : 'quiz_game_over').tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Kanit',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                (isWon ? 'quiz_victory_desc' : 'quiz_game_over_desc').tr,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedFor(theme.brightness),
                  height: 1.5,
                  fontSize: 13.5,
                ),
              ),

              const SizedBox(height: 22),

              // Score badge box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3029)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          'quiz_score'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedFor(theme.brightness),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$score XP',
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isWon ? const Color(0xFFB58316) : null,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: theme.dividerColor.withValues(alpha: 0.6),
                    ),
                    Column(
                      children: [
                        Text(
                          'quiz_streak'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedFor(theme.brightness),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: Color(0xFFE8590C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$bestStreak',
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.offAllNamed(AppRoutes.home);
                      },
                      child: Text('result_back_home'.tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        controller.restart();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text('quiz_play_again'.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
