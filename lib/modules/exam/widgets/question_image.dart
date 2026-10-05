import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/utils/asset_paths.dart';

/// Keeps the sign artwork on a neutral canvas and allows closer inspection.
class QuestionImage extends StatelessWidget {
  final String filename;
  const QuestionImage({super.key, required this.filename});
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFF9FAF6),
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => _ImageDialog(filename: filename),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _Artwork(filename: filename, height: 190),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.zoom_in_rounded,
                  size: 18,
                  color: AppColors.accentGreen,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'study_zoom_image'.tr,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _Artwork extends StatelessWidget {
  final String filename;
  final double? height;
  const _Artwork({required this.filename, this.height});
  @override
  Widget build(BuildContext context) => Image.asset(
    AssetPaths.promptImage(filename),
    width: double.infinity,
    height: height,
    fit: BoxFit.contain,
    errorBuilder: (context, error, stack) => const Icon(
      Icons.image_not_supported_outlined,
      size: 70,
      color: AppColors.textMutedLight,
    ),
  );
}

class _ImageDialog extends StatefulWidget {
  final String filename;
  const _ImageDialog({required this.filename});
  @override
  State<_ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<_ImageDialog> {
  final _transform = TransformationController();
  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _zoom(double factor, Size size) {
    final zoom = (_transform.value.getMaxScaleOnAxis() * factor).clamp(
      1.0,
      4.0,
    );
    _transform.value = Matrix4.translationValues(
      -size.width * (zoom - 1) / 2,
      -size.height * (zoom - 1) / 2,
      0,
    )..multiply(Matrix4.diagonal3Values(zoom, zoom, 1));
  }

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.all(20),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 740),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'study_image_hint'.tr,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'close'.tr,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    (constraints.maxHeight - 60).clamp(
                      0.0,
                      (MediaQuery.sizeOf(context).height * .5).clamp(
                        180.0,
                        460.0,
                      ),
                    ),
                  );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAF6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: size.width,
                        height: size.height,
                        child: InteractiveViewer(
                          transformationController: _transform,
                          minScale: 1,
                          maxScale: 4,
                          trackpadScrollCausesScale: true,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _Artwork(filename: widget.filename),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            tooltip: 'zoom_out'.tr,
                            onPressed: () => _zoom(.75, size),
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          TextButton(
                            onPressed: () =>
                                _transform.value = Matrix4.identity(),
                            child: Text('zoom_reset'.tr),
                          ),
                          IconButton(
                            tooltip: 'zoom_in'.tr,
                            onPressed: () => _zoom(1.4, size),
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
