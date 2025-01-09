import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/view/widgets/chat_card.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:chatoid/features/messages/view/chat_screen.dart';
import 'package:chatoid/features/messages/view_model/messagesCubit/messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.chatsCubit,
    required this.authCubit,
    required this.messagesCubit,
  });

  final ChatsCubit chatsCubit;
  final LoginCubit authCubit;
  final MessagesCubit messagesCubit;

  ClsMessage? _getLastMessage(UserData friend) {
    List<ClsMessage> conversationMessages = chatsCubit.friendMessages
        .where((msg) =>
            (msg.senderId == friend.friendId &&
                msg.friendId == authCubit.currentUser.userId) ||
            (msg.senderId == authCubit.currentUser.userId &&
                msg.friendId == friend.friendId))
        .toList();

    conversationMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return conversationMessages.isNotEmpty ? conversationMessages.first : null;
  }

  List<ClsMessage> _messagesNotReadByMe(int friendId, int currentUserId) {
    return chatsCubit.friendMessages
        .where((msg) =>
            friendId == msg.senderId &&
            !msg.isRead &&
            msg.friendId == currentUserId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    List<UserData> sortedFriendsList = List.from(chatsCubit.friendsList);

    sortedFriendsList.sort((a, b) {
      final lastMessageA = _getLastMessage(a);
      final lastMessageB = _getLastMessage(b);

      if (lastMessageA == null && lastMessageB == null) {
        return 0;
      } else if (lastMessageA == null) {
        return 1;
      } else if (lastMessageB == null) {
        return -1;
      } else {
        return lastMessageB.createdAt.compareTo(lastMessageA.createdAt);
      }
    });

    return sortedFriendsList.isEmpty
        ? const Center(child: Text("No friends found."))
        : ListView.builder(
            itemCount: sortedFriendsList.length,
            itemBuilder: (context, index) {
              final friend = sortedFriendsList[index];
              final lastMessage = _getLastMessage(friend);

              List<ClsMessage> unreadMessages = _messagesNotReadByMe(
                  friend.friendId, authCubit.currentUser.userId);
              final messagesCount = unreadMessages.length;

              return GestureDetector(
                onLongPress: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    title: 'Delete freind\n"${friend.username}"',
                    confirmBtnText: 'Delete!',
                    onConfirmBtnTap: () {
                      Navigator.of(context).pop();
                      chatsCubit.deleteFriend(friend,authCubit.currentUser);
                    },
                  );
                },
                child: ChatCard(
                  messageDate: lastMessage != null
                      ? chatsCubit.formatMessageDate(lastMessage.createdAt)
                      : "No messages",
                  friendData: friend,
                  messageCount: messagesCount,
                  messageText: lastMessage?.messageText ?? "No messages yet",
                  isLastMessageFromFriend:
                      lastMessage?.senderId == friend.friendId,
                  isLastMessageSeenByUser: lastMessage?.isRead ?? false,
                  onTap: () {
                    messagesCubit.onEnterChat(friend.friendId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(friendUser: friend),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}
