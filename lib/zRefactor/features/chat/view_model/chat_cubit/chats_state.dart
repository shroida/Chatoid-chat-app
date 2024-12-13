import 'package:chatoid/zRefactor/features/messages/model/clsMessage.dart';
import 'package:chatoid/zRefactor/core/utlis/user_data.dart';

abstract class ChatsState {}

class ChatInitial extends ChatsState {}

class ChatLoading extends ChatsState {}
class ChatEmpty extends ChatsState {}

class ChatFriendsFetched extends ChatsState {
  final List<UserData> friendsList;

  ChatFriendsFetched({required this.friendsList});
}

class ChatMessagesFetched extends ChatsState {
  final List<clsMessage> friendMessages;

  ChatMessagesFetched({required this.friendMessages});
}

class ChatError extends ChatsState {
  final String message;

  ChatError(this.message);
}
