import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:flutter/material.dart';

class GroupChatCard extends StatelessWidget {
  // final UserData friendData;
  final String messageText;
  final int messageCount;
  final String messageDate;
  final VoidCallback onTap;
  final List<ClsMessage> allMessages;
  final bool isLastMessageFromOther;
  const GroupChatCard({
    super.key,
    required this.allMessages,
    required this.messageText,
    required this.messageCount,
    required this.messageDate,
    required this.onTap,
    required this.isLastMessageFromOther,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              child: Image.asset(
                'assets/profile.gif',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '@all',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      //
                      const SizedBox(width: 4),
                      !isLastMessageFromOther
                          ? Text(
                              'you:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : const SizedBox(),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          allMessages[allMessages.length - 1].messageText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Text(messageDate),
          ],
        ),
      ),
    );
  }
}
