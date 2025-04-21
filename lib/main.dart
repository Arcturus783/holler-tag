import 'package:flutter/material.dart';
import 'package:myapp/elements/custom_button.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/elements/image_carousel.dart';
import 'package:myapp/screens/firebase_login.dart'; // Import needed for route definition
import 'dart:math' as math;
import 'package:myapp/screens/shopping.dart'; // Import needed for route definition
import 'package:myapp/elements/my_app_bar.dart'; // Import the reusable AppBar
import 'package:myapp/screens/product_page.dart';
import 'package:myapp/backend/product.dart';
import 'package:myapp/qr_signup_page.dart';
import 'package:myapp/goofy_ahh_renderer.dart';
//import 'package:google_fonts/google_fonts.dart';

// Define route constants (optional but recommended)
class AppRoutes {
  static const String home = '/';
  // static const String reviews = '/reviews'; // Uncomment when ready
  //static const String product = '/product';
  // static const String dashboard = '/dashboard'; // Uncomment when ready
  static const String signin = '/signin';
  static const String product_page = '/productPage';
  // static const String qr = '/qr'
  // static const String contact = '/contact'; // Uncomment when ready
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //move api keys eventually
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyDbpGqdo3YDfpcnoH6UXhDUbK7B7EvbmnY", // SECURITY RISK
    authDomain: "holler-tag.firebaseapp.com",
    projectId: "holler-tag",
    storageBucket: "holler-tag.firebasestorage.app",
    messagingSenderId: "147037316014",
    appId: "1:147037316014:web:4f8247a912242943155e3f",
  ));
  runApp(const MyApp());
  
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Start with system default

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
      theme: AppTheme.lightTheme, // Define your light theme
      darkTheme: AppTheme.darkTheme, // Define your dark theme
      themeMode: _themeMode,

      initialRoute: AppRoutes.home, // Use constant
      routes: {
        // Pass _toggleTheme during route creation
        AppRoutes.home: (context) => HomePage(toggleTheme: _toggleTheme),
        // AppRoutes.reviews: (context) => ReviewsPage(toggleTheme: _toggleTheme), // Uncomment when ReviewsPage exists
        //AppRoutes.product: (context) => ShoppingPage(toggleTheme: _toggleTheme),
        // AppRoutes.dashboard: (context) => DashboardPage(toggleTheme: _toggleTheme), // Uncomment when DashboardPage exists
        AppRoutes.signin: (context) =>
            FirebaseLoginPage(toggleTheme: _toggleTheme),
        AppRoutes.product_page: (context) => ProductPage(toggleTheme: _toggleTheme)
      },
      // home: HomePage(toggleTheme: _toggleTheme), // Remove 'home' if using initialRoute
    );
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const HomePage({super.key, required this.toggleTheme});
  //const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//IMPORTANT
//vvv  |Write your UI code in this class| vvv

class _HomePageState extends State<HomePage> {
  final List<String> imageListLarge = [
    'assets/images/laptop.jpg',
    'assets/images/laptop.jpg',
    'assets/images/laptop.jpg',
    'assets/images/laptop.jpg',
    'assets/images/laptop.jpg',
  ];
  final List<String> imageListSmall = [
    'assets/images/516QZcrv+dL.jpg', // Replace with your small screen images
    'assets/images/516QZcrv+dL.jpg',
    'assets/images/516QZcrv+dL.jpg',
    'assets/images/516QZcrv+dL.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    double screenWidth = queryData.size.width;
    double screenHeight = queryData.size.height;
    // double appBarHeight = AppBar().preferredSize.height; // Already calculated by MyAppBar preferredSize
    // Use kToolbarHeight if needed directly, or access AppBar().preferredSize.height
    double appBarHeight = kToolbarHeight;
    double availableHeightForCarousel = screenHeight - appBarHeight;

    // Base sizes for different screen heights (you can adjust these)
    double baseTitleFontSize = 25.0;
    double baseSubtitleFontSize = 15.0;
    double baseButtonPaddingVertical = 10.0;
    double baseButtonPaddingHorizontal = 20.0;

    // Calculate scaling factor based on available height
    double baseCarouselHeight = 200.0; // Adjust base height as needed
    // Ensure availableHeightForCarousel isn't negative or zero if screenHeight is small
    double scaleFactor = availableHeightForCarousel > 0
        ? availableHeightForCarousel / baseCarouselHeight
        : 1.0;
    if (scaleFactor < 0.8) scaleFactor = 0.8; // Minimum scale
    if (scaleFactor > 1.2) scaleFactor = 1.2; // Maximum scale

    // Apply scaling to sizes
    double titleFontSize = baseTitleFontSize * scaleFactor;
    double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    double buttonPaddingVertical = baseButtonPaddingVertical * scaleFactor;
    double buttonPaddingHorizontal = baseButtonPaddingHorizontal * scaleFactor;

    // Determine which image list to use based on screen width
    List<String> imageUrlsToUse;
    if (screenWidth >= 800) {
      imageUrlsToUse = imageListLarge;
    } else {
      imageUrlsToUse = imageListSmall;
    }

    final currentGradient = AppTheme.getDefaultGradient(context);
    final gradientStartColor = currentGradient.colors.first;

    return Scaffold(
      // Use the reusable AppBar, passing the toggleTheme function from the widget property
      appBar: MyAppBar(toggleTheme: widget.toggleTheme),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                Positioned(
                  // Title Block
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    // Ensure height isn't negative
                    height: availableHeightForCarousel > 0
                        ? availableHeightForCarousel * 0.4
                        : 100, // Adjust height based on available height, provide fallback
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        IgnorePointer(
                          ignoring: true,
                          child: Container(
                            width: double.infinity,
                            color: Colors.transparent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Holler Tag",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  // Optionally add color from theme if needed
                                  // color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                "Built for safety. Built to last.\nBuilt for you.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  // Optionally add color from theme if needed
                                  // color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: buttonPaddingVertical,
                                  horizontal: buttonPaddingHorizontal,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomButton(
                                      // Original Register button -> Navigates to Sign In
                                      onPressed: () {
                                        // Use named route consistent with MaterialApp setup
                                        Navigator.pushNamed(
                                            context, AppRoutes.signin);
                                      },
                                      child: Text("Register",
                                          style: TextStyle(
                                              fontSize: subtitleFontSize)),
                                    ),
                                    const SizedBox(width: 10.0),
                                    ElevatedButton(
                                      // Inverted button -> Navigates to Product/Shopping
                                      onPressed: () {
                                        // Use named route consistent with MaterialApp setup
                                        Navigator.pushNamed(
                                            context, AppRoutes.product_page);
                                      },
                                      // Removed onHover as it wasn't doing anything
                                      style: ButtonStyle(
                                        shadowColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.transparent),
                                        foregroundColor: WidgetStateProperty
                                            .resolveWith<Color>(
                                                (Set<WidgetState> states) {
                                          return gradientStartColor;
                                        }),
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.transparent),
                                        side: WidgetStateProperty.resolveWith<
                                            BorderSide>(
                                          (Set<WidgetState> states) {
                                            return BorderSide(
                                              color: gradientStartColor,
                                              width: 2.5,
                                            );
                                          },
                                        ),
                                      ),
                                      child: ShaderMask(
                                        // Renamed button text for clarity
                                        blendMode: BlendMode.srcIn,
                                        shaderCallback: (bounds) =>
                                            currentGradient.createShader(
                                          Rect.fromLTWH(0, 0, bounds.width,
                                              bounds.height),
                                        ),
                                        child: Text("Shop Now", // Changed text
                                            style: TextStyle(
                                                fontSize: subtitleFontSize,
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              // Filler Paragraphs with Background Image
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(// Added const
                        'assets/images/download (1).jpg'), // Replace with your image path
                    fit: BoxFit.cover,
                    // Optional: Add color filter for better text readability
                    // colorFilter: ColorFilter.mode(
                    //   Colors.black.withOpacity(0.5), // Adjust opacity
                    //   BlendMode.darken,
                    // ),
                  ),
                  borderRadius: BorderRadius.circular(
                      8.0), // Optional: Add rounded corners
                ),
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: math.min(screenWidth * (2 / 3), 800.0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          // Use const if text is static
                          "Our Mission",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: subtitleFontSize * 1.5,
                            fontWeight: FontWeight.bold,
                            // Ensure text color contrasts with background image
                            // color: Colors.white, // Example if background is dark
                          ),
                        ),
                        const SizedBox(height: 10.0), // Use const
                        Text(
                          // Use const if text is static
                          textAlign: TextAlign.center,
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                          style: TextStyle(
                            fontSize: subtitleFontSize * 1,
                            // Ensure text color contrasts with background image
                            // color: Colors.white70, // Example
                          ),
                        ),
                        const SizedBox(height: 10.0), // Use const
                        Text(
                          // Use const if text is static
                          textAlign: TextAlign.center,
                          "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                          style: TextStyle(
                            fontSize: subtitleFontSize * 1,
                            // Ensure text color contrasts with background image
                            // color: Colors.white70, // Example
                          ),
                        ),
                        const SizedBox(height: 10.0), // Use const
                        Text(
                          // Use const if text is static
                          textAlign: TextAlign.center,
                          "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
                          style: TextStyle(
                            fontSize: subtitleFontSize * 1,
                            // Ensure text color contrasts with background image
                            // color: Colors.white70, // Example
                          ),
                        ),
                        const SizedBox(height: 10.0), // Use const
                        Text(
                          // Use const if text is static
                          textAlign: TextAlign.center,
                          "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
                          style: TextStyle(
                            fontSize: subtitleFontSize * 1,
                            // Ensure text color contrasts with background image
                            // color: Colors.white70, // Example
                          ),
                        ),
                      ],
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
}
