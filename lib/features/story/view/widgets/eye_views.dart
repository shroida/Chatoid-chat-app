import 'package:flutter/material.dart';

class EyeViews extends StatelessWidget {
  const EyeViews({super.key, required this.countViews});
  final int countViews;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  const Color.fromARGB(255, 179, 179, 179), // Add border color
              width: 2.0, // Border width
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/eye.gif',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          countViews.toString(),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ],
    );
  }
}
