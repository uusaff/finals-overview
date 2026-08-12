import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NothingTheme {
  // Shared
  static const Color accent = Color(0xFFE51D2A);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF151515);
  static const Color darkBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  static const Color darkTextPrimary = Color(0xFFF0F0F0);
  static const Color darkTextMuted = Color(0xFF888888);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0x1A000000); // rgba(0,0,0,0.1)
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextMuted = Color(0xFF777777);

  // Theme Data Builder
  static ThemeData getTheme({
    required bool isDark,
    Color accent = NothingTheme.accent,
    Color? customBackground,
  }) {
    final background = customBackground ?? (isDark ? darkBackground : lightBackground);
    final surface = isDark ? darkSurface : lightSurface;
    final textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    final textMuted = isDark ? darkTextMuted : lightTextMuted;
    final border = isDark ? darkBorder : lightBorder;

    final baseTextTheme = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: isDark 
          ? ColorScheme.dark(primary: accent, surface: surface, onPrimary: accent.computeLuminance() > 0.5 ? Colors.black : Colors.white, onSurface: textPrimary)
          : ColorScheme.light(primary: accent, surface: surface, onPrimary: accent.computeLuminance() > 0.5 ? Colors.black : Colors.white, onSurface: textPrimary),
      textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
        bodyLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w400),
        titleLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        labelLarge: GoogleFonts.inter(color: isDark ? Colors.white : Colors.white, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: accent, width: 1),
        ),
        labelStyle: GoogleFonts.inter(color: textMuted),
        hintStyle: GoogleFonts.inter(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: accent.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 20),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: accent.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(color: accent, fontWeight: FontWeight.w700, fontSize: 12);
          }
          return GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accent);
          }
          return IconThemeData(color: textPrimary);
        }),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      dialogBackgroundColor: surface,
    );
  }

  static TextStyle metricsStyle(bool isDark) => GoogleFonts.shareTechMono(
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );
}
