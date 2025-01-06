import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Color containerColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Delay to allow animation to run first before checking login status
    Future.delayed(Duration.zero, () {
      setState(() {
        containerColor = ChatAppColors.appBarColor;
      });
    });
    checkLoginSession();
  }

  Future<void> checkLoginSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    // Navigate to the appropriate screen based on login status
    if (mounted) {
      Future.delayed(const Duration(seconds: 3), () {
        if (isLoggedIn) {
          // If logged in, navigate to HomePage
          GoRouter.of(context).push(AppRouter.kHomePage);
        } else {
          // If not logged in, navigate to Login view
          GoRouter.of(context).push(AppRouter.kLoginView);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        color: containerColor,
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        alignment: Alignment.center,
        child: AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              'CHATOID',
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 80,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
              speed: const Duration(milliseconds: 200),
            ),
          ],
          totalRepeatCount: 1,
          pause: const Duration(seconds: 1),
          displayFullTextOnTap: true,
        ),
      ),
    );
  }
}
