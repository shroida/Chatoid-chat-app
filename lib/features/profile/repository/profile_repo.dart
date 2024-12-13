import 'package:chatoid/core/utlis/user_data.dart';

mixin ProfileRepo {
  Future<List<UserData>> fetchFriends(int userId);
}
