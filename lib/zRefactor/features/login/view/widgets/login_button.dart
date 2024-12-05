import 'package:chatoid/zRefactor/features/login/model/login_data.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart'; // For RiveAnimationController

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final FocusNode passwordFocusNode;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Function(RiveAnimationController<dynamic>) addAnimation;
  final RiveAnimationController<dynamic> controllerSuccess;
  final RiveAnimationController<dynamic> controllerFail;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.passwordFocusNode,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.addAnimation,
    required this.controllerSuccess,
    required this.controllerFail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12.0),
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 15),
      child: TextButton(
        onPressed: () async {
          passwordFocusNode.unfocus();
          if (formKey.currentState?.validate() ?? false) {
            final request = LoginModel(
              email: emailController.text.trim(),
              password: passwordController.text,
            );

            await BlocProvider.of<LoginCubit>(context).onLogin(
              context,
              request,
              success: () {
                addAnimation(controllerSuccess);
              },
              failure: () {
                addAnimation(controllerFail);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Email or password is incorrect.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            );
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }
}
