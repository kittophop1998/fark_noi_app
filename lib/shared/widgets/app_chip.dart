import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';
import 'pressable.dart';

/// A preset you flick through: a category, a radius, an amount.
///
/// **A chip is selectable; a badge is not.** Keeping the two apart is what
/// stops a feed's filters and its statuses from looking like the same control.
///
/// Selected is a coral tint with `primaryInkStrong` ink, never a filled coral:
/// a row of filled coral chips would spend the screen's one loud thing on a
/// filter, leaving the actual action nothing to be louder than.
class AppChoiceChip extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  /// An emoji or any small widget in the icon's place.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.ease,
        height: AppMetrics.controlSm,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: AppRadius.brPill,
          border: Border.all(
            color: selected ? AppColors.primaryBorder : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: AppSpace.x1 + 2),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: AppMetrics.iconXs,
                color: selected ? AppColors.primaryInkStrong : AppColors.faint,
              ),
              const SizedBox(width: AppSpace.x1 + 2),
            ],
            Text(
              label,
              style: AppText.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color:
                    selected ? AppColors.primaryInkStrong : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontally scrolling row of chips, bled to the page edge so the last one
/// does not look clipped by the gutter.
class AppChoiceChipRow extends StatelessWidget {
  const AppChoiceChipRow({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpace.pageX),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppMetrics.controlSm,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpace.x2),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }
}
