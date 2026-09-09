import 'package:flutter/material.dart';

/// LAYER 1 — the ramps.
///
/// A tint is decided once, here, and nowhere else. This file is the Dart half
/// of `frontend/src/app/globals.css`'s ramp block: the same hex values, in the
/// same order, so a re-tint on the web is a mechanical change here.
///
/// **Nothing outside [AppColors] may name a ramp step.** A widget reaching for
/// [AppPalette.primary500] means a semantic role was needed and got inlined
/// instead of named — see `frontend/DESIGN_SYSTEM.md` §2.
class AppPalette {
  AppPalette._();

  // ── FarkNoi coral — the brand ramp ────────────────────────────────────
  //
  // The ramp is anchored at 600 = #F2553D, the approved Coral. Every other step
  // is that hue (~8°) walked up and down in lightness, so the family reads as
  // one colour rather than a set.
  //
  // Which step each *role* takes is a contrast decision, not a taste one:
  // white on 500 is 2.8:1, so 500 stays the *mark* (a shape, never a word),
  // the filled action takes 600, coral text on white takes 700, and coral text
  // on a coral tint takes 800.
  static const Color primary50 = Color(0xFFFFF5F2);
  static const Color primary100 = Color(0xFFFFE5E0);
  static const Color primary200 = Color(0xFFFFCBC2);
  static const Color primary300 = Color(0xFFFFA899);
  static const Color primary400 = Color(0xFFFC7F69);
  static const Color primary500 = Color(0xFFF66B55);
  static const Color primary600 = Color(0xFFF2553D);
  static const Color primary700 = Color(0xFFC53620);
  static const Color primary800 = Color(0xFF9F2F1E);
  static const Color primary900 = Color(0xFF7C2A1D);

  // ── Neutrals ──────────────────────────────────────────────────────────
  //
  // Very slightly cool, which is the right partner for a warm brand: a warm
  // neutral beside coral makes the whole screen read as one orange wash. The
  // *page* is warmed instead, once, by `AppColors.background`.
  //
  // 0 and 25 are surfaces. 400 and below never carry text.
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral25 = Color(0xFFFCFCFC);
  static const Color neutral50 = Color(0xFFF8F9FA);
  static const Color neutral100 = Color(0xFFF1F3F5);
  static const Color neutral200 = Color(0xFFE9ECEF);
  static const Color neutral300 = Color(0xFFDEE2E6);
  static const Color neutral400 = Color(0xFFADB5BD);
  static const Color neutral500 = Color(0xFF868E96);
  static const Color neutral600 = Color(0xFF68707C);
  static const Color neutral700 = Color(0xFF4B5563);
  static const Color neutral800 = Color(0xFF363C45);
  static const Color neutral900 = Color(0xFF252A31);
  static const Color neutral950 = Color(0xFF14181D);

  // ── Deep teal — trust ─────────────────────────────────────────────────
  //
  // The second accent, and deliberately *not* a second call to action. Teal is
  // what the product says about itself rather than what it asks you to do:
  // an identity confirmed, a payment handle, a community signal. Anchored at
  // 600 = #176B63, with 50 = #E4F2EF, the mint a teal panel sits on.
  //
  // It earns the job coral cannot do: #176B63 is 6.3:1 on white *and* 5.5:1 on
  // its own mint, so the same colour can be the icon and the sentence.
  static const Color teal50 = Color(0xFFE4F2EF);
  static const Color teal100 = Color(0xFFCEE9E5);
  static const Color teal200 = Color(0xFFACD8D2);
  static const Color teal300 = Color(0xFF81C1B8);
  static const Color teal400 = Color(0xFF46A499);
  static const Color teal500 = Color(0xFF2A847B);
  static const Color teal600 = Color(0xFF176B63);
  static const Color teal700 = Color(0xFF125952);
  static const Color teal800 = Color(0xFF0E4944);
  static const Color teal900 = Color(0xFF0A3835);

  // ── Green — success, arrival, and the journey accent ───────────────────
  static const Color green50 = Color(0xFFECFDF5);
  static const Color green100 = Color(0xFFD1FAE5);
  static const Color green200 = Color(0xFFA7F3D0);
  static const Color green500 = Color(0xFF10B981);
  static const Color green600 = Color(0xFF059669);
  static const Color green700 = Color(0xFF047857);
  static const Color green800 = Color(0xFF065F46);

  // ── Amber — warning, and the rating star ──────────────────────────────
  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber800 = Color(0xFF92400E);

  // ── Blue — information, and the device's own position on a map ────────
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue800 = Color(0xFF1E40AF);

  // ── Red — destructive and error, and nothing else ─────────────────────
  //
  // Never a "hot" price, never an emphasis: in a product that moves money, red
  // has one meaning.
  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red800 = Color(0xFF991B1B);
}
