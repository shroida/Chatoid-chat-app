import 'package:chatoid/zRefactor/features/messages/model/clsMessage.dart';
import 'package:chatoid/data/models/userData/user_data.dart';

mixin ChatRepo {
  Future<void> saveFriendList(List<UserData> friendsListToSave)async{}
  Future<void> saveMessages(List<clsMessage> messagesToSave)async{}
}
