import 'package:chatoid/core/widgets/bear_animation.dart';
import 'package:chatoid/features/login/view/widgets/email_field.dart';
import 'package:chatoid/features/login/view/widgets/password_field.dart';
import 'package:chatoid/features/login/view/widgets/rive_animation_manager.dart';
import 'package:chatoid/features/register/view/widgets/navigate_to_login.dart';
import 'package:chatoid/features/register/view/widgets/register_button.dart';
import 'package:flutter/material.dart';
import 'package:chatoid/features/login/view/widgets/diver.dart';

class RegisterScreen extends StatefulWidget {
  static String id = 'register_page';

  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final riveManager = RiveAnimationManager();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _usernameConroller = TextEditingController();
  bool isLoading = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  bool _obscureText = true;
  bool _obscureConfirmText = true;

  bool isLookingLeft = false;
  bool isLookingRight = false;

  @override
  void initState() {
    super.initState();
    riveManager.loadArtboard('assets/animated_login.riv').then((_) {
      setState(() {});
    });
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

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmText = !_obscureConfirmText;
      riveManager.addAnimation(
        _obscureConfirmText
            ? riveManager.controllerHandsUp
            : riveManager.controllerHandsDown,
      );
    });
  }

  @override
  void dispose() {
    passwordFocusNode.removeListener(() {});
    confirmPasswordController.removeListener(() {});
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    riveManager.resetToIdle();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Stack(children: [
      riveManager.riveArtboard == null
          ? const Center(child: CircularProgressIndicator())
          : BearAnimation(riveArtboard: riveManager.riveArtboard),
      Positioned.fill(
        top: 300,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width / 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      EmailField(
                        labelTextField: 'Username',
                        controller: riveManager.controllerLookDownLeft,
                        emailController: _usernameConroller,
                        onAnimationChanged: (controller) {
                          if (_usernameConroller.text.length > 16) {
                            riveManager.addAnimation(
                                riveManager.controllerLookDownRight);
                          } else {
                            riveManager.addAnimation(
                                riveManager.controllerLookDownLeft);
                          }
                        },
                      ),
                      SizedBox(height: size.height / 30),
                      EmailField(
                        controller: riveManager.controllerLookDownLeft,
                        emailController: emailController,
                        onAnimationChanged: (controller) {
                          if (emailController.text.length > 16) {
                            riveManager.addAnimation(
                                riveManager.controllerLookDownRight);
                          } else {
                            riveManager.addAnimation(
                                riveManager.controllerLookDownLeft);
                          }
                        },
                      ),
                      SizedBox(height: size.height / 30),
                      PasswordField(
                          passwordController: passwordController,
                          passwordFocusNode: passwordFocusNode,
                          obscureText: _obscureText,
                          togglePasswordVisibility: _togglePasswordVisibility),
                      SizedBox(height: size.height / 30),
                      PasswordField(
                          passwordController: confirmPasswordController,
                          passwordFocusNode: confirmPasswordFocusNode,
                          obscureText: _obscureConfirmText,
                          togglePasswordVisibility:
                              _toggleConfirmPasswordVisibility),
                      SizedBox(height: size.height / 30),
                      RegisterButton(
                        emailController: emailController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        usernameController: _usernameConroller,
                        riveManager: riveManager,
                        formKey: formKey,
                      ),
                      const SizedBox(height: 13),
                    ],
                  ),
                ),
                const Diver(),
                const NavigateToLogin(),
                const SizedBox(height: 13),
              ],
            ),
          ),
        ),
      )
    ]));
  }
}
