import 'package:chatoid/features/messages/model/cls_message.dart';


sealed class MessagesState {}

final class MessagesInitial extends MessagesState {}

final class MessagesLoading extends MessagesState {}

final class MessagesSend extends MessagesState {
  final List<ClsMessage> messages;

  MessagesSend(this.messages);
}

final class MessagesError extends MessagesState {
  final String message;

  MessagesError(this.message);
}
