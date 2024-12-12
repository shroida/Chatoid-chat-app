import 'dart:convert';

import 'package:chatoid/zRefactor/features/messages/model/clsMessage.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/messages/repository/msg_repo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
  Future<void> sendPushNotification(
      String playerId, String message, String senderusername) async {
    const String onesignalAppId = 'e1416184-6af7-4fcc-8603-72e042e1718d';
    const String onesignalApiKey =
        'NjkxZDkwMWMtMGMyZC00NTBhLWI5N2EtNmE0ZTA4MTA1MGUx';

    const url = 'https://onesignal.com/api/v1/notifications';

    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Basic $onesignalApiKey',
    };

    final body = jsonEncode({
      'app_id': onesignalAppId,
      'include_player_ids': [playerId],
      'contents': {'en': message},
      'headings': {'en': senderusername},
    });

    await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
  }

  @override
  Future<void> leaveChat(LoginCubit loginCubit) async {
    try {
      print('sdfsdfsdf leeeeaaaaaaaa ss${loginCubit.currentUser.username}');
      await supabase.client
          .from('user_profiles')
          .update({'in_chat': null}) // Set in_chat to null
          .eq('user_id',
              loginCubit.currentUser.user_id); // Target the current user
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
          .eq('receiver_id', loginCubit.currentUser.user_id);
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
          {'in_chat': friendId}).eq('user_id', loginCubit.currentUser.user_id);
    } catch (e) {}
  }
}
