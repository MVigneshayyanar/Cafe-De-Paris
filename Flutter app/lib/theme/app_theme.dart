import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cafe De Paris Design System
class AppColors {
  static const Color primaryTeal = Color(0xFF1E5F74);
  static const Color goldAccent = Color(0xFFC9A84C);
  static const Color background = Color(0xFFFBF9F6);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color successGreen = Color(0xFF2D6A4F);
  static const Color warningOrange = Color(0xFFB07D05);
  static const Color errorRed = Color(0xFF9E2A2B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFF1F5F9);

  // Status Badge Colors (More refined)
  static const Color availableBg = Color(0xFFF5F3FF);
  static const Color availableText = Color(0xFF5B21B6);
  static const Color orderingBg = Color(0xFFEFF6FF);
  static const Color orderingText = Color(0xFF1E40AF);
  static const Color preparingBg = Color(0xFFFFFBEB);
  static const Color preparingText = Color(0xFF92400E);
  static const Color readyBg = Color(0xFFECFDF5);
  static const Color readyText = Color(0xFF065F46);
  static const Color billingBg = Color(0xFFFDF2F8);
  static const Color billingText = Color(0xFF9D174D);
  static const Color eatingBg = Color(0xFFF0F9FF);
  static const Color eatingText = Color(0xFF0369A1);
  static const Color billedBg = Color(0xFFF0FDF4);
  static const Color billedText = Color(0xFF166534);
}

class AppTheme {
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double badgeRadius = 999.0;

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        primary: AppColors.primaryTeal,
        surface: AppColors.cardSurface,
        error: AppColors.errorRed,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        displayMedium: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        displaySmall: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        bodyLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardSurface,
        selectedItemColor: AppColors.primaryTeal,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
