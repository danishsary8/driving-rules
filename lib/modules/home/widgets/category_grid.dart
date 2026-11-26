import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/data_service.dart';
import '../../../shared/widgets/app_motion.dart';
import '../../../shared/widgets/design_components.dart';
import '../../../shared/widgets/premium_card.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../home_controller.dart';
import 'learning_cards.dart';

/// Responsive grid of learning categories (1–3 columns by width), with
/// loading shimmer and an error/retry state while question data loads.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.data.status.value;
      if (status == DataStatus.error) {
        return PremiumCard(
          child: Column(
            children: [
              const Icon(Icons.wifi_off_rounded, size: 32),
              const SizedBox(height: 12),
              Text('error_body'.tr),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: controller.data.retry,
                child: Text('error_retry'.tr),
              ),
            ],
          ),
        );
      }
      if (status != DataStatus.ready) {
        return const ShimmerBox(height: 210, borderRadius: 22);
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1000
              ? 3
              : constraints.maxWidth >= 620
              ? 2
              : 1;
          final width = (constraints.maxWidth - (columns - 1) * 18) / columns;
          return Wrap(
            spacing: 18,
            runSpacing: 18,
            children: [
              for (var i = 0; i < learningCategories.length; i++)
                SizedBox(
                  width: width,
                  child: MotionEntrance(
                    order: i,
                    child: LearningCategoryCard(
                      category: learningCategories[i],
                      number: i + 1,
                      count: controller.data
                          .questionsFor(learningCategories[i])
                          .length,
                      onTap: () => controller.openStudy(learningCategories[i]),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}
