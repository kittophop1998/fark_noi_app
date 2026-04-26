import 'package:flutter/material.dart';

// App Colors — Minimal Palette (60-30-10 rule)
//   60% → bgPage / surface / border  — neutral backgrounds & dividers
//   30% → text colors                — hierarchy without extra hues
//   10% → primary + action           — one accent + one urgent signal only
class AppColors {
  AppColors._();

// 60% Neutral
  static const Color bgPage  = Color(0xFFF2F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border  = Color(0xFFE2E8ED);

  // 30% Text
  static const int  textPrimary   = 0xFF102A43; // Dark Blue Grey
  static const int  textSecondary = 0xFF486581; 
  static const Color textDisabled = Color(0xFF9FB3C8);

  // 10% Accent
  static const int   primary      = 0xFF243B53; // Charcoal Blue
  static const Color primaryLight = Color(0xFFD9E2EC); 

  static const Color action      = Color(0xFF009688); // Teal (ดูสะอาดและเด่นพอดีๆ)
  static const Color actionLight = Color(0xFFE0F2F1);

  // Error — Destructive actions, remove / cancel
  static const Color error      = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
}
