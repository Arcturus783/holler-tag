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