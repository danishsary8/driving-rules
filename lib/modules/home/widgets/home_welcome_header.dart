import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../shared/widgets/design_components.dart';

/// Page title block at the top of the overview: eyebrow, heading and intro
/// copy, plus a "self-paced" chip on wide layouts.
class HomeWelcomeHeader extends StatelessWidget {
  const HomeWelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow('your_learning_space'.tr),
                const SizedBox(height: 8),
                Text(
                  'welcome_heading'.tr,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: constraints.maxWidth < 500 ? 28 : 35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'welcome_description'.tr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mutedFor(Theme.of(context).brightness),
                  ),
                ),
              ],
            ),
          ),
          if (constraints.maxWidth > 850) ...[
            const SizedBox(width: 20),
            StatusChip('self_paced'.tr, icon: Icons.spa_outlined),
          ],
        ],
      ),
    );
  }
}
