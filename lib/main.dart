import 'package:flutter/material.dart';
import 'screens/LandingPage.dart';
import 'package:firebase_core/firebase_core.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Duration duration = Duration(milliseconds: 800);
  static const Curve curve = Curves.fastOutSlowIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey, // <- ini ditambahkan
      home: Scaffold(
        backgroundColor: Colors.white,
        body: LandingPage(
          duration: MyApp.duration,
          curve: MyApp.curve,
        ),
      ),
    );
  }
}
