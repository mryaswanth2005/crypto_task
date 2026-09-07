import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Colors ────────────────────────────────────────────────
  static const Color scaffoldBg = Color(0xFF0D1117);
  static const Color cardBg = Color(0xFF161B22);
  static const Color surfaceBg = Color(0xFF1C2333);
  static const Color borderColor = Color(0xFF30363D);
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  static const Color accentCyan = Color(0xFF00D2FF);
  static const Color accentPurple = Color(0xFF7B61FF);
  static const Color gainGreen = Color(0xFF00E676);
  static const Color lossRed = Color(0xFFFF5252);
  static const Color shimmerBase = Color(0xFF21262D);
  static const Color shimmerHighlight = Color(0xFF30363D);

  static LinearGradient get accentGradient => const LinearGradient(
        colors: [accentCyan, accentPurple],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cardGradient => LinearGradient(
        colors: [
          cardBg.withOpacity(0.8),
          surfaceBg.withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ─── Theme Data ────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: const ColorScheme.dark(
        surface: scaffoldBg,
        primary: accentCyan,
        secondary: accentPurple,
        error: lossRed,
        onSurface: textPrimary,
        onPrimary: scaffoldBg,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: accentCyan,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceBg,
        selectedColor: accentCyan.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 0.5,
      ),
    );
  }
}
