import 'package:chatoid/core/utlis/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigateToLogin extends StatelessWidget {
  const NavigateToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        GoRouter.of(context).push(AppRouter.kLoginView);
      },
      child: const Text(
        "I have an account, login here",
        style: TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }
}
