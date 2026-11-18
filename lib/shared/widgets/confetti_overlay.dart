import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive celebration confetti particle burst overlay.
///
/// Features realistic gravity, horizontal wind flutter (sine oscillation),
/// multi-axis rotational spin, vibrant celebratory colors, and auto-fade out.
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  final bool autoTrigger;

  const ConfettiOverlay({
    super.key,
    required this.child,
    this.autoTrigger = true,
  });

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();
  bool _isPlaying = false;

  static const List<Color> _palette = [
    Color(0xFFEAB308), // Gold
    Color(0xFF10B981), // Emerald
    Color(0xFF3B82F6), // Blue
    Color(0xFFEF4444), // Coral Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..addListener(() {
        if (mounted) setState(() {});
      })..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _isPlaying = false;
        }
      });

    if (widget.autoTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        play();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggers a fresh celebratory confetti burst.
  void play() {
    _particles.clear();
    const count = 75;
    for (int i = 0; i < count; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _random.nextDouble(),
          y: -0.15 - (_random.nextDouble() * 0.25),
          vx: (_random.nextDouble() - 0.5) * 0.45,
          vy: 0.35 + _random.nextDouble() * 0.55,
          size: 7.0 + _random.nextDouble() * 7.0,
          color: _palette[_random.nextInt(_palette.length)],
          rotationZ: _random.nextDouble() * math.pi * 2,
          spinZ: (_random.nextDouble() - 0.5) * 12.0,
          spinX: (_random.nextDouble() - 0.5) * 15.0,
          aspectRatio: 0.4 + _random.nextDouble() * 0.5,
          isCircle: _random.nextBool(),
        ),
      );
    }
    _isPlaying = true;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isPlaying)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(
                  progress: _controller.value,
                  particles: _particles,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double rotationZ;
  final double spinZ;
  final double spinX;
  final double aspectRatio;
  final bool isCircle;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotationZ,
    required this.spinZ,
    required this.spinX,
    required this.aspectRatio,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    // Fade out smoothly in the last 25% of the animation
    final double opacity = (1.0 - ((progress - 0.75) / 0.25).clamp(0.0, 1.0));
    final paint = Paint()..isAntiAlias = true;

    for (final p in particles) {
      final double t = progress;
      // Gravity with terminal velocity curve
      final double currentY = (p.y + p.vy * t + 0.5 * 0.8 * t * t) * size.height;
      // Horizontal flutter with sinusoidal wave
      final double flutter = math.sin((t * 8.0) + (p.size * 2)) * (size.width * 0.04);
      final double currentX = (p.x * size.width) + (p.vx * t * size.width) + flutter;

      // Skip particles outside viewport
      if (currentY > size.height + 20 || currentY < -40) continue;

      final double rotZ = p.rotationZ + (p.spinZ * t);
      final double scaleY = math.cos(p.spinX * t).abs().clamp(0.1, 1.0);

      paint.color = p.color.withValues(alpha: opacity * 0.95);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotZ);
      canvas.scale(1.0, scaleY);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
      } else {
        final w = p.size;
        final h = p.size * p.aspectRatio;
        final rrect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(2),
        );
        canvas.drawRRect(rrect, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
