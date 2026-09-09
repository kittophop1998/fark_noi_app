import 'package:flutter/material.dart';

/// Corner radius. Radius communicates *grouping*, so the step is chosen by what
/// a thing **is**, rather than by taste — and a screen may not invent one in
/// between.
///
///   xs   6px  a tag, a swatch, a progress bar
///   sm   8px  a small tile, an icon button
///   md  12px  every control — button, input, select, textarea
///   lg  16px  a standard card: a trip, an order, a person
///   xl  20px  a hero card, the wallet, a bottom sheet
///   xl2 24px  a modal, a full-bleed panel
///   pill      chips, badges, avatars, anything round by nature
class AppRadius {
  AppRadius._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double pill = 9999;

  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXl2 = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));

  /// A bottom sheet: rounded at the top only.
  static const BorderRadius brSheet = BorderRadius.vertical(
    top: Radius.circular(xl2),
  );
}

/// A 4px ladder, mirroring the web's `--space-*`.
///
/// The page gutter is [pageX] — 16 on a phone, which is what every screen's
/// horizontal padding should come from rather than a literal.
class AppSpace {
  AppSpace._();

  static const double x1 = 4;
  static const double x2 = 8;
  static const double x3 = 12;
  static const double x4 = 16;
  static const double x5 = 20;
  static const double x6 = 24;
  static const double x8 = 32;
  static const double x10 = 40;
  static const double x12 = 48;
  static const double x16 = 64;

  /// The page gutter.
  static const double pageX = x4;

  /// The air between the header band and the first block under it, and between
  /// two sections — a full-bleed band and the block under it stand in the same
  /// relation two sections do.
  static const double sectionGap = x6;
}

/// Three shadows and a sheet — and nothing else. Most grouping should be
/// carried by spacing and surface colour and reach for none of them.
///
///   xs     a resting card in a feed
///   sm     something raised on purpose: a sticky bar, a floating control
///   md     something genuinely floating: a modal, a popover, a menu
///   sheet  a bottom sheet, whose shadow falls upward
class AppShadow {
  AppShadow._();

  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0F252A31), // rgba(37, 42, 49, 0.06)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F252A31),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A252A31), // rgba(37, 42, 49, 0.04)
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A252A31), // rgba(37, 42, 49, 0.10)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> sheet = [
    BoxShadow(
      color: Color(0x1A252A31),
      blurRadius: 24,
      offset: Offset(0, -8),
    ),
  ];
}

/// Motion is for press feedback, tab changes, sheets and success confirmation
/// — and nowhere else. Never decorative.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 140);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);

  /// The web's `--motion-ease`, `cubic-bezier(0.32, 0.72, 0, 1)`.
  static const Curve ease = Cubic(0.32, 0.72, 0, 1);
}

/// Control heights and the chrome the shell draws, so a screen and the bar
/// floating over it agree on one number.
class AppMetrics {
  AppMetrics._();

  /// The header band, without the device's top inset.
  static const double headerHeight = 56;

  static const double bottomNavHeight = 64;
  static const double navIconSize = 24;

  /// Button rungs. [controlLg] is the committing action's size; [controlMd] is
  /// exactly the 44px touch-target minimum; [controlSm] is the only step under
  /// it, used inline beside text where the row carries the height.
  static const double controlSm = 36;
  static const double controlMd = 44;
  static const double controlLg = 52;

  /// Inputs are one size: 52px, so a form reads as a stack of equal rows.
  static const double fieldHeight = 52;

  /// The floor for anything a thumb aims at.
  static const double touchTarget = 44;

  /// Icons: 16 / 18 / 20 / 24, and 20 is the default for UI. The bottom nav is
  /// the one place that steps up to 24.
  static const double iconXs = 16;
  static const double iconSm = 18;
  static const double icon = 20;
  static const double iconLg = 24;
}
