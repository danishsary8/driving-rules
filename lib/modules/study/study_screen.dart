import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../core/models/sign_category.dart';
import '../../core/services/data_service.dart';
import '../../core/utils/app_haptics.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/design_components.dart';
import '../../shared/widgets/premium_card.dart';
import 'study_controller.dart';
import 'widgets/lesson_card.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  StudyController get controller => Get.find<StudyController>();
  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _change(Category category) {
    AppHaptics.selection();
    FocusManager.instance.primaryFocus?.unfocus();
    _search.clear();
    controller.changeCategory(category);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final theme = Theme.of(context);
    final category = controller.category;
    final questions = controller.filtered;
    final status = controller.data.status.value;
    return AppShell(
      title: category.navKey.tr,
      category: category,
      onCategory: _change,
      showBack: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = constraints.maxWidth < 600 ? 20.0 : 36.0;
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 1040,
              child: ListView.builder(
                key: const ValueKey('study-questions'),
                controller: _scroll,
                padding: EdgeInsets.fromLTRB(padding, 30, padding, 36),
                itemCount: questions.isEmpty || status != DataStatus.ready
                    ? 2
                    : questions.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Eyebrow('learning_library'.tr),
                        const SizedBox(height: 8),
                        SectionHeading(
                          category.navKey.tr,
                          subtitle: 'study_intro'.tr,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.auto_stories_rounded,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'study_read_mode'.tr,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'study_practice_hint'.tr,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final c in learningCategories)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(c.navKey.tr),
                                    avatar: Icon(c.icon, size: 17),
                                    selected:
                                        !controller.showOnlyBookmarks.value &&
                                        c == category,
                                    showCheckmark: false,
                                    selectedColor:
                                        theme.colorScheme.primaryContainer,
                                    onSelected: (_) => _change(c),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(
                                    '${'study_bookmarks'.tr} (${controller.totalBookmarksCount})',
                                  ),
                                  avatar: Icon(
                                    controller.showOnlyBookmarks.value
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    size: 17,
                                    color: const Color(0xFFEAB308),
                                  ),
                                  selected: controller.showOnlyBookmarks.value,
                                  showCheckmark: false,
                                  selectedColor:
                                      theme.colorScheme.primaryContainer,
                                  onSelected: (_) =>
                                      controller.toggleBookmarkFilter(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (category == Category.sign &&
                            !controller.showOnlyBookmarks.value) ...[
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: () {
                              AppHaptics.selection();
                              Get.toNamed(AppRoutes.flashcards);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    theme.colorScheme.secondary.withValues(
                                      alpha: 0.08,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.style_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'flashcards_title'.tr,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          'flashcards_subtitle'.tr,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors.mutedFor(
                                                  theme.brightness,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final type in SignType.values)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        type.icon,
                                        size: 15,
                                        color:
                                            controller.selectedSignType.value ==
                                                type
                                            ? Colors.white
                                            : type.color,
                                      ),
                                      label: Text(type.labelKey.tr),
                                      selected:
                                          controller.selectedSignType.value ==
                                          type,
                                      selectedColor: type.color,
                                      labelStyle: TextStyle(
                                        color:
                                            controller.selectedSignType.value ==
                                                type
                                            ? Colors.white
                                            : theme.textTheme.bodyMedium?.color,
                                        fontWeight:
                                            controller.selectedSignType.value ==
                                                type
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                      showCheckmark: false,
                                      onSelected: (_) =>
                                          controller.changeSignType(type),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Semantics(
                          container: true,
                          child: TextField(
                            controller: _search,
                            onChanged: controller.setSearch,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            onTapOutside: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: InputDecoration(
                              hintText: 'study_search_placeholder'.tr,
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 21,
                              ),
                              suffixIcon: _search.text.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'clear_search'.tr,
                                      onPressed: () {
                                        _search.clear();
                                        controller.setSearch('');
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 19,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            Eyebrow('study_all'.tr),
                            Text(
                              '${questions.length} / ${controller.totalCount} ${'study_question_count'.tr}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    );
                  }
                  if (status == DataStatus.error) {
                    return PremiumCard(
                      child: Column(
                        children: [
                          Text('error_body'.tr),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: controller.data.retry,
                            child: Text('error_retry'.tr),
                          ),
                        ],
                      ),
                    );
                  }
                  if (status != DataStatus.ready) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (questions.isEmpty) {
                    return PremiumCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: AppColors.mutedFor(theme.brightness),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'no_results'.tr,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'study_empty_hint'.tr,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }
                  final question = questions[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: LessonCard(
                      key: ValueKey('${question.category.name}_${question.id}'),
                      question: question,
                      number: index,
                      isBookmarked: controller.isBookmarked(question.id),
                      onToggleBookmark: () =>
                          controller.toggleBookmark(question.id),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  });
}
