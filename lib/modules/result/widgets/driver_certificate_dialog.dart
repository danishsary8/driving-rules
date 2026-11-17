import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/models/exam_result_model.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/file_download.dart';

/// Interactive high-resolution official pass certificate modal displayed when
/// the user passes the driving theory exam (38+ score and 100% priority accuracy).
///
/// Features authentic Cambodian national styling, bilingual typography, and
/// instant high-resolution PNG image download via [RepaintBoundary].
class DriverCertificateDialog extends StatefulWidget {
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

  @override
  State<DriverCertificateDialog> createState() => _DriverCertificateDialogState();
}

class _DriverCertificateDialogState extends State<DriverCertificateDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  String get _serialId {
    final now = DateTime.now();
    final year = now.year;
    final dayOfYear = now.difference(DateTime(year, 1, 1)).inDays;
    final scoreHex = widget.result.totalCorrect.toRadixString(16).toUpperCase();
    return 'KH-DR-$year-$dayOfYear$scoreHex';
  }

  Future<void> _exportCertificate() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      AppHaptics.success();
      final boundary =
          _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      final filename = 'Driver_Certificate_$_serialId.png';
      saveOrDownloadFile(pngBytes, filename);

      Get.snackbar(
        'certificate_title'.tr,
        'certificate_downloaded'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (_) {
      Clipboard.setData(ClipboardData(text: _serialId));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final serial = _serialId;
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Captured Credential Content for PNG rasterization
                  RepaintBoundary(
                    key: _repaintKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF162520)
                            : const Color(0xFFFCFDFD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Official Kingdom of Cambodia Header
                          Text(
                            'certificate_cambodia_header'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'NotoSansKhmer',
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'certificate_cambodia_motto'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'NotoSansKhmer',
                              color: AppColors.mutedFor(theme.brightness),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 90,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFD4AF37),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Gold emblem seal
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFFDE68A), Color(0xFFD4AF37)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: Color(0xFF4A3705),
                                size: 38,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Certificate Title
                          Text(
                            'certificate_title'.tr,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFD4AF37),
                              letterSpacing: 0.5,
                              fontSize: 21,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'certificate_theory_pass'.tr,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? const Color(0xFFE2E8F0)
                                  : const Color(0xFF1E293B),
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Official Pass Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.15),
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
                                  size: 19,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'certificate_pass_badge'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.1,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Score & Priority Clearance Box
                          Container(
                            padding: const EdgeInsets.all(16),
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
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: AppColors.mutedFor(
                                                    theme.brightness,
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${widget.result.totalCorrect} / ${widget.result.total}',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: const Color(0xFF10B981),
                                                  fontSize: 22,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      height: 38,
                                      width: 1,
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.black12,
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            'result_accuracy'.tr,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: AppColors.mutedFor(
                                                    theme.brightness,
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${(widget.result.totalCorrect / widget.result.total * 100).round()}%',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
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
                                const SizedBox(height: 12),
                                const Divider(height: 1),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.shield_rounded,
                                      color: Color(0xFFD4AF37),
                                      size: 19,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'certificate_priority_cleared'.tr,
                                        style: const TextStyle(
                                          color: Color(0xFFD4AF37),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons: Direct PNG Download & Copy ID
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC99726),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isExporting ? null : _exportCertificate,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      'download_certificate'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          icon: const Icon(Icons.copy_rounded, size: 17),
                          label: Text('share_certificate'.tr),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton(
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
