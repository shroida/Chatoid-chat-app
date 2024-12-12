import 'package:chatoid/zRefactor/features/messages/model/clsMessage.dart';

// Notification State
abstract class NotificationState  {
  const NotificationState();
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<clsMessage> notifications;

  const NotificationSuccess(this.notifications);

  @override
  List<Object> get props => [notifications];
}

class NotificationFailure extends NotificationState {
  final String error;

  const NotificationFailure(this.error);

  @override
  List<Object> get props => [error];
}
