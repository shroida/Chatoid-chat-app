import 'package:chatoid/zRefactor/core/utlis/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ButtonToRegister extends StatelessWidget {
  const ButtonToRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        GoRouter.of(context).push(AppRouter.kRegisterScreen);
      },
      child: const Text(
        "I don't have an account yet, Register here",
        style: TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }
}
