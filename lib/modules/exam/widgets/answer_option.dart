import 'package:flutter/material.dart';
import '../../../app/themes/app_theme.dart';
import '../../../shared/widgets/app_motion.dart';

class AnswerOption extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final int index;
  final bool? correct;
  const AnswerOption({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.index = 0,
    this.correct,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = selected || correct == true;
    final color = correct == false
        ? AppColors.accentRed
        : AppColors.accentGreen;
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: AnimatedContainer(
        duration: AppMotion.duration(context, AppMotion.quick),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: .08) : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color.withValues(alpha: .65) : theme.dividerColor,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: AppMotion.duration(context, AppMotion.quick),
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? color
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: correct != null && active
                        ? Icon(
                            correct!
                                ? Icons.check_rounded
                                : Icons.close_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : Text(
                            String.fromCharCode(65 + index),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: active
                                  ? Colors.white
                                  : AppColors.mutedFor(theme.brightness),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      correct == false
                          ? Icons.cancel_rounded
                          : active
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 19,
                      color: active
                          ? AppColors.contentColor(color, theme.brightness)
                          : AppColors.mutedFor(theme.brightness),
                    ),
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
