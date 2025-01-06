import 'package:chatoid/core/utlis/app_router.dart';
import 'package:chatoid/core/widgets/bear_animation.dart';
import 'package:chatoid/features/login/view/widgets/button_to_register.dart';
import 'package:chatoid/features/login/view/widgets/diver.dart';
import 'package:chatoid/features/login/view/widgets/email_field.dart';
import 'package:chatoid/features/login/view/widgets/login_button.dart';
import 'package:chatoid/features/login/view/widgets/password_field.dart';
import 'package:chatoid/features/login/view/widgets/rive_animation_manager.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final passwordFocusNode = FocusNode();
  bool _obscureText = true;
  final riveManager = RiveAnimationManager();

  @override
  void initState() {
    super.initState();
    _loadRiveAnimation();
    _setupPasswordFocusListener();
  }

  void _loadRiveAnimation() {
    riveManager.loadArtboard('assets/animated_login.riv').then((_) {
      setState(() {});
    });
  }

  void _setupPasswordFocusListener() {
    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus) {
        riveManager.addAnimation(riveManager.controllerHandsUp);
      } else {
        riveManager.addAnimation(riveManager.controllerHandsDown);
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
      riveManager.addAnimation(
        _obscureText
            ? riveManager.controllerHandsUp
            : riveManager.controllerHandsDown,
      );
    });
  }

  @override
  void dispose() {
    // Cancel or clean up any ongoing tasks
    passwordFocusNode.removeListener(() {});
    passwordFocusNode.dispose();
    riveManager
        .resetToIdle(); // Ensure this doesn't perform async work that can cause issues

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          setState(() => isLoading = true);
        } else if (state is LoginSuccess) {
          _loadDataAndNavigate();
        } else if (state is LoginFailure) {
          _showLoginFailureMessage();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildBackgroundAnimation(),
            _buildLoginForm(size),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundAnimation() {
    return riveManager.riveArtboard == null
        ? const Center(child: CircularProgressIndicator())
        : BearAnimation(riveArtboard: riveManager.riveArtboard);
  }

  Widget _buildLoginForm(Size size) {
    return Positioned.fill(
      top: 320,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width / 20),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                EmailField(
                  controller: riveManager.controllerLookDownLeft,
                  emailController: emailController,
                  onAnimationChanged: (controller) {
                    riveManager.addAnimation(
                      emailController.text.length > 16
                          ? riveManager.controllerLookDownRight
                          : riveManager.controllerLookDownLeft,
                    );
                  },
                ),
                SizedBox(height: size.height / 25),
                PasswordField(
                  passwordController: passwordController,
                  passwordFocusNode: passwordFocusNode,
                  obscureText: _obscureText,
                  togglePasswordVisibility: _togglePasswordVisibility,
                ),
                SizedBox(height: size.height / 25),
                LoginButton(
                  isLoading: isLoading,
                  passwordFocusNode: passwordFocusNode,
                  formKey: formKey,
                  emailController: emailController,
                  passwordController: passwordController,
                  addAnimation: riveManager.addAnimation,
                  controllerSuccess: riveManager.controllersuccess,
                  controllerFail: riveManager.controllerFail,
                ),
                const SizedBox(height: 13),
                const Diver(),
                const ButtonToRegister(),
                const SizedBox(height: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadDataAndNavigate() async {
    final loginCubit = context.read<LoginCubit>();

    setState(() => isLoading = true);

    await loginCubit.loadUserDataCubits();

    // Check if the widget is still mounted
    if (!mounted) return;

    try {
      GoRouter.of(context).push(AppRouter.kHomePage);
    } catch (e) {
      debugPrint("Error during navigation: $e");
      _showErrorSnackbar('Failed to navigate to home page. Try again.');
    } finally {
      // Check if the widget is still mounted before updating the state
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showLoginFailureMessage() {
    // Check if mounted before calling setState
    if (mounted) {
      setState(() => isLoading = false);
    }
    _showErrorSnackbar('Login failed. Please try again.');
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
