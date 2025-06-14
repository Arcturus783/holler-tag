import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/elements/my_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/backend/google_auth.dart';

class FirebaseLoginPage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const FirebaseLoginPage({super.key, required this.toggleTheme});

  @override
  State<FirebaseLoginPage> createState() => _FirebaseLoginPageState();
}

class _FirebaseLoginPageState extends State<FirebaseLoginPage>
    with SingleTickerProviderStateMixin {
  UserCredential? userCred;
  String _status = "Not signed in.";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _showEmailForm = false;
  bool _isSignUp = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Email form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
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
        _status =
        "Signed in as: ${userCred?.user?.email ?? "No email found"}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = "Sign-in Error: ${e.toString()}";
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
      _status = _isSignUp ? "Creating account..." : "Signing in...";
    });

    try {
      if (_isSignUp) {
        // Create user with email and password
        userCred = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Update user profile with display name
        if (userCred?.user != null && _fullNameController.text.trim().isNotEmpty) {
          await userCred!.user!.updateDisplayName(_fullNameController.text.trim());
          await userCred!.user!.reload();
        }

        // Send email verification
        if (userCred?.user != null && !userCred!.user!.emailVerified) {
          await userCred!.user!.sendEmailVerification();
          setState(() {
            _status = "Account created! Please check your email to verify your account.";
          });
        } else {
          setState(() {
            _status = "Account created successfully! Signed in as: ${userCred?.user?.displayName ?? userCred?.user?.email}";
          });
        }
      } else {
        // Sign in with existing account
        userCred = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Check if email is verified
        if (userCred?.user != null && !userCred!.user!.emailVerified) {
          setState(() {
            _status = "Please verify your email address. Check your inbox for verification link.";
          });
          // Optionally, you can sign out unverified users
          // await _auth.signOut();
          // userCred = null;
        } else {
          setState(() {
            _status = "Signed in as: ${userCred?.user?.displayName ?? userCred?.user?.email}";
          });
        }
      }

      // Clear form and hide it after successful operation
      _clearForm();
      setState(() {
        _showEmailForm = false;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _status = "${_isSignUp ? 'Sign-up' : 'Sign-in'} Error: ${_getFirebaseErrorMessage(e)}";
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = "${_isSignUp ? 'Sign-up' : 'Sign-in'} Error: ${e.toString()}";
      });
    }
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return e.message ?? 'An unknown error occurred.';
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
          _status = "Verification email sent! Please check your inbox.";
        });
      }
    } catch (e) {
      setState(() {
        _status = "Error sending verification email: ${e.toString()}";
      });
    }
  }

  Future<void> resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _status = "Please enter your email address to reset password.";
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _status = "Password reset email sent! Check your inbox.";
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _status = "Password reset error: ${_getFirebaseErrorMessage(e)}";
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

  Widget _buildEmailForm() {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showEmailForm ? null : 0,
      child: _showEmailForm
          ? Card(
        margin: const EdgeInsets.only(top: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isSignUp ? "Create Account" : "Sign In",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: _toggleEmailForm,
                      icon: const Icon(Icons.close),
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _fullNameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      hintText: "Enter your full name",
                      prefixIcon: const Icon(Icons.person_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface.withOpacity(0.5),
                    ),
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
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface.withOpacity(0.5),
                  ),
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
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface.withOpacity(0.5),
                  ),
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
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Confirm your password",
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface.withOpacity(0.5),
                    ),
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
                ElevatedButton(
                  onPressed: _isLoading ? null : signInWithEmail,
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
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(_isSignUp ? "Create Account" : "Sign In"),
                ),
                const SizedBox(height: 16),
                if (!_isSignUp) ...[
                  TextButton(
                    onPressed: resetPassword,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: colorScheme.primary,
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
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: MyAppBar(toggleTheme: widget.toggleTheme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SizedBox(
            width: 800,
            child: AuthService.getCurrentUser() != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                      Icons.check_circle_outline,
                      size: 60,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Welcome back ${(AuthService.getCurrentUser()!.displayName ?? AuthService.getCurrentUser()!.email)}!",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _auth.signOut();
                      setState(() {
                        userCred = null;
                        _status = "Signed out successfully.";
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: colorScheme.onSecondary,
                      backgroundColor: colorScheme.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Sign Out"),
                  ),
                  if (AuthService.getCurrentUser() != null && !AuthService.getCurrentUser()!.emailVerified) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.error.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_outlined,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Email not verified",
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: resendVerificationEmail,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: colorScheme.onError,
                              backgroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text("Resend Verification Email"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            )
                : Container(
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
                            userCred == null ? Icons.lock_outline_rounded : Icons.lock_open_outlined,
                            size: 60,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "Welcome!",
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
                                _isLoading && !_showEmailForm
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
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
                                  child: const Text("Sign In with Google"),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.5))),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "OR",
                                        style: TextStyle(
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: colorScheme.outline.withOpacity(0.5))),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _toggleEmailForm,
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    backgroundColor: colorScheme.surface,
                                    side: BorderSide(color: colorScheme.primary),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(_showEmailForm ? "Hide Email Form" : "Sign In with Email"),
                                ),
                                _buildEmailForm(),
                                const SizedBox(height: 24),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _status.startsWith("Sign-in Error") || _status.startsWith("Sign-up Error")
                                        ? colorScheme.error.withOpacity(0.1)
                                        : _status.startsWith("Signed in") || _status.startsWith("Account created")
                                        ? colorScheme.primary.withOpacity(0.1)
                                        : colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _status.startsWith("Sign-in Error") || _status.startsWith("Sign-up Error")
                                          ? colorScheme.error
                                          : _status.startsWith("Signed in") || _status.startsWith("Account created")
                                          ? colorScheme.primary
                                          : colorScheme.outline.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _status.startsWith("Sign-in Error") || _status.startsWith("Sign-up Error")
                                            ? Icons.error_outline
                                            : _status.startsWith("Signed in") || _status.startsWith("Account created")
                                            ? Icons.check_circle_outline
                                            : Icons.info_outline,
                                        color: _status.startsWith("Sign-in Error") || _status.startsWith("Sign-up Error")
                                            ? colorScheme.error
                                            : _status.startsWith("Signed in") || _status.startsWith("Account created")
                                            ? colorScheme.primary
                                            : colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _status,
                                          style: TextStyle(
                                            color: _status.startsWith("Sign-in Error") || _status.startsWith("Sign-up Error")
                                                ? colorScheme.error
                                                : _status.startsWith("Signed in") || _status.startsWith("Account created")
                                                ? colorScheme.primary
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}