import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/zRefactor/features/messages/repository/msg_repo_impl.dart';
import 'package:chatoid/zRefactor/features/messages/view_model/messagesCubit/messages_state.dart';
import 'package:chatoid/zRefactor/features/chat/model/clsMessage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final ChatsCubit chatsCubit;
  final LoginCubit authProvider;
  MessagesCubit({
    required this.chatsCubit,
    required this.authProvider,
  }) : super(MessagesInitial());


  final supabase = Supabase.instance;
  final MsgRepoImpl _msgRepoImpl = MsgRepoImpl();

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

    String senderUsername = await fetchUsername(senderId);
    if (await ifTwoUsersInChat(authProvider.currentUser.user_id, receiverId) ==
        false) {
      _msgRepoImpl.sendPushNotification(playerId, messageText, senderUsername);
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

  void onLeaveChat() {
    print('username ${authProvider.currentUser.username}');

    _msgRepoImpl.leaveChat(authProvider);
  }

  // void onEnterChat(int friendId) async {
  //   print('Entering chat with friendId: $friendId');
  //   print('LoginCubit User ID: ${loginCubit.currentUser.user_id}');
  //   print('LoginCubit User name: ${loginCubit.currentUser.username}');
  //   print('ChatsCubit Messages: ${chatsCubit.friendMessages[10].messageText}');
  //   await _msgRepoImpl.makeMessagesIsRead(friendId, loginCubit);
  //   await _msgRepoImpl.makeMeInChatUser(friendId, loginCubit);
  //   await ifTwoUsersInChat(loginCubit.currentUser.user_id, friendId);
  // }
  void onEnterChat(int friendId) {
    print(
        'username from authProvider cubit ${authProvider.currentUser.username}');
    print('test for chatsCubit ${chatsCubit.friendsList[5].username}');

    print('onEnterChat');
    makeMessagesIsRead(friendId);
    makeMeInChatUser(friendId);
    ifTwoUsersInChat(authProvider.currentUser.user_id, friendId);
  }

  Future<void> makeMeInChatUser(int friendId) async {
    try {
      print('makeMeInChatUser');

      await supabase.client
          .from('user_profiles')
          .update({'in_chat': friendId}).eq(
              'user_id', authProvider.currentUser.user_id);
    } catch (e) {
      print('Error updating messages to read: $e');
    }
  }

  Future<void> makeMessagesIsRead(int senderId) async {
    try {
      final supabase = Supabase.instance.client;
      print('makeMessagesIsRead');

      // Update only the messages where you are the receiver and senderId is the sender
      await supabase
          .from('messages')
          .update({'is_read': true}) // Set is_read to true
          .eq('sender_id',
              senderId) // Match senderId (messages sent by this user)
          .eq('receiver_id',
              authProvider.currentUser.user_id); // Match receiverId (you)
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
}
