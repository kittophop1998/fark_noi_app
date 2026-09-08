import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import 'pressable.dart';

/// The product's only card.
///
/// A card means "this is one real thing the user recognises" — a trip, a
/// request, an order, a place, a person. That is the whole test: a group of
/// three form fields is not an object, so it gets spacing and a heading
/// instead. **Cards are never nested inside cards.**
///
/// The default card is defined by its *surface*, not by a border: white on the
/// warm page plus the barely-there resting shadow. A ring of grey around every
/// object is what makes a feed read as a data table.
enum AppCardVariant {
  /// The default. White surface, whisper of a shadow, no border.
  plain,

  /// A plain card that is itself the tap target.
  interactive,

  /// Tinted, no border — a grouped block inside a card-free page.
  soft,

  /// Hairline border, for a card that sits on a white surface where the shadow
  /// alone would not separate it.
  outlined,

  /// Genuinely floats: sheets, popovers.
  elevated,

  /// Brand-tinted. At most one per screen, for the current task.
  accent,
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.plain,
    this.padding = AppSpace.x5,
    this.onTap,
    this.selected = false,
    this.margin,
  });

  final Widget child;
  final AppCardVariant variant;

  /// 20px is the standard content padding; 16 is for dense rows and 24 for a
  /// card that is the main event on its screen.
  final double padding;

  final VoidCallback? onTap;

  /// Marks a card as chosen — a brand ring rather than a border, so selecting
  /// one cannot shift the layout by a pixel.
  final bool selected;

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final resolved = onTap != null && variant == AppCardVariant.plain
        ? AppCardVariant.interactive
        : variant;

    final decorated = AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.ease,
      margin: margin,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _background(resolved),
        borderRadius: AppRadius.brLg,
        boxShadow: _shadow(resolved),
        border: selected
            ? Border.all(color: AppColors.primary, width: 2)
            : _border(resolved),
      ),
      child: child,
    );

    if (onTap == null) return decorated;
    return Pressable(onTap: onTap, child: decorated);
  }
}

Color _background(AppCardVariant variant) {
  switch (variant) {
    case AppCardVariant.soft:
      return AppColors.surfaceMuted;
    case AppCardVariant.accent:
      return AppColors.primarySoft;
    case AppCardVariant.plain:
    case AppCardVariant.interactive:
    case AppCardVariant.outlined:
    case AppCardVariant.elevated:
      return AppColors.surface;
  }
}

List<BoxShadow>? _shadow(AppCardVariant variant) {
  switch (variant) {
    case AppCardVariant.plain:
    case AppCardVariant.interactive:
      return AppShadow.xs;
    case AppCardVariant.elevated:
      return AppShadow.sm;
    case AppCardVariant.soft:
    case AppCardVariant.outlined:
    case AppCardVariant.accent:
      return null;
  }
}

Border? _border(AppCardVariant variant) {
  return variant == AppCardVariant.outlined
      ? Border.all(color: AppColors.border)
      : null;
}

/// The *edge* a card wears when it rests on the page rather than on white.
///
/// A 2% step between `surface` and `background` plus a 6% shadow does not say
/// where a card ends and the paper begins — a feed of them reads as one
/// continuous field. So the marketplace card gets a warm hairline (a cool grey
/// ring on warm paper reads as a seam, not as an edge) and a step up in
/// elevation, so it is lifted off the paper as well as outlined from it.
///
/// Still one of the three product elevations: a fourth shadow invented for one
/// card is how a modal ends up floating less than the thing behind it.
class AppFeedCard extends StatelessWidget {
  const AppFeedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpace.x5,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.brLg,
        border: Border.all(color: AppColors.borderWarm),
        boxShadow: AppShadow.sm,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, child: card);
  }
}
