import 'package:chatoid/constants.dart';
import 'package:flutter/material.dart';

class CardFriend extends StatelessWidget {
  const CardFriend({super.key, required this.username});
  final String username;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ChatAppColors.appBarColor,
        borderRadius: BorderRadius.circular(16),
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
          ClipOval(
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Image.asset('assets/profile.gif'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            username,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
