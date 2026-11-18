import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/exam_analytics_model.dart';
import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/app_haptics.dart';
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
        const SizedBox(height: 30),
        MotionEntrance(
          order: 3,
          child: _ExamModesSection(controller: controller),
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
    final readiness = controller.readiness;
    final tip = _Note(
      icon: Icons.lightbulb_outline_rounded,
      eyebrow: 'learning_tip'.tr,
      title: 'tip_title'.tr,
      description: 'tip_description'.tr,
    );
    final progress = _Note(
      icon: readiness.level == ReadinessLevel.ready
          ? Icons.verified_rounded
          : (readiness.level == ReadinessLevel.moderate
              ? Icons.trending_up_rounded
              : Icons.insights_rounded),
      eyebrow: 'exam_readiness'.tr,
      title: readiness.level == ReadinessLevel.unrated
          ? (controller.lastResult == null
              ? 'progress_first_step'.tr
              : '${'last_score'.tr}: ${controller.lastResult!.totalCorrect}/45')
          : '${readiness.score}% · ${readiness.level.labelKey.tr}',
      description: readiness.level == ReadinessLevel.unrated
          ? 'readiness_unrated_tip'.tr
          : readiness.recommendationKey.tr,
      onTap: () {
        AppHaptics.light();
        showProgress(context);
      },
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

class _ExamModesSection extends StatelessWidget {
  final HomeController controller;
  const _ExamModesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final realExam = Obx(
          () => RealExamCard(
            enabled: controller.canStartExam,
            onTap: () => controller.startExam(skipRules: true),
          ),
        );
        final practice = PracticeModeCard(
          onTap: () => controller.openStudy(Category.general),
        );

        return Column(
          children: [
            if (controller.storage.hasOngoingExam) ...[
              _ResumeExamBanner(
                storage: controller.storage,
                onResume: () {
                  AppHaptics.selection();
                  Get.toNamed(
                    AppRoutes.exam,
                    arguments: {'resume': true, 'skipRules': true},
                  );
                },
                onDiscard: () async {
                  AppHaptics.light();
                  await controller.storage.clearOngoingExam();
                  (context as Element).markNeedsBuild();
                },
              ),
              const SizedBox(height: 18),
            ],
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: realExam),
                  const SizedBox(width: 18),
                  Expanded(child: practice),
                ],
              )
            else ...[
              realExam,
              const SizedBox(height: 16),
              practice,
            ],
            if (controller.storage.mistakeCount > 0) ...[
              const SizedBox(height: 16),
              _MistakesBankBanner(count: controller.storage.mistakeCount),
            ],
            const SizedBox(height: 16),
            const _FlashcardsBanner(),
            if (controller.storage.bookmarkCount > 0) ...[
              const SizedBox(height: 16),
              _BookmarksBanner(count: controller.storage.bookmarkCount),
            ],
          ],
        );
      },
    );
  }
}

class _ResumeExamBanner extends StatelessWidget {
  final StorageService storage;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const _ResumeExamBanner({
    required this.storage,
    required this.onResume,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final session = storage.readOngoingExam();
    if (session == null) return const SizedBox.shrink();

    final remainingSec = session['remainingSeconds'] as int? ?? 0;
    final m = (remainingSec ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSec % 60).toString().padLeft(2, '0');
    final currentQ = (session['currentIndex'] as int? ?? 0) + 1;
    final answersCount = (session['selectedAnswers'] as Map?)?.length ?? 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 480;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF132F23), const Color(0xFF0F241B)]
                  : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_filled_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'exam_resume_title'.tr,
                                style: const TextStyle(
                                  color: Color(0xFF047857),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF047857),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$m:$s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${'exam_resume_desc'.tr} · ${'exam_question_progress'.tr} $currentQ/45 ($answersCount ឆ្លើយរួច)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedFor(theme.brightness),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                    ),
                    onPressed: onDiscard,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: Text('exam_resume_discard'.tr),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 14 : 20,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: onResume,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      'exam_resume_btn'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlashcardsBanner extends StatelessWidget {
  const _FlashcardsBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showButton = constraints.maxWidth >= 460;
        return InkWell(
          onTap: () {
            AppHaptics.selection();
            Get.toNamed(AppRoutes.flashcards);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.style_rounded,
                    color: Color(0xFF2563EB),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'flashcards_title'.tr,
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '100',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'flashcards_subtitle'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedFor(theme.brightness),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (showButton)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      AppHaptics.selection();
                      Get.toNamed(AppRoutes.flashcards);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(
                      'flashcards_practice_button'.tr,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BookmarksBanner extends StatelessWidget {
  final int count;
  const _BookmarksBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showButton = constraints.maxWidth >= 460;
        return InkWell(
          onTap: () {
            AppHaptics.selection();
            Get.toNamed(AppRoutes.study, arguments: Category.general);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2612) : const Color(0xFFFEFCE8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFEAB308).withValues(alpha: 0.5),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: Color(0xFFCA8A04),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'study_bookmarks'.tr,
                              style: const TextStyle(
                                color: Color(0xFFCA8A04),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCA8A04),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'bookmark_empty_hint'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedFor(theme.brightness),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (showButton)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCA8A04),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      AppHaptics.selection();
                      Get.toNamed(AppRoutes.study, arguments: Category.general);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(
                      'lessons'.tr,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFFCA8A04),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MistakesBankBanner extends StatelessWidget {
  final int count;
  const _MistakesBankBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showButton = constraints.maxWidth >= 460;
        return InkWell(
          onTap: () {
            AppHaptics.light();
            Get.toNamed(AppRoutes.mistakes);
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2E2214) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_fix_high_rounded,
                    color: Color(0xFFD97706),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'mistakes_bank'.tr,
                              style: const TextStyle(
                                color: Color(0xFFD97706),
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'mistakes_bank_desc'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedFor(theme.brightness),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (showButton)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      AppHaptics.light();
                      Get.toNamed(AppRoutes.mistakes);
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(
                      'practice_mistakes'.tr,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
