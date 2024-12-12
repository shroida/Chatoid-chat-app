import 'package:chatoid/constants.dart';
import 'package:flutter/material.dart';

class ButtonScrollDown extends StatelessWidget {
  const ButtonScrollDown({super.key, required this.scrollToBottom});
  final VoidCallback scrollToBottom;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      right: 10,
      child: FloatingActionButton(
        onPressed: scrollToBottom,
        backgroundColor: ChatAppColors.backgroundColor,
        child: const Icon(Icons.arrow_downward, color: Colors.grey),
      ),
    );
  }
}
