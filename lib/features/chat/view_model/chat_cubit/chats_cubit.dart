import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/chat/repository/chat_repo_impl.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_state.dart';
import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(ChatInitial());

  List<UserData> friendsList = [];
  List<UserData> allUsersApp = [];
  final supabase = Supabase.instance;
  List<ClsMessage> friendMessages = [];
  List<ClsMessage> allUsersMessagesGroup = [];

  final ChatRepoImpl _chatRepoImpl = ChatRepoImpl();

  Future<void> fetchFriends(int currentUserId) async {
    emit(ChatLoading());
    try {
      final response = await supabase.client
          .from('friendships')
          .select(
              'user_id, friend_id, user_profiles_friend:friend_id(username, email), user_profiles_user:user_id(username, email)')
          .or('user_id.eq.$currentUserId,friend_id.eq.$currentUserId');

      if (response.isNotEmpty) {
        final Set<int> uniqueFriendIds = {};
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
        await _chatRepoImpl.saveFriendList(friendsList);

        emit(ChatFriendsFetched(friendsList: friendsList));
      } else {
        emit(ChatFriendsFetched(friendsList: []));
      }
    } catch (e) {
      emit(ChatError("Error fetching friends: $e"));
    }
  }

  Future<void> fetchAllUsersGroup() async {
    emit(ChatLoading());
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('user_id, username,email');

      if (response.isNotEmpty) {
        {
          for (var user in response) {
            allUsersApp.add(UserData(
                userId: user['user_id'],
                friendId: -1,
                username: user['username'],
                email: user['email']));
          }
        }

        await _chatRepoImpl.saveFriendList(allUsersApp);
      }
    } catch (e) {
      emit(ChatError("Error fetching friends: $e"));
    }
  }

  Future<void> fetchAllMessages(UserData currentUser) async {
    emit(ChatLoading()); // Emit loading state for messages
    try {
      final response = await supabase.client
          .from('messages')
          .select(
              'id, message_text, sender_id, receiver_id, created_at, is_read, message_reply,reaction') // Include message_reply here
          .or('sender_id.eq.${currentUser.userId},receiver_id.eq.${currentUser.userId}');
      if (response.isNotEmpty) {
        friendMessages.clear();
        for (var message in response) {
          friendMessages.add(ClsMessage(
            senderId: message['sender_id'] as int,
            friendId: message['receiver_id'] as int,
            messageText: message['message_text'] as String,
            createdAt: DateTime.parse(message['created_at']),
            isRead: message['is_read'] as bool,
            messsagReply: message['message_reply'] as String?, // Add this line
            react: message['reaction'] as String?, // New field for reaction
          ));
        }
        await _chatRepoImpl.saveMessages(friendMessages);
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

  Future<void> fetchAllMessagesInGroupForAllUsers() async {
    emit(ChatLoading());
    try {
      final response = await supabase.client
          .from('all_messages_group')
          .select('id, user_id, created_at, msg_text, message_reply');

      allUsersMessagesGroup.clear();
      for (var message in response) {
        allUsersMessagesGroup.add(ClsMessage(
          senderId: message['user_id'] as int,
          friendId: -1,
          messageText: message['msg_text'] as String,
          createdAt: DateTime.parse(message['created_at']),
          isRead: false,
          messsagReply: message['message_reply'] as String?,
        ));
      }
    } catch (e) {
      print("Error fetching messages: $e");
      emit(ChatError("Error fetching messages: $e"));
    }
  }

  String formatMessageDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference > 8) {
      // More than 2 days ago
      return DateFormat('hh:mm a\ndd/MM/yyyy ').format(date);
    } else {
      // Within the last 2 days
      String hour = (date.hour < 10 ? '0' : '') +
          (date.hour > 12 ? '${date.hour - 12}' : '${date.hour}');
      String minute = date.minute < 10 ? '0${date.minute}' : '${date.minute}';
      String period = date.hour >= 12 ? 'PM' : 'AM';

      return "$hour:$minute $period";
    }
  }

  Future<void> subscribe(
    String table,
    Future<void> Function() callbackAction,
  ) async {
    try {
      supabase.client
          .channel('public:$table')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            callback: (payload) async {
              await callbackAction();
            },
          )
          .subscribe();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setReactOnMessage(
    String messageText,
    int receiverId,
    int senderId,
    String reaction,
  ) async {
    final response = await supabase.client
        .from('messages')
        .update({'reaction': reaction})
        .eq('sender_id', senderId)
        .eq('message_text', messageText)
        .eq('receiver_id', receiverId);

    if (response != null) {
    } else {}
  }

  Future<void> addFriend(int currentUserId, UserData friend) async {
    final supabase = Supabase.instance;
    if (currentUserId == friend.userId) return;

    try {
      // Check if friendship already exists
      final response = await supabase.client
          .from('friendships')
          .select()
          .eq('user_id', currentUserId)
          .eq('friend_id', friend.userId); // Make sure to call execute()

      // Check if there is a friendship record
      if (response.isNotEmpty) {
        return; // Friendship already exists
      }

      // If no friendship exists, proceed to insert a new record
      final insertResponse = await supabase.client.from('friendships').insert({
        'user_id': currentUserId,
        'friend_id': friend.userId,
        'status': 'accepted',
        'created_at': DateTime.now().toIso8601String(),
      }); // Make sure to call

      if (insertResponse.error != null) {
        return;
      }

      // Update local friends list
      friendsList.add(friend);
      await _chatRepoImpl
          .saveFriendList(friendsList); // Save friends list after adding
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
