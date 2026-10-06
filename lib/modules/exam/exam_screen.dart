import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import '../../shared/widgets/app_motion.dart';
import 'exam_controller.dart';
import 'widgets/answer_option.dart';
import 'widgets/exam_timer.dart';
import 'widgets/question_card.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  ExamController get controller => Get.find<ExamController>();
  bool _allowPop = false;
  final _scroll = ScrollController();
  @override
  void dispose() {
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
    if (leave != true || !mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Get.offAllNamed(AppRoutes.home);
    });
  }

  Future<void> _next() async {
    if (controller.isLast) {
      final submit = await Get.dialog<bool>(
        AlertDialog(
          scrollable: true,
          title: Text('exam_submit_confirm_title'.tr),
          content: Text('exam_submit_confirm_body'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('exam_submit_confirm_no'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: Text('exam_submit_confirm_yes'.tr),
            ),
          ],
        ),
      );
      if (submit != true || !mounted) return;
    }
    controller.goNext();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    if (controller.hasBuildError) {
      return Scaffold(
        appBar: AppBar(title: Text('practice_exam'.tr)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded, size: 40),
                const SizedBox(height: 16),
                Text('error_body'.tr),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  child: Text('result_back_home'.tr),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _leave();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1220),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          const BrandMark(size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'practice_exam'.tr,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 18),
                            ),
                          ),
                          ExamTimer(controller: controller),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'exam_leave'.tr,
                            onPressed: _leave,
                            icon: const Icon(Icons.close_rounded, size: 21),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 1000;
                    return SingleChildScrollView(
                      controller: _scroll,
                      padding: EdgeInsets.all(
                        constraints.maxWidth < 600 ? 20 : 36,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1148),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Eyebrow('exam_mode'.tr),
                              const SizedBox(height: 8),
                              Text(
                                'exam_heading'.tr,
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(fontSize: wide ? 36 : 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'exam_description'.tr,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.mutedFor(
                                        Theme.of(context).brightness,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 28),
                              if (wide)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _QuestionPanel(
                                        controller: controller,
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    SizedBox(
                                      width: 280,
                                      child: _SessionPanel(
                                        controller: controller,
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _QuestionPanel(controller: controller),
                                const SizedBox(height: 20),
                                _SessionPanel(
                                  controller: controller,
                                  compact: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1188),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Obx(
                        () => Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: controller.isFirst
                                  ? null
                                  : () {
                                      controller.goBack();
                                      if (_scroll.hasClients) _scroll.jumpTo(0);
                                    },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                              ),
                              label: Text('exam_back'.tr),
                            ),
                            const Spacer(),
                            if (MediaQuery.sizeOf(context).width >= 800) ...[
                              Text(
                                'exam_finish_hint'.tr,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                            ],
                            ElevatedButton.icon(
                              onPressed:
                                  controller.answerFor(
                                        controller.currentIndex.value,
                                      ) ==
                                      null
                                  ? null
                                  : _next,
                              icon: Icon(
                                controller.isLast
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                              label: Text(
                                (controller.isLast
                                        ? 'exam_finish'
                                        : 'exam_next')
                                    .tr,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  final ExamController controller;
  const _QuestionPanel({required this.controller});
  @override
  Widget build(BuildContext context) => Obx(() {
    final i = controller.currentIndex.value;
    final q = controller.current;
    return PremiumCard(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusChip(
                q.category.navKey.tr,
                icon: q.category.icon,
                color: q.category.color,
              ),
              const Spacer(),
              Text(
                '${(i + 1).toString().padLeft(2, '0')} / ${controller.questions.length}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 22),
          LinearProgressIndicator(
            value: (i + 1) / controller.questions.length,
            minHeight: 4,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 30),
          MotionSwitcher(
            child: Align(
              key: ValueKey(i),
              alignment: Alignment.centerLeft,
              child: QuestionCard(question: q),
            ),
          ),
          const SizedBox(height: 28),
          Eyebrow('exam_select_one'.tr),
          const SizedBox(height: 14),
          for (var n = 0; n < q.options.length; n++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnswerOption(
                text: q.options[n],
                index: n,
                selected: controller.answerFor(i) == n,
                onTap: () => controller.selectAnswer(n),
              ),
            ),
          if (q.category == Category.priority) ...[
            const SizedBox(height: 8),
            StatusChip(
              'exam_priority_notice'.tr,
              icon: Icons.info_outline,
              color: const Color(0xFFAD822B),
            ),
          ],
        ],
      ),
    );
  });
}

class _SessionPanel extends StatelessWidget {
  final ExamController controller;
  final bool compact;
  const _SessionPanel({required this.controller, this.compact = false});
  @override
  Widget build(BuildContext context) => Obx(
    () => PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'exam_session'.tr,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SessionMetric(
                  '${controller.selectedAnswers.length}',
                  'exam_answered'.tr,
                ),
              ),
              Expanded(
                child: _SessionMetric(
                  '${controller.questions.length - controller.selectedAnswers.length}',
                  'exam_remaining'.tr,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (var i = 0; i < controller.questions.length; i++)
                  Semantics(
                    label: '${'exam_question_progress'.tr} ${i + 1}',
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: i == controller.currentIndex.value
                              ? AppColors.accentGreen
                              : Colors.transparent,
                        ),
                        color: controller.answerFor(i) != null
                            ? AppColors.accentGreen.withValues(alpha: .15)
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: controller.answerFor(i) != null
                              ? AppColors.accentGreen
                              : null,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Divider(color: Theme.of(context).dividerColor),
          const SizedBox(height: 14),
          const Icon(
            Icons.shield_outlined,
            size: 24,
            color: AppColors.accentGreen,
          ),
          const SizedBox(height: 10),
          Text('exam_rules'.tr, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class _SessionMetric extends StatelessWidget {
  final String value, label;
  const _SessionMetric(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontSize: 28),
      ),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ],
  );
}
