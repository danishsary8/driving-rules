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
    final isCompact = MediaQuery.sizeOf(context).width < 450;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: isCompact ? 16 : 18, color: color),
          SizedBox(width: isCompact ? 5 : 7),
          Text(
            controller.formattedTime,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontSize: isCompact ? 14 : 16,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  });
}
