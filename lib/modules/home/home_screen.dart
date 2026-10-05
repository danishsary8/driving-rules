import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';
import '../../shared/widgets/app_motion.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import '../../shared/widgets/shimmer_box.dart';
import 'home_controller.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/learning_cards.dart';
import 'widgets/learning_journey.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => AppShell(
    title: 'overview'.tr,
    child: PageContent(
      children: [
        MotionEntrance(
          child: LayoutBuilder(
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
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: constraints.maxWidth < 500 ? 28 : 35,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'welcome_description'.tr,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedFor(
                            Theme.of(context).brightness,
                          ),
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
          ),
        ),
        const SizedBox(height: 28),
        MotionEntrance(
          order: 1,
          child: DashboardHero(
            onLearn: () => controller.openStudy(Category.general),
            onSigns: () => controller.openStudy(Category.sign),
          ),
        ),
        const SizedBox(height: 20),
        MotionEntrance(
          order: 2,
          child: _DashboardStats(controller: controller),
        ),
        const SizedBox(height: 34),
        MotionEntrance(
          order: 3,
          child: LearningJourney(controller: controller),
        ),
        const SizedBox(height: 36),
        SectionHeading(
          'home_choose_category'.tr,
          subtitle: 'category_intro'.tr,
        ),
        const SizedBox(height: 20),
        Obx(() {
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
              final width =
                  (constraints.maxWidth - (columns - 1) * 18) / columns;
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
                          onTap: () =>
                              controller.openStudy(learningCategories[i]),
                        ),
                      ),
                    ),
                  SizedBox(
                    width: width,
                    child: MotionEntrance(
                      order: 5,
                      child: PracticeExamCard(
                        enabled: controller.canStartExam,
                        onTap: controller.startExam,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }),
        const SizedBox(height: 26),
        _DashboardNotes(controller: controller),
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

class _DashboardStats extends StatelessWidget {
  final HomeController controller;
  const _DashboardStats({required this.controller});
  @override
  Widget build(BuildContext context) => Obx(() {
    final ready = controller.data.status.value == DataStatus.ready;
    final count = ready
        ? learningCategories.fold<int>(
            0,
            (sum, c) => sum + controller.data.questionsFor(c).length,
          )
        : 0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.menu_book_outlined,
                  value: count,
                  label: 'practice_questions'.tr,
                  compact: compact,
                ),
              ),
              SizedBox(width: compact ? 8 : 16),
              Expanded(
                child: _Metric(
                  icon: Icons.layers_outlined,
                  value: learningCategories.length,
                  label: 'learning_categories'.tr,
                  compact: compact,
                ),
              ),
              SizedBox(width: compact ? 8 : 16),
              Expanded(
                child: _Metric(
                  icon: Icons.emoji_events_outlined,
                  value: controller.bestScore,
                  suffix: '/45',
                  empty: controller.lastResult == null,
                  label: 'best_score'.tr,
                  compact: compact,
                ),
              ),
            ],
          ),
        );
      },
    );
  });
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label, suffix;
  final bool compact, empty;
  const _Metric({
    required this.icon,
    required this.value,
    required this.label,
    required this.compact,
    this.suffix = '',
    this.empty = false,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (empty)
          Text('—', style: theme.textTheme.headlineMedium)
        else
          AnimatedNumber(
            value: value,
            suffix: suffix,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: compact ? 27 : 31,
            ),
          ),
        const SizedBox(height: 5),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: compact ? 12 : 14,
          ),
        ),
      ],
    );
    return PremiumCard(
      padding: EdgeInsets.all(compact ? 12 : 22),
      borderRadius: 18,
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 22, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                content,
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 25, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 17),
                Expanded(child: content),
              ],
            ),
    );
  }
}

class _DashboardNotes extends StatelessWidget {
  final HomeController controller;
  const _DashboardNotes({required this.controller});
  @override
  Widget build(BuildContext context) {
    final tip = _Note(
      icon: Icons.lightbulb_outline_rounded,
      eyebrow: 'learning_tip'.tr,
      title: 'tip_title'.tr,
      description: 'tip_description'.tr,
    );
    final progress = _Note(
      icon: Icons.insights_rounded,
      eyebrow: 'your_progress'.tr,
      title: controller.lastResult == null
          ? 'progress_first_step'.tr
          : '${'last_score'.tr}: ${controller.lastResult!.totalCorrect}/45',
      description: 'progress_description'.tr,
      onTap: () => showProgress(context),
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 850
          ? Column(children: [tip, const SizedBox(height: 16), progress])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: tip),
                const SizedBox(width: 18),
                Expanded(child: progress),
              ],
            ),
    );
  }
}

class _Note extends StatelessWidget {
  final IconData icon;
  final String eyebrow, title, description;
  final VoidCallback? onTap;
  const _Note({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => PremiumCard(
    onTap: onTap,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 27, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(eyebrow),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (onTap != null) const Icon(Icons.arrow_forward_rounded, size: 19),
      ],
    ),
  );
}
