import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CountEase Premium Design System
/// A curated, professional-grade theme with glassmorphism,
/// gradient accents, and harmonious color palettes.

class AppColors {
  // ─── Brand Primaries ───
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF14B8A6);

  // ─── Surfaces ───
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceDarkElevated = Color(0xFF1E293B);
  static const Color surfaceDarkCard = Color(0xFF1A2332);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceLightCard = Color(0xFFFFFFFF);
  static const Color surfaceLightElevated = Color(0xFFF1F5F9);

  // ─── Text Colors ───
  static const Color textDarkPrimary = Color(0xFFF1F5F9);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF64748B);

  // ─── Event Type Colors ───
  static const Color birthdayStart = Color(0xFFF43F5E);
  static const Color birthdayEnd = Color(0xFFEC4899);
  static const Color examStart = Color(0xFF10B981);
  static const Color examEnd = Color(0xFF14B8A6);
  static const Color poyaStart = Color(0xFFF59E0B);
  static const Color poyaEnd = Color(0xFFF97316);
  static const Color customStart = Color(0xFF6366F1);
  static const Color customEnd = Color(0xFF8B5CF6);

  // ─── Status Colors ───
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Glass ───
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassLight = Color(0x33FFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryIndigo, AppColors.primaryViolet],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accent, Color(0xFF06B6D4)],
  );

  static const LinearGradient birthdayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.birthdayStart, AppColors.birthdayEnd],
  );

  static const LinearGradient examGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.examStart, AppColors.examEnd],
  );

  static const LinearGradient poyaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.poyaStart, AppColors.poyaEnd],
  );

  static const LinearGradient customGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.customStart, AppColors.customEnd],
  );

  static LinearGradient darkBackground = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF1A1A2E)],
  );

  static LinearGradient lightBackground = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Color(0xFFEEF2FF)],
  );
}

class AppDecorations {
  /// Premium glassmorphism container decoration
  static BoxDecoration glassCard({
    bool isDark = false,
    double borderRadius = 20,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: isDark
          ? Colors.white.withValues(alpha: opacity)
          : Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.8),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Soft elevated card decoration
  static BoxDecoration elevatedCard({
    bool isDark = false,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: isDark ? AppColors.surfaceDarkCard : AppColors.surfaceLightCard,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  /// Gradient accent card with event-type colors
  static BoxDecoration gradientCard({
    required LinearGradient gradient,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withValues(alpha: 0.4),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Subtle inner glass effect
  static BoxDecoration innerGlass({double borderRadius = 12}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        width: 1,
      ),
    );
  }
}

class AppTheme {
  static TextTheme _buildTextTheme(bool isDark) {
    final Color primary = isDark
        ? AppColors.textDarkPrimary
        : AppColors.textLightPrimary;
    final Color secondary = isDark
        ? AppColors.textDarkSecondary
        : AppColors.textLightSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -1,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.5,
      ),
    );
  }

  static ThemeData lightTheme() {
    final textTheme = _buildTextTheme(false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryIndigo,
        secondary: AppColors.accent,
        tertiary: AppColors.primaryViolet,
        surface: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textLightPrimary,
        outline: Color(0xFFCBD5E1),
        surfaceContainerHighest: Color(0xFFE2E8F0),
        primaryContainer: Color(0xFFEEF2FF),
        onPrimaryContainer: AppColors.primaryIndigo,
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textLightPrimary,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceLightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryIndigo,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF94A3B8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryIndigo;
          }
          return const Color(0xFFE2E8F0);
        }),
      ),
    );
  }

  static ThemeData darkTheme() {
    final textTheme = _buildTextTheme(true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryIndigo,
        secondary: AppColors.accent,
        tertiary: AppColors.primaryViolet,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDarkPrimary,
        outline: Color(0xFF334155),
        surfaceContainerHighest: Color(0xFF1E293B),
        primaryContainer: Color(0xFF1E1B4B),
        onPrimaryContainer: Color(0xFFC7D2FE),
      ),
      scaffoldBackgroundColor: AppColors.surfaceDark,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDarkPrimary,
        titleTextStyle: textTheme.headlineMedium,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surfaceDarkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryIndigo,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: AppColors.surfaceDarkElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1E293B),
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF64748B);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryIndigo;
          }
          return const Color(0xFF334155);
        }),
      ),
    );
  }
}

/// Helper to get event gradient by type
LinearGradient getEventGradient(String eventType) {
  switch (eventType) {
    case 'birthday':
      return AppGradients.birthdayGradient;
    case 'exam':
      return AppGradients.examGradient;
    case 'poya':
      return AppGradients.poyaGradient;
    default:
      return AppGradients.customGradient;
  }
}

/// Helper to get event color by type
Color getEventColor(String eventType) {
  switch (eventType) {
    case 'birthday':
      return AppColors.birthdayStart;
    case 'exam':
      return AppColors.examStart;
    case 'poya':
      return AppColors.poyaStart;
    default:
      return AppColors.customStart;
  }
}
