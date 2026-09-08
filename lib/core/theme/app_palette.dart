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
  // Which step each *role* takes is a contrast decision, not a taste one:
  // white on 500 is 2.91:1, so 500 stays the *mark* (a shape, never a word),
  // the filled action takes 600, coral text on white takes 700, and coral text
  // on a coral tint takes 800.
  static const Color primary50 = Color(0xFFFFF5F2);
  static const Color primary100 = Color(0xFFFFE8E1);
  static const Color primary200 = Color(0xFFFFD0C4);
  static const Color primary300 = Color(0xFFFFAD98);
  static const Color primary400 = Color(0xFFFF8065);
  static const Color primary500 = Color(0xFFFF6548);
  static const Color primary600 = Color(0xFFF24E32);
  static const Color primary700 = Color(0xFFCC3B24);
  static const Color primary800 = Color(0xFFA93221);
  static const Color primary900 = Color(0xFF8B2E22);

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
  static const Color neutral600 = Color(0xFF6B7280);
  static const Color neutral700 = Color(0xFF4B5563);
  static const Color neutral800 = Color(0xFF2F3437);
  static const Color neutral900 = Color(0xFF191C1F);
  static const Color neutral950 = Color(0xFF0B0D0F);

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
