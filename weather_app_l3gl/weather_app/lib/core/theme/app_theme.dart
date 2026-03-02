import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────
// CONSTANTES DE COULEURS
// ─────────────────────────────────────────

class AppColors {
  // DARK MODE
  static const darkScaffold = Color(0xFF050510);
  static const darkSurface = Color(0xFF0F0F20);
  static const darkTextPrimary = Color(0xFFF0F0FF);
  static const darkTextSecondary = Color(0xFF9999BB);
  static const darkAccent = Color(0xFF00FFD1);
  static const darkAccentSecondary = Color(0xFFB44FFF);
  static const darkBorder = Color(0x14FFFFFF);

  // LIGHT MODE
  static const lightScaffold = Color(0xFFF5F7FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF0A0A1A);
  static const lightTextSecondary = Color(0xFF4A4A70);
  static const lightAccent = Color(0xFF006B54);
  static const lightAccentSecondary = Color(0xFF5B21B6);
  static const lightBorder = Color(0xFFE2E4F0);

  // MÉTÉO
  static const sun = Color(0xFFF59E0B);
  static const cloudy = Color(0xFF64748B);
  static const rain = Color(0xFF3B82F6);
  static const storm = Color(0xFF7C3AED);
  static const snow = Color(0xFF93C5FD);
  static const wind = Color(0xFF10B981);

  // FOND DYNAMIQUE MÉTÉO (dark mode)
  static const bgSun = [Color(0xFF0D1117), Color(0xFF1A2744), Color(0xFF2D4A8A)];
  static const bgCloudy = [Color(0xFF0D0D14), Color(0xFF1A1A2E), Color(0xFF2D2D4A)];
  static const bgRain = [Color(0xFF050A14), Color(0xFF0A1A2E), Color(0xFF0F2A4A)];
  static const bgStorm = [Color(0xFF0A0514), Color(0xFF1A0A2E), Color(0xFF2D0F4A)];
  static const bgNight = [Color(0xFF050510), Color(0xFF0A0A20), Color(0xFF0F0F30)];
  static const bgSnow = [Color(0xFF0A0F14), Color(0xFF0F1A2E), Color(0xFF1A2A4A)];
}

// ─────────────────────────────────────────
// THÈME APPLICATION
// ─────────────────────────────────────────

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkScaffold,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkAccent,
        secondary: AppColors.darkAccentSecondary,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.darkScaffold,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: _buildTextTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightScaffold,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightAccent,
        secondary: AppColors.lightAccentSecondary,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: _buildTextTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 120,
        fontWeight: FontWeight.w900,
        color: primary,
        letterSpacing: -4,
        height: 1,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 80,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondary,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─────────────────────────────────────────
// HELPERS MÉTÉO
// ─────────────────────────────────────────

class WeatherTheme {
  static Color getColor(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sun')) return AppColors.sun;
    if (c.contains('storm') || c.contains('thunder')) return AppColors.storm;
    if (c.contains('rain') || c.contains('drizzle')) return AppColors.rain;
    if (c.contains('snow')) return AppColors.snow;
    return AppColors.cloudy;
  }

  static List<Color> getGradient(String condition, bool isDark) {
    final c = condition.toLowerCase();
    if (!isDark) {
      if (c.contains('clear') || c.contains('sun')) {
        return [const Color(0xFF87CEEB), const Color(0xFF4A90D9), const Color(0xFF2171C7)];
      }
      if (c.contains('storm') || c.contains('thunder')) {
        return [const Color(0xFF4A0080), const Color(0xFF2D0050), const Color(0xFF1A0030)];
      }
      if (c.contains('rain') || c.contains('drizzle')) {
        return [const Color(0xFF2C5F8A), const Color(0xFF1A3D5C), const Color(0xFF0F2A40)];
      }
      if (c.contains('snow')) {
        return [const Color(0xFF8AB4D4), const Color(0xFF5A8AAA), const Color(0xFF3A6A8A)];
      }
      return [const Color(0xFF6B8FA8), const Color(0xFF4A6A80), const Color(0xFF2A4A60)];
    }
    if (c.contains('clear') || c.contains('sun')) return AppColors.bgSun;
    if (c.contains('storm') || c.contains('thunder')) return AppColors.bgStorm;
    if (c.contains('rain') || c.contains('drizzle')) return AppColors.bgRain;
    if (c.contains('snow')) return AppColors.bgSnow;
    return AppColors.bgCloudy;
  }

  static String getEmoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sun')) return '☀️';
    if (c.contains('thunder') || c.contains('storm')) return '⛈️';
    if (c.contains('rain') || c.contains('drizzle')) return '🌧️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('cloud')) return '☁️';
    if (c.contains('mist') || c.contains('fog') || c.contains('haze')) return '🌫️';
    return '🌤️';
  }

  static String getUnsplashUrl(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('clear') || c.contains('sun')) {
      return 'https://images.unsplash.com/photo-1601297183305-6df142704ea2?w=800&q=80';
    }
    if (c.contains('thunder') || c.contains('storm')) {
      return 'https://images.unsplash.com/photo-1605727216801-e27ce1d0cc28?w=800&q=80';
    }
    if (c.contains('rain') || c.contains('drizzle')) {
      return 'https://images.unsplash.com/photo-1433863448220-78aaa064ff47?w=800&q=80';
    }
    if (c.contains('snow')) {
      return 'https://images.unsplash.com/photo-1491002052546-bf38f186af56?w=800&q=80';
    }
    return 'https://images.unsplash.com/photo-1534088568595-a066f410bcda?w=800&q=80';
  }
}
