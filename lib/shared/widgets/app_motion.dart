import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// One place for motion timing, easing and accessibility preferences.
abstract final class AppMotion {
  static const quick = Duration(milliseconds: 180);
  static const standard = Duration(milliseconds: 320);
  static const entrance = Duration(milliseconds: 650);
  static const page = Duration(milliseconds: 380);
  static Duration duration(BuildContext context, Duration value) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : value;
}

/// A finite entrance. The child is cached while only opacity/position animate.
class MotionEntrance extends StatelessWidget {
  final Widget child;
  final int order;
  const MotionEntrance({super.key, required this.child, this.order = 0});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = order.clamp(0, 5) * 55;
    final total = AppMotion.entrance.inMilliseconds + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      child: child,
      builder: (context, value, child) {
        final progress = Interval(
          delay / total,
          1,
          curve: Curves.easeOutCubic,
        ).transform(value);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - progress)),
            child: child,
          ),
        );
      },
    );
  }
}

class MotionSwitcher extends StatelessWidget {
  final Widget child;
  const MotionSwitcher({super.key, required this.child});
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: AppMotion.duration(context, AppMotion.standard),
    switchInCurve: Curves.easeOutCubic,
    switchOutCurve: Curves.easeInCubic,
    transitionBuilder: (child, animation) => FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .035),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    ),
    child: child,
  );
}

class AnimatedNumber extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;
  const AnimatedNumber({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: '$value$suffix',
    child: ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.toDouble()),
        duration: AppMotion.duration(
          context,
          const Duration(milliseconds: 850),
        ),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) =>
            Text('${value.round()}$suffix', style: style),
      ),
    ),
  );
}

/// Gentle fade and vertical travel for forward and backward route changes.
class AppPageTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final eased = animation.drive(CurveTween(curve: Curves.easeOutCubic));
    return FadeTransition(
      opacity: eased,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .025),
          end: Offset.zero,
        ).animate(eased),
        child: child,
      ),
    );
  }
}
