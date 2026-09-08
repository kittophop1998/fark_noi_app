import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';
import 'pressable.dart';

/// A label and a value on one line — the shape a detail screen is made of.
///
/// The label is muted and the value is ink, so a column of them reads down the
/// values rather than down the labels.
class AppDataRow extends StatelessWidget {
  const AppDataRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.valueColor,
  });

  final String label;
  final String value;

  /// The row a screen is about — a total, a payout. One per group.
  final bool emphasis;

  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: (emphasis ? AppText.label : AppText.bodySmall).copyWith(
                color: emphasis ? AppColors.text : AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: AppSpace.x4),
          Text(
            value,
            textAlign: TextAlign.right,
            style: (emphasis ? AppText.price : AppText.bodySmall).copyWith(
              color: valueColor ?? AppColors.text,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A row that goes somewhere. A settings entry, a menu item, a person.
///
/// The chevron is the affordance and the whole row is the target — 44px
/// minimum, because a 20px glyph at the end of a line is not a thing a thumb
/// can aim at.
class AppNavRow extends StatelessWidget {
  const AppNavRow({
    super.key,
    required this.label,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final String label;
  final String? subtitle;
  final IconData? icon;

  /// A value at the end of the row, drawn *before* the chevron.
  final Widget? trailing;

  final VoidCallback? onTap;

  /// Sign out, delete. The ink goes red; the row does not.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ink = destructive ? AppColors.error : AppColors.text;

    return Pressable(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: AppMetrics.touchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x4,
          vertical: AppSpace.x3,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.brMd,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: destructive
                      ? AppColors.errorSoft
                      : AppColors.surfaceMuted,
                  borderRadius: AppRadius.brSm,
                ),
                child: Icon(icon, size: AppMetrics.iconSm, color: ink),
              ),
              const SizedBox(width: AppSpace.x3),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppText.label.copyWith(color: ink),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption.copyWith(color: AppColors.faint),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpace.x3),
              trailing!,
            ],
            if (onTap != null) ...[
              const SizedBox(width: AppSpace.x2),
              const Icon(
                Icons.chevron_right_rounded,
                size: AppMetrics.icon,
                color: AppColors.disabled,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A stack of rows sharing one white surface, with a hairline between them —
/// the settings-list shape, and the one place a divider is the right answer
/// rather than more space.
class AppRowGroup extends StatelessWidget {
  const AppRowGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brLg,
        boxShadow: AppShadow.xs,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.only(left: AppSpace.x4),
                child: Divider(height: 1, color: AppColors.divider),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
