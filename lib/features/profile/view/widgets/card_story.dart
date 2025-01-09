import 'package:chatoid/constants.dart';
import 'package:flutter/material.dart';

class CardStory extends StatelessWidget {
  const CardStory({super.key, required this.storyText, required this.username});
  final String storyText;
  final String username;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          vertical: 10, horizontal: 20), // Adjust margins as needed
      padding: const EdgeInsets.only(top: 10, left: 20, bottom: 80),
      decoration: BoxDecoration(
        color: ChatAppColors.appBarColor,
        borderRadius: BorderRadius.circular(16), // Add border radius here
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Image.asset('assets/profile.gif'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                username,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold), 
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            storyText,

            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
