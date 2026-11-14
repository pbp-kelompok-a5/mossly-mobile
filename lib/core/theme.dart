import 'package:flutter/material.dart';

/// Warna Mossly, disalin dari static/css/tokens.css di situs web
/// supaya tampilan web dan mobile selaras.
class MosslyColors {
  static const Color moss50 = Color(0xFFF1F4EC);
  static const Color moss100 = Color(0xFFE2E9D8);
  static const Color moss200 = Color(0xFFC6D3B2);
  static const Color moss300 = Color(0xFF99AD7A);
  static const Color moss400 = Color(0xFF7A9160);
  static const Color moss500 = Color(0xFF546B41);
  static const Color moss600 = Color(0xFF45583A);
  static const Color moss700 = Color(0xFF374630);
  static const Color moss800 = Color(0xFF2F3A25);
  static const Color moss900 = Color(0xFF1E2618);

  static const Color sand50 = Color(0xFFFFF8EC);
  static const Color sand100 = Color(0xFFF6EEDC);
  static const Color sand200 = Color(0xFFEBDFC6);
  static const Color sand300 = Color(0xFFDCCCAC);
  static const Color sand400 = Color(0xFFC8B48C);

  static const Color clay100 = Color(0xFFF3E4D1);
  static const Color clay300 = Color(0xFFD39C5E);
  static const Color clay500 = Color(0xFFB07634);
  static const Color clay700 = Color(0xFF7E521F);

  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral400 = Color(0xFF8C937F);
  static const Color neutral600 = Color(0xFF5E6852);

  static const Color red50 = Color(0xFFFBEAE8);
  static const Color red500 = Color(0xFFB3261E);

  static const Color pink100 = Color(0xFFFBE3EA);
  static const Color pink200 = Color(0xFFF7CBD8);
  static const Color pink500 = Color(0xFFD97F9C);
}

/// Jarak dan sudut, sama dengan token --space-* dan --radius-* di web.
class MosslySpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s6 = 24;
  static const double s8 = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
}

ThemeData buildMosslyTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: MosslyColors.moss500,
    brightness: Brightness.light,
  ).copyWith(
    primary: MosslyColors.moss500,
    onPrimary: MosslyColors.sand50,
    primaryContainer: MosslyColors.moss100,
    onPrimaryContainer: MosslyColors.moss800,
    secondary: MosslyColors.clay500,
    onSecondary: MosslyColors.sand50,
    secondaryContainer: MosslyColors.moss100,
    onSecondaryContainer: MosslyColors.moss800,
    tertiary: MosslyColors.pink500,
    error: MosslyColors.red500,
    errorContainer: MosslyColors.red50,
    surface: MosslyColors.sand50,
    onSurface: MosslyColors.moss800,
    onSurfaceVariant: MosslyColors.neutral600,
    surfaceContainerLowest: MosslyColors.neutral0,
    surfaceContainerLow: MosslyColors.neutral0,
    surfaceContainer: MosslyColors.neutral0,
    surfaceContainerHigh: MosslyColors.sand100,
    surfaceContainerHighest: MosslyColors.sand200,
    outline: MosslyColors.sand400,
    outlineVariant: MosslyColors.sand300,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MosslyColors.sand50,
  );
}
