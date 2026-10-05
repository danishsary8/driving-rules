import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_theme.dart';
import '../../core/models/question_model.dart';
import 'app_motion.dart';

const learningCategories = [
  Category.general,
  Category.sign,
  Category.priority,
  Category.technique,
  Category.emergency,
];

extension CategoryDesign on Category {
  IconData get icon => switch (this) {
    Category.general => Icons.menu_book_rounded,
    Category.sign => Icons.traffic_outlined,
    Category.priority => Icons.alt_route_rounded,
    Category.technique => Icons.directions_car_filled_outlined,
    Category.emergency => Icons.health_and_safety_outlined,
  };
  Color get color => switch (this) {
    Category.general => AppColors.accentGreen,
    Category.sign => const Color(0xFFAD751B),
    Category.priority => const Color(0xFF7B6DA7),
    Category.technique => const Color(0xFF347C9C),
    Category.emergency => const Color(0xFFB65656),
  };
}

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 42});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.accentGold,
      borderRadius: BorderRadius.circular(size * .29),
    ),
    child: CustomPaint(painter: _BrandPainter()),
  );
}

class _BrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 42, size.height / 42);
    final path = Path()
      ..moveTo(14, 31)
      ..lineTo(20, 11)
      ..lineTo(24, 11)
      ..lineTo(30, 31)
      ..lineTo(24, 31)
      ..lineTo(21, 19)
      ..lineTo(18, 31)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.textDark);
    canvas.drawLine(
      const Offset(21, 26),
      const Offset(22, 30),
      Paint()
        ..color = AppColors.accentGold
        ..strokeWidth = 1.5,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Eyebrow extends StatelessWidget {
  final String text;
  final Color? color;
  const Eyebrow(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: Get.locale?.languageCode == 'km' ? 0 : 1.0,
      color: color ?? AppColors.mutedFor(Theme.of(context).brightness),
    ),
  );
}

class StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool adaptive;
  const StatusChip(
    this.label, {
    super.key,
    this.icon,
    this.color = AppColors.accentGreen,
    this.adaptive = true,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: adaptive
                ? AppColors.contentColor(color, Theme.of(context).brightness)
                : color,
          ),
          const SizedBox(width: 5),
        ],
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: adaptive
                  ? AppColors.contentColor(color, Theme.of(context).brightness)
                  : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const SectionHeading(this.title, {super.key, this.subtitle, this.trailing});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedFor(Theme.of(context).brightness),
                ),
              ),
            ],
          ],
        ),
      ),
      if (trailing != null) ...[const SizedBox(width: 12), trailing!],
    ],
  );
}

/// Resolution independent artwork for the dashboard and welcome screen.
class RoadIllustration extends StatelessWidget {
  final bool compact;
  const RoadIllustration({super.key, this.compact = false});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: .3, end: .55),
        duration: AppMotion.duration(
          context,
          const Duration(milliseconds: 1800),
        ),
        curve: Curves.easeInOutCubic,
        builder: (context, progress, _) => CustomPaint(
          painter: _RoadPainter(progress),
          size: Size(compact ? 220 : 390, compact ? 180 : 300),
        ),
      ),
    ),
  );
}

class _RoadPainter extends CustomPainter {
  final double progress;
  _RoadPainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 390, size.height / 300);
    final paint = Paint();
    for (var i = 0; i < 4; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(238, 148),
          width: 190 + i * 56,
          height: 120 + i * 53,
        ),
        paint
          ..color = const Color(0xFFDFC990).withValues(alpha: .38)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    final path = Path()
      ..moveTo(20, 332)
      ..cubicTo(10, 225, 182, 247, 184, 168)
      ..cubicTo(188, 100, 304, 169, 324, 91)
      ..cubicTo(337, 53, 299, 24, 343, -30);
    canvas.drawPath(
      path,
      paint
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 76
        ..color = const Color(0xFFE1CB9B),
    );
    canvas.drawPath(
      path,
      paint
        ..strokeWidth = 63
        ..color = const Color(0xFF414B42),
    );
    canvas.drawPath(
      path,
      paint
        ..strokeWidth = 53
        ..color = const Color(0xFF566052),
    );
    final metric = path.computeMetrics().first;
    for (double d = 0; d < metric.length; d += 26) {
      canvas.drawPath(
        metric.extractPath(d, d + 12),
        paint
          ..strokeWidth = 2
          ..color = const Color(0xFFFFE5A0),
      );
    }
    void tree(double x, double y, double radius) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 5, y + 14),
          width: radius * 2,
          height: radius,
        ),
        paint
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF847E4D).withValues(alpha: .15),
      );
      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + 18),
        paint
          ..color = const Color(0xFF766847)
          ..strokeWidth = 4,
      );
      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = const Color(0xFF819066),
      );
      canvas.drawCircle(
        Offset(x - 5, y - 4),
        radius * .66,
        paint..color = const Color(0xFF9CA77A),
      );
    }

    tree(78, 174, 20);
    tree(255, 206, 23);
    tree(132, 64, 16);
    tree(365, 193, 16);
    canvas.save();
    final position = metric.getTangentForOffset(metric.length * progress)!;
    canvas.translate(position.position.dx, position.position.dy);
    canvas.rotate(
      math.atan2(position.vector.dy, position.vector.dx) + math.pi / 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, -25, 32, 53),
        const Radius.circular(9),
      ),
      paint..color = Colors.black.withValues(alpha: .18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-15, -28, 30, 52),
        const Radius.circular(8),
      ),
      paint..color = const Color(0xFFF7C64F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-11, -15, 22, 27),
        const Radius.circular(5),
      ),
      paint..color = const Color(0xFF354A41),
    );
    canvas.drawRect(
      const Rect.fromLTWH(-10, -8, 20, 14),
      paint..color = const Color(0xFFE9B444),
    );
    canvas.drawLine(
      const Offset(-9, -22),
      const Offset(9, -22),
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFEAB0),
    );
    canvas.restore();
    canvas.drawLine(
      const Offset(290, 58),
      const Offset(290, 102),
      paint
        ..strokeWidth = 3
        ..color = const Color(0xFF7E8268),
    );
    canvas.drawCircle(
      const Offset(290, 54),
      21,
      paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFC55D49),
    );
    canvas.drawCircle(
      const Offset(290, 54),
      16,
      paint..color = const Color(0xFFFFFBF0),
    );
    final label = TextPainter(
      text: const TextSpan(
        text: '40',
        style: TextStyle(
          fontFamily: 'Kanit',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(290 - label.width / 2, 54 - label.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RoadPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
