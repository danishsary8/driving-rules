import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/utils/app_haptics.dart';
import 'exam_rules/rule_graphics.dart';
import 'exam_rules/rule_slide.dart';
import 'exam_rules/rules_dialog_parts.dart';

/// Carousel dialog that explains the exam rules in 4 short slides.
/// Can be re-opened anytime during the exam via the in-exam reminder pill.
class ExamRulesDialog extends StatefulWidget {
  final VoidCallback onStart;
  final bool isRevisit;

  const ExamRulesDialog({
    super.key,
    required this.onStart,
    this.isRevisit = false,
  });

  /// Shows the rules modal dialog.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onStart,
    bool isRevisit = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          ExamRulesDialog(onStart: onStart, isRevisit: isRevisit),
    );
  }

  @override
  State<ExamRulesDialog> createState() => _ExamRulesDialogState();
}

class _ExamRulesDialogState extends State<ExamRulesDialog> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    AppHaptics.selection();
    if (_currentIndex < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    AppHaptics.selection();
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _goToPage(int index) {
    AppHaptics.selection();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleConfirm() {
    AppHaptics.success();
    Navigator.of(context).pop();
    widget.onStart();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;
    final compact = width < 480;

    // Define the 4 instructional rules
    final rules = [
      // 1. CRITICAL PRIORITY RULE
      RuleSlideData(
        icon: Icons.warning_amber_rounded,
        accentColor: AppColors.accentRed,
        badgeText: 'rules_badge_strict'.tr,
        title: 'rule_priority_title'.tr,
        highlightText: 'rules_hl_priority'.tr,
        description: 'rule_priority_desc'.tr,
        tipText: 'exam_rules_tip_priority'.tr,
        isStrict: true,
        visualGraphic: const PriorityRuleGraphic(),
      ),
      // 2. PASSING SCORE REQUIREMENT
      RuleSlideData(
        icon: Icons.verified_rounded,
        accentColor: AppColors.accentGreen,
        badgeText: 'rules_badge_pass'.tr,
        title: 'rule_pass_title'.tr,
        highlightText: 'rules_hl_pass'.tr,
        description: 'rule_pass_desc'.tr,
        tipText: 'exam_rules_tip_pass'.tr,
        visualGraphic: const PassRuleGraphic(),
      ),
      // 3. TIME LIMIT
      RuleSlideData(
        icon: Icons.timer_outlined,
        accentColor: const Color(0xFF2563EB),
        badgeText: 'rules_badge_time'.tr,
        title: 'rule_time_title'.tr,
        highlightText: 'rules_hl_time'.tr,
        description: 'rule_time_desc'.tr,
        tipText: 'exam_rules_tip_time'.tr,
        visualGraphic: const TimeRuleGraphic(),
      ),
      // 4. NAVIGATION & ANSWER REVIEW
      RuleSlideData(
        icon: Icons.swap_horiz_rounded,
        accentColor: const Color(0xFF8B5CF6),
        badgeText: 'rules_badge_review'.tr,
        title: 'rule_nav_title'.tr,
        highlightText: 'rules_hl_review'.tr,
        description: 'rule_nav_desc'.tr,
        tipText: 'exam_rules_tip_nav'.tr,
        visualGraphic: const NavRuleGraphic(),
      ),
    ];

    final currentRule = rules[_currentIndex];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 24,
        vertical: height < 600 ? 8 : 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.cardColor,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: compact ? 395 : 480,
          maxHeight: compact ? 560 : 590,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RulesDialogHeader(
              compact: compact,
              accentColor: currentRule.accentColor,
              currentIndex: _currentIndex,
            ),
            // 2. CAROUSEL SLIDES (PAGEVIEW)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: rules.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  AppHaptics.selection();
                },
                itemBuilder: (context, index) {
                  final data = rules[index];
                  return RuleCarouselSlide(
                    data: data,
                    compact: compact,
                    isDark: isDark,
                  );
                },
              ),
            ),
            RulesPageDots(
              total: rules.length,
              currentIndex: _currentIndex,
              accentColor: currentRule.accentColor,
              onDotTap: _goToPage,
            ),
            RulesDialogActions(
              compact: compact,
              isRevisit: widget.isRevisit,
              currentIndex: _currentIndex,
              total: rules.length,
              accentColor: currentRule.accentColor,
              onBack: _previousPage,
              onNext: _nextPage,
              onConfirm: _handleConfirm,
            ),
          ],
        ),
      ),
    );
  }
}
