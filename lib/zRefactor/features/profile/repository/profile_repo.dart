import 'package:chatoid/data/models/userData/user_data.dart';

mixin ProfileRepo {
  Future<List<UserData>> fetchFriends(int userId);
}
