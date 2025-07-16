import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignUpPage.dart';
import 'HomePage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool highlightSignUp = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (highlightSignUp && mounted) {
        setState(() {
          highlightSignUp = false;
        });
      }
    });
  }

  void _showErrorDialog(String message) {
    if (!mounted) return; // Always check mounted before showing dialog

    showDialog(
      context: context, // Use the current widget's context
      builder: (BuildContext dialogContext) {
        // Use dialogContext inside the builder
        return AlertDialog(
          title: const Text("Login Failed"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Pop the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      print("Attempting to login with email: $email");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) {
        print("Widget unmounted after successful login attempt.");
        return;
      }

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        _showErrorDialog("Please verify your email before logging in.");
        await FirebaseAuth.instance.signOut(); // Logout lagi
        return;
      }

      // Navigate to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      print("Login successful, navigating to HomePage.");
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error Code: ${e.code}");
      print("Firebase Auth Error Message: ${e.message}");

      String errorMessage;
      bool shouldHighlightSignUp = false;

      if (e.code == 'user-not-found') {
        errorMessage = 'Account not found. Please Sign Up.';
        shouldHighlightSignUp = true;
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong Password.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid Email or Password.';
      } else {
        errorMessage = 'Error: ${e.message ?? 'There is an error.'}';
      }

      if (mounted) {
        // Only update state if widget is still active
        setState(() {
          highlightSignUp = shouldHighlightSignUp;
        });
        _showErrorDialog(errorMessage); // <-- Call the new dialog function
        print("Error dialog for '${e.code}' attempted.");
      } else {
        print("Widget unmounted, cannot show error dialog.");
      }
    }
  }

  Future<void> signInWithGoogle() async {
    // Changed return type to void for async
    try {
      print("Attempting Google Sign-In...");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in flow
        print("Google Sign-In cancelled by user.");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) {
        print("Widget unmounted after successful Google Sign-In.");
        return;
      }

      // If successful, navigate to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      print("Google Sign-In successful, navigating to HomePage.");
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Google Error Code: ${e.code}");
      print("Firebase Auth Google Error Message: ${e.message}");

      String errorMessage;
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage =
            'An account already exists with the same email address but different sign-in credentials. Please try signing in with a different method.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.code == 'cancelled') {
        // This usually happens if the user cancels the Google Sign-In prompt
        print("Google Sign-In cancelled (FirebaseAuthException).");
        return; // No need to show an error dialog for user cancellation
      } else {
        errorMessage =
            'Google Sign-In Error: ${e.message ?? 'An unknown error occurred.'}';
      }

      if (mounted) {
        _showErrorDialog(errorMessage); // Show dialog for errors
        print("Error dialog for Google Sign-In attempted.");
      } else {
        print("Widget unmounted, cannot show Google Sign-In error dialog.");
      }
    } catch (e) {
      print('General Google Sign-In Exception: $e');
      if (mounted) {
        _showErrorDialog('Google Sign-In failed: ${e.toString()}');
      }
    }
  }

  // Your signOutFromGoogle method (you might not need this on a login page)
  // But if you keep it, make sure GoogleSignIn is initialized.
  Future<bool> signOutFromGoogle() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      // Also sign out from GoogleSignIn if the user might still be logged into Google
      await GoogleSignIn().signOut();
      print("Successfully signed out from Google and Firebase.");
      return true;
    } on Exception catch (e) {
      print('Error signing out from Google: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(51, 63, 72, 1),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Setengah lingkaran atas
          Positioned(
            bottom: -screenWidth * 0.5,
            child: Container(
              width: screenWidth * 2.5,
              height: screenWidth * 2.2,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(239, 248, 244, 1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Konten Login
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 100,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  SvgPicture.asset('asset/logo-app.svg', height: 100),
                  const SizedBox(height: 10),
                  const Text(
                    "Welcome! Please Login Here",
                    style: TextStyle(
                      color: Color.fromRGBO(51, 63, 72, 1),
                      fontSize: 12,
                      fontFamily: 'inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Align(
                    alignment: Alignment(-0.7, 0.5),
                    child: Text("Email", style: labelStyle),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 300, // <-- Atur lebar yang Anda inginkan di sini
                    child: TextFormField(
                      controller: _emailController,
                      style: const TextStyle(
                        color: Colors.white,
                      ), // Gabungkan style
                      decoration: inputDecoration("Enter your email"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment(-0.7, 0.5),
                    child: Text("Password", style: labelStyle),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 300, // <-- Atur lebar yang Anda inginkan di sini
                    child: TextFormField(
                      controller: _passwordController,
                      style: const TextStyle(
                        color: Colors.white,
                      ), // Gabungkan style
                      decoration: inputDecoration("Enter your password"),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(51, 63, 72, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      loginWithEmail(email, password);
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(239, 248, 244, 1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Divider
                  Row(
                    children: const [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromRGBO(51, 63, 72, 1),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("Or Login with"),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Color.fromRGBO(51, 63, 72, 1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  InkWell(
                    onTap: () {
                      signInWithGoogle();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromRGBO(51, 63, 72, 1),
                      ),
                      child: SvgPicture.asset('asset/google.svg', height: 24),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Sign Up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account yet? ",
                        style: TextStyle(
                          color: Color.fromRGBO(51, 63, 72, 1),
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        },
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: highlightSignUp ? Colors.red : Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          child: const Text("Sign Up here!"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF333F48),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  TextStyle get labelStyle => const TextStyle(
    color: Color(0xFF333F48),
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}
