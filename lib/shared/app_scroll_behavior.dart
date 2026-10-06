import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Keep web scrolling inside the app while preserving native platform physics.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => kIsWeb
      ? const RangeMaintainingScrollPhysics(parent: ClampingScrollPhysics())
      : super.getScrollPhysics(context);

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => kIsWeb ? child : super.buildOverscrollIndicator(context, child, details);

  @override
  ScrollViewKeyboardDismissBehavior getKeyboardDismissBehavior(
    BuildContext context,
  ) => ScrollViewKeyboardDismissBehavior.onDrag;
}
