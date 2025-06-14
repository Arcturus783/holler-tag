import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

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