import 'package:chatoid/zRefactor/features/messages/model/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/chat/repository/chat_repo_impl.dart';
import 'package:chatoid/zRefactor/features/chat/view_model/chat_cubit/chats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(ChatInitial());

  List<UserData> friendsList = [];
  final supabase = Supabase.instance;
  List<clsMessage> friendMessages = []; // Store messages for each friend

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
        await _chatRepoImpl.saveFriendList(friendsList);

        emit(ChatFriendsFetched(friendsList: friendsList));
      } else {
        emit(ChatFriendsFetched(friendsList: []));
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
    } catch (e) {}
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