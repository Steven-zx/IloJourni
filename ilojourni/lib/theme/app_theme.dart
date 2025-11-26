import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color navy = Color(0xFF0B2239);
  static const Color teal = Color(0xFF5AB8A9);
  static const Color grey = Color(0xFFBDBDBD);
  static const Color lightGrey = Color(0xFFE9E9E9);
  
  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  static const Color darkTeal = Color(0xFF4A9B8E);
  static const Color darkAccent = Color(0xFF6DD4C4);

  static ThemeData light() {
    final base = ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: navy));
    final josefin = GoogleFonts.josefinSans(fontWeight: FontWeight.w400);
    final textTheme = GoogleFonts.josefinSansTextTheme(base.textTheme).copyWith(
      headlineMedium: josefin.copyWith(fontSize: 28, color: Colors.black),
      titleLarge: josefin.copyWith(fontSize: 20, color: Colors.black),
      bodyMedium: josefin.copyWith(fontSize: 14, color: Colors.black87),
      labelLarge: josefin.copyWith(fontSize: 16, color: Colors.white),
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme,
      primaryColor: navy,
      colorScheme: base.colorScheme.copyWith(
        secondary: teal,
        primary: navy,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 3,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          side: const BorderSide(color: navy, width: 1.5),
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.josefinSans(color: Colors.black45, fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFCDCDCD), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: navy, width: 1.6),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark();
    final josefin = GoogleFonts.josefinSans(fontWeight: FontWeight.w400);
    final textTheme = GoogleFonts.josefinSansTextTheme(base.textTheme).copyWith(
      headlineMedium: josefin.copyWith(fontSize: 28, color: Colors.white),
      titleLarge: josefin.copyWith(fontSize: 20, color: Colors.white),
      bodyMedium: josefin.copyWith(fontSize: 14, color: Colors.white70),
      labelLarge: josefin.copyWith(fontSize: 16, color: Colors.white),
    );

    return base.copyWith(
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,
      primaryColor: darkTeal,
      colorScheme: ColorScheme.dark(
        primary: darkTeal,
        secondary: darkAccent,
        surface: darkSurface,
        background: darkBackground,
        error: const Color(0xFFCF6679),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.black,
        brightness: Brightness.dark,
      ),
      cardColor: darkCard,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkAccent,
          side: const BorderSide(color: darkAccent, width: 1.5),
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        hintStyle: GoogleFonts.josefinSans(color: Colors.white38, fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFF3A3A3A), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: darkAccent, width: 1.6),
        ),
      ),
      dividerColor: const Color(0xFF3A3A3A),
      iconTheme: const IconThemeData(color: Colors.white70),
    );
  }
}
