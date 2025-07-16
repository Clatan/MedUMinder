import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'VerifiedEmailPage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool highlightLogin = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      if (highlightLogin && mounted) {
        setState(() {
          highlightLogin = false;
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
          title: const Text("Sign Up Failed"),
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

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      print("Attempting to sign up with email: $email");
      final username = _usernameController.text.trim();
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(username);
      await credential.user!.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        print("Verification email sent to ${user.email}");
      }
      // Tampilkan dialog info
      if (mounted) {
        _showErrorDialog("We've sent a verification email to ${user?.email}. Please verify your email before logging in.");
      }

      // Arahkan ke halaman Login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerifiedEmailPage()),
        );
      }


      // if (user != null && user.emailVerified) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (_) => const HomePage()),
      //   );
      // } else {
      //   _showErrorDialog("Please verify your email before continuing. We've sent a verification email.");
      // }
      // print("Sign Up successful, navigating to HomePage.");
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error Code: ${e.code}");
      print("Firebase Auth Error Message: ${e.message}");
    }
  }

  Future<void> signUpWithGoogle() async {
    // Changed return type to void for async
    try {
      print("Attempting Google Sign-Up...");
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
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(51, 63, 72, 1),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height + 200, // agar cukup tinggi untuk lingkaran + form
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                bottom: -screenWidth * 0.5,
                child: Container(
                  width: screenWidth * 2.5,
                  height: screenWidth * 3.0,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(239, 248, 244, 1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

          // Konten Sign Up
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  SvgPicture.asset('asset/logo-app.svg', height: 100),
                  const SizedBox(height: 10),
                  const Text(
                    "Welcome! Please Sign Up Here",
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
                    child: Text("Username", style: labelStyle),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: inputDecoration("Enter your username"),
                    ),
                  ),
                  const SizedBox(height: 20),


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
                      signUpWithEmail(email, password);
                    },
                    child: const Text(
                      "Sign Up",
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
                        child: Text("Or Sign Up with"),
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
                      signUpWithGoogle();
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
                        "Already have an account? ",
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
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            color: highlightLogin ? Colors.red : Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          child: const Text("Login here!"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
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
