import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseLoginPage extends StatefulWidget {
  const FirebaseLoginPage({super.key});
  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage> {
  UserCredential? userCred; // Initialize as nullable, no late keyword
  String _status = "Nothing yet...";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('https://www.googleapis.com/auth/userinfo.email');
      googleProvider
          .addScope('https://www.googleapis.com/auth/userinfo.profile');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      userCred = await _auth.signInWithPopup(googleProvider);
      setState(() {
        _status = userCred?.user?.email ?? "No email found";
      });
    } catch (e) {
      // Handle the error and update state
      setState(() {
        _status = "Error: ${e.toString()}";
      });
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.login_rounded),
              onPressed: () async {
                await signInWithGoogle();
              },
            ),
            const SizedBox(height: 20),
            Text(_status,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                )),
          ],
        ),
      ),
    );
  }
}
