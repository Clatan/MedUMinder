import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'LoginPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final updatedUser = FirebaseAuth.instance.currentUser;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // --- Start of New Sign-Out Logic ---
  Future<void> _signOut() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Sign out from Google if the user originally signed in with Google
      // This is important to clear the Google session as well.
      // We check if GoogleSignIn is initialized before calling signOut on it.
      if (await GoogleSignIn().isSignedIn()) {
        await GoogleSignIn().signOut();
        print("Signed out from Google.");
      }

      print("Successfully signed out from Firebase.");

      // Navigate back to the LoginPage and clear the navigation stack
      // This prevents the user from going back to HomePage with the back button
      if (mounted) {
        // Check if the widget is still in the tree before navigating
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) =>
              false, // This predicate removes all previous routes
        );
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error during sign out: ${e.message}");
      _showErrorDialog("Sign Out Failed", "Firebase Error: ${e.message}");
    } catch (e) {
      print("General Error during sign out: $e");
      _showErrorDialog(
        "Sign Out Failed",
        "An unexpected error occurred: ${e.toString()}",
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // --- End of New Sign-Out Logic ---

  @override
  Widget build(BuildContext context) {
    // Optionally, get the current user to display their email or name
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Bookmark icon (existing)
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              // Your bookmark logic here
            },
          ),
          // --- New Sign-Out Button ---
          IconButton(
            icon: const Icon(Icons.logout), // Logout icon
            tooltip: 'Sign Out',
            onPressed: _signOut, // Call the new sign-out function
          ),
          // --- End of New Sign-Out Button ---
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display user's email if available
            if (user != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Welcome, ${updatedUser?.displayName ?? updatedUser?.email ?? 'Minders'}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
