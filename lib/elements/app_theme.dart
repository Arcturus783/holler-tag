import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppTheme {
  // Updated gradients to match the modern design in your HomePage
  static const LinearGradient lightDefaultGradient = LinearGradient(
    colors: [
      Color(0xFF00D9FF), // Bright cyan - matches your existing cyan
      Color(0xFF00FFFF), // Pure cyan
      Color(0xFF0099FF), // Bright blue accent
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkDefaultGradient = LinearGradient(
    colors: [
      Color(0xFF3F51B5), // Indigo
      Color(0xFF7C4DFF), // Deep purple accent
      Color(0xFF9C27B0), // Purple accent
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  // Additional gradients for variety
  static const LinearGradient lightAccentGradient = LinearGradient(
    colors: [
      Color(0xFF00BCD4), // Cyan
      Color(0xFF2196F3), // Blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkAccentGradient = LinearGradient(
    colors: [
      Color(0xFF673AB7), // Deep purple
      Color(0xFF9C27B0), // Purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00D9FF),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00D9FF), // Bright cyan
      onPrimary: Colors.white,
      secondary: Color(0xFF0099FF), // Bright blue
      onSecondary: Colors.white,
      surface: Color(0xFFFAFAFA), // Very light gray
      onSurface: Color(0xFF212121), // Dark gray
      background: Colors.white,
      onBackground: Color(0xFF212121),
      error: Color(0xFFD32F2F), // Material red
      onError: Colors.white,
      outline: Color(0xFFE0E0E0), // Light gray for borders
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF00D9FF),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00D9FF),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF00D9FF).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ), textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
        color: Color(0xFF212121),
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Color(0xFF212121),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Color(0xFF212121),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: Color(0xFF424242),
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: Color(0xFF424242),
        height: 1.5,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF3F51B5),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3F51B5), // Indigo
      onPrimary: Colors.white,
      secondary: Color(0xFF7C4DFF), // Deep purple accent
      onSecondary: Colors.white,
      surface: Color(0xFF1E1E1E), // Dark surface
      onSurface: Colors.white,
      background: Color(0xFF121212), // Very dark background
      onBackground: Colors.white,
      error: Color(0xFFCF6679), // Material dark red
      onError: Colors.black,
      outline: Color(0xFF424242), // Dark gray for borders
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A237E), // Dark indigo
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF3F51B5).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: Color(0xFFE0E0E0),
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: Color(0xFFE0E0E0),
        height: 1.5,
      ),
    ),
  );

  static ThemeData getThemeFromSystem() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  static LinearGradient getDefaultGradient(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkDefaultGradient : lightDefaultGradient;
  }

  static LinearGradient getAccentGradient(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? darkAccentGradient : lightAccentGradient;
  }

  // Helper method to get theme-appropriate shadow color
  static Color getShadowColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.2);
  }

  // Helper method to get theme-appropriate overlay color
  static Color getOverlayColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.white.withOpacity(0.9);
  }

  // Helper method to get theme-appropriate border color
  static Color getBorderColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);
  }
}