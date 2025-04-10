import 'package:flutter/material.dart';
import 'package:myapp/elements/custom_button.dart';
import 'package:myapp/elements/app_theme.dart';

class Shopping extends StatefulWidget {
  const Shopping({super.key});

  @override
  State<Shopping> createState() => _ShoppingState();
}

class _ShoppingState extends State<Shopping> {
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
      home: ShoppingPage(toggleTheme: _toggleTheme), // Pass the toggle function
    );
  }
}

class ShoppingPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const ShoppingPage({super.key, required this.toggleTheme});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

//IMPORTANT
//vvv  |Write your UI code in this class| vvv

class _ShoppingPageState extends State<ShoppingPage> {
  int _crossAxisCount(BuildContext context, double width){
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    double screenWidth = queryData.size.width;
    double screenHeight = queryData.size.height;
    double appBarHeight =
        AppBar().preferredSize.height; // Get AppBar height properly

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
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirebaseLoginPage()),
                );
                */
              },
              child:
                  Text('Something', style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        
      ),
    );
  }
}
