import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/elements/custom_button.dart';
import 'package:myapp/screens/old_login.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/elements/image_carousel.dart';
import 'package:myapp/screens/firebase_login.dart';
//import 'package:myapp/qr_signup_page.dart';

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
  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    double screenWidth = queryData.size.width;
    //double screenHeight = queryData.size.height;
    double desiredAspectRatio = 16 / 9; // Same as in ImageCarousel
    double carouselHeight = screenWidth / desiredAspectRatio;

    // Base sizes for different screen heights (you can adjust these)
    double baseTitleFontSize = 25.0;
    double baseSubtitleFontSize = 15.0;
    double baseButtonPaddingVertical = 10.0;
    double baseButtonPaddingHorizontal = 20.0;

    // Calculate scaling factor based on carousel height relative to a base height (e.g., 200)
    double baseCarouselHeight = 200.0;
    double scaleFactor = carouselHeight / baseCarouselHeight;
    if (scaleFactor < 0.8) scaleFactor = 0.8; // Minimum scale
    if (scaleFactor > 1.2) scaleFactor = 1.2; // Maximum scale

    // Apply scaling to sizes
    double titleFontSize = baseTitleFontSize * scaleFactor;
    double subtitleFontSize = baseSubtitleFontSize * scaleFactor;
    double buttonPaddingVertical = baseButtonPaddingVertical * scaleFactor;
    double buttonPaddingHorizontal = baseButtonPaddingHorizontal * scaleFactor;

    List<String> imageList = [
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
      'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 50,
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          CustomButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FirebaseLoginPage()),
              );
            },
            child: Text('sign in',
                style: TextStyle(
                    fontSize:
                        subtitleFontSize)), // Scale sign in button text as well
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  // Wrap ImageCarousel with full height
                  height: carouselHeight,
                  width: double.infinity,
                  child: ImageCarousel(
                    imageUrls: imageList,
                    screenWidth: screenWidth,
                  ),
                ),
                Positioned(
                  // Title Block
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: carouselHeight * 0.4,
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
                                child: CustomButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const FirebaseLoginPage(),
                                      ),
                                    );
                                  },
                                  child: Text("Register",
                                      style: TextStyle(
                                          fontSize: subtitleFontSize)),
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
          ],
        ),
      ),
    );
  }
}
