import 'package:chatoid/features/messages/model/cls_message.dart';
import 'package:chatoid/core/utlis/user_data.dart';

mixin ChatRepo {
  Future<void> saveFriendList(List<UserData> friendsListToSave) async {}
  Future<void> saveMessages(List<ClsMessage> messagesToSave) async {}
  Future<void> addFriend(int currentUserId, UserData friend) async {}
}
