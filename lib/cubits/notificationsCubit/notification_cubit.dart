import 'dart:convert';
import 'package:chatoid/cubits/notificationsCubit/notification_state.dart';
import 'package:chatoid/zRefactor/features/chat/model/clsMessage.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient supabase = Supabase.instance.client;

  final ChatsCubit chatCubit; // Use dependency injection for ChatCubit

  NotificationCubit(this.chatCubit) : super(NotificationInitial()) {
    _initializeNotifications();
  }

  List<clsMessage> notifications = [];

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      emit(NotificationFailure('Failed to initialize notifications'));
    }
  }

  Future<String> fetchUsername(int userId) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('username')
          .eq('user_id', userId)
          .single();

      return response['username'] ?? 'Unknown';
    } catch (e) {
      return 'Unknown'; // Fallback if fetching username fails
    }
  }

  Future<void> insertMessageIntoDatabase(
      int senderId, int receiverId, String messageText) async {
    emit(NotificationLoading());

    try {
      await supabase.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message_text': messageText,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });

      // await chatCubit.saveMessages(chatCubit.friendMessages);
      emit(NotificationSuccess(chatCubit.friendMessages));
    } catch (e) {
      emit(NotificationFailure('Failed to insert message into database'));
    }
  }

  Future<String?> fetchPlayerId(int userId) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select('player_id')
          .eq('user_id', userId.toString())
          .single();

      return response['player_id'] as String?;
    } catch (e) {
      return null; // Indicate failure
    }
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
