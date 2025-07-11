import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/elements/my_app_bar.dart';
import 'package:myapp/elements/app_theme.dart';
import 'package:myapp/backend/google_auth.dart';

class FirebaseLoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const FirebaseLoginPage({super.key, required this.toggleTheme});

  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage>
    with TickerProviderStateMixin {
  UserCredential? userCred;
  String _status = "Ready to sign in";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _showEmailForm = false;
  bool _isSignUp = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Email form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  Future<bool> userDocumentExists(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      return userDoc.exists;
    } catch (e) {
      print("Error checking document existence: $e");
      return false;
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _status = "Signing in with Google...";
    });

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      userCred = await _auth.signInWithPopup(googleProvider);
      setState(() {
        _status = "Successfully signed in!";
        _isLoading = false;
      });

      bool exists = await userDocumentExists(userCred!.user!.uid);
      if (!exists) {
        final Map<String, dynamic> userData = {
          "email": userCred!.user!.email,
          "pets": [],
          "provider": "google"
        };
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred!.user!.uid)
            .set(userData);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = "Sign-in failed. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _status = _isSignUp ? "Creating your account..." : "Signing you in...";
    });

    try {
      if (_isSignUp) {
        userCred = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCred?.user != null && _fullNameController.text.trim().isNotEmpty) {
          await userCred!.user!.updateDisplayName(_fullNameController.text.trim());
          await userCred!.user!.reload();
        }

        final Map<String, dynamic> userData = {
          "email": userCred!.user!.email,
          "pets": [],
          "provider": "email"
        };
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred!.user!.uid)
            .set(userData);

        if (userCred?.user != null && !userCred!.user!.emailVerified) {
          await userCred!.user!.sendEmailVerification();
          setState(() {
            _status = "Account created! Please verify your email address.";
          });
        } else {
          setState(() {
            _status = "Account created successfully!";
          });
        }
      } else {
        userCred = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCred?.user != null && !userCred!.user!.emailVerified) {
          setState(() {
            _status = "Please verify your email address first.";
          });
        } else {
          setState(() {
            _status = "Successfully signed in!";
          });
        }
      }

      _clearForm();
      setState(() {
        _showEmailForm = false;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _status = _getFirebaseErrorMessage(e);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = "An error occurred. Please try again.";
      });
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _fullNameController.clear();
  }

  Future<void> resendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _status = "Verification email sent successfully!";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Failed to send verification email.";
      });
    }
  }

  Future<void> resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _status = "Please enter your email address first.";
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _status = "Password reset email sent!";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _status = _getFirebaseErrorMessage(e);
      });
    }
  }

  void _toggleEmailForm() {
    setState(() {
      _showEmailForm = !_showEmailForm;
      if (!_showEmailForm) {
        _isSignUp = false;
        _clearForm();
      }
    });
  }

  void _toggleSignUpMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _confirmPasswordController.clear();
      _fullNameController.clear();
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.02),
        labelStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.7)
              : Colors.black.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.black.withValues(alpha: 0.4),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: currentGradient.colors.first,
            width: 2.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildEmailForm() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _showEmailForm
          ? Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
              Colors.grey[800]!.withValues(alpha: 0.95),
              Colors.grey[700]!.withValues(alpha: 0.95),
            ]
                : [
              Colors.white.withValues(alpha: 0.95),
              Colors.grey[50]!.withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: currentGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: currentGradient.colors.first.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isSignUp ? Icons.person_add : Icons.email,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isSignUp ? "Create New Account" : "Sign In with Email",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleEmailForm,
                    icon: const Icon(Icons.close),
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.6),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_isSignUp) ...[
                _buildTextField(
                  controller: _fullNameController,
                  label: "Full Name",
                  hint: "Enter your full name",
                  icon: Icons.person_outlined,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter your full name";
                    }
                    if (value.trim().length < 2) {
                      return "Name must be at least 2 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              _buildTextField(
                controller: _emailController,
                label: "Email Address",
                hint: "Enter your email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                label: "Password",
                hint: "Enter your password",
                icon: Icons.lock_outlined,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your password";
                  }
                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),
              if (_isSignUp) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  hint: "Confirm your password",
                  icon: Icons.lock_outlined,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (value != _passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: currentGradient,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: currentGradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : signInWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isSignUp ? "Create Account" : "Sign In",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_isSignUp) ...[
                TextButton(
                  onPressed: resetPassword,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: currentGradient.colors.first,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextButton(
                onPressed: _toggleSignUpMode,
                child: Text(
                  _isSignUp
                      ? "Already have an account? Sign In"
                      : "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: currentGradient.colors.first,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildStatusCard() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isError = _status.contains("failed") || _status.contains("error") || _status.contains("Error");
    final bool isSuccess = _status.contains("Successfully") || _status.contains("created");

    Color cardColor;
    Color iconColor;
    IconData iconData;

    if (isError) {
      cardColor = Colors.red;
      iconColor = Colors.red;
      iconData = Icons.error_outline;
    } else if (isSuccess) {
      cardColor = Colors.green;
      iconColor = Colors.green;
      iconData = Icons.check_circle_outline;
    } else {
      cardColor = Colors.blue;
      iconColor = Colors.blue;
      iconData = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _status,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.black.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: MyAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ]
                : [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                margin: const EdgeInsets.all(20),
                child: AuthService.getCurrentUser() != null
                    ? _buildSignedInView()
                    : _buildSignInView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignedInView() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.grey[850]!.withValues(alpha: 0.95),
            Colors.grey[800]!.withValues(alpha: 0.95),
          ]
              : [
            Colors.white.withValues(alpha: 0.95),
            Colors.grey[50]!.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: currentGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: currentGradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Welcome back!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AuthService.getCurrentUser()!.displayName ??
                AuthService.getCurrentUser()!.email ??
                "User",
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.8)
                  : Colors.black.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red, Colors.red.shade700],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  await _auth.signOut();
                  setState(() {
                    userCred = null;
                    _status = "Signed out successfully";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Sign Out",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (AuthService.getCurrentUser() != null && !AuthService.getCurrentUser()!.emailVerified) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Email verification required",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: resendVerificationEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Resend Verification Email",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSignInView() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final currentGradient = AppTheme.getDefaultGradient(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              gradient: currentGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: currentGradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to HollerTag",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to manage your pet tags",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Sign in options
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                  Colors.grey[850]!.withValues(alpha: 0.95),
                  Colors.grey[800]!.withValues(alpha: 0.95),
                ]
                    : [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.grey[50]!.withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Google Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: currentGradient,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: currentGradient.colors.first.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading && !_showEmailForm
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Sign In with Google",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.black.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Email Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _toggleEmailForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: currentGradient.colors.first,
                      side: BorderSide(
                        color: currentGradient.colors.first,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showEmailForm ? Icons.visibility_off : Icons.email,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _showEmailForm ? "Hide Email Form" : "Sign In with Email",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Email form
                _buildEmailForm(),

                const SizedBox(height: 24),

                // Status card
                _buildStatusCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}