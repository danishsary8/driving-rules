import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../quiz_practice_controller.dart';

/// Top Heads-Up Display (HUD) showing lives, 15s countdown timer, score, and combo streak.
class QuizHud extends StatelessWidget {
  final QuizPracticeController controller;

  const QuizHud({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2D26) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final seconds = controller.secondsLeft.value;
        final progress = controller.timerProgress;
        final hearts = controller.hearts.value;
        final streak = controller.streak.value;
        final score = controller.score.value;

        // Dynamic timer color
        final timerColor = seconds > 8.0
            ? AppColors.accentGreen
            : seconds > 4.0
            ? const Color(0xFFD9822B)
            : AppColors.accentRed;

        return Row(
          children: [
            // Hearts (Lives) display
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < QuizPracticeController.kMaxHearts; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Icon(
                      i < hearts
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: i < hearts
                          ? AppColors.accentRed
                          : AppColors.mutedFor(theme.brightness),
                      size: 22,
                    )
                        .animate(
                          target: i < hearts ? 0 : 1,
                        )
                        .shake(duration: 350.ms, hz: 4)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(0.85, 0.85),
                        ),
                  ),
              ],
            ),
            const Spacer(),

            // Circular Countdown Timer (15s)
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    strokeCap: StrokeCap.round,
                    color: timerColor,
                    backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                Text(
                  '${seconds.ceil()}',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: timerColor,
                  ),
                ),
              ],
            )
                .animate(target: seconds <= 4.0 ? 1 : 0)
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.15, 1.15),
                  duration: 400.ms,
                ),

            const Spacer(),

            // Score & Streak
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: Color(0xFFB58316),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$score XP',
                      style: const TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (streak > 1) ...[
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8590C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '🔥',
                          style: TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$streak x ${'quiz_streak'.tr}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFE8590C),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.elasticOut,
                        duration: 400.ms,
                      ),
                ],
              ],
            ),
          ],
        );
      }),
    );
  }
}
