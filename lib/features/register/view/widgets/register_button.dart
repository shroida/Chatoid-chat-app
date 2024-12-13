import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatoid/features/register/view_model/signUp/signup_cubit.dart';
import 'package:chatoid/features/register/model/signup_data.dart';
import 'package:chatoid/features/login/view/widgets/rive_animation_manager.dart';

class RegisterButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController usernameController;
  final RiveAnimationManager riveManager;
  final GlobalKey<FormState> formKey;

  const RegisterButton({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.usernameController,
    required this.riveManager,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12.0),
      ),
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          // Validate form and check if passwords match
          if (formKey.currentState?.validate() == true) {
            if (passwordController.text == confirmPasswordController.text) {
              final signupCubit = BlocProvider.of<SignupCubit>(context, listen: false);

              signupCubit.submitForm(
                context: context,
                userData: RegisterModel(
                  email: emailController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                ),
                success: () {
                  riveManager.addAnimation(riveManager.controllersuccess);
                },
                failure: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Registration failed. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Passwords do not match. Please try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: const Text(
          "Register",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
