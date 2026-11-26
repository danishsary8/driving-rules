import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/question_model.dart';
import '../../../core/utils/app_haptics.dart';

class BookmarksBanner extends StatelessWidget {
  final int count;
  const BookmarksBanner({super.key, required this.count});

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
