import 'package:flutter/material.dart';
import 'package:myapp/screens/firebase_login.dart'; // Adjust import if needed
import 'package:myapp/screens/shopping.dart'; // Adjust import if needed
import 'package:myapp/elements/app_theme.dart';
import 'package:myapp/screens/dashboard_page.dart'; // Import DashboardPage explicitly for route access
import 'package:myapp/screens/product_page.dart'; // Import ProductPage explicitly for route access
// Note: You might want to define AppRoutes in a separate common file (e.g., app_routes.dart)
// and import that into main.dart and other files that need access to route constants.
// For now, mirroring the AppRoutes definition here for immediate functionality.

// Define your route names as constants
class AppRoutes {
  static const String home = '/';
  static const String reviews = '/reviews';
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
  TextStyle _getBaseTextStyle(
      BuildContext context, bool isActive, double screenWidth) {
    final Color? foregroundColor =
        Theme.of(context).appBarTheme.foregroundColor;

    // --- Responsive Font Size Logic ---
    double targetFontSize;
    // Define breakpoints and target font sizes (adjust these as needed)
    if (screenWidth < 400) {
      // Very Narrow screens (small phones portrait)
      targetFontSize = 14.0;
    } else if (screenWidth < 600) {
      // Narrow screens (most phones portrait)
      targetFontSize = 15.0;
    } else if (screenWidth < 900) {
      // Medium screens (large phones landscape, small tablets)
      targetFontSize = 16.0;
    } else if (screenWidth < 1200) {
      // Wide screens (test with tablets landscape, small desktop)
      targetFontSize =
          17.0; // Changed from 18.0 to 17.0 for more consistent scaling
    } else {
      // Very Wide screens (large desktop)
      targetFontSize =
          18.0; // Changed from 20.0 to 18.0 for more consistent scaling
    }
    // --- End Responsive Font Size Logic ---

    return TextStyle(
      color: foregroundColor ?? Colors.white, // Use fallback for safety
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      fontSize: targetFontSize, // Apply the calculated font size
    );
  }

  // --- Function to show the Contact Us popup ---
  void _showContactUsPopup(BuildContext context) {
    // Get screen width for responsive sizing of the dialog
    final double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15.0), // Rounded corners for the dialog
          ),
          // Constrain the width of the AlertDialog based on screen size
          contentPadding: EdgeInsets
              .zero, // Remove default content padding to allow CustomContent to handle it
          insetPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0), // Standard material dialog padding
          content: Container(
            width: screenWidth > 600
                ? screenWidth * 0.4
                : screenWidth * 0.8, // 40% for large, 80% for small
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600
                  ? screenWidth * 0.4
                  : screenWidth * 0.8, // Ensure it doesn't exceed this width
              maxHeight: MediaQuery.of(context).size.height *
                  0.6, // Max height 60% of screen height
            ),
            child: SingleChildScrollView(
              // Make content scrollable if it overflows
              child: Padding(
                padding:
                    const EdgeInsets.all(24.0), // Add padding back to content
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To wrap content tightly
                  children: [
                    Text(
                      'Contact Us',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth > 600
                            ? 24
                            : 20, // Responsive title font size
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .primary, // Use app's primary color
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Email: support@example.com',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth > 600
                            ? 18
                            : 16, // Responsive content font size
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Phone: +1 (123) 456-7890', // Example phone number
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth > 600
                            ? 18
                            : 16, // Responsive content font size
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: Text(
                'Close',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsiveness
    final double screenWidth = MediaQuery.of(context).size.width;
    const double mobileBreakpoint = 850; // Adjust this value as needed

    final String? currentRouteName = ModalRoute.of(context)?.settings.name;
    final Color? appBarBackgroundColor =
        Theme.of(context).appBarTheme.backgroundColor;
    final Color appBarForegroundColor =
        Theme.of(context).appBarTheme.foregroundColor ?? Colors.white;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // --- Function to create the MenuItem for the Hamburger ---
    PopupMenuItem<String> buildMenuItem(String label, String routeName) {
      final bool isActive = currentRouteName == routeName;
      final Color textColor = Theme.of(context).textTheme.bodyMedium?.color ??
          Colors.black; // Use a fallback color
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
      final baseStyle = _getBaseTextStyle(
          context, isActive, screenWidth); // Use the private helper
      final textWidget = Text(label, style: baseStyle);

      return TextButton(
        onPressed: () {
          if (buttonRouteName == AppRoutes.contact) {
            _showContactUsPopup(context); // Show popup for Contact Us
          } else if (currentRouteName != buttonRouteName) {
            // Avoid navigating if already on the current route
            // For 'Home', clear the navigation stack to prevent back button issues
            if (buttonRouteName == AppRoutes.home) {
              Navigator.pushNamedAndRemoveUntil(
                  context, buttonRouteName, (route) => false);
            } else {
              // For other routes, push the new route
              Navigator.pushNamed(context, buttonRouteName);
            }
          }
        },
        child: _ActiveUnderlineWrapper(
          isActive: isActive,
          color: appBarForegroundColor,
          thickness: 2.5,
          underlineOffset: 4.0,
          child: textWidget,
        ),
      );
    }

    return AppBar(
      backgroundColor: appBarBackgroundColor,
      elevation: 0,
      title: screenWidth < mobileBreakpoint // Check for mobile breakpoint
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hamburger menu button for small screens
                PopupMenuButton<String>(
                  icon: Icon(Icons.menu, color: appBarForegroundColor),
                  onSelected: (String route) {
                    if (route == AppRoutes.contact) {
                      _showContactUsPopup(context); // Show popup for Contact Us
                    } else if (currentRouteName != route) {
                      if (route == AppRoutes.home) {
                        Navigator.pushNamedAndRemoveUntil(
                            context, route, (r) => false);
                      } else {
                        Navigator.pushNamed(context, route);
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    buildMenuItem('Home', AppRoutes.home),
                    buildMenuItem('Reviews', AppRoutes.reviews),
                    buildMenuItem('Product', AppRoutes.product_page),
                    buildMenuItem('Dashboard', AppRoutes.dashboard),
                    buildMenuItem('Sign In', AppRoutes.signin),
                    buildMenuItem('Contact Us', AppRoutes.contact),
                  ],
                ),
                // Theme toggle button for small screens
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
              // Row of TextButtons for wide screens
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildRowButton('Home', AppRoutes.home),
                const SizedBox(width: 30.0),
                buildRowButton('Reviews', AppRoutes.reviews),
                const SizedBox(width: 30.0),
                buildRowButton('Product', AppRoutes.product_page),
                const SizedBox(width: 30.0),
                buildRowButton(
                    'Dashboard', AppRoutes.dashboard), // Fixed navigation here
                const SizedBox(width: 30.0),
                buildRowButton('Sign In', AppRoutes.signin),
                const SizedBox(width: 30.0),
                buildRowButton(
                    'Contact Us', AppRoutes.contact), // Now opens popup
                const SizedBox(width: 30.0),
                // Theme toggle button for wide screens
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
