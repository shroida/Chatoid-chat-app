import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:chatoid/core/utlis/user_data.dart';

abstract class ChatsState {}

class ChatInitial extends ChatsState {}

class ChatLoading extends ChatsState {}
class ChatEmpty extends ChatsState {}

class ChatFriendsFetched extends ChatsState {
  final List<UserData> friendsList;

  ChatFriendsFetched({required this.friendsList});
}

class ChatMessagesFetched extends ChatsState {
  final List<ClsMessage> friendMessages;

  ChatMessagesFetched({required this.friendMessages});
}

class AllUsersLoaded extends ChatsState {
  final List<UserData> allUsersFetched;

  AllUsersLoaded({required this.allUsersFetched});
}

class ChatError extends ChatsState {
  final String message;

  ChatError(this.message);
}
