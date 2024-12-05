// lib/message_reply_display.dart

import 'package:flutter/material.dart';

class MessageReplyDisplay extends StatelessWidget {
  final String username; // The friend's username
  final String replyMessage; // The replied message text

  const MessageReplyDisplay({
    Key? key,
    required this.username,
    required this.replyMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color.fromARGB(164, 248, 249, 250),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            replyMessage,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color.fromARGB(255, 49, 48, 48),
            ),
          ),
        
        ],
      ),
    );
  }
}
