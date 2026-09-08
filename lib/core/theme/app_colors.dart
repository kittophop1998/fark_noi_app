import 'package:flutter/material.dart';

import 'app_palette.dart';

/// LAYER 2 — the roles. *Why* a colour is used.
///
/// This is the layer screens and widgets consume. It mirrors the role block of
/// `frontend/src/app/globals.css` name for name, so "what colour is a filled
/// action" has one answer across the web app and this one.
///
/// The rule from `DESIGN_SYSTEM.md` §14 holds here: no raw hex in a widget, and
/// no [AppPalette] step outside this file.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────
  //
  // Three roles over one coral ramp, and mixing them up is the palette mistake
  // that ships an illegible screen:
  //
  //   brand           a *shape*: the logo plate, a map pin, an icon on a tint.
  //                   2.91:1 under white — never a label.
  //   primary         every filled action. 3.55:1 under white, which is what a
  //                   button label needs and 500 cannot give.
  //   primaryInk      coral *text* on a white or near-white surface (5.0:1).
  //   primaryInkStrong  coral text on a coral tint — a secondary button's
  //                   label, a selected chip (5.65:1 on [primarySoft]).
  static const Color brand = AppPalette.primary500;
  static const Color primary = AppPalette.primary600;
  static const Color primaryHover = AppPalette.primary700;
  static const Color primaryActive = AppPalette.primary800;
  static const Color primaryInk = AppPalette.primary700;
  static const Color primaryInkStrong = AppPalette.primary800;
  static const Color primarySoft = AppPalette.primary100;
  static const Color primarySubtle = AppPalette.primary50;
  static const Color primarySoftStrong = AppPalette.primary200;
  static const Color primaryBorder = AppPalette.primary200;
  static const Color onPrimary = AppPalette.neutral0;

  /// The journey accent — a destination reached, an arrival, a verified thing.
  /// Points at the same green as [success] on purpose.
  static const Color secondary = AppPalette.green600;
  static const Color secondaryHover = AppPalette.green700;
  static const Color secondaryInk = AppPalette.green800;
  static const Color secondarySoft = AppPalette.green50;
  static const Color secondaryBorder = AppPalette.green200;

  // ── Status families ───────────────────────────────────────────────────
  //
  // Every status in the product resolves to one of four families, and each
  // family has the same jobs:
  //
  //   x            the colour itself — an icon, a dot, a bar
  //   xSoft        the tinted ground a badge or a notice sits on
  //   xStrong      text on that ground
  //   xBorder      a hairline around it
  //   xFill        a *filled* control's background, where a white label has to
  //                clear 4.5:1 — which `x` alone does not always do
  //   xForeground  the ink on `xFill`
  //
  // Nothing here is fully saturated: a status is information, not an alarm.
  static const Color success = AppPalette.green600;
  static const Color successSoft = AppPalette.green50;
  static const Color successStrong = AppPalette.green800;
  static const Color successBorder = AppPalette.green200;
  static const Color successFill = AppPalette.green700;
  static const Color successForeground = AppPalette.neutral0;

  static const Color warning = AppPalette.amber600;
  static const Color warningSoft = AppPalette.amber50;
  static const Color warningStrong = AppPalette.amber800;
  static const Color warningBorder = AppPalette.amber200;
  static const Color warningFill = AppPalette.amber700;
  static const Color warningForeground = AppPalette.neutral0;

  static const Color error = AppPalette.red600;
  static const Color errorSoft = AppPalette.red50;
  static const Color errorStrong = AppPalette.red800;
  static const Color errorBorder = AppPalette.red200;
  static const Color errorFill = AppPalette.red600;
  static const Color errorForeground = AppPalette.neutral0;

  /// `danger` is the same family under the name a button variant uses. One set
  /// of values, two vocabularies — a destructive *action* is a danger, the
  /// state it leaves behind is an error.
  static const Color danger = error;
  static const Color dangerSoft = errorSoft;
  static const Color dangerStrong = errorStrong;
  static const Color dangerBorder = errorBorder;
  static const Color dangerFill = errorFill;
  static const Color dangerForeground = errorForeground;

  static const Color info = AppPalette.blue600;
  static const Color infoSoft = AppPalette.blue50;
  static const Color infoStrong = AppPalette.blue800;
  static const Color infoBorder = AppPalette.blue200;
  static const Color infoFill = AppPalette.blue700;
  static const Color infoForeground = AppPalette.neutral0;

  /// The star on a rating. Its own role rather than [warning], because the two
  /// mean opposite things: warning is "something needs your attention", and a
  /// five-star review needs nothing at all.
  static const Color rating = AppPalette.amber400;
  static const Color ratingEmpty = AppPalette.neutral200;

  // ── The route ─────────────────────────────────────────────────────────
  //
  // FarkNoi's one recurring picture: a line between two places with something
  // happening on it. Naming the ends as roles is what stops a trip card, a
  // create-trip form and an order timeline from each inventing their own
  // colour for "where this is going".
  static const Color routeOrigin = success;
  static const Color routeDestination = brand;
  static const Color routeCurrent = info;
  static const Color routeStop = warning;
  static const Color routeLine = borderStrong;

  /// The connector on a surface whose *subject* is the journey — the trip card.
  /// `primary-200` and not [primary]: the connector must never out-weigh the
  /// mark it arrives at.
  static const Color routeLineStrong = AppPalette.primary200;

  // ── Page header grounds ───────────────────────────────────────────────
  //
  // The band at the top of every screen. `headerBrand` is `primary.700` rather
  // than the brand coral because white on `primary.500` is 2.9:1 — a headline
  // at best and never a sentence.
  static const Color headerBrand = AppPalette.primary700;
  static const Color headerNeutral = surface;
  static const Color headerOnBrand = AppPalette.neutral0;
  static const Color headerOnBrandMuted = AppPalette.primary100;
  static const Color headerInk = text;
  static const Color headerInkMuted = muted;

  /// The bright coral is spent on the *shapes* inside a header, never on text.
  static const Color headerAccent = brand;

  // ── Surfaces ──────────────────────────────────────────────────────────
  //
  // A warm off-white page, white objects on it, and a grey tint for a recess
  // inside one. Not every block is a card — most grouping is whitespace and a
  // heading.
  //
  // The page is warmed once, here, so the paper is warm and the chroma stays
  // on the actions.
  static const Color background = Color(0xFFFFFAF8);
  static const Color backgroundSubtle = AppPalette.neutral50;
  static const Color surface = AppPalette.neutral0;
  static const Color surfaceRaised = AppPalette.neutral0;
  static const Color surfaceMuted = AppPalette.neutral50;
  static const Color surfaceStrong = AppPalette.neutral100;
  static const Color surfaceDisabled = AppPalette.neutral100;

  /// The one *filled* coral ground in the product: a status hero, where the
  /// state of an errand is drawn on colour so it cannot be scrolled past.
  /// One per screen, and only where the colour is the message.
  static const Color surfaceBrand = AppPalette.primary700;
  static const Color onSurfaceBrand = AppPalette.neutral0;
  static const Color onSurfaceBrandMuted = AppPalette.primary50;

  // ── Ink ───────────────────────────────────────────────────────────────
  //
  // Nothing in the product is pure black.
  //
  //   text      headings and body          16.5:1
  //   muted     supporting copy             7.3:1
  //   faint     metadata, timestamps        4.7:1
  //   disabled  an unavailable control's label
  //   inverse   on a filled dark or coloured ground
  static const Color text = AppPalette.neutral900;
  static const Color textStrong = AppPalette.neutral950;
  static const Color muted = AppPalette.neutral700;
  static const Color faint = AppPalette.neutral600;
  static const Color placeholder = AppPalette.neutral600;
  static const Color disabled = AppPalette.neutral400;
  static const Color inverse = AppPalette.neutral0;

  // ── Borders ───────────────────────────────────────────────────────────
  //
  // Default is a 1px hairline. Heavy outlines are the fastest way to make a
  // light product look like a form from 2009, so [borderStrong] is for a
  // control's hover, never for a resting card.
  static const Color border = AppPalette.neutral200;
  static const Color borderSubtle = AppPalette.neutral100;
  static const Color borderStrong = AppPalette.neutral300;

  /// The hairline on an object resting on the *page* rather than on white.
  /// A cool grey ring around a white card floating on `#fffaf8` reads as a
  /// seam drawn over the paper; this is the same hairline warmed to the page's
  /// hue, so the edge reads as where the card stops.
  static const Color borderWarm = Color(0xFFEEE4DF);
  static const Color borderPrimary = AppPalette.primary200;
  static const Color divider = AppPalette.neutral100;

  static const Color focus = AppPalette.primary600;
  static const Color scrim = Color(0x7A0B0D0F); // rgba(11, 13, 15, 0.48)

  // ── Navigation ────────────────────────────────────────────────────────
  //
  // "Which tab am I on" is a question the navigation answers about itself, so
  // it gets its own inks rather than borrowing the body's.
  static const Color navActive = primaryInk;
  static const Color navInactive = faint;
}
