import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF080B10);
  static const surface = Color(0xFF0E1117);
  static const card = Color(0xFF131820);
  static const cardBorder = Color(0xFF1E2733);

  static const neon = Color(0xFF00F5A0);
  static const neonDim = Color(0x1A00F5A0);
  static const accent = Color(0xFF00C8FF);
  static const accentDim = Color(0x1500C8FF);
  static const warn = Color(0xFFFF6B35);
  static const warnDim = Color(0x15FF6B35);
  static const purple = Color(0xFFA855F7);
  static const purpleDim = Color(0x15A855F7);
  static const red = Color(0xFFFF3B3B);

  static const textPrimary = Color(0xFFE8EDF2);
  static const textSecondary = Color(0xFF8A9BAB);
  static const textMuted = Color(0xFF5A6A7A);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neon,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.rajdhaniTextTheme(
      ThemeData.dark().textTheme.copyWith(
        bodyLarge: const TextStyle(color: AppColors.textPrimary),
        bodyMedium: const TextStyle(color: AppColors.textSecondary),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.neon,
      unselectedItemColor: AppColors.textMuted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}