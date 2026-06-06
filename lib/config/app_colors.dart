import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF0061A4);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFD1E4FF);
  static const Color lightOnPrimaryContainer = Color(0xFF001D36);

  static const Color lightSecondary = Color(0xFF535F70);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFD7E3F7);
  static const Color lightOnSecondaryContainer = Color(0xFF101C2B);

  static const Color lightTertiary = Color(0xFF6B5778);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFF2DAFF);
  static const Color lightOnTertiaryContainer = Color(0xFF251431);

  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF410002);

  static const Color lightBackground = Color(0xFFFDFCFF);
  static const Color lightOnBackground = Color(0xFF1A1C1E);
  static const Color lightSurface = Color(0xFFFDFCFF);
  static const Color lightOnSurface = Color(0xFF1A1C1E);
  static const Color lightSurfaceVariant = Color(0xFFDFE2EB);
  static const Color lightOnSurfaceVariant = Color(0xFF43474E);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF9ECAFF);
  static const Color darkOnPrimary = Color(0xFF003258);
  static const Color darkPrimaryContainer = Color(0xFF00497D);
  static const Color darkOnPrimaryContainer = Color(0xFFD1E4FF);

  static const Color darkSecondary = Color(0xFFBBC7DB);
  static const Color darkOnSecondary = Color(0xFF253141);
  static const Color darkSecondaryContainer = Color(0xFF3B4858);
  static const Color darkOnSecondaryContainer = Color(0xFFD7E3F7);

  static const Color darkTertiary = Color(0xFFD6BEE0);
  static const Color darkOnTertiary = Color(0xFF3A2946);
  static const Color darkTertiaryContainer = Color(0xFF513F5D);
  static const Color darkOnTertiaryContainer = Color(0xFFF2DAFF);

  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color darkBackground = Color(0xFF1A1C1E);
  static const Color darkOnBackground = Color(0xFFE2E2E6);
  static const Color darkSurface = Color(0xFF1A1C1E);
  static const Color darkOnSurface = Color(0xFFE2E2E6);
  static const Color darkSurfaceVariant = Color(0xFF43474E);
  static const Color darkOnSurfaceVariant = Color(0xFFC3C7CF);

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFF44336);
  static const Color primary = lightPrimary;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lightPrimary, Color(0xFF00497D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [lightSecondary, Color(0xFF253141)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
