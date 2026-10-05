/// A press-feedback wrapper that scales its child down on touch.
///
/// [PressScale] gives interactive elements an Apple-style tactile feel: on
/// tap-down the [child] animates to 97% scale, and on tap-up or cancel it
/// springs back to 100%. The animation uses [AnimatedScale] (~130ms,
/// [Curves.easeOutCubic]). Taps are reported through [onTap]. (Req 16.6)
library;

import 'package:flutter/material.dart';

/// Wraps [child] and animates a subtle scale-down while pressed.
class PressScale extends StatefulWidget {
  /// The widget to scale on press.
  final Widget child;

  /// Called when the press completes as a tap.
  final VoidCallback? onTap;

  /// Scale applied while pressed. Defaults to `0.97`.
  final double pressedScale;

  /// Duration of the scale animation. Defaults to 130ms.
  final Duration duration;

  /// Creates a press-scale wrapper.
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 130),
  });

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
