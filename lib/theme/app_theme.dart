/*import 'package:flutter/material.dart';

final class AppTheme {
  AppTheme._();

  // ─── Light Mode Colors ─────────────────────────────────────────────────────
  static const Color _violet = Color(0xFF6B21A8);
  static const Color _blue = Color(0xFF2563EB);

  // ─── Dark Mode Colors ──────────────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF0D0F1A);
  static const Color _darkMid = Color(0xFF1A1040);
  static const Color _darkAccent = Color(0xFF2D1B69);
  static const Color _darkSurface = Color(0xFF0D0F1A);
  static const Color _darkInput = Color(0xFF1E1B2E);
  static const Color _darkCard = Color(0xFF1A1730);

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static BoxDecoration get gradient => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_violet, Colors.deepPurple.shade700, _blue],
        ),
      );

  static LinearGradient get gradientLinear => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_violet, Colors.deepPurple.shade700, _blue],
      );

  static BoxDecoration gradientFor(BuildContext context) =>
      BoxDecoration(gradient: gradientLinearFor(context));

  static LinearGradient gradientLinearFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [_darkBg, _darkMid, _darkAccent]
          : [_violet, Colors.deepPurple.shade700, _blue],
    );
  }

  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _violet,
          primary: _violet,
          secondary: _blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.95),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: _violet.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _violet, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _violet,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _blue),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      );

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _darkAccent,
          primary: const Color(0xFFB794F4),   // soft purple
          secondary: const Color(0xFF90CDF4), // soft blue
          surface: _darkCard,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _darkBg,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkInput,
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFFB794F4), width: 2),
          ),
          labelStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIconColor: Colors.white60,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D28D9), // deep purple
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB794F4)),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          color: _darkCard,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withValues(alpha: 0.10),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white.withValues(alpha: 0.90),
          iconColor: Colors.white60,
        ),
        switchTheme: SwitchThemeData(
          thumbColor:
              WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFB794F4);
            }
            return Colors.white38;
          }),
          trackColor:
              WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF6D28D9);
            }
            return Colors.white24;
          }),
        ),
      );
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  AppTheme._();

  // ─── Light Mode Colors ─────────────────────────────────────────────────────
  static const Color _violet = Color(0xFF6B21A8);
  static const Color _blue = Color(0xFF2563EB);

  // ─── Dark Mode Colors ──────────────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF0D0F1A);
  static const Color _darkMid = Color(0xFF1A1040);
  static const Color _darkAccent = Color(0xFF2D1B69);
  static const Color _darkInput = Color(0xFF1E1B2E);
  static const Color _darkCard = Color(0xFF1A1730);

  // ─── Gradients ─────────────────────────────────────────────────────────────
  static BoxDecoration get gradient => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_violet, Colors.deepPurple.shade700, _blue],
        ),
      );

  static LinearGradient get gradientLinear => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_violet, Colors.deepPurple.shade700, _blue],
      );

  static BoxDecoration gradientFor(BuildContext context) =>
      BoxDecoration(gradient: gradientLinearFor(context));

  static LinearGradient gradientLinearFor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [_darkBg, _darkMid, _darkAccent]
          : [_violet, Colors.deepPurple.shade700, _blue],
    );
  }

  // ─── Shared Snackbar theme (floating + dismissible) ────────────────────────
  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    dismissDirection: DismissDirection.horizontal,
  );

  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        textTheme:
            GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _violet,
          primary: _violet,
          secondary: _blue,
          brightness: Brightness.light,
        ),
        snackBarTheme: _snackBarTheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.95),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          // Use hint instead of label approach — keep label short & non-wrapping
          labelStyle: const TextStyle(
            color: Color(0xFF6B21A8),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFF6B21A8),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _violet.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _violet, width: 2),
          ),
          // Extra vertical padding so the floating label has space
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _violet,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.montserrat(fontWeight: FontWeight.w700),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _blue,
            textStyle:
                GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      );

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        textTheme:
            GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: _darkAccent,
          primary: const Color(0xFFB794F4),
          secondary: const Color(0xFF90CDF4),
          surface: _darkCard,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _darkBg,
        snackBarTheme: _snackBarTheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _darkInput,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          floatingLabelStyle: const TextStyle(
            color: Color(0xFFB794F4),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFB794F4), width: 2),
          ),
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIconColor: Colors.white60,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6D28D9),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.montserrat(fontWeight: FontWeight.w700),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFB794F4),
            textStyle:
                GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          color: _darkCard,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withValues(alpha: 0.10),
        ),
        listTileTheme: ListTileThemeData(
          textColor: Colors.white.withValues(alpha: 0.90),
          iconColor: Colors.white60,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFFB794F4);
            }
            return Colors.white38;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color(0xFF6D28D9);
            }
            return Colors.white24;
          }),
        ),
      );
}