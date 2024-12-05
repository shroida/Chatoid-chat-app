import 'dart:async';
import 'dart:convert';
import 'package:chatoid/data/models/tables/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

final supabase = Supabase.instance;

class ChatProvider extends ChangeNotifier {
  final LoginCubit loginCubit;

  ChatProvider({required this.loginCubit});

  List<UserData> friendsList = [];
  bool isLoading = true; // Initially loading
  List<clsMessage> friendMessages = []; // Store messages for each friend

  Future<void> saveFriendData(UserData friend) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('friend', jsonEncode(friend.toJson()));
  }

  Future<void> saveFriendList(List<UserData> friendsListToSave) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> friendsJsonList = friendsListToSave
        .map((friend) => jsonEncode(friend.toJson()))
        .toList(); // Convert the list of friends to JSON
    await prefs.setStringList(
        'friends_list', friendsJsonList); // Save the list of friends
  }

  Future<void> loadFriendsList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? friendsJsonList = prefs.getStringList('friends_list');

    if (friendsJsonList != null) {
      friendsList = friendsJsonList
          .map((friendJson) => UserData.fromJson(jsonDecode(friendJson)))
          .toList();
    } else {
    }
    notifyListeners(); // Notify listeners that friends list has been updated
  }

  Future<void> fetchFriends(int currentUserId) async {
    try {
      final response = await supabase.client
          .from('friendships')
          .select(
              'user_id, friend_id, user_profiles_friend:friend_id(username, email), user_profiles_user:user_id(username, email)')
          .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId');

      isLoading = false;
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
        await saveFriendList(friendsList); // Save updated friends list
        notifyListeners();
      } else {
        friendsList = [];
      }
    } catch (e) {
    }
  }

  Future<void> loadMessages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? messagesJsonList = prefs.getStringList('messages_list');

    if (messagesJsonList != null) {
      friendMessages = messagesJsonList
          .map((messageJson) => clsMessage.fromJson(jsonDecode(messageJson)))
          .toList();
    } else {
    }
    notifyListeners(); // Notify listeners that messages have been updated
  }

  Future<void> fetchAllMessages(UserData currentUser) async {

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final response = await supabase.client
          .from('messages')
          .select(
              'id, message_text, sender_id, receiver_id, created_at, is_read, message_reply,reaction') // Include message_reply here
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
            messsagReply: message['message_reply'] as String?, // Add this line
            react: message['reaction'] as String?, // New field for reaction
          ));
        }
        await saveMessages(friendMessages); // Save messages after fetching
        notifyListeners();
      } else {
      }
    } catch (e) {
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
  ) async {
    try {
      final channel = Supabase.instance.client
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

  List<Function> subscriptions = []; // Store your subscription functions

  void unsubscribe() {
    for (var unsubscribe in subscriptions) {
      unsubscribe();
    }
    subscriptions.clear(); // Clear the list after unsubscribing
  }

  clsMessage? getLatestMessage(int userId) {
    // Filter messages for the given userId
    final userMessages =
        friendMessages.where((msg) => msg.friendId == userId).toList();

    userMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return userMessages.isNotEmpty ? userMessages.first : null;
  }

  Future<void> subscribeToFriendsUpdates(int userId) async {
    // Assume supabase is your Supabase client instance
    final response = await supabase.client
        .channel('friendships')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'friendships',
            callback: (payload) {
            })
        .subscribe();
    notifyListeners();
  }

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

    friendMessages.add(newMessage);
    notifyListeners();

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

    await saveMessages(friendMessages);

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
    if (await ifTwoUsersInChat(loginCubit.currentUser.user_id, receiverId) ==
        false) {
      sendPushNotification(playerId, messageText, senderUsername);
    }

    notifyListeners();
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
              loginCubit.currentUser.user_id); // Match receiverId (you)
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

  Future<void> upLoadImageProfile(String imagePath, int userid) async {
    try {
      // Update the user's profile image where user_id matches the provided userid
      await supabase.client.from('user_profiles').update({
        'profile_image': imagePath,
      }).eq('user_id', userid);

      notifyListeners();
    } catch (e) {
      // Handle any potential errors
    }
  }

  Future<void> addFriend(int currentUserId, UserData friend) async {
    // Prevent adding self as a friend
    if (currentUserId == friend.user_id) return;

    try {
      // Check if friendship already exists
      final response = await supabase.client
          .from('friendships')
          .select()
          .eq('user_id', currentUserId)
          .eq('friend_id', friend.user_id); // Make sure to call execute()

      // Check if there is a friendship record
      if (response.isNotEmpty) {
        return; // Friendship already exists
      }

      // If no friendship exists, proceed to insert a new record
      final insertResponse = await supabase.client.from('friendships').insert({
        'user_id': currentUserId,
        'friend_id': friend.user_id,
        'status': 'accepted',
        'created_at': DateTime.now().toIso8601String(),
      }); // Make sure to call

      // Check for errors in the insert response
      if (insertResponse.error != null) {
        return;
      }

      // Update local friends list
      friendsList.add(friend);
      await saveFriendList(friendsList); // Save friends list after adding
      notifyListeners(); // Notify listeners after updating
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

  void onEnterChat(int friendId) {
    makeMessagesIsRead(friendId);
    makeMeInChatUser(friendId);
    ifTwoUsersInChat(loginCubit.currentUser.user_id, friendId);
  }

  void onLeaveChat() {
    leaveChat();
  }

  Future<void> makeMeInChatUser(int friendId) async {
    try {
      await supabase.client.from('user_profiles').update(
          {'in_chat': friendId}).eq('user_id', loginCubit.currentUser.user_id);
      notifyListeners(); // Update UI
    } catch (e) {
    }
  }

  Future<void> leaveChat() async {
    try {
      await supabase.client
          .from('user_profiles')
          .update({'in_chat': null}) // Set in_chat to null
          .eq('user_id',
              loginCubit.currentUser.user_id); // Target the current user
      notifyListeners(); // Update UI
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

  Future<clsMessage?> fillMessageIWillReplyByID(int id) async {
    try {
      final response = await Supabase.instance.client
          .from('messages') // Use your actual table name
          .select(
              'sender_id, receiver_id, message_text, created_at, is_read') // Select necessary columns
          .eq('id', id)
          .single(); // Fetch a single row

      // Directly retrieve and return a clsMessage instance using the response data
      return clsMessage(
        senderId: response['sender_id'] as int,
        friendId: response['receiver_id'] as int,
        messageText: response['message_text'] as String,
        createdAt: DateTime.parse(response['created_at'] as String),
        isRead: response['is_read'] as bool,
      );
    } catch (e) {
      return null; // Return null if there's an error or exception
    }
  }

  Future<void> setReactOnMessage(
    String messageText,
    int receiverId,
    int senderId,
    String reaction, // Add reaction as an argument
  ) async {
    final response = await supabase.client
        .from('messages')
        .update({'reaction': reaction})
        .eq('sender_id', senderId)
        .eq('message_text', messageText)
        .eq('receiver_id', receiverId);

    if (response != null) {
    } else {
    }
  }

  Future<void> deleteMessage(clsMessage message) async {
    final response = await supabase.client
        .from('messages')
        .delete()
        .eq('message_text', message.messageText)
        .or('receiver_id.eq.${message.senderId},receiver_id.eq.${message.friendId}') // Correct usage of OR for receiver_id
        .or('sender_id.eq.${message.senderId},sender_id.eq.${message.friendId}'); // Correct usage of OR for sender_id
  }
}
