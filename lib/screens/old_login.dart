import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:google_sign_in_web/web_only.dart';
//import 'package:myapp/backend/google_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final fireStoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  String _status = "Checking login status...";
  //late AuthService auth;
  final GoogleSignInPlugin _plugin =
      GoogleSignInPlatform.instance as GoogleSignInPlugin;
  late UserCredential? tempCred;

  //final GoogleSignIn _gsi = GoogleSignIn(
  //clientId:
  //  '147037316014-k25n77jbig8j694mn3d8g3e2dma3vfin.apps.googleusercontent.com',
  //);
  //GoogleSignInAccount? _currentUser;
  GoogleSignInUserData? _userData;

  @override
  void initState() {
    super.initState();
    initPlugin();

    _plugin.userDataEvents?.listen((GoogleSignInUserData? userData) {
      setState(() {
        _userData = userData;
      });
    });

    /*
    _plugin.userDataEvents?.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        _status = _currentUser?.email ?? "Something is null...";
      });
      await _gsi.requestScopes(
          ['https://www.googleapis.com/auth/user.birthday.read']);
    });
    */
    //_gsi.signInSilently(); //super cool method for auto sign in
  }

  Future<void> initPlugin() async{
    await _plugin.initWithParams(const SignInInitParameters(
      clientId:
          '147037316014-k25n77jbig8j694mn3d8g3e2dma3vfin.apps.googleusercontent.com',
    ));
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
        child: isLoading
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
                  const SizedBox(height: 20),
                  renderButton(
                    configuration: GSIButtonConfiguration(
                      shape: GSIButtonShape.pill,
                      size: GSIButtonSize.medium,
                      logoAlignment: GSIButtonLogoAlignment.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.red, //red bc error text
                      //like "Sign-In Failed" or something
                    ),
                  ), // Show status (errors)
                ],
              ),
      ),
    );
  }
}
