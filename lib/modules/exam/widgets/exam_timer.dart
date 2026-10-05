import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../exam_controller.dart';

class ExamTimer extends StatelessWidget {
  final ExamController controller;
  const ExamTimer({super.key, required this.controller});
  @override
  Widget build(BuildContext context) => Obx(() {
    final urgent = controller.secondsLeft.value <= 300;
    final color = AppColors.contentColor(
      urgent ? AppColors.accentRed : AppColors.accentGreen,
      Theme.of(context).brightness,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 19, color: color),
          const SizedBox(width: 9),
          Text(
            controller.formattedTime,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontSize: 17,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  });
}
