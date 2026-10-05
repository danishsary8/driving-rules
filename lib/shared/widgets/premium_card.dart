import 'package:flutter/material.dart';
import 'app_motion.dart';

class PremiumCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? accentColor;
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
    this.borderRadius = 22,
    this.accentColor,
  });
  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) {
        if (widget.onTap != null) setState(() => _hovered = true);
      },
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: AnimatedSlide(
        offset: _hovered ? const Offset(0, -.012) : Offset.zero,
        duration: AppMotion.duration(context, AppMotion.quick),
        child: AnimatedScale(
          scale: _pressed ? .988 : 1,
          duration: AppMotion.duration(context, AppMotion.quick),
          child: AnimatedContainer(
            duration: AppMotion.duration(context, AppMotion.quick),
            decoration: BoxDecoration(
              color: theme.cardColor,
              gradient: widget.accentColor == null
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.alphaBlend(
                          widget.accentColor!.withValues(alpha: .07),
                          theme.cardColor,
                        ),
                        theme.cardColor,
                      ],
                    ),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: (_hovered || _focused) && widget.onTap != null
                    ? theme.colorScheme.primary.withValues(alpha: .7)
                    : theme.dividerColor,
              ),
              boxShadow: (_hovered || _focused) && widget.onTap != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .04),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              type: MaterialType.transparency,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                canRequestFocus: widget.onTap != null,
                onFocusChange: (value) => setState(() => _focused = value),
                onHighlightChanged: widget.onTap == null
                    ? null
                    : (value) => setState(() => _pressed = value),
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
