import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';

mixin MsgRepo {
  Future<void> saveMessages(List<ClsMessage> messagesToSave) async {}
  Future<void> leaveChat(LoginCubit loginCubit) async {}
  Future<void> makeMessagesIsRead(int senderId, LoginCubit loginCubit) async {}
  Future<void> makeMeInChatUser(int friendId, LoginCubit loginCubit) async {}

  Future<String> fetchUsername(int userId);
}
