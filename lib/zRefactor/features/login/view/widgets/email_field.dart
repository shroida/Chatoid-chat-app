import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class EmailField extends StatelessWidget {
  const EmailField(
      {super.key,
      required this.emailController,
      required this.onAnimationChanged,
      required this.controller,
      this.labelTextField = 'Email'});

  final rive.RiveAnimationController controller;
  final Function(rive.RiveAnimationController) onAnimationChanged;
  final TextEditingController emailController;
  final String labelTextField;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.email),
        ),
        labelText: labelTextField,
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? "Please enter a valid email" : null,
      onChanged: (value) {
        // Trigger animation changes based on input length or other logic
        if (value.isNotEmpty) {
          if (value.length < 16) {
            onAnimationChanged(controller); // Controller for short input
          } else {
            // You can customize more logic for animations if necessary
            onAnimationChanged(controller); // Controller for long input
          }
        } else {
          onAnimationChanged(controller); // Reset to idle or default animation
        }
      },
    );
  }
}
