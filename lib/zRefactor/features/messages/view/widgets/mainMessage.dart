import 'package:chatoid/constants.dart';
import 'package:chatoid/zRefactor/features/messages/model/clsMessage.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'reaction_button.dart'; // Ensure you import the ReactionButton widget

class MainMessage extends StatelessWidget {
  final clsMessage message;
  final bool isSentByUser;
  final ChatsCubit chatProvider; // Assuming you need to pass ChatProvider

  const MainMessage({
    super.key,
    required this.message,
    required this.isSentByUser,
    required this.chatProvider,
  });
  String _formatMessageDate(DateTime date) {
    String hour = '';
    hour = (date.hour < 10 ? '0' : '') +
        (date.hour > 12 ? '0${date.hour - 12}' : date.hour.toString());

    String minute = date.minute < 10 ? '0${date.minute}' : '${date.minute}';

    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow overflow for the reaction button
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
          decoration: BoxDecoration(
            color: isSentByUser
                ? ChatAppColors.chatBubbleColorReceiver
                : const Color.fromARGB(115, 180, 180, 180),
            borderRadius: isSentByUser && message.messsagReply == null
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
                : isSentByUser && message.messsagReply != null
                    ? const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )
                    : const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(
                  maxWidth: 250, // Adjust the width as needed
                ),
                child: Text(
                  message.messageText,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSentByUser
                        ? const Color.fromARGB(255, 36, 36, 36)
                        : ChatAppColors.chatBubbleColorReceiver,
                  ),
                  overflow:
                      TextOverflow.visible, // Allow overflow to be visible
                  softWrap:
                      true, // Ensure the text wraps when reaching the container's width
                ),
              ),

              const SizedBox(width: 15),
              // Seen Icon and Timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Message Date
                  Text(
                    _formatMessageDate(message.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(
                          255, 34, 32, 32), // Use a subtle color for the date
                    ),
                  ),
                  // Seen or Not Seen Icon
                  if (isSentByUser)
                    Icon(
                      message.isRead
                          ? Icons.done_all // Seen (double checkmark icon)
                          : Icons.check, // Not seen (single checkmark icon)
                      color: message.isRead ? Colors.blue : Colors.grey,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 0,
          left: isSentByUser ? 0 : null,
          right: isSentByUser ? null : 0,
          child: ReactionButton(
            reactFromDatabase: message.react ?? 'none',
            onReactionChanged: (reaction) {
              chatProvider.setReactOnMessage(
                message.messageText,
                message.friendId,
                message.senderId,
                reaction,
              );
            },
          ),
        ),
      ],
    );
  }
}
