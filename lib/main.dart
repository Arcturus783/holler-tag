import 'package:flutter/material.dart';
import 'package:myapp/elements/custom_button.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/elements/image_carousel.dart';
import 'package:myapp/screens/firebase_login.dart';
import 'dart:math' as math;
import 'package:myapp/screens/shopping.dart';
//import 'package:myapp/qr_signup_page.dart';
//import 'package:google_fonts/google_fonts.dart';

void main() async {
  //runApp(QrTo3DApp()); //use this to test qr code thing

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: "AIzaSyDbpGqdo3YDfpcnoH6UXhDUbK7B7EvbmnY",
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
      themeMode: _themeMode, // Use the managed theme mode
      home: HomePage(toggleTheme: _toggleTheme), // Pass the toggle function
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
    // double desiredAspectRatio = 16 / 9; // No longer needed here
    // double desiredCarouselHeight = screenWidth / desiredAspectRatio; // No longer needed here
    double appBarHeight =
        AppBar().preferredSize.height; // Get AppBar height properly
    double availableHeightForCarousel = screenHeight - appBarHeight;

    // Ensure carousel height doesn't exceed available screen height
    // double carouselHeight = desiredCarouselHeight > availableHeightForCarousel
    //     ? availableHeightForCarousel
    //     : desiredCarouselHeight; // No longer needed here

    // Base sizes for different screen heights (you can adjust these)
    double baseTitleFontSize = 25.0;
    double baseSubtitleFontSize = 15.0;
    double baseButtonPaddingVertical = 10.0;
    double baseButtonPaddingHorizontal = 20.0;

    // Calculate scaling factor based on carousel height relative to a base height (e.g., 200)
    double baseCarouselHeight = 200.0;
    double scaleFactor = availableHeightForCarousel /
        baseCarouselHeight; // Use available height for scaling
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 50,
        actions: [
          Padding(
            // Add right padding to the theme toggle button
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: widget.toggleTheme,
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ),
          Padding(
            // Add right padding to the sign-in button
            padding: const EdgeInsets.only(right: 16.0),
            child: CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirebaseLoginPage()),
                );
              },
              child:
                  Text('sign in', style: TextStyle(fontSize: subtitleFontSize)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  // Removed fixed height
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
                    height: availableHeightForCarousel *
                        0.4, // Adjust height based on available height
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        IgnorePointer(
                          // Add IgnorePointer to the transparent background
                          ignoring: true,
                          child: Container(
                            width: double.infinity,
                            color: Colors.transparent,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Holler Tag",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Built for safety. Built to last.\nBuilt for you.",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: subtitleFontSize),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: buttonPaddingVertical,
                                  horizontal: buttonPaddingHorizontal,
                                ),
                                child: Row(
                                  // Wrap buttons in a Row
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomButton(
                                      // Original Register button
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const FirebaseLoginPage()),
                                        );
                                      },
                                      child: Text("Register",
                                          style: TextStyle(
                                              fontSize: subtitleFontSize)),
                                    ),
                                    SizedBox(
                                        width:
                                            10.0), // Add some space between the buttons
                                    ElevatedButton(
                                      // Inverted Register button
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const FirebaseLoginPage()),
                                        );
                                      },
                                      onHover: (hover) {
                                        if (hover) {
                                        } else {}
                                      },
                                      style: ButtonStyle(
                                        shadowColor:
                                            WidgetStateProperty.all<Color>(
                                                Colors.transparent),
                                        foregroundColor: WidgetStateProperty
                                            .resolveWith<Color>(
                                                (Set<WidgetState> states) {
                                          return gradientStartColor; // Use the start color of the gradient for simplicity on the outline
                                        }),
                                        backgroundColor: WidgetStateProperty
                                            .all<Color>(Colors
                                                .transparent), // Transparent background
                                        side: WidgetStateProperty.resolveWith<
                                                BorderSide>(
                                            (Set<WidgetState> states) {
                                          return BorderSide(
                                            color:
                                                gradientStartColor, // Use the start color of the gradient for simplicity on the outline
                                            width:
                                                2.5, // Adjust width as needed
                                          );
                                        }),
                                      ),
                                      child: ShaderMask(
                                        blendMode: BlendMode.srcIn,
                                        shaderCallback: (bounds) =>
                                            currentGradient.createShader(
                                          Rect.fromLTWH(0, 0, bounds.width,
                                              bounds.height),
                                        ),
                                        child: Text("something",
                                            style: TextStyle(
                                                fontSize: subtitleFontSize,
                                                color: Colors
                                                    .white)), // Keep color white as the shader will apply the gradient
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
                    image: AssetImage(
                        'assets/images/download (1).jpg'), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.all(
                    16.0), // Add padding inside the container for the text
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    // Use ConstrainedBox instead of SizedBox
                    constraints: BoxConstraints(
                        maxWidth: math.min(screenWidth * (2 / 3),
                            800.0)), // Set maximum width to 2/3 of screen width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Center the text within the limited width
                      children: [
                        Text(
                          textAlign: TextAlign.center,
                          "Our Mission",
                          style: TextStyle(
                            fontSize: subtitleFontSize * 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          textAlign: TextAlign.center,
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                          style: TextStyle(fontSize: subtitleFontSize * 1),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          textAlign: TextAlign.center,
                          "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                          style: TextStyle(fontSize: subtitleFontSize * 1),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          textAlign: TextAlign.center,
                          "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.",
                          style: TextStyle(fontSize: subtitleFontSize * 1),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          textAlign: TextAlign.center,
                          "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.",
                          style: TextStyle(fontSize: subtitleFontSize * 1),
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
