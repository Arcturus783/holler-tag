import 'package:flutter/material.dart';
import 'package:myapp/screens/firebase_login.dart'; // Adjust import if needed
import 'package:myapp/screens/shopping.dart'; // Adjust import if needed
import 'package:myapp/elements/app_theme.dart';
import 'package:myapp/screens/dashboard_page.dart'; // Import DashboardPage explicitly for route access
import 'package:myapp/screens/product_page.dart'; // Import ProductPage explicitly for route access
import 'package:myapp/backend/google_auth.dart';
import 'package:myapp/elements/custom_button.dart';
// Note: You might want to define AppRoutes in a separate common file (e.g., app_routes.dart)
// and import that into main.dart and other files that need access to route constants.
// For now, mirroring the AppRoutes definition here for immediate functionality.

// Define your route names as constants
class AppRoutes {
  static const String home = '/';
  static const String product_page = '/product_page';
  static const String dashboard = '/dashboard';
  static const String signin = '/signin';
  static const String contact = '/contact';
}

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback toggleTheme;

  const MyAppBar({super.key, required this.toggleTheme});

  @override
  State<MyAppBar> createState() => _MyAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class _MyAppBarState extends State<MyAppBar> with TickerProviderStateMixin {
  late AnimationController _hoverController;
  String _hoveredButton = '';

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  // --- Helper Method for modern text style with enhanced typography ---
  TextStyle _getModernTextStyle(
      BuildContext context, bool isActive, bool isHovered, double screenWidth) {
    final Color? foregroundColor =
        Theme.of(context).appBarTheme.foregroundColor;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // --- Enhanced Responsive Font Size Logic ---
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
      color: isActive
          ? (isDark ? Colors.white : Colors.white)
          : (isHovered
          ? (isDark ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9))
          : (foregroundColor ?? Colors.white).withValues(alpha: 0.8)),
      fontWeight: isActive ? FontWeight.w600 : (isHovered ? FontWeight.w500 : FontWeight.w400),
      fontSize: targetFontSize,
      letterSpacing: 0.5,
    );
  }

  // --- Enhanced Contact Us popup with modern design ---
  void _showContactUsPopup(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.85,
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.85,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  Colors.grey[900]!.withValues(alpha: 0.95),
                  Colors.grey[800]!.withValues(alpha: 0.95),
                ]
                    : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.grey[50]!.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Contact title with gradient
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => currentGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        'Contact Us',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28 : 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Contact info cards
                    _buildContactCard(
                      Icons.email_outlined,
                      'Email',
                      'support@example.com',
                      screenWidth,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildContactCard(
                      Icons.phone_outlined,
                      'Phone',
                      '+1 (123) 456-7890',
                      screenWidth,
                      isDark,
                    ),
                    const SizedBox(height: 32),
                    // Close button with gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: currentGradient,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: currentGradient.colors.first.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactCard(IconData icon, String title, String info, double screenWidth, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.getDefaultGradient(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Enhanced Sign In popup ---
  // --- Enhanced Sign In popup with modern design matching Contact Us popup ---
  void _showSignInPopup(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.85,
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600 ? screenWidth * 0.4 : screenWidth * 0.85,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  Colors.grey[900]!.withValues(alpha: 0.95),
                  Colors.grey[800]!.withValues(alpha: 0.95),
                ]
                    : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.grey[50]!.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with gradient matching Contact Us style
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => currentGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        'Sign In Required',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28 : 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info cards matching the contact card style
                    _buildSignInCard(
                      Icons.dashboard_outlined,
                      'Dashboard Access',
                      'Unlock personalized features and manage your account',
                      screenWidth,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildSignInCard(
                      Icons.security_outlined,
                      'Secure Authentication',
                      'Your data is protected with industry-standard security',
                      screenWidth,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildSignInCard(
                      Icons.person_outline,
                      'Personal Experience',
                      'Customized content and saved preferences',
                      screenWidth,
                      isDark,
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: currentGradient,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: currentGradient.colors.first.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                                Navigator.pushNamed(context, AppRoutes.signin);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.black.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Helper method to build sign-in info cards matching contact card style
  Widget _buildSignInCard(IconData icon, String title, String description, double screenWidth, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppTheme.getDefaultGradient(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double mobileBreakpoint = 850;

    final String? currentRouteName = ModalRoute.of(context)?.settings.name;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    // Modern navigation button builder
    Widget buildModernNavButton(String label, String buttonRouteName, {IconData? icon}) {
      final bool isActive = currentRouteName == buttonRouteName;
      final bool isHovered = _hoveredButton == buttonRouteName;

      return MouseRegion(
        onEnter: (_) => setState(() => _hoveredButton = buttonRouteName),
        onExit: (_) => setState(() => _hoveredButton = ''),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive ? currentGradient : null,
            color: isActive
                ? null
                : (isHovered
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent),
            borderRadius: BorderRadius.circular(25),
            border: isHovered && !isActive
                ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1)
                : null,
            boxShadow: isActive ? [
              BoxShadow(
                color: currentGradient.colors.first.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          child: TextButton(
            onPressed: () {
              if (buttonRouteName == AppRoutes.contact) {
                _showContactUsPopup(context);
              } else if (buttonRouteName == AppRoutes.dashboard) {
                if (AuthService.getCurrentUser() != null) {
                  Navigator.pushNamed(context, buttonRouteName);
                } else {
                  _showSignInPopup(context);
                }
              } else if (currentRouteName != buttonRouteName) {
                if (buttonRouteName == AppRoutes.home) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, buttonRouteName, (route) => false);
                } else {
                  Navigator.pushNamed(context, buttonRouteName);
                }
              }
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: _getModernTextStyle(context, isActive, isHovered, screenWidth),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Enhanced mobile menu item builder
    PopupMenuItem<String> buildModernMenuItem(String label, String routeName, {IconData? icon}) {
      final bool isActive = currentRouteName == routeName;
      final Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

      return PopupMenuItem<String>(
        value: routeName,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isActive ? currentGradient : null,
                    color: isActive ? null : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isActive ? Colors.white : textColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
            Colors.black.withValues(alpha: 0.8),
            Colors.black.withValues(alpha: 0.6),
          ]
              : [
            Colors.black.withValues(alpha: 0.7),
            Colors.black.withValues(alpha: 0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: screenWidth < mobileBreakpoint
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Enhanced hamburger menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.menu_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: isDark
                    ? Colors.grey[900]
                    : Colors.white,
                elevation: 20,
                onSelected: (String route) {
                  if (route == AppRoutes.contact) {
                    _showContactUsPopup(context);
                  } else if (route == AppRoutes.dashboard) {
                    if (AuthService.getCurrentUser() != null) {
                      Navigator.pushNamed(context, route);
                    } else {
                      _showSignInPopup(context);
                    }
                  } else if (currentRouteName != route) {
                    if (route == AppRoutes.home) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, route, (r) => false);
                    } else {
                      Navigator.pushNamed(context, route);
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  buildModernMenuItem('Home', AppRoutes.home, icon: Icons.home_outlined),
                  buildModernMenuItem('Product', AppRoutes.product_page, icon: Icons.shopping_bag_outlined),
                  buildModernMenuItem('Dashboard', AppRoutes.dashboard, icon: Icons.dashboard_outlined),
                  buildModernMenuItem('Sign In', AppRoutes.signin, icon: Icons.login_outlined),
                  buildModernMenuItem('Contact Us', AppRoutes.contact, icon: Icons.contact_support_outlined),
                ],
              ),
            ),
            // Enhanced theme toggle
            /*
            Container(
              decoration: BoxDecoration(
                gradient: currentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: currentGradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: widget.toggleTheme,
                tooltip: 'Toggle Theme',
              ),
            ),
            */
          ],
        )

            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildModernNavButton('Home', AppRoutes.home),
            buildModernNavButton('Product', AppRoutes.product_page),
            buildModernNavButton('Dashboard', AppRoutes.dashboard),
            buildModernNavButton('Sign In', AppRoutes.signin),
            buildModernNavButton('Contact Us', AppRoutes.contact),
            const SizedBox(width: 20),
            // Enhanced theme toggle for desktop
            /*
            Container(
              decoration: BoxDecoration(
                gradient: currentGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: currentGradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: widget.toggleTheme,
                tooltip: 'Toggle Theme',
              ),
            ),
             */
          ],
        ),
      ),
    );
  }
}