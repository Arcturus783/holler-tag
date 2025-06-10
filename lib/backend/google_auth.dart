/*
IMPORTANT

This is based on a deprecated method for google
sign in. We will eventually delete it, but I want it around
for now as a reference.
*/

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '147037316014-k25n77jbig8j694mn3d8g3e2dma3vfin.apps.googleusercontent.com', // Only needed for web
    scopes: [
      'email',
      'profile',
    ],
  );

  static Future<UserCredential?> signInWithGoogle() async {
    //bool isAuthorized = await _googleSignIn.canAccessScopes(["email", "profile"]);

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If sign in was aborted or failed
      if (googleUser == null) {
        print('Sign in aborted by user or failed');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Store user in Firestore if it's a new user
      //await _storeUserInFirestore(userCredential.user!);

      return userCredential;
    } catch (e) {
      print('Error during Google sign in: $e');
      return null;
    }
  }

  /*
  // Method to store user in Firestore
  Future<void> _storeUserInFirestore(User user) async {
    // Reference to the user document
    final userDoc = _firestore.collection('users').doc(user.uid);
    
    // Check if the user document already exists
    final docSnapshot = await userDoc.get();
    
    if (!docSnapshot.exists) {
      // Create new user document if it doesn't exist
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
      
      // You could also create initial sub-collections or documents for the user here
      await userDoc.collection('userData').doc('initial').set({
        'createdAt': FieldValue.serverTimestamp(),
        'sampleData': 'This is a sample document for the new user',
      });
    } else {
      // Update the last login timestamp for existing users
      await userDoc.update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }
  */

  // Sign out method
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}


/*

Implementation:
                  CustomButton(
                    onPressed: () async {
                      try {
                        tempCred = await auth.signInWithGoogle();
                        if (tempCred == null) {
                          throw ("UserCred is null.");
                        }
                        setState(() {
                          _status =
                              "User name: ${tempCred?.user?.displayName ?? "not found"}";
                        });
                      } catch (e) {
                        setState(() {
                          _status = e.toString();
                          //_status = "There was a problem signing in.\nPlease try again or contact support if the issue continues.";
                        });
                      }
                    },
                    child: const Text("Sign in with Google"),
                  ),
*/