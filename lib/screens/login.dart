import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/elements/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final fireStoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  String _status = "Checking login status...";

  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        _status = "Starting Google sign-in popup...";
      });
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);


      final User? user = userCredential.user;
      if (user != null) {
        setState(() {
          _status = "Signed in as: ${user.displayName}";
        });
        //User ID: user.uid
        //next send to contact info page
      } else {
        setState(() {
          _status = "User is null";
        });
        //ask user to try again
      }
    } catch (e) {
      setState(() {
        _status = "Error during sign-in: $e";
      });
      //if there's an error, ask user to try again
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 50,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_max_sharp),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(_status), // Show status for debugging
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      FirebaseAuth.instance.currentUser?.email ??
                          "Not signed in",
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onPressed: () {
                        // Don't navigate away immediately after starting sign-in
                        signInWithGoogle();
                      },
                      child: const Text("Sign in with Google"),
                    ),
                    const SizedBox(height: 20),
                    Text(_status), // Show status for debugging
                  ],
                ),
      ),
    );
  }
}
