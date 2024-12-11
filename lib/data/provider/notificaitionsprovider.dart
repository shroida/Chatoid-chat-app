import 'dart:convert';

import 'package:chatoid/data/models/notification/notification.dart';
import 'package:chatoid/data/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationProvider with ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final supabase = Supabase.instance;

  final ChatProvider chatProvider; // Use dependency injection
  NotificationProvider(this.chatProvider) {
    _initializeNotifications();
  }

  List<NotificationModel> notifications = [];

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<String> fetchUsername(int userId) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('username')
          .eq('user_id', userId)
          .single();

      return response['username'] ??
          'Unknown'; // Fallback if username is not found
    } catch (e) {
      return 'Unknown'; // Fallback if fetching username fails
    }
  }

  Future<bool> insertMessageIntoDatabase(
      int senderId, int receiverId, String messageText) async {
    try {
      await supabase.client.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message_text': messageText,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
      // await chatProvider.saveMessages(chatProvider.friendMessages);
      notifyListeners();
      return true;
    } catch (e) {
      return false; // Indicate failure
    }
  }
  

  Future<String?> fetchPlayerId(int userId) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select(
              'player_id') // Assuming 'player_id' column stores OneSignal player ID
          .eq('user_id', userId.toString())
          .single();

      return response['player_id'] as String?;
    } catch (e) {
      return null; // Indicate failure
    }
  }

  Future<void> _sendPushNotification(
      String receiverPlayerId, String messageText) async {
    try {
      final response =
          await _sendPushNotificationToOneSignal(receiverPlayerId, messageText);

      if (response.statusCode == 200) {
      } else {
      }
    } catch (e) {
    }
  }

  Future<http.Response> _sendPushNotificationToOneSignal(
      String receiverPlayerId, String messageText) async {
    const String oneSignalAppId =
        'YOUR_ONESIGNAL_APP_ID'; // Replace with your OneSignal App ID
    const String oneSignalApiKey =
        'YOUR_ONESIGNAL_API_KEY'; // Replace with your OneSignal API Key

    final uri = Uri.parse('https://onesignal.com/api/v1/notifications');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Basic $oneSignalApiKey', // Your OneSignal REST API Key
    };

    final body = jsonEncode({
      'app_id': oneSignalAppId,
      'include_player_ids': [
        receiverPlayerId
      ], // OneSignal player_id of receiver
      'contents': {'en': messageText}, // Notification content
      'headings': {'en': 'New Message'}, // Notification title
    });

    return await http.post(uri, headers: headers, body: body);
  }

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
}
