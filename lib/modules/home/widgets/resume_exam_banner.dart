import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/services/storage_service.dart';

class ResumeExamBanner extends StatelessWidget {
  final StorageService storage;
  final VoidCallback onResume;
  final VoidCallback onDiscard;

  const ResumeExamBanner({
    super.key,
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
                          '${'exam_resume_desc'.tr} · ${'exam_question_progress'.tr} $currentQ/45 (${'home_answered_count'.trParams({'n': '$answersCount'})})',
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
