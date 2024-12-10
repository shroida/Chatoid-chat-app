import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/cubits/messagesCubit/messages_state.dart';
import 'package:chatoid/cubits/notificationsCubit/notification_cubit.dart';
import 'package:chatoid/data/models/tables/clsMessage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final ChatsCubit chatCubit;
  final LoginCubit loginCubit;
  final NotificationCubit notificationCubit; // Inject notificationCubit

  MessagesCubit({
    required this.chatCubit,
    required this.loginCubit,
    required this.notificationCubit, // Pass notificationCubit
  }) : super(MessagesInitial());

  final supabase = Supabase.instance;

  Future<void> sendMessage(
      int senderId, int receiverId, String messageText) async {
    clsMessage newMessage = clsMessage(
      senderId: senderId,
      friendId: receiverId,
      messageText: messageText,
      createdAt: DateTime.now(),
      isRead: false,
    );

    final updatedMessages = List<clsMessage>.from(chatCubit.friendMessages)
      ..add(newMessage);
    emit(MessagesSend(updatedMessages));

    try {
      // Save the message to Supabase database
      await supabase.client.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message_text': messageText,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
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

    await saveMessages(updatedMessages);

    String playerId;
    try {
      // Fetch the receiver's player_id for push notifications
      final response = await supabase.client
          .from('user_profiles')
          .select('player_id')
          .eq('user_id', receiverId)
          .single();

      playerId = response['player_id'];
    } catch (e) {
      playerId = ''; // Set playerId to an empty string if there's an error
    }

    String senderUsername = await fetchUsername(senderId);

    // Only send a notification if both users are not in the same chat
    if (await ifTwoUsersInChat(loginCubit.currentUser.user_id, receiverId) ==
        false) {
      // Use notificationCubit to send push notification
      notificationCubit.sendPushNotification(
        playerId,
        messageText,
        senderUsername,
      );
    }
  }

  Future<String> fetchUsername(int userId) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('username')
          .eq('user_id', userId)
          .single();
      return response['username'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
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

  Future<void> saveMessages(List<clsMessage> messagesToSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesJsonList = messagesToSave
        .map((message) => jsonEncode(message.toJson()))
        .toList(); // Convert messages to JSON
    await prefs.setStringList('messages_list', messagesJsonList);
  }
}
