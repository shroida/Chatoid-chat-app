import 'package:flutter/material.dart';

class TextInChat extends StatelessWidget {
  const TextInChat({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Y\'all in the chat',
      style: TextStyle(
          color: Color.fromARGB(255, 9, 225, 16), fontWeight: FontWeight.w800),
    );
  }
}
