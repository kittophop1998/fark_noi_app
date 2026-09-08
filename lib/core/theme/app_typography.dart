import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The semantic type styles.
///
/// A screen asks for [AppText.title], not for "18px semibold" — so the day the
/// title step moves, every title in the product moves with it. The ladder is
/// the web app's `theme/typography.ts`, rung for rung:
///
///   display     32/700   the one line on a screen that is a statement
///   heading1    28/700   a root screen's title
///   heading2    24/700   a section heading, and a pushed screen's title
///   heading3    20/600   a card title
///   title       18/600   a row title, a field group's name
///   body        16/400   the reading size, and the floor for Thai
///   bodySmall   14/400   supporting copy under a title
///   label       14/600   a form label, a column heading
///   caption     13/400   metadata — a timestamp, a distance
///   overline    12/600   a small marker above a heading
///   price       18/700   a figure in a row
///   priceLarge  24/700   the figure a screen is about — a balance, a total
///
/// **Colour is not baked in**, deliberately: the same step is [AppColors.text]
/// in a heading and [AppColors.muted] in a caption. Compose it —
/// `AppText.caption.copyWith(color: AppColors.muted)`.
///
/// **Body is 16px and stays 16px.** Thai has no capitals to anchor a glyph on
/// and its marks sit above and below the line, so it loses legibility a step
/// earlier than Latin. Nothing in the product is under 12px.
class AppText {
  AppText._();

  /// The one family, bundled from `frontend/public/font` so both apps draw Thai
  /// and Latin with the same face.
  static const String fontFamily = 'Anuphan';

  static const TextStyle display = TextStyle(
    fontSize: 32,
    height: 1.25,
    letterSpacing: -0.64,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    height: 1.29,
    letterSpacing: -0.42,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    height: 1.33,
    letterSpacing: -0.24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    height: 1.4,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    height: 1.45,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.42,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 12,
    height: 1.35,
    letterSpacing: 0.48,
    fontWeight: FontWeight.w600,
  );

  /// Money always goes through [price] / [priceLarge], which carry tabular
  /// figures. A total that re-renders with proportional digits jitters
  /// sideways, and a column of rewards fails to align.
  static const TextStyle price = TextStyle(
    fontSize: 18,
    height: 1.45,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    height: 1.33,
    letterSpacing: -0.24,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
