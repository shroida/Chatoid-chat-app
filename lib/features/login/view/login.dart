import 'package:chatoid/core/widgets/bear_animation.dart';
import 'package:chatoid/features/login/view/widgets/rive_animation_manager.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_state.dart';
import 'package:chatoid/features/login/view/widgets/button_to_register.dart';
import 'package:chatoid/features/login/view/widgets/email_field.dart';
import 'package:chatoid/features/login/view/widgets/login_button.dart';
import 'package:chatoid/features/login/view/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/features/login/view/widgets/diver.dart';
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

  @override
  void dispose() {
    passwordFocusNode.removeListener(() {}); // Remove the listener
    passwordFocusNode.dispose();
    riveManager.resetToIdle();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          isLoading = true;
        } else if (state is LoginSuccess) {
          GoRouter.of(context).push('/');
        } else if (state is LoginFailure) {
          final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
              GlobalKey<ScaffoldMessengerState>();

          scaffoldMessengerKey.currentState?.showSnackBar(
            const SnackBar(
              content: Text('Sign-up failed"'),
              backgroundColor: Color.fromARGB(255, 54, 244, 86),
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            riveManager.riveArtboard == null
                ? const Center(child: CircularProgressIndicator())
                : BearAnimation(riveArtboard: riveManager.riveArtboard),
            Positioned.fill(
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
                            if (emailController.text.length > 16) {
                              riveManager.addAnimation(
                                  riveManager.controllerLookDownRight);
                            } else {
                              riveManager.addAnimation(
                                  riveManager.controllerLookDownLeft);
                            }
                          },
                        ),
                        SizedBox(height: size.height / 25),
                        PasswordField(
                            passwordController: passwordController,
                            passwordFocusNode: passwordFocusNode,
                            obscureText: _obscureText,
                            togglePasswordVisibility:
                                _togglePasswordVisibility),
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
            )
          ],
        ),
      ),
    );
  }
}
