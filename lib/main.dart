import 'package:myapp/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:myapp/elements/custom_button.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/elements/image_carousel.dart';
//import 'package:myapp/qr_signup_page.dart';

void main() async {
  //runApp(QrTo3DApp()); //use this to test qr code thing

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    //double w = queryData.size.width;
    double h = queryData.size.height;

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
        backgroundColor: ThemeData().primaryColor,
        toolbarHeight: 50,
        actions: [
          IconButton(
            onPressed: widget.toggleTheme, // Use the passed toggle function
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
          CustomButton(
            onPressed: () {
              //open log in page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('sign in'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: h * 0.8,
                  decoration: BoxDecoration(
                      //gradient: AppTheme.getDefaultGradient(context),
                      ),
                ),
                Positioned(
                  top: h * 0.1,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Holler Tag",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Built for safety. Built to last.\nBuilt for you.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                        child: CustomButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          }, //for now
                          child: const Text("Register"),
                        ),
                      ),
                      SizedBox(
                        height: h * 0.4,
                        width: h * 0.4,
                        child: ImageCarousel(
                          imageUrls: imageList,
                        ) /* Image.network(
                          'https://9to5toys.com/wp-content/uploads/sites/5/2020/11/macbook-air-202o-m1.jpg',
                        ),*/
                        ,
                      ),
                    ],
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

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        // Find the closest ancestor of _MyAppState and call its _toggleTheme method.
        context.findAncestorStateOfType<_MyAppState>()?._toggleTheme();
      },
    );
  }
}
