import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:chatoid/data/models/tables/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/presntation/widgets/chatCard.dart';
import 'package:chatoid/presntation/screens/chat_screen.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({
    super.key,
    required this.chatsCubit,
    required this.authCubit,
  });

  final ChatsCubit chatsCubit;
  final LoginCubit authCubit;

  clsMessage? _getLastMessage(UserData friend) {
    List<clsMessage> conversationMessages = chatsCubit.friendMessages
        .where((msg) =>
            (msg.senderId == friend.friendId &&
                msg.friendId == authCubit.currentUser.user_id) ||
            (msg.senderId == authCubit.currentUser.user_id &&
                msg.friendId == friend.friendId))
        .toList();

    conversationMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return conversationMessages.isNotEmpty ? conversationMessages.first : null;
  }

  String _formatDate(DateTime date) {
    String hour = (date.hour < 10 ? '0' : '') +
        (date.hour > 12 ? '0${date.hour - 12}' : date.hour.toString());

    String minute = date.minute < 10 ? '0${date.minute}' : '${date.minute}';

    return "$hour:$minute";
  }

  List<clsMessage> _messagesNotReadByMe(
      int friendId, int currentUserId) {
    return chatsCubit.friendMessages
        .where((msg) =>
            friendId == msg.senderId && !msg.isRead && msg.friendId == currentUserId)
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

              List<clsMessage> unreadMessages =
                  _messagesNotReadByMe(friend.friendId, authCubit.currentUser.user_id);
              final messagesCount = unreadMessages.length;

              return ChatCard(
                messageDate: lastMessage != null
                    ? _formatDate(lastMessage.createdAt)
                    : "No messages",
                friendData: friend,
                messageCount: messagesCount,
                messageText: lastMessage?.messageText ?? "No messages yet",
                isLastMessageFromFriend: lastMessage?.senderId == friend.friendId,
                isLastMessageSeenByUser: lastMessage?.isRead ?? false,
                onTap: () {
                  // chatsCubit.onEnterChat(friend.friendId);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(friendUser: friend),
                    ),
                  );
                },
              );
            },
          );
  }
}
