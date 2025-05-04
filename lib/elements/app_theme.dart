import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppTheme {
  static const LinearGradient lightDefaultGradient = LinearGradient(
    colors: [Color.fromARGB(255, 0, 217, 255), Color.fromARGB(255, 0, 255, 255)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkDefaultGradient = LinearGradient(
    colors: [Colors.indigo, Colors.deepPurpleAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    colorScheme: ColorScheme.light(
      secondary: Colors.blue,
      onSecondary: Colors.black,
      primary: Colors.blue,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.indigo,
    colorScheme: ColorScheme.dark(
      secondary: Colors.deepOrangeAccent,
      onSecondary: Colors.black,
      primary: Colors.indigo,
      onPrimary: Colors.white,
      surface: Colors.grey[900]!,
      onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.indigo[900],
      foregroundColor: Colors.white,
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
}