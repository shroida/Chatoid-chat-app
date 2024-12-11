import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/presntation/widgets/mainMessage.dart';
import 'package:chatoid/presntation/widgets/replyMessage.dart';
import 'package:chatoid/zRefactor/features/chat/model/clsMessage.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageListView extends StatefulWidget {
  final List<clsMessage> messages;
  final int currentUserId;
  final String? messsagReply;

  final ScrollController scrollController;
  final FocusNode focusNode;
  final Map<int, double> dragOffsets;
  final ValueChanged<bool> onReplyChanged;
  final ValueChanged<String?> onMessageTextToReplyChanged;
  final UserData friendUser;

  const MessageListView({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    required this.focusNode,
    required this.dragOffsets,
    required this.onReplyChanged,
    required this.onMessageTextToReplyChanged,
    required this.friendUser,
    this.messsagReply,
  });

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatsCubit>(context, listen: true);

    return Expanded(
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          final message = widget.messages[index];
          final bool isSentByUser = widget.currentUserId == message.senderId;

          widget.dragOffsets[index] = widget.dragOffsets[index] ?? 0;

          return GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                double screenWidth = MediaQuery.of(context).size.width;
                widget.dragOffsets[index] =
                    (widget.dragOffsets[index]! + details.delta.dx)
                        .clamp(0, screenWidth / 2);

                if (widget.dragOffsets[index]! > screenWidth / 2) {
                  widget.onReplyChanged(true);
                } else {
                  widget.onReplyChanged(false);
                }
              });
            },
            onPanEnd: (details) {
              double screenWidth = MediaQuery.of(context).size.width;

              if (widget.dragOffsets[index]! > screenWidth / 2) {
                widget.onMessageTextToReplyChanged(message.messageText);
              } else {
                widget.onMessageTextToReplyChanged(null);
              }

              widget.focusNode.requestFocus();

              setState(() {
                widget.dragOffsets[index] = 0;
              });
              widget.onReplyChanged(true);
              widget.onMessageTextToReplyChanged(message.messageText);
            },
            onLongPress: () {
              print('message reply${message.messsagReply}');
              // Add your long press actions here if needed
            },
            child: Transform.translate(
              offset: Offset(widget.dragOffsets[index]!, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: isSentByUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (message.messsagReply != null)
                          MessageReplyDisplay(
                            username: widget.friendUser.username,
                            replyMessage: message.messsagReply!,
                          ),
                        MainMessage(
                          message: message,
                          isSentByUser: isSentByUser,
                          chatProvider: chatProvider,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
