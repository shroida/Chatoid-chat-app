// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatoid/features/notification/repository/noti_repo_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:chatoid/features/messages/repository/msg_repo_impl.dart';
import 'package:chatoid/features/messages/view_model/messagesCubit/messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final ChatsCubit chatsCubit;
  final LoginCubit loginCubit;
  MessagesCubit({
    required this.chatsCubit,
    required this.loginCubit,
  }) : super(MessagesInitial());

  final supabase = Supabase.instance;
  final MsgRepoImpl _msgRepoImpl = MsgRepoImpl();
  final NotiRepoImpl _notiRepoImpl = NotiRepoImpl();

  Future<void> sendMessage(int senderId, int receiverId, String messageText,
      {bool willReply = false,
      String? messageTextWillReply,
      bool? makeItReadWeAreInChat}) async {
    clsMessage newMessage = clsMessage(
      senderId: senderId,
      friendId: receiverId,
      messageText: messageText,
      createdAt: DateTime.now(),
      isRead: false,
      messsagReply: willReply ? messageTextWillReply : null,
    );

    chatsCubit.friendMessages.add(newMessage);

    try {
      await supabase.client.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message_text': messageText,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': makeItReadWeAreInChat ?? false,
        'message_reply': messageTextWillReply
      });
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Try to send from home page'),
          backgroundColor: Colors.green,
        ),
      );
    }

    await _msgRepoImpl.saveMessages(chatsCubit.friendMessages);

    String senderUsername = await _msgRepoImpl.fetchUsername(senderId);
    if (await ifTwoUsersInChat(loginCubit.currentUser.userId, receiverId) ==
        false) {
      _notiRepoImpl.sendPushNotification(
          receiverId, messageText, senderUsername);
    }
  }

  Future<bool> ifTwoUsersInChat(int currentUserId, int friendId) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('user_id, in_chat')
          .or('user_id.eq.$currentUserId,user_id.eq.$friendId');

      if (response.isNotEmpty && response.length == 2) {
        var currentUserChat;
        var friendChat;

        for (var user in response) {
          if (user['user_id'] == currentUserId) {
            currentUserChat = user['in_chat'];
          } else if (user['user_id'] == friendId) {
            friendChat = user['in_chat'];
          }
        }

        if (currentUserChat != null && friendChat != null) {
          return currentUserChat == friendId && friendChat == currentUserId;
        }
      }
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Error showing chat status'),
          backgroundColor: Colors.green,
        ),
      );
    }
    return false;
  }

  void onLeaveChat() {
    _msgRepoImpl.leaveChat(loginCubit);
  }

  void onEnterChat(int friendId) {
    makeMessagesIsRead(friendId);
    makeMeInChatUser(friendId);
    ifTwoUsersInChat(loginCubit.currentUser.userId, friendId);
  }

  Future<void> makeMeInChatUser(int friendId) async {
    try {
      await supabase.client.from('user_profiles').update(
          {'in_chat': friendId}).eq('user_id', loginCubit.currentUser.userId);
    } catch (e) {
      print('Error updating messages to read: $e');
    }
  }

  Future<void> makeMessagesIsRead(int senderId) async {
    try {
      final supabase = Supabase.instance.client;

      // Update only the messages where you are the receiver and senderId is the sender
      await supabase
          .from('messages')
          .update({'is_read': true}) // Set is_read to true
          .eq('sender_id',
              senderId) // Match senderId (messages sent by this user)
          .eq('receiver_id',
              loginCubit.currentUser.userId); // Match receiverId (you)
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Try to send from home page'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> deleteMessage(clsMessage message) async {
    await supabase.client
        .from('messages')
        .delete()
        .eq('message_text', message.messageText)
        .or('receiver_id.eq.${message.senderId},receiver_id.eq.${message.friendId}') // Correct usage of OR for receiver_id
        .or('sender_id.eq.${message.senderId},sender_id.eq.${message.friendId}'); // Correct usage of OR for sender_id
  }


}
