import 'package:chatoid/data/models/tables/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatFriendsFetched extends ChatState {
  final List<UserData> friendsList;

  ChatFriendsFetched({required this.friendsList});
}

class ChatMessagesFetched extends ChatState {
  final List<clsMessage> friendMessages;

  ChatMessagesFetched({required this.friendMessages});
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);
}
