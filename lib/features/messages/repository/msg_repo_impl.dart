import 'dart:convert';

import 'package:chatoid/features/messages/model/clsMessage.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/messages/repository/msg_repo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MsgRepoImpl with MsgRepo {
  final supabase = Supabase.instance;
  @override
  Future<void> saveMessages(List<clsMessage> messagesToSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesJsonList = messagesToSave
        .map((message) => jsonEncode(message.toJson()))
        .toList(); // Convert messages to JSON
    await prefs.setStringList('messages_list', messagesJsonList);
  }

  @override
  Future<void> leaveChat(LoginCubit loginCubit) async {
    try {
      await supabase.client
          .from('user_profiles')
          .update({'in_chat': null}) // Set in_chat to null
          .eq('user_id',
              loginCubit.currentUser.userId); // Target the current user
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

  @override
  Future<void> makeMessagesIsRead(int senderId, LoginCubit loginCubit) async {
    try {
      final supabase = Supabase.instance.client;

      await supabase
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', senderId)
          .eq('receiver_id', loginCubit.currentUser.userId);
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

  @override
  Future<void> makeMeInChatUser(int friendId, LoginCubit loginCubit) async {
    try {
      await supabase.client.from('user_profiles').update(
          {'in_chat': friendId}).eq('user_id', loginCubit.currentUser.userId);
    } catch (e) {}
  }
  @override
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
}
