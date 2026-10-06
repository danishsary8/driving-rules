import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import '../../core/services/data_service.dart';
import '../../core/services/storage_service.dart';
import 'design_components.dart';
import 'language_toggle.dart';
import 'theme_toggle.dart';
import 'premium_card.dart';
import 'app_motion.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String title;
  final Category? category;
  final ValueChanged<Category>? onCategory;
  final bool showBack;
  const AppShell({
    super.key,
    required this.child,
    required this.title,
    this.category,
    this.onCategory,
    this.showBack = false,
  });

  void _study(Category value) {
    if (onCategory != null) {
      onCategory!(value);
    } else {
      Get.toNamed(AppRoutes.study, arguments: value);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 1050;
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (desktop) _Sidebar(category: category, onCategory: _study),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: desktop ? 83 : 72,
                      padding: EdgeInsets.symmetric(
                        horizontal: desktop ? 36 : 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (!desktop) ...[
                            if (showBack)
                              IconButton(
                                tooltip: 'exam_back'.tr,
                                onPressed: () {
                                  if (Get.key.currentState?.canPop() ?? false) {
                                    Get.back();
                                  } else {
                                    Get.offAllNamed(AppRoutes.home);
                                  }
                                },
                                icon: const Icon(Icons.arrow_back_rounded),
                              )
                            else
                              const BrandMark(size: 34),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: desktop
                                ? Row(
                                    children: [
                                      Text(
                                        'workspace'.tr,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Icon(
                                          Icons.chevron_right,
                                          size: 15,
                                        ),
                                      ),
                                      Flexible(
                                        child: Text(
                                          title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelLarge,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'app_title'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 17),
                                  ),
                          ),
                          const LanguageToggle(),
                          const SizedBox(width: 4),
                          const ThemeToggle(),
                          if (desktop) ...[
                            Container(
                              height: 26,
                              width: 1,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              color: Theme.of(context).dividerColor,
                            ),
                            StatusChip(
                              'local_study'.tr,
                              icon: Icons.auto_stories_outlined,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar:
            desktop || MediaQuery.viewInsetsOf(context).bottom > 0
            ? null
            : NavigationBar(
                height: 72,
                backgroundColor: Theme.of(context).cardColor,
                surfaceTintColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.primaryContainer,
                selectedIndex: category != null
                    ? 1
                    : (Get.currentRoute == AppRoutes.result ||
                          Get.currentRoute == AppRoutes.review)
                    ? 3
                    : 0,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                onDestinationSelected: (index) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  switch (index) {
                    case 0:
                      if (Get.currentRoute != AppRoutes.home) {
                        Get.offAllNamed(AppRoutes.home);
                      }
                    case 1:
                      _study(category ?? Category.general);
                    case 2:
                      startPractice();
                    case 3:
                      showProgress(context);
                  }
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.grid_view_rounded, size: 21),
                    label: 'overview'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.menu_book_outlined, size: 21),
                    label: 'lessons'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.route_outlined, size: 21),
                    label: 'practice'.tr,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.bar_chart_rounded, size: 22),
                    label: 'progress'.tr,
                  ),
                ],
              ),
      );
    },
  );
}

void startPractice() {
  if (Get.find<DataService>().status.value == DataStatus.ready) {
    Get.toNamed(AppRoutes.exam);
  }
}

class _Sidebar extends StatelessWidget {
  final Category? category;
  final ValueChanged<Category> onCategory;
  const _Sidebar({this.category, required this.onCategory});
  @override
  Widget build(BuildContext context) => Container(
    width: 260,
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 20, 24),
          child: Row(
            children: [
              const BrandMark(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driving Rules',
                      style: AppTextStyles.headline2.copyWith(fontSize: 20),
                    ),
                    Text(
                      'LEARN. PRACTICE. DRIVE.',
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        letterSpacing: .65,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            children: [
              _NavItem(
                label: 'overview'.tr,
                icon: Icons.grid_view_rounded,
                selected:
                    category == null && Get.currentRoute == AppRoutes.home,
                onTap: () {
                  if (Get.currentRoute != AppRoutes.home) {
                    Get.offAllNamed(AppRoutes.home);
                  }
                },
              ),
              _NavItem(
                label: 'practice_exam'.tr,
                icon: Icons.route_outlined,
                onTap: startPractice,
              ),
              _NavItem(
                label: 'my_progress'.tr,
                icon: Icons.bar_chart_rounded,
                selected:
                    Get.currentRoute == AppRoutes.result ||
                    Get.currentRoute == AppRoutes.review,
                onTap: () => showProgress(context),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 14, bottom: 12),
                child: Eyebrow('learning_library'.tr),
              ),
              for (final c in learningCategories)
                _NavItem(
                  label: c.navKey.tr,
                  icon: c.icon,
                  selected: c == category,
                  onTap: () => onCategory(c),
                  trailing: '${c.sourceCount}',
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 23,
                  color: AppColors.accentGreen,
                ),
                const SizedBox(height: 10),
                Text(
                  'small_steps'.tr,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 7),
                Text(
                  'sidebar_tip'.tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          child: Row(
            children: [
              const Icon(
                Icons.favorite_border_rounded,
                size: 13,
                color: AppColors.accentGreen,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'made_for_cambodia'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? trailing;
  const _NavItem({
    required this.label,
    required this.icon,
    this.selected = false,
    required this.onTap,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Material(
      color: selected
          ? Theme.of(context).colorScheme.primaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.mutedFor(Theme.of(context).brightness),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class PageContent extends StatelessWidget {
  final List<Widget> children;
  final double maxWidth;
  const PageContent({super.key, required this.children, this.maxWidth = 1240});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        constraints.maxWidth < 600 ? 20 : 36,
        30,
        constraints.maxWidth < 600 ? 20 : 36,
        36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: MotionEntrance(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}

void showProgress(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
  final storage = Get.find<StorageService>();
  final last = storage.readLastResult();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    constraints: const BoxConstraints(maxWidth: 600),
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SectionHeading('my_progress'.tr, subtitle: 'progress_subtitle'.tr),
            const SizedBox(height: 22),
            PremiumCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow('best_score'.tr),
                  const SizedBox(height: 10),
                  Text(
                    '${storage.bestScore} / 45',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: storage.bestScore / 45,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    last == null
                        ? 'progress_empty'.tr
                        : '${'last_score'.tr}: ${last.totalCorrect} / ${last.total}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                startPractice();
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
              label: Text('exam_start'.tr),
            ),
            if (last != null) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.result, arguments: last);
                },
                child: Text('view_last_result'.tr),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
