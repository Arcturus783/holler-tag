import 'package:flutter/material.dart';
import 'package:myapp/elements/custom_button.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/elements/image_carousel.dart';
import 'package:myapp/screens/firebase_login.dart';
import 'dart:math' as math;
import 'package:myapp/screens/shopping.dart';
import 'package:myapp/elements/my_app_bar.dart';
import 'package:myapp/screens/product_page.dart'; // Your existing product (shopping) page
import 'package:myapp/backend/product.dart';
import 'package:myapp/qr_signup_page.dart';
import 'package:myapp/screens/dashboard_page.dart';
import 'package:myapp/backend/model_generation.dart';

// NEW IMPORT for the page that displays scanned product details
import 'package:myapp/screens/scanned_product_detail_page.dart'; // Create this file

// Define route constants for easy navigation
class AppRoutes {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String signin = '/signin';
  static const String product_page =
      '/product_page'; // This is your SHOPPING page
// static const String scanned_product_detail = '/products/:productId'; // Conceptual, handled by onGenerateRoute
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyDbpGqdo3YDfpcnoH6UXhDUbK7B7EvbmnY",
    // SECURITY RISK: THIS SHOULD BE SECURED!
    authDomain: "holler-tag.firebaseapp.com",
    projectId: "holler-tag",
    storageBucket: "holler-tag.firebasestorage.app",
    messagingSenderId: "147037316014",
    appId: "1:147037316014:web:4f8247a912242943155e3f",
  ));
  runApp(const MyApp());
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Holler Tag',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: AppRoutes.home,
      routes: {
// Your existing static routes for the application
        AppRoutes.home: (context) => HomePage(toggleTheme: _toggleTheme),
        AppRoutes.dashboard: (context) =>
            DashboardPage(toggleTheme: _toggleTheme),
        AppRoutes.signin: (context) =>
            FirebaseLoginPage(toggleTheme: _toggleTheme),
        AppRoutes.product_page: (context) =>
            ProductPage(toggleTheme: _toggleTheme) // This is your SHOPPING page
      },

// Use onGenerateRoute for dynamic routes (like /products/:productId from QR scan)
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name!);
        final pathSegments = uri.pathSegments;

// Handle the /products/:productId route for scanned QR codes
        if (pathSegments.length == 2 && pathSegments[0] == 'products') {
          final productId = pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => ScannedProductDetailPage(
              productId: productId,
            ),
            settings: settings, // Important for browser history and back button
          );
        }

// If no matching dynamic route is found, fall back to an error page or home
// IMPORTANT: For production, you might want to return a dedicated 404 page
// or redirect to a known route.
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(
              child: Text('Error: Page not found. Check the URL.'),
            ),
          ),
        );
      },
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme; // Receive toggleTheme callback from MyApp

  const HomePage({super.key, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

// IMPORTANT: This class contains the UI code for your HomePage
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

// Image lists for carousel, responsive to screen size and theme
  final List<String> _lightImageListLarge = [
    'assets/images/Neues-Macbook-Pro-hat-Power-und-Ports.jpg',
    'assets/images/apple-macbook-pro-13-3-side-uhd-4k-wallpaper.jpg',
    'assets/images/Neues-Macbook-Pro-hat-Power-und-Ports.jpg',
    'assets/images/apple-macbook-pro-13-3-side-uhd-4k-wallpaper.jpg',
  ];
  final List<String> _lightImageListSmall = [
    'assets/images/516QZcrv+dL.jpg',
    'assets/images/clouds.jpg',
    'assets/images/516QZcrv+dL.jpg',
    'assets/images/clouds.jpg',
  ];
  final List<String> _darkImageListLarge = [
    'assets/images/laptop.jpg',
    'assets/images/macbook-pro__catc3my4a336_og.png',
    'assets/images/laptop.jpg',
    'assets/images/macbook-pro__catc3my4a336_og.png',
    'assets/images/laptop.jpg',
    'assets/images/macbook-pro__catc3my4a336_og.png',
  ];
  final List<String> _darkImageListSmall = [
    'assets/images/dtech.jpg',
    'assets/images/smoke.jpg',
    'assets/images/dtech.jpg',
    'assets/images/smoke.jpg'
  ];

// Background images for the "Our Mission" section
  final String _lightBackgroundImage = 'assets/images/flowers.jpg';
  final String _darkBackgroundImage = 'assets/images/download (1).jpg';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

// Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
// Get media query data for responsive sizing
    MediaQueryData queryData = MediaQuery.of(context);
    double screenWidth = queryData.size.width;
    double screenHeight = queryData.size.height;
    double appBarHeight = kToolbarHeight;
// Calculate available vertical space for the carousel
    double availableHeightForCarousel = screenHeight - appBarHeight;

// Define responsive font sizes
    double titleFontSize = screenWidth < 600 ? 32.0 : 48.0;
    double subtitleFontSize = screenWidth < 600 ? 16.0 : 20.0;
    double missionTitleSize = screenWidth < 600 ? 28.0 : 36.0;
    double bodyTextSize = screenWidth < 600 ? 14.0 : 16.0;

// Select image list based on screen width and current theme
    List<String> imageUrlsToUse;
    if (Theme.of(context).brightness == Brightness.dark) {
      imageUrlsToUse =
          screenWidth >= 800 ? _darkImageListLarge : _darkImageListSmall;
    } else {
      imageUrlsToUse =
          screenWidth >= 800 ? _lightImageListLarge : _lightImageListSmall;
    }

// Select background image based on current theme
    final String currentBackgroundImage =
        Theme.of(context).brightness == Brightness.dark
            ? _darkBackgroundImage
            : _lightBackgroundImage;

// Get the current gradient from the app theme
    final currentGradient = AppTheme.getDefaultGradient(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
// Hero Section with enhanced overlay
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ImageCarousel(
                    imageUrls: imageUrlsToUse,
                    screenWidth: screenWidth,
                    maxHeight: availableHeightForCarousel,
                  ),
                ),
// Enhanced gradient overlay
                Container(
                  width: double.infinity,
                  height: availableHeightForCarousel,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
// Hero content with animations
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: availableHeightForCarousel > 0
                        ? availableHeightForCarousel * 0.5
                        : 200,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.08,
                            vertical: 40.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
// Brand title with enhanced typography
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) =>
                                    currentGradient.createShader(
                                  Rect.fromLTWH(
                                      0, 0, bounds.width, bounds.height),
                                ),
                                child: Text(
                                  "Holler Tag",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
// Subtitle with better typography
                              Text(
                                "Built for safety. Built to last.\nBuilt for you.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white.withValues(alpha: 0.95),
                                  height: 1.4,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 32),
// Enhanced button row
                              Wrap(
                                spacing: 16.0,
                                runSpacing: 12.0,
                                alignment: WrapAlignment.center,
                                children: [
// Register button with gradient background
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: currentGradient,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: currentGradient.colors.first
                                              .withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                        MaterialPageRoute(
                                          builder: (context) => const ScannedProductDetailPage(productId: "qXOsghS7Sx0uht6JcBby")
                                        ),
                                        );
                                        /*
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const QrTo3DApp(),
                                          ),
                                        );
                                         */
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              screenWidth < 600 ? 32 : 40,
                                          vertical: screenWidth < 600 ? 16 : 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        "Register",
                                        style: TextStyle(
                                          fontSize: subtitleFontSize * 0.9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
// Shop Now button with glass morphism effect
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      color:
                                          Colors.white.withValues(alpha: 0.1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, AppRoutes.product_page);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              screenWidth < 600 ? 32 : 40,
                                          vertical: screenWidth < 600 ? 16 : 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Text(
                                        "Shop Now",
                                        style: TextStyle(
                                          fontSize: subtitleFontSize * 0.9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
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
                  ),
                ),
              ],
            ),

// Mission Section with modern card design
            Container(
              margin: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: AssetImage(currentBackgroundImage),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        isDark
                            ? Colors.black.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.8),
                        BlendMode.overlay,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth < 600 ? 24.0 : 48.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: math.min(screenWidth * 0.8, 800.0),
                      ),
                      child: Column(
                        children: [
// Mission title with gradient
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) =>
                                currentGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              "Our Mission",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: missionTitleSize,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
// Mission content in cards
                          _buildMissionCard(
                            "Innovation & Safety",
                            "We're committed to creating products that prioritize your safety without compromising on innovation. Every Holler Tag is designed with cutting-edge technology to protect what matters most.",
                            bodyTextSize,
                            isDark,
                          ),
                          const SizedBox(height: 20),
                          _buildMissionCard(
                            "Built to Last",
                            "Durability is at the core of our design philosophy. Our products are engineered to withstand the test of time, ensuring reliable performance when you need it most.",
                            bodyTextSize,
                            isDark,
                          ),
                          const SizedBox(height: 20),
                          _buildMissionCard(
                            "Personalized Experience",
                            "We understand that every user is unique. That's why we've built our platform to adapt to your specific needs, providing a truly personalized experience that grows with you.",
                            bodyTextSize,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(
      String title, String content, double fontSize, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: fontSize,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
