import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../core/models/exam_result_model.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../core/utils/file_download.dart';

/// 9:16 vertical social media story achievement card modal for Instagram / Facebook / Telegram.
class SocialStoryDialog extends StatefulWidget {
  final ExamResult result;

  const SocialStoryDialog({super.key, required this.result});

  static Future<void> show(BuildContext context, {required ExamResult result}) {
    AppHaptics.success();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SocialStoryDialog(result: result),
    );
  }

  @override
  State<SocialStoryDialog> createState() => _SocialStoryDialogState();
}

class _SocialStoryDialogState extends State<SocialStoryDialog> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportStory() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      AppHaptics.success();
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      saveOrDownloadFile(pngBytes, 'driving_rules_story.png');

      if (mounted) {
        Get.snackbar(
          'story_download_title'.tr,
          'story_download_desc'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exportable 9:16 Card
              RepaintBoundary(
                key: _repaintKey,
                child: Container(
                  width: 340,
                  height: 580,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0F172A), // Slate 900
                        Color(0xFF064E3B), // Emerald 900
                        Color(0xFF022C22), // Deep Forest
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(
                                  0xFFF59E0B,
                                ).withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: Color(0xFFF59E0B),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'PRACTICE EXAM PASS',
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Trophy Icon with Glow
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.18),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 42,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Headline
                      const Text(
                        'ខ្ញុំបានប្រឡងជាប់ហើយ!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ការប្រឡងសាកល្បងទ្រឹស្ដីច្បាប់ចរាចរណ៍',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Score Circle Banner
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${widget.result.totalCorrect} / ${widget.result.total}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'ពិន្ទុ ${((widget.result.totalCorrect / widget.result.total) * 100).round()}% (ជាប់ការប្រឡងសាកល្បង)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Priority Safe Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(
                              0xFF10B981,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_rounded,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'សំណួរអាទិភាព ១០០% គ្មានកំហុស',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Footer URL & Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.language_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'drivingruletest.netlify.app',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: Text('close'.tr),
                  ),
                  const SizedBox(width: 14),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _isExporting ? null : _exportStory,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text('share_story_download'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
