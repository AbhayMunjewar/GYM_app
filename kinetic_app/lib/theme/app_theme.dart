import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF131313);
  static const Color primaryFixed = Color(0xFFCAF300);
  static const Color primaryContainer = Color(0xFFCAF300);
  static const Color onPrimaryContainer = Color(0xFF596C00);
  static const Color onPrimaryFixed = Color(0xFF171E00);
  static const Color onPrimaryFixedVariant = Color(0xFF3E4C00);
  static const Color secondaryContainer = Color(0xFF4B8EFF);
  static const Color onSurfaceVariant = Color(0xFFC5C9AC);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color transparent = Colors.transparent;

  // Legacy mappings for existing components
  static const Color primary = primaryFixed;
  static const Color surface = background;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryFixed,
        surface: AppColors.background,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.8),
        headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.64),
        headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.24),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.7),
        labelSmall: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.96),
      ),
    );
  }
}
