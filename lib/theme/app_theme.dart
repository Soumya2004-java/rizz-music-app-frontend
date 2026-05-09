import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF8EA2FF),
      onPrimary: Color(0xFF09104A),
      secondary: Color(0xFFFFA186),
      onSecondary: Color(0xFF4A1508),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: Color(0xFF090E1A),
      onSurface: Color(0xFFEAF0FF),
      surfaceContainerHighest: Color(0xFF283043),
      onSurfaceVariant: Color(0xFFBFC7DC),
      outline: Color(0xFF8993AB),
      outlineVariant: Color(0xFF434C62),
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
      inverseSurface: Color(0xFFEAF0FF),
      onInverseSurface: Color(0xFF171D2A),
      inversePrimary: Color(0xFF2B59FF),
    );

    const baseGrey = Color(0xFFB7BFCE);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: NoSplash.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface.withValues(alpha: 0.9),
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: scheme.onSurface),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: baseGrey),
        displayMedium: TextStyle(color: baseGrey),
        displaySmall: TextStyle(color: baseGrey),
        headlineLarge: TextStyle(color: baseGrey),
        headlineMedium: TextStyle(color: baseGrey),
        headlineSmall: TextStyle(color: baseGrey),
        titleLarge: TextStyle(color: baseGrey, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: baseGrey, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(color: baseGrey),
        bodyLarge: TextStyle(color: baseGrey),
        bodyMedium: TextStyle(color: baseGrey, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(color: baseGrey),
        labelLarge: TextStyle(color: baseGrey),
        labelMedium: TextStyle(color: baseGrey),
        labelSmall: TextStyle(color: baseGrey),
      ),
    );
  }
}
