import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/elements/my_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class FirebaseLoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const FirebaseLoginPage({super.key, required this.toggleTheme});

  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage> with SingleTickerProviderStateMixin {
  UserCredential? userCred;
  String _status = "Not signed in.";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _status = "Signing in...";
    });
    
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      userCred = await _auth.signInWithPopup(googleProvider);
      setState(() {
        _status = "Signed in as: ${userCred?.user?.email ?? "No email found"}";
      });
    } catch (e) {
      setState(() {
        _status = "Sign-in Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MyAppBar(toggleTheme: widget.toggleTheme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      colorScheme.surface,
                      colorScheme.surface.withOpacity(0.8),
                    ]
                  : [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.1),
                    ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 40),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 60,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Welcome Back",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Sign in to continue",
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: colorScheme.shadow.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton.icon(
                                    icon: const Icon(Icons.login),
                                    label: const Text("Sign In with Google"),
                                    onPressed: signInWithGoogle,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: colorScheme.onPrimary,
                                      backgroundColor: colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 2,
                                    ),
                                  ),
                            const SizedBox(height: 24),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _status.startsWith("Sign-in Error")
                                    ? colorScheme.error.withOpacity(0.1)
                                    : _status.startsWith("Signed in")
                                        ? colorScheme.primary.withOpacity(0.1)
                                        : colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _status.startsWith("Sign-in Error")
                                      ? colorScheme.error
                                      : _status.startsWith("Signed in")
                                          ? colorScheme.primary
                                          : colorScheme.outline.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _status.startsWith("Sign-in Error")
                                        ? Icons.error_outline
                                        : _status.startsWith("Signed in")
                                            ? Icons.check_circle_outline
                                            : Icons.info_outline,
                                    color: _status.startsWith("Sign-in Error")
                                        ? colorScheme.error
                                        : _status.startsWith("Signed in")
                                            ? colorScheme.primary
                                            : colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _status,
                                      style: TextStyle(
                                        color: _status.startsWith("Sign-in Error")
                                            ? colorScheme.error
                                            : _status.startsWith("Signed in")
                                                ? colorScheme.primary
                                                : colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/*
// firebase_login.dart (Corrected)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/elements/my_app_bar.dart'; // Import the reusable AppBar

class FirebaseLoginPage extends StatefulWidget {
  final VoidCallback toggleTheme; // Add parameter to receive the function

  const FirebaseLoginPage({super.key, required this.toggleTheme}); // Update constructor

  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage> {
  UserCredential? userCred;
  String _status = "Not signed in."; // Initial status
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Keep initState if needed, though it's empty now
  @override
  void initState() {
    super.initState();
  }

  // Keep signInWithGoogle function
  Future<void> signInWithGoogle() async {
     // ... (your existing sign-in logic) ...
     try {
       GoogleAuthProvider googleProvider = GoogleAuthProvider();
       // scopes are often default, but keep if needed
       // googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
       // googleProvider.addScope('https://www.googleapis.com/auth/userinfo.profile');
       // googleProvider.setCustomParameters({'login_hint': 'user@example.com'}); // Optional

       // Prefer signInWithPopup for web, consider platform checks for mobile
       userCred = await _auth.signInWithPopup(googleProvider);
       setState(() {
         _status = "Signed in as: ${userCred?.user?.email ?? "No email found"}";
       });
     } catch (e) {
       setState(() {
         _status = "Sign-in Error: ${e.toString()}";
       });
     }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the reusable AppBar, passing the toggleTheme function received from the parent
      appBar: MyAppBar(toggleTheme: widget.toggleTheme), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Sign In With Google"), // Add a label
            const SizedBox(height: 20),
            ElevatedButton.icon( // Use a more standard button
              icon: const Icon(Icons.login), // Use a generic login icon or Google logo
              label: const Text("Sign In"),
              onPressed: signInWithGoogle, // Call the async function directly
            ),
            const SizedBox(height: 20),
            Padding( // Add padding for status text
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                 _status,
                 textAlign: TextAlign.center, // Center align if status is long
                 // Use theme text color instead of hardcoded red
                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                     color: _status.startsWith("Error") || _status.startsWith("Sign-in Error")
                          ? Theme.of(context).colorScheme.error // Use theme error color
                          : null // Use default text color otherwise
                 ),
               ),
            ),
          ],
        ),
      ),
    );
  }
}
*/