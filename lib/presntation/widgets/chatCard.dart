import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:flutter/material.dart';
import 'package:chatoid/constants.dart';

class ChatCard extends StatelessWidget {
  final UserData friendData;
  final String messageText;
  final int messageCount;
  final String messageDate;
  final VoidCallback onTap;
  final bool isLastMessageFromFriend;
  final bool isLastMessageSeenByUser;
  const ChatCard({
    super.key,
    required this.friendData,
    required this.messageText,
    required this.messageCount,
    required this.messageDate,
    required this.onTap,
    required this.isLastMessageFromFriend,
    required this.isLastMessageSeenByUser,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          children: [
            
            CircleAvatar(
              radius: 30,
              child: Image.asset(
                friendData.profile_image.isNotEmpty
                    ? friendData.profile_image
                    : 'assets/profile.gif',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friendData.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (!isLastMessageFromFriend)
                        Icon(
                          isLastMessageSeenByUser
                              ? Icons.done_all
                              : Icons.done, // Choose icon based on state
                          color: isLastMessageSeenByUser
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white // White for dark mode
                                  : ChatAppColors
                                      .primaryColor) // Use your primary color for light mode
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors
                                      .white70 // Light grey for dark mode unseen
                                  : ChatAppColors
                                      .chatTextColorSender), // Use your sender color for light mode
                          size: 24.0, // Adjust size as needed
                        ),
                      const SizedBox(width: 4),
                      !isLastMessageFromFriend
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
                          messageText,
                          maxLines: 1, // Limit to a single line
                          overflow: TextOverflow
                              .ellipsis, // Add "..." if the text is too long
                          style: TextStyle(
                            fontSize: 16.0, // You can adjust the font size
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (messageCount > 0)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: ChatAppColors.appBarColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$messageCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(messageDate),
              ],
            )
          ],
        ),
      ),
    );
  }
}
