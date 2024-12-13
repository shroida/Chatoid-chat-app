import 'dart:convert';

import 'package:chatoid/zRefactor/features/notification/repository/noti_repo.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotiRepoImpl with NotiRepo {
  final supabase = Supabase.instance;
  @override
  Future<void> sendPushNotification(
      int receiverId, String message, String senderusername) async {
    const String onesignalAppId = 'e1416184-6af7-4fcc-8603-72e042e1718d';
    const String onesignalApiKey =
        'NjkxZDkwMWMtMGMyZC00NTBhLWI5N2EtNmE0ZTA4MTA1MGUx';

    const url = 'https://onesignal.com/api/v1/notifications';

    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Basic $onesignalApiKey',
    };
    String playerId;
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('player_id')
          .eq('user_id', receiverId)
          .single();

      playerId = response['player_id'];
    } catch (e) {
      playerId = ''; // Set playerId to null if there's an error
    }
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
