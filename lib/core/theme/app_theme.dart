import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_shape.dart';
import 'app_typography.dart';

/// The Material theme, assembled from the token layer.
///
/// Nothing here decides a value: every colour comes from [AppColors], every
/// radius from [AppRadius] and every size from [AppText] / [AppMetrics]. The
/// theme's job is to make the *defaults* of Material land on the design
/// system's values, so a plain `Text` or `TextField` is already right and a
/// widget only reaches for a token when it wants something specific.
///
/// **There is no dark mode**, and that is a decision rather than an omission —
/// the token layer is structured for one (roles, not values), but nothing
/// declares a dark palette, and half a dark mode is worse than none.
class AppTheme {
  AppTheme._();

  /// The status bar over a coral header: white glyphs on `primary.700`.
  static const SystemUiOverlayStyle brandOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  /// The status bar over a neutral header or a plain page.
  static const SystemUiOverlayStyle neutralOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme(
      brightness: Brightness.light,
      // The filled action's step, not the brand mark's: a white label on
      // `primary.500` is 2.91:1.
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryInkStrong,
      secondary: AppColors.secondary,
      onSecondary: AppColors.inverse,
      secondaryContainer: AppColors.secondarySoft,
      onSecondaryContainer: AppColors.secondaryInk,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.backgroundSubtle,
      surfaceContainer: AppColors.surfaceMuted,
      surfaceContainerHigh: AppColors.surfaceStrong,
      surfaceContainerHighest: AppColors.surfaceStrong,
      onSurfaceVariant: AppColors.muted,
      error: AppColors.error,
      onError: AppColors.errorForeground,
      errorContainer: AppColors.errorSoft,
      onErrorContainer: AppColors.errorStrong,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
      scrim: AppColors.scrim,
      shadow: AppColors.text,
      inverseSurface: AppColors.textStrong,
      onInverseSurface: AppColors.inverse,
      inversePrimary: AppColors.primarySoft,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppText.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,

      textTheme: _textTheme,

      // The band at the top of a route is drawn by `AppPageHeader`, not by an
      // `AppBar` — this only styles the few places Material puts one up on its
      // own (a dialog's full-screen page, a picker).
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: neutralOverlay,
        titleTextStyle: TextStyle(
          fontFamily: AppText.fontFamily,
          fontSize: 18,
          height: 1.45,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),

      // `AppButton` is the product's button and carries the six variants; these
      // defaults exist so a stray Material button is not visibly foreign.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.45),
          disabledForegroundColor: AppColors.onPrimary.withOpacity(0.45),
          minimumSize: const Size(0, AppMetrics.controlMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: AppText.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.surfaceMuted,
          minimumSize: const Size(0, AppMetrics.controlMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
          side: BorderSide.none,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: AppText.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryInk,
          minimumSize: const Size(0, AppMetrics.controlMd),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
          textStyle: AppText.label,
        ),
      ),

      // 52px, 12px radius, a hairline that thickens to the focus coral. Error
      // is never a red border alone — the message under the field is the
      // signal, and `AppTextField` draws it.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppText.body.copyWith(color: AppColors.placeholder),
        labelStyle: AppText.label.copyWith(color: AppColors.muted),
        floatingLabelStyle: AppText.label.copyWith(color: AppColors.primaryInk),
        errorStyle: AppText.caption.copyWith(color: AppColors.errorStrong),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x4,
          vertical: AppSpace.x3,
        ),
        border: _fieldBorder(AppColors.border),
        enabledBorder: _fieldBorder(AppColors.border),
        focusedBorder: _fieldBorder(AppColors.focus, width: 2),
        errorBorder: _fieldBorder(AppColors.errorBorder),
        focusedErrorBorder: _fieldBorder(AppColors.error, width: 2),
        disabledBorder: _fieldBorder(AppColors.borderSubtle),
      ),

      cardTheme: const CardTheme(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primarySoft,
        side: const BorderSide(color: AppColors.border),
        labelStyle: AppText.label.copyWith(color: AppColors.muted),
        secondaryLabelStyle:
            AppText.label.copyWith(color: AppColors.primaryInkStrong),
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brPill),
        showCheckmark: false,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.muted,
        size: AppMetrics.icon,
      ),

      dialogTheme: const DialogTheme(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brXl2),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brSheet),
        showDragHandle: true,
        dragHandleColor: AppColors.borderStrong,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textStrong,
        contentTextStyle: AppText.bodySmall.copyWith(color: AppColors.inverse),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.brMd),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceStrong,
        circularTrackColor: Colors.transparent,
      ),

      // Motion is a token too: 200ms is the product's default, and the same
      // curve the web uses for a page transition.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.brMd,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Material's text roles, pointed at the product's ladder — so a widget that
  /// asks the theme for `titleMedium` gets the same 18/600 an [AppText.title]
  /// would have given it.
  static final TextTheme _textTheme = TextTheme(
    displayLarge: AppText.display.copyWith(color: AppColors.textStrong),
    displayMedium: AppText.heading1.copyWith(color: AppColors.textStrong),
    displaySmall: AppText.heading2.copyWith(color: AppColors.text),
    headlineLarge: AppText.heading1.copyWith(color: AppColors.text),
    headlineMedium: AppText.heading2.copyWith(color: AppColors.text),
    headlineSmall: AppText.heading3.copyWith(color: AppColors.text),
    titleLarge: AppText.heading3.copyWith(color: AppColors.text),
    titleMedium: AppText.title.copyWith(color: AppColors.text),
    titleSmall: AppText.label.copyWith(color: AppColors.text),
    bodyLarge: AppText.body.copyWith(color: AppColors.text),
    bodyMedium: AppText.bodySmall.copyWith(color: AppColors.muted),
    bodySmall: AppText.caption.copyWith(color: AppColors.faint),
    labelLarge: AppText.label.copyWith(color: AppColors.text),
    labelMedium: AppText.caption.copyWith(color: AppColors.muted),
    labelSmall: AppText.overline.copyWith(color: AppColors.faint),
  );
}
