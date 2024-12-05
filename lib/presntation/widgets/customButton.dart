import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Size size;
  final String imageButton;
  final String textButtonName;
  final Function() func;

  const CustomButton(
      {Key? key,
      required this.size,
      required this.imageButton,
      required this.textButtonName,
      required this.func})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red, // Google button color
        borderRadius: BorderRadius.circular(12.0),
      ),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: size.width / 15),
      child: TextButton(
        onPressed: () {
            func();
          },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageButton, // Path to your Google logo
              height: 24, // Adjust the size of the logo
              width: 24,
            ),
            const SizedBox(width: 10),
            Text(
              textButtonName,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
