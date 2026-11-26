import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/utils/app_haptics.dart';

/// A prominent, beautifully styled carousel modal that explains the official driving
/// exam rules in 4 clean, bite-sized slides with smooth transitions and haptic feedback.
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
      builder: (context) => ExamRulesDialog(
        onStart: onStart,
        isRevisit: isRevisit,
      ),
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
      _RuleSlideData(
        icon: Icons.warning_amber_rounded,
        accentColor: AppColors.accentRed,
        badgeText: 'rules_badge_strict'.tr,
        title: 'rule_priority_title'.tr,
        highlightText: 'rules_hl_priority'.tr,
        description: 'rule_priority_desc'.tr,
        tipText: 'exam_rules_tip_priority'.tr,
        isStrict: true,
        visualGraphic: _buildPriorityGraphic(isDark),
      ),
      // 2. PASSING SCORE REQUIREMENT
      _RuleSlideData(
        icon: Icons.verified_rounded,
        accentColor: AppColors.accentGreen,
        badgeText: 'rules_badge_pass'.tr,
        title: 'rule_pass_title'.tr,
        highlightText: 'rules_hl_pass'.tr,
        description: 'rule_pass_desc'.tr,
        tipText: 'exam_rules_tip_pass'.tr,
        visualGraphic: _buildPassGraphic(theme, isDark),
      ),
      // 3. TIME LIMIT
      _RuleSlideData(
        icon: Icons.timer_outlined,
        accentColor: const Color(0xFF2563EB),
        badgeText: 'rules_badge_time'.tr,
        title: 'rule_time_title'.tr,
        highlightText: 'rules_hl_time'.tr,
        description: 'rule_time_desc'.tr,
        tipText: 'exam_rules_tip_time'.tr,
        visualGraphic: _buildTimeGraphic(isDark),
      ),
      // 4. NAVIGATION & ANSWER REVIEW
      _RuleSlideData(
        icon: Icons.swap_horiz_rounded,
        accentColor: const Color(0xFF8B5CF6),
        badgeText: 'rules_badge_review'.tr,
        title: 'rule_nav_title'.tr,
        highlightText: 'rules_hl_review'.tr,
        description: 'rule_nav_desc'.tr,
        tipText: 'exam_rules_tip_nav'.tr,
        visualGraphic: _buildNavGraphic(theme, isDark),
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
            // 1. DIALOG HEADER WITH STEP COUNTER
            Container(
              padding: EdgeInsets.fromLTRB(compact ? 14 : 20, 14, 10, 14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2623)
                    : const Color(0xFFF4F7F5),
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: compact ? 38 : 42,
                    height: compact ? 38 : 42,
                    decoration: BoxDecoration(
                      color: AppColors.accentGold.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFFB58316),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'exam_rules_title'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Kanit',
                            fontSize: compact ? 15 : 16.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'exam_rules_subtitle'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedFor(theme.brightness),
                            fontSize: compact ? 11 : 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Step Indicator Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: currentRule.accentColor.withValues(
                        alpha: isDark ? 0.22 : 0.12,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: currentRule.accentColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / 4',
                      style: TextStyle(
                        color: currentRule.accentColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    tooltip: 'close'.tr,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
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
                  return _RuleCarouselSlide(
                    data: data,
                    compact: compact,
                    isDark: isDark,
                  );
                },
              ),
            ),

            // 3. ANIMATED DOT / PILL INDICATOR
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(rules.length, (idx) {
                  final isActive = idx == _currentIndex;
                  return InkWell(
                    onTap: () => _goToPage(idx),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 3.5),
                      width: isActive ? 24 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isActive
                            ? currentRule.accentColor
                            : theme.dividerColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // 4. BOTTOM ACTION CONTROLS
            Container(
              padding: EdgeInsets.fromLTRB(
                compact ? 10 : 16,
                8,
                compact ? 10 : 16,
                12,
              ),
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Left Action Button
                  if (widget.isRevisit) ...[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('close'.tr),
                    ),
                    const SizedBox(width: 8),
                  ] else if (_currentIndex == 0) ...[
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        foregroundColor: AppColors.mutedFor(theme.brightness),
                      ),
                      onPressed: _handleConfirm,
                      icon: const Icon(Icons.flash_on_rounded, size: 15),
                      label: Text(
                        'exam_rules_skip'.tr,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ] else ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 10 : 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back_rounded, size: 15),
                      label: Text(
                        'exam_back'.tr,
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Right Action Button (Expanded so it always fits without overflow!)
                  Expanded(
                    child: widget.isRevisit
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.check_rounded, size: 17),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('close'.tr),
                            ),
                          )
                        : _currentIndex < rules.length - 1
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentRule.accentColor,
                                  foregroundColor: Colors.white,
                                  elevation: 1.5,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 14 : 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _nextPage,
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'exam_next'.tr,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              )
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 12 : 18,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _handleConfirm,
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 19,
                                ),
                                label: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'exam_rules_confirm'.tr,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Visual Graphic: Priority 26-30 Pill (1-based, as displayed)
  Widget _buildPriorityGraphic(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accentRed.withValues(alpha: 0.3),
        ),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final q in ['26', '27', '28', '29', '30'])
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.accentRed,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                q,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                ),
              ),
            ),
          const SizedBox(width: 4),
          Text(
            'rules_zero_mistakes'.tr,
            style: TextStyle(
              color: AppColors.accentRed,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Visual Graphic: Pass Progress Bar
  Widget _buildPassGraphic(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Target: 38 / 45 Correct',
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '84%',
              style: TextStyle(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 38 / 45,
            minHeight: 7,
            backgroundColor: AppColors.accentGreen.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
          ),
        ),
      ],
    );
  }

  // Visual Graphic: Time Clock Tag
  Widget _buildTimeGraphic(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2563EB).withValues(alpha: 0.3),
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.access_time_rounded, color: Color(0xFF2563EB), size: 14),
          SizedBox(width: 5),
          Text(
            'rules_countdown'.tr,
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // Visual Graphic: Nav Directional Chips
  Widget _buildNavGraphic(ThemeData theme, bool isDark) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildMiniBadge(Icons.arrow_back_rounded, 'rules_mini_back'.tr, theme, isDark),
        _buildMiniBadge(Icons.edit_note_rounded, 'rules_mini_change'.tr, theme, isDark),
        _buildMiniBadge(Icons.done_all_rounded, 'rules_mini_review'.tr, theme, isDark),
      ],
    );
  }

  Widget _buildMiniBadge(
    IconData icon,
    String label,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleSlideData {
  final IconData icon;
  final Color accentColor;
  final String badgeText;
  final String title;
  final String highlightText;
  final String description;
  final String tipText;
  final bool isStrict;
  final Widget? visualGraphic;

  const _RuleSlideData({
    required this.icon,
    required this.accentColor,
    required this.badgeText,
    required this.title,
    required this.highlightText,
    required this.description,
    required this.tipText,
    this.isStrict = false,
    this.visualGraphic,
  });
}

class _RuleCarouselSlide extends StatelessWidget {
  final _RuleSlideData data;
  final bool compact;
  final bool isDark;

  const _RuleCarouselSlide({
    required this.data,
    required this.compact,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        compact ? 14 : 20,
        14,
        compact ? 14 : 20,
        8,
      ),
      child: Container(
        padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(
          color: data.accentColor.withValues(alpha: isDark ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: data.accentColor.withValues(alpha: 0.35),
            width: data.isStrict ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Badge + Icon
            Row(
              children: [
                Container(
                  width: compact ? 36 : 40,
                  height: compact ? 36 : 40,
                  decoration: BoxDecoration(
                    color: data.accentColor.withValues(
                      alpha: isDark ? 0.28 : 0.16,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    color: data.accentColor,
                    size: compact ? 20 : 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: data.isStrict
                            ? AppColors.accentRed
                            : data.accentColor.withValues(
                                alpha: isDark ? 0.24 : 0.12,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        data.badgeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: data.isStrict ? Colors.white : data.accentColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              data.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'Kanit',
                color: data.isStrict
                    ? AppColors.accentRed
                    : theme.textTheme.titleMedium?.color,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 15 : 16.5,
              ),
            ),
            const SizedBox(height: 6),

            // Highlight Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.7,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                data.highlightText,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.contentColor(
                    data.accentColor,
                    theme.brightness,
                  ),
                  fontSize: compact ? 11.5 : 12.5,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Visual Graphic (if present)
            if (data.visualGraphic != null) ...[
              data.visualGraphic!,
              const SizedBox(height: 10),
            ],

            // Full Description
            Text(
              data.description,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.55,
                fontSize: compact ? 12 : 12.8,
              ),
            ),
            const SizedBox(height: 10),

            // Actionable Pro-Tip Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF262624)
                    : const Color(0xFFFEF9C3).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEAB308).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Color(0xFFCA8A04),
                    size: 15,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data.tipText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        height: 1.4,
                        color: isDark ? const Color(0xFFFDE047) : const Color(0xFF854D0E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
