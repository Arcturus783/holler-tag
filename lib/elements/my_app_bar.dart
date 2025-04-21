// In 'elements/my_app_bar.dart'

import 'package:flutter/material.dart';
import 'package:myapp/screens/firebase_login.dart'; // Adjust import if needed
import 'package:myapp/screens/shopping.dart';       // Adjust import if needed
// Import AppTheme if not already
import 'package:myapp/elements/app_theme.dart';

// Define your route names as constants
class AppRoutes {
  static const String home = '/';
  static const String reviews = '/reviews';
  //static const String product = '/product';
  static const String product_page = '/product_page';
  static const String dashboard = '/dashboard';
  static const String signin = '/signin';
  static const String contact = '/contact';
}


class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback toggleTheme;

  const MyAppBar({super.key, required this.toggleTheme});

  // --- Helper Method for basic text style (color, weight, RESPONSIVE FONT SIZE) ---
  // Added screenWidth parameter
  TextStyle _getBaseTextStyle(BuildContext context, bool isActive, double screenWidth) {
    final Color? foregroundColor = Theme.of(context).appBarTheme.foregroundColor;

    // --- Responsive Font Size Logic ---
    double targetFontSize;
    // Define breakpoints and target font sizes (adjust these as needed)
    if (screenWidth < 400) {         // Very Narrow screens (small phones portrait)
      targetFontSize = 14.0;
    } else if (screenWidth < 600) {  // Narrow screens (most phones portrait)
      targetFontSize = 15.0;
    } else if (screenWidth < 900) {  // Medium screens (large phones landscape, small tablets)
      targetFontSize = 16.0;
    } else if (screenWidth < 1200) { // Wide screens (tablets landscape, small desktop)
      targetFontSize = 18.0;
    } else {                          // Very Wide screens (large desktop)
      targetFontSize = 20.0;
    }
    // --- End Responsive Font Size Logic ---

    return TextStyle(
      color: foregroundColor ?? Colors.white, // Use fallback for safety
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      fontSize: targetFontSize, // Apply the calculated font size
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    const double mobileBreakpoint = 850; // Adjust this value as needed

    final String? currentRouteName = ModalRoute.of(context)?.settings.name;
    final Color? appBarBackgroundColor = Theme.of(context).appBarTheme.backgroundColor;
    final Color appBarForegroundColor = Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // --- Helper Method for basic text style (color, weight, RESPONSIVE FONT SIZE) ---
    TextStyle getBaseTextStyle(BuildContext context, bool isActive, double screenWidth) {
      final Color? foregroundColor = Theme.of(context).appBarTheme.foregroundColor;

      // --- Responsive Font Size Logic ---
      double targetFontSize;
      if (screenWidth < 400) {
        targetFontSize = 14.0;
      } else if (screenWidth < 600) {
        targetFontSize = 15.0;
      } else if (screenWidth < 900) {
        targetFontSize = 16.0;
      } else if (screenWidth < 1200) {
        targetFontSize = 17.0;
      } else {
        targetFontSize = 18.0;
      }
      return TextStyle(
        color: foregroundColor ?? Colors.white, // Use fallback for safety
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        fontSize: targetFontSize,
      );
    }

    // --- Function to create the MenuItem for the Hamburger ---
    PopupMenuItem<String> buildMenuItem(String label, String routeName) {
      final bool isActive = currentRouteName == routeName;
      final Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black; // Use a fallback color
      final double targetFontSize;
      if (screenWidth < 400) {
        targetFontSize = 14.0;
      } else if (screenWidth < 600) {
        targetFontSize = 15.0;
      } else if (screenWidth < 900) {
        targetFontSize = 16.0;
      } else if (screenWidth < 1200) {
        targetFontSize = 17.0;
      } else {
        targetFontSize = 18.0;
      }
      return PopupMenuItem<String>(
        value: routeName,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: targetFontSize,
          ),
        ),
      );
    }

    // --- Function to create the TextButton Child for the Row ---
    Widget buildRowButton(String label, String buttonRouteName) {
      final bool isActive = currentRouteName == buttonRouteName;
      final baseStyle = getBaseTextStyle(context, isActive, screenWidth);
      final textWidget = Text(label, style: baseStyle);
      return _ActiveUnderlineWrapper(
        isActive: isActive,
        color: appBarForegroundColor,
        thickness: 2.5,
        underlineOffset: 4.0,
        child: textWidget,
      );
    }

    return AppBar(
      backgroundColor: appBarBackgroundColor,
      elevation: 0,
      title: screenWidth < mobileBreakpoint
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.menu, color: appBarForegroundColor),
                  onSelected: (String route) {
                    if (currentRouteName != route) {
                      if (route == AppRoutes.home) {
                        Navigator.pushNamedAndRemoveUntil(context, route, (r) => false);
                      } else {
                        Navigator.pushNamed(context, route);
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    buildMenuItem('Home', AppRoutes.home),
                    buildMenuItem('Reviews', AppRoutes.reviews),
                    buildMenuItem('Product', AppRoutes.product_page),
                    buildMenuItem('Dashboard', AppRoutes.dashboard),
                    buildMenuItem('Sign In', AppRoutes.signin),
                    buildMenuItem('Contact Us', AppRoutes.contact),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: appBarForegroundColor,
                  ),
                  onPressed: toggleTheme,
                  tooltip: 'Toggle Theme',
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    if (currentRouteName != AppRoutes.home) {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                    }
                  },
                  child: buildRowButton('Home', AppRoutes.home),
                ),
                const SizedBox(width: 30.0),
                TextButton(
                  onPressed: () {
                    if (currentRouteName != AppRoutes.reviews) {
                      // TODO: Implement Reviews Page Navigation
                    }
                  },
                  child: buildRowButton('Reviews', AppRoutes.reviews),
                ),
                const SizedBox(width: 30.0),
                TextButton(
                  onPressed: () {
                    if (currentRouteName != AppRoutes.product_page) {
                      Navigator.pushNamed(context, AppRoutes.product_page);
                    }
                  },
                  child: buildRowButton('Product', AppRoutes.product_page),
                ),
                const SizedBox(width: 30.0),
                TextButton(
                  onPressed: () {
                    if (currentRouteName != AppRoutes.dashboard) {
                      // TODO: Implement Dashboard Page Navigation
                    }
                  },
                  child: buildRowButton('Dashboard', AppRoutes.dashboard),
                ),
                const SizedBox(width: 30.0),
                TextButton(
                  onPressed: () {
                    if (currentRouteName != AppRoutes.signin) {
                      Navigator.pushNamed(context, AppRoutes.signin);
                    }
                  },
                  child: buildRowButton('Sign In', AppRoutes.signin),
                ),
                const SizedBox(width: 30.0),
                TextButton(
                  onPressed: () {
                    if (currentRouteName != AppRoutes.contact) {
                      // TODO: Implement Contact Page Navigation
                    }
                  },
                  child: buildRowButton('Contact Us', AppRoutes.contact),
                ),
                const SizedBox(width: 30.0),
                IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: appBarForegroundColor,
                  ),
                  onPressed: toggleTheme,
                  tooltip: 'Toggle Theme',
                ),
              ],
            ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}


// --- Private Helper Widget for Conditional Underlining ---
class _ActiveUnderlineWrapper extends StatelessWidget {
  final bool isActive;
  final Widget child;
  final Color color;
  final double thickness;
  final double underlineOffset;

  const _ActiveUnderlineWrapper({
    required this.isActive,
    required this.child,
    required this.color,
    this.thickness = 2.5,
    this.underlineOffset = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      return child;
    }
    return Container(
      padding: EdgeInsets.only(bottom: underlineOffset),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: color,
            width: thickness,
          ),
        ),
      ),
      child: child,
    );
  }
}