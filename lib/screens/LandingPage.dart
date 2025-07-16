import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'LoginPage.dart'; // Import your LoginPage
import 'HomePage.dart'; // Import your HomePage

class LandingPage extends StatefulWidget {
  const LandingPage({required this.duration, required this.curve, super.key});

  final Duration duration;
  final Curve curve;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with TickerProviderStateMixin {
  bool showText = false;
  bool showU = false;
  bool showFullScreenColor = false; // This variable seems unused, consider removing
  bool expandCircle = false;
  late AnimationController expandController;
  late Animation<double> scaleAnimation;

  // fullScreenFadeController and fullScreenOpacity are unused based on your current build method
  // Consider removing them if they are not used elsewhere.
  late AnimationController fullScreenFadeController;
  late Animation<double> fullScreenOpacity;


  late AnimationController textController;
  late Animation<Offset> medSlide;
  late Animation<Offset> minderSlide;
  late AnimationController medFadeController;
  late AnimationController minderFadeController;

  late AnimationController circleController;
  late Animation<Offset> circleSlideIn;
  late Animation<double> circleSize;
  late Animation<double> circleClipFactor; // This variable seems unused in the build, consider removing or using it

  final List<Alignment> path = [
    const Alignment(-1, -0.5),
    const Alignment(-0.5, -0.5),
    const Alignment(-0.3, -0.3),
    const Alignment(-0.1, -0.1),
    const Alignment(-0.01, -0.02),
  ];

  final List<double> rotations = [
    0.0,
    -(120 / 360),
    35 / 360,
    -(135 / 360),
    90 / 360,
  ];

  final double horizontalShift = -0.1;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    animateThroughPath();

    textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    medFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    minderFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    circleSlideIn = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.0, 1.2),
          end: const Offset(0.0, 0.6),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Offset>(const Offset(0.0, 0.6)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0.0, 0.6),
          end: const Offset(0.0, 0.0),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(circleController);

    circleSize = Tween<double>(
      begin: 1.2,
      end: 3.0,
    ).animate(circleController);

    circleClipFactor = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.5), weight: 70),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    ]).animate(circleController);


    medSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-0.1, 0),
    ).animate(CurvedAnimation(parent: textController, curve: Curves.easeOut));

    minderSlide = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.17, 0),
    ).animate(CurvedAnimation(parent: textController, curve: Curves.easeOut));

    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 6.0).animate(
      CurvedAnimation(parent: expandController, curve: Curves.easeInOut),
    );

    // Initialize fullScreenFadeController even if not used in build
    fullScreenFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    fullScreenOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(fullScreenFadeController);


    // Key change: When the last animation (circleController) completes,
    // we check the authentication status and navigate accordingly.
    circleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          expandCircle = true;
        });
        expandController.forward().then((_) {
          // --- START OF NEW AUTH CHECK LOGIC ---
          _checkAuthStatusAndNavigate();
          // --- END OF NEW AUTH CHECK LOGIC ---
        });
      }
    });
  }

  // --- NEW FUNCTION TO HANDLE AUTHENTICATION CHECK ---
  void _checkAuthStatusAndNavigate() {
    // Listen to authentication state changes.
    // This stream will immediately emit the current user if one is logged in,
    // or null if not. We only need the first emission to decide navigation.
    final User? user = FirebaseAuth.instance.currentUser;

    if (mounted) { // Ensure the widget is still mounted before navigating
      if (user == null) {
        // User is not signed in, navigate to LoginPage
        print("User not logged in, navigating to LoginPage.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        // User is signed in, navigate to HomePage
        print("User ${user.uid} logged in, navigating to HomePage.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }
  // --- END OF NEW FUNCTION ---


  void animateThroughPath() async {
    for (int i = 1; i < path.length; i++) {
      await Future.delayed(widget.duration, () {
        if (mounted) {
          setState(() {
            currentIndex = i;
            if (i == path.length - 1) {
              showU = true;
              showText = true;
              textController.forward();
              medFadeController.forward().then((_) {
                minderFadeController.forward().then((_) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      circleController.forward();
                    }
                  });
                });
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    textController.dispose();
    medFadeController.dispose();
    minderFadeController.dispose();
    circleController.dispose();
    expandController.dispose(); // Added dispose for expandController
    fullScreenFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Your existing animation UI elements
          if (showText)
            Positioned(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 1.0).animate(medFadeController),
                    child: SlideTransition(
                      position: medSlide,
                      child: const Text(
                        'Med',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(51, 63, 72, 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 0),
                  FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(minderFadeController),
                    child: SlideTransition(
                      position: minderSlide,
                      child: const Text(
                        'Minder',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'inter',
                          fontWeight: FontWeight.w900,
                          color: Color.fromRGBO(246, 182, 169, 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (showU)
            Align(
              alignment: Alignment(horizontalShift, 0.0),
              child: const Text(
                'U',
                style: TextStyle(
                  fontSize: 50,
                  fontFamily: 'inter',
                  fontWeight: FontWeight.w900,
                  color: Color.fromRGBO(51, 63, 72, 1),
                ),
              ),
            ),

          AnimatedAlign(
            alignment: Alignment(
              path[currentIndex].x + horizontalShift,
              path[currentIndex].y,
            ),
            duration: widget.duration,
            curve: widget.curve,
            child: AnimatedRotation(
              turns: rotations[currentIndex],
              duration: widget.duration,
              curve: widget.curve,
              child: SvgPicture.asset(
                'asset/pill2.svg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),

          if (!expandCircle)
            AnimatedBuilder(
              animation: circleController,
              builder: (context, child) {
                double size = MediaQuery.of(context).size.longestSide * circleSize.value;

                return SlideTransition(
                  position: circleSlideIn,
                  child: Center(
                    child: Container(
                      width: size,
                      height: size,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(246, 182, 169, 1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            )
          else // This else block handles the final circle expansion before navigation
            AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                final baseSize = MediaQuery.of(context).size.longestSide * circleSize.value;

                return ScaleTransition(
                  scale: scaleAnimation,
                  child: Container(
                    width: baseSize,
                    height: baseSize,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(246, 182, 169, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}