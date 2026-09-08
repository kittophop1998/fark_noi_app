import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';
import 'pressable.dart';

/// Six variants, and a screen that needs a seventh look almost always needs one
/// of these in a different place instead.
///
/// The shape of the ladder is the point: exactly one filled coral action per
/// screen, a soft-coral alternative that reads as an option rather than a
/// rival, and everything below that carrying no container at all. There is
/// deliberately **no outlined brand button** — a ring of coral around a second
/// action is precisely how a screen ends up with two CTAs of equal weight.
enum AppButtonVariant {
  /// One filled action per screen. The thing to do next.
  primary,

  /// A real alternative to it: soft brand fill, brand ink, no border.
  secondary,

  /// Neutral and quiet, for actions that are not brand-weighted ("แก้ไข",
  /// "ยกเลิก"). A soft grey fill, not a ring — the name is kept because it is
  /// the one every design vocabulary uses for "the quiet neutral button".
  outline,

  /// Tertiary / inline. No container.
  ghost,

  /// Destructive and irreversible. Filled, so it is never mistaken for the safe
  /// option, but never the screen's default.
  danger,

  /// The rare confirming action that is *not* the screen's coral CTA — a runner
  /// marking money received. Filled green, and a genuine second choice.
  success,
}

/// `large` (52px) is the committing action's size — on a phone that is the
/// difference between a button you aim at and a button that is simply where
/// your thumb already is. `medium` is 44px, exactly the touch-target minimum.
/// `small` (36px) is the only step under it, used inline beside text where the
/// row itself carries the height.
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;

  /// Shows a spinner *inside* the button and blocks the press, which is what
  /// stops a double submit on a screen that moves money.
  final bool loading;

  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(variant);
    final metrics = _metrics(size);
    // Disabled keeps the button's own colours at 45% rather than collapsing to
    // grey, so the user can still read what the unavailable action was.
    final enabled = onPressed != null && !loading;
    final opacity = enabled ? 1.0 : 0.45;

    final content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: metrics.iconSize,
            height: metrics.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(palette.foreground),
            ),
          ),
          SizedBox(width: AppSpace.x2),
        ] else if (icon != null) ...[
          Icon(icon, size: metrics.iconSize, color: palette.foreground),
          SizedBox(width: AppSpace.x2),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: metrics.textStyle.copyWith(color: palette.foreground),
          ),
        ),
        if (trailingIcon != null) ...[
          SizedBox(width: AppSpace.x2),
          Icon(trailingIcon, size: metrics.iconSize, color: palette.foreground),
        ],
      ],
    );

    return Opacity(
      opacity: opacity,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.ease,
          height: metrics.height,
          width: fullWidth ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: metrics.paddingX),
          decoration: BoxDecoration(
            color: palette.background,
            borderRadius: AppRadius.brMd,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

class _ButtonPalette {
  const _ButtonPalette(this.background, this.foreground);
  final Color background;
  final Color foreground;
}

_ButtonPalette _palette(AppButtonVariant variant) {
  switch (variant) {
    case AppButtonVariant.primary:
      return const _ButtonPalette(AppColors.primary, AppColors.onPrimary);
    // `primaryInkStrong` rather than `primary` or `primaryInk`: the fill is a
    // coral tint, where `primary` lands at 3.0:1 (a legible *shape* and an
    // illegible *label*) and `primaryInk` at 4.24:1. The strong step clears
    // 4.5:1, which is what a 14px semibold needs.
    case AppButtonVariant.secondary:
      return const _ButtonPalette(
        AppColors.primarySoft,
        AppColors.primaryInkStrong,
      );
    case AppButtonVariant.outline:
      return const _ButtonPalette(AppColors.surfaceMuted, AppColors.text);
    case AppButtonVariant.ghost:
      return const _ButtonPalette(Colors.transparent, AppColors.primaryInk);
    // Both filled status variants take the `-fill` step, not the icon step:
    // `success` and `error` sit at 3.8:1 and 4.8:1 under white, and a label
    // needs 4.5:1.
    case AppButtonVariant.danger:
      return const _ButtonPalette(
        AppColors.dangerFill,
        AppColors.dangerForeground,
      );
    case AppButtonVariant.success:
      return const _ButtonPalette(
        AppColors.successFill,
        AppColors.successForeground,
      );
  }
}

class _ButtonMetrics {
  const _ButtonMetrics({
    required this.height,
    required this.paddingX,
    required this.iconSize,
    required this.textStyle,
  });

  final double height;
  final double paddingX;
  final double iconSize;
  final TextStyle textStyle;
}

_ButtonMetrics _metrics(AppButtonSize size) {
  switch (size) {
    case AppButtonSize.small:
      return _ButtonMetrics(
        height: AppMetrics.controlSm,
        paddingX: 14,
        iconSize: AppMetrics.iconXs,
        textStyle: AppText.caption.copyWith(fontWeight: FontWeight.w600),
      );
    case AppButtonSize.medium:
      return _ButtonMetrics(
        height: AppMetrics.controlMd,
        paddingX: AppSpace.x4,
        iconSize: AppMetrics.iconSm,
        textStyle: AppText.label,
      );
    case AppButtonSize.large:
      return _ButtonMetrics(
        height: AppMetrics.controlLg,
        paddingX: AppSpace.x6,
        iconSize: AppMetrics.icon,
        textStyle: AppText.body.copyWith(fontWeight: FontWeight.w600),
      );
  }
}

/// An icon-only control. 44px even at its smallest, because it is still what a
/// thumb aims at.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.background = Colors.transparent,
    this.foreground = AppColors.muted,
    this.size = AppMetrics.touchTarget,
    this.iconSize = AppMetrics.icon,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final double size;
  final double iconSize;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Pressable(
      onTap: onPressed,
      scale: 0.94,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.brPill,
        ),
        child: Icon(icon, size: iconSize, color: foreground),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
