import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/models/question_model.dart';
import '../../shared/widgets/app_motion.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import 'home_controller.dart';
import 'widgets/category_grid.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/dashboard_notes.dart';
import 'widgets/dashboard_stats.dart';
import 'widgets/exam_modes_section.dart';
import 'widgets/home_welcome_header.dart';
import 'widgets/learning_journey.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => AppShell(
    title: 'overview'.tr,
    child: PageContent(
      children: [
        const MotionEntrance(child: HomeWelcomeHeader()),
        const SizedBox(height: 28),
        MotionEntrance(
          order: 1,
          child: DashboardHero(
            onLearn: () => controller.openStudy(Category.general),
            onSigns: () => controller.openStudy(Category.sign),
          ),
        ),
        const SizedBox(height: 20),
        MotionEntrance(order: 2, child: DashboardStats(controller: controller)),
        const SizedBox(height: 30),
        MotionEntrance(
          order: 3,
          child: ExamModesSection(controller: controller),
        ),
        const SizedBox(height: 34),
        MotionEntrance(
          order: 4,
          child: LearningJourney(controller: controller),
        ),
        const SizedBox(height: 36),
        SectionHeading(
          'home_choose_category'.tr,
          subtitle: 'category_intro'.tr,
        ),
        const SizedBox(height: 20),
        CategoryGrid(controller: controller),
        const SizedBox(height: 26),
        DashboardNotes(controller: controller),
        const SizedBox(height: 30),
        Text(
          'footer_note'.tr,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );
}
