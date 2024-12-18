import 'dart:convert';

import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/repository/chat_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepoImpl with ChatRepo {
  @override
  Future<void> saveFriendList(List<UserData> friendsListToSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> friendsJsonList = friendsListToSave
        .map((friend) => jsonEncode(friend.toJson()))
        .toList(); // Convert the list of friends to JSON
    await prefs.setStringList(
        'friends_list', friendsJsonList); // Save the list of friends
  }

  @override
  Future<void> saveMessages(List<ClsMessage> messagesToSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesJsonList = messagesToSave
        .map((message) => jsonEncode(message.toJson()))
        .toList(); // Convert messages to JSON
    await prefs.setStringList(
        'messages_list', messagesJsonList); // Save messages
  }
}
