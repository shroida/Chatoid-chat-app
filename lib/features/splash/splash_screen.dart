import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatoid/constants.dart';
import 'package:chatoid/core/utlis/app_router.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Color containerColor = Colors.white;
  bool isLoading = false;
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

    // Show a loading indicator
    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        if (isLoggedIn) {
          final loginCubit = context.read<LoginCubit>();

          try {
            await loginCubit.loadUserDataCubits();

            // Check if the widget is still mounted
            if (!mounted) return;

            GoRouter.of(context).push(AppRouter.kHomePage);
          } catch (e) {
            debugPrint("Error during navigation: $e");
          } finally {
            // Check if the widget is still mounted before updating the state
            if (mounted) {
              setState(() => isLoading = false);
            }
          }
        } else {
          GoRouter.of(context).push(AppRouter.kLoginView);
          setState(() => isLoading = false);
        }
      }
    });
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
