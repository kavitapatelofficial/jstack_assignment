import 'package:flutter/material.dart';

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF0A0F1D); // Obsidian Slate
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color accent = Color(0xFF2563EB); // Royal Blue
  static const Color accentLight = Color(0xFF38BDF8); // Cyan Glow
  static const Color brandPurple = Color(0xFF6366F1); // Indigo Violet
  static const Color brandOrange = Color(0xFFF97316);

  // Success / Credit
  static const Color creditGreen = Color(0xFF10B981); // Emerald
  static const Color creditGreenBg = Color(0xFFECFDF5);
  static const Color creditGreenBgDark = Color(0xFF064E3B);

  // Debit / Alert
  static const Color debitRed = Color(0xFFEF4444); // Crimson
  static const Color debitRedBg = Color(0xFFFEF2F2);
  static const Color debitRedBgDark = Color(0xFF7F1D1D);

  // Category Colors
  static const Color catFood = Color(0xFFF97316);
  static const Color catShopping = Color(0xFFA855F7);
  static const Color catBills = Color(0xFF06B6D4);
  static const Color catTravel = Color(0xFF3B82F6);
  static const Color catSalary = Color(0xFF10B981);
  static const Color catReward = Color(0xFFF59E0B);

  // Neutral Colors (Light) - High Contrast & Sharp Visibility
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF0F172A); // Pitch obsidian black
  static const Color textSecondaryLight = Color(0xFF1E293B); // Deep slate 800 - crisp, visible, no blur
  static const Color textMutedLight = Color(0xFF334155); // Slate 700 - clear high contrast
  static const Color borderLight = Color(0xFFCBD5E1); // Crisp Slate 300

  // Neutral Colors (Dark) - High Contrast & Sharp Visibility
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color surfaceDark = Color(0xFF111726);
  static const Color cardDark = Color(0xFF161F33);
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // Pure crisp white
  static const Color textSecondaryDark = Color(0xFFF1F5F9); // Bright slate 100
  static const Color textMutedDark = Color(0xFFCBD5E1); // Clear slate 300
  static const Color borderDark = Color(0xFF334155);

  // Luxury Gradients
  static const LinearGradient walletCardGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumCardGradient = LinearGradient(
    colors: [Color(0xFF0A0F1D), Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldCardGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleCardGradient = LinearGradient(
    colors: [Color(0xFF311042), Color(0xFF581C87), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentButtonGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldChipGradient = LinearGradient(
    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B), Color(0xFFB45309)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassOverlay = LinearGradient(
    colors: [Color(0x28FFFFFF), Color(0x06FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient meshGlow = LinearGradient(
    colors: [Color(0x1A2563EB), Color(0x002563EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
