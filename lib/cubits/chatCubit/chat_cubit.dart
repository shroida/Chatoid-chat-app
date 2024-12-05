import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:chatoid/cubits/chatCubit/chat_state.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/data/models/tables/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  List<UserData> friendsList = [];
  bool isLoading = true; // Initially loading
  List<clsMessage> friendMessages = []; // Store messages for each friend
  List<Function> subscriptions = []; // Store your subscription functions
  final supabase = Supabase.instance;
  void unsubscribe() {
    for (var unsubscribe in subscriptions) {
      unsubscribe();
    }
    subscriptions.clear(); // Clear the list after unsubscribing
  }

  // Ensure this is how you're using emit in your fetchFriends method
  Future<void> fetchFriends(int currentUserId) async {
    emit(ChatLoading());
    try {
      final response = await supabase.client
          .from('friendships')
          .select(
              'user_id, friend_id, user_profiles_friend:friend_id(username, email), user_profiles_user:user_id(username, email)')
          .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId');

      if (response.isNotEmpty) {
        final Set<int> uniqueFriendIds = Set();
        friendsList = [];

        for (var friend in response) {
          int friendUserId;
          Map<String, dynamic> userProfile;

          if (friend['user_id'] == currentUserId) {
            friendUserId = friend['friend_id'];
            userProfile =
                friend['user_profiles_friend'] as Map<String, dynamic>;
          } else {
            friendUserId = friend['user_id'];
            userProfile = friend['user_profiles_user'] as Map<String, dynamic>;
          }

          if (uniqueFriendIds.add(friendUserId)) {
            friendsList.add(UserData.fromJson({
              'friend_id': friendUserId,
              'user_id': currentUserId,
              'username': userProfile['username'] ?? 'Unknown User',
              'email': userProfile['email'] ?? 'Unknown Email',
            }));
          }
        }
        await saveFriendList(friendsList);

        emit(ChatFriendsFetched(friendsList: friendsList));
        
      } else {
        emit(ChatFriendsFetched(friendsList: []));
       
      }
    } catch (e) {
      emit(ChatError("Error fetching friends: $e"));
    }
  }

  Future<void> saveFriendList(List<UserData> friendsListToSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> friendsJsonList = friendsListToSave
        .map((friend) => jsonEncode(friend.toJson()))
        .toList(); // Convert the list of friends to JSON
    await prefs.setStringList(
        'friends_list', friendsJsonList); // Save the list of friends
  }

  Future<void> fetchAllMessages(UserData currentUser) async {
    emit(ChatLoading()); // Emit loading state for messages
    try {
      final response = await supabase.client
          .from('messages')
          .select(
              'id, message_text, sender_id, receiver_id, created_at, is_read')
          .or('sender_id.eq.${currentUser.user_id},receiver_id.eq.${currentUser.user_id}');

      if (response.isNotEmpty) {
        friendMessages.clear();
        for (var message in response) {
          friendMessages.add(clsMessage(
            senderId: message['sender_id'] as int,
            friendId: message['receiver_id'] as int,
            messageText: message['message_text'] as String,
            createdAt: DateTime.parse(message['created_at']),
            isRead: message['is_read'] as bool,
          ));
        }
        await saveMessages(friendMessages);
        emit(ChatMessagesFetched(
            friendMessages: friendMessages)); // Emit messages fetched state
      } else {
        emit(ChatMessagesFetched(
            friendMessages: [])); // Emit empty messages list
      }
    } catch (e) {
      emit(ChatError(
          "Error fetching messages: $e")); // Emit error state for messages
    }
  }

  Future<void> saveMessages(List<clsMessage> messagesToSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesJsonList = messagesToSave
        .map((message) => jsonEncode(message.toJson()))
        .toList(); // Convert messages to JSON
    await prefs.setStringList(
        'messages_list', messagesJsonList); // Save messages
  }

  Future<void> subscribe(
    String table,
    Future<void> Function() callbackAction,
    int userId, // Renamed for clarity
  ) async {
    try {
      Supabase.instance.client
          .channel('public:$table')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            callback: (payload) async {
              await callbackAction(); // Perform action when a change is detected
            },
          )
          .subscribe(); // Subscribe to the channel
    } catch (e) {
    }
  }

 
  Future<void> leaveChat(BuildContext context) async {
    try {
      await supabase.client
          .from('user_profiles')
          .update({'in_chat': null}) // Set in_chat to null
          .eq(
              'user_id',
              BlocProvider.of<LoginCubit>(context)
                  .currentUser
                  .user_id); // Target the current user
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

  void onLeaveChat(BuildContext context) {
    leaveChat(context);
  }

  void onEnterChat(int friendId, BuildContext context) {
    makeMessagesIsRead(friendId, context);
    makeMeInChatUser(friendId, context);
    ifTwoUsersInChat(
        BlocProvider.of<LoginCubit>(context).currentUser.user_id, friendId);
  }

  Future<void> makeMessagesIsRead(int senderId, BuildContext context) async {
    try {
      final supabase = Supabase.instance.client;

      // Update only the messages where you are the receiver and senderId is the sender
      await supabase
          .from('messages')
          .update({'is_read': true}) 
          .eq('sender_id',
              senderId) // Match senderId (messages sent by this user)
          .eq(
              'receiver_id',
              BlocProvider.of<LoginCubit>(context)
                  .currentUser
                  .user_id); // Match receiverId (you)
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

  Future<void> makeMeInChatUser(int friendId, BuildContext context) async {
    try {
      await supabase.client
          .from('user_profiles')
          .update({'in_chat': friendId}).eq('user_id',
              BlocProvider.of<LoginCubit>(context).currentUser.user_id);
    } catch (e) {
    }
  }

  Future<bool> ifTwoUsersInChat(int currentUserId, int friendId) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('user_id, in_chat')
          .or('user_id.eq.$currentUserId,user_id.eq.$friendId'); // Check both users

      if (response.isNotEmpty && response.length == 2) {
        var currentUserChat;
        var friendChat;

        // Ensure that we correctly assign the chats to the corresponding users
        for (var user in response) {
          if (user['user_id'] == currentUserId) {
            currentUserChat = user['in_chat'];
          } else if (user['user_id'] == friendId) {
            friendChat = user['in_chat'];
          }
        }

        // Ensure both users' in_chat are not null or empty
        if (currentUserChat != null && friendChat != null) {
          // Return true if both users are in each other's in_chat
          return currentUserChat == friendId && friendChat == currentUserId;
        } else {
        }
      } else {
      }
    } catch (e) {
      final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
          GlobalKey<ScaffoldMessengerState>();

      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Erorr to show who is in chat '),
          backgroundColor: Colors.green,
        ),
      );
    }
    return false; // Return false if users are not in chat together
  }
}
