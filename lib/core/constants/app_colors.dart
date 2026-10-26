import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color accent = Color(0xFF2563EB); // Royal Blue
  static const Color accentLight = Color(0xFF3B82F6);
  static const Color brandOrange = Color(0xFFEA580C);

  // Success / Credit
  static const Color creditGreen = Color(0xFF16A34A);
  static const Color creditGreenBg = Color(0xFFDCFCE7);
  static const Color creditGreenBgDark = Color(0xFF14532D);

  // Debit / Alert
  static const Color debitRed = Color(0xFFDC2626);
  static const Color debitRedBg = Color(0xFFFEE2E2);
  static const Color debitRedBgDark = Color(0xFF7F1D1D);

  // Neutral Colors (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral Colors (Dark)
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131B2E);
  static const Color cardDark = Color(0xFF1A233A);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);
  static const Color borderDark = Color(0xFF24324D);

  // Gradients
  static const LinearGradient walletCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
