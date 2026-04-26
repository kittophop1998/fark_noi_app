import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _fontFamily = null; // TODO: เปลี่มเป็น 'AppFont' เมื่อเพิ่มไฟล์ font แล้ว

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: _fontFamily,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          // ── Primary (10%) ──
          primary: const Color(AppColors.primary),
          onPrimary: Colors.white,
          primaryContainer: AppColors.primaryLight,
          onPrimaryContainer: const Color(AppColors.primary),
          // ── Secondary — reuse primary family ──
          secondary: const Color(AppColors.primary),
          onSecondary: Colors.white,
          secondaryContainer: AppColors.primaryLight,
          onSecondaryContainer: const Color(AppColors.primary),
          // ── Neutral (60%) ──
          surface: AppColors.surface,
          onSurface: const Color(AppColors.textPrimary),
          surfaceContainerHighest: AppColors.bgPage,
          onSurfaceVariant: const Color(AppColors.textSecondary),
          // ── Error ──
          error: AppColors.error,
          onError: Colors.white,
          // ── Outline ──
          outline: AppColors.border,
          outlineVariant: AppColors.border,
        ),
        scaffoldBackgroundColor: AppColors.bgPage,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.bgPage,
          foregroundColor: Color(AppColors.textPrimary),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.textPrimary),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppColors.primary),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(AppColors.primary),
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.primaryLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Color(AppColors.primary)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(AppColors.primary),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.error),
          ),
          hintStyle: TextStyle(color: AppColors.textDisabled),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.primaryLight,
          selectedColor: const Color(AppColors.primary),
          labelStyle: const TextStyle(
            color: Color(AppColors.primary),
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        iconTheme: const IconThemeData(
          color: Color(AppColors.textSecondary),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        fontFamily: _fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppColors.primary),
          brightness: Brightness.dark,
        ),
      );
}
