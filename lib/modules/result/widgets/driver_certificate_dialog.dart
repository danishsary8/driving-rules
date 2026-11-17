import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/exam_result_model.dart';
import '../../../core/utils/app_haptics.dart';

/// Interactive high-resolution official pass certificate modal displayed when
/// the user passes the driving theory exam (38+ score and 100% priority accuracy).
class DriverCertificateDialog extends StatelessWidget {
  final ExamResult result;

  const DriverCertificateDialog({super.key, required this.result});

  static Future<void> show(BuildContext context, {required ExamResult result}) {
    AppHaptics.success();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => DriverCertificateDialog(result: result),
    );
  }

  String _generateSerialId() {
    final now = DateTime.now();
    final year = now.year;
    final dayOfYear = now.difference(DateTime(year, 1, 1)).inDays;
    final scoreHex = result.totalCorrect.toRadixString(16).toUpperCase();
    return 'KH-DR-$year-$dayOfYear$scoreHex';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final serial = _generateSerialId();
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF162520) : const Color(0xFFFCFDFD),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gold emblem seal
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFDE68A), Color(0xFFD4AF37)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF4A3705),
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header titles
                  Text(
                    'certificate_title'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFD4AF37),
                      letterSpacing: 0.5,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'certificate_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedFor(theme.brightness),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Official Pass Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'certificate_pass_badge'.tr,
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Score & Priority Clearance Box
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'certificate_score_label'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: AppColors.mutedFor(theme.brightness),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${result.totalCorrect} / ${result.total}',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF10B981),
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'result_accuracy'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      color: AppColors.mutedFor(theme.brightness),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(result.totalCorrect / result.total * 100).round()}%',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFFD4AF37),
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.shield_rounded,
                              color: Color(0xFFD4AF37),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'certificate_priority_cleared'.tr,
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Metadata row: Serial & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'certificate_serial'.tr,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.mutedFor(theme.brightness),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            serial,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'certificate_date'.tr,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.mutedFor(theme.brightness),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            dateStr,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            AppHaptics.light();
                            Clipboard.setData(ClipboardData(text: serial));
                            Get.snackbar(
                              'certificate_serial'.tr,
                              'certificate_copied'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: Text('share_certificate'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            AppHaptics.light();
                            Get.back();
                          },
                          child: Text('exam_leave_no'.tr),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
