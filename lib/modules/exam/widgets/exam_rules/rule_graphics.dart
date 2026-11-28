import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_theme.dart';

/// Red pills for questions 26–30 with a "no mistakes" label.
class PriorityRuleGraphic extends StatelessWidget {
  const PriorityRuleGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentRed.withValues(alpha: isDark ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accentRed.withValues(alpha: 0.3)),
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
          // An icon, not an emoji: emoji need a font downloaded at runtime,
          // which the installed app can't do offline.
          const Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: AppColors.accentRed,
          ),
          const SizedBox(width: 3),
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
}

/// Progress bar showing the 38 / 45 (84%) pass mark.
class PassRuleGraphic extends StatelessWidget {
  const PassRuleGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'rules_pass_target'.tr,
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
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.accentGreen,
            ),
          ),
        ),
      ],
    );
  }
}

/// Clock tag for the 45-minute countdown.
class TimeRuleGraphic extends StatelessWidget {
  const TimeRuleGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          const Icon(
            Icons.access_time_rounded,
            color: Color(0xFF2563EB),
            size: 14,
          ),
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
}

/// Chips for going back, changing answers and reviewing.
class NavRuleGraphic extends StatelessWidget {
  const NavRuleGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _MiniBadge(icon: Icons.arrow_back_rounded, label: 'rules_mini_back'.tr),
        _MiniBadge(
          icon: Icons.edit_note_rounded,
          label: 'rules_mini_change'.tr,
        ),
        _MiniBadge(icon: Icons.done_all_rounded, label: 'rules_mini_review'.tr),
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
