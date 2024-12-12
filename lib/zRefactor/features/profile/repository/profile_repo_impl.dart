import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/profile/repository/profile_repo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepoImpl with ProfileRepo {
  @override
  Future<List<UserData>> fetchFriends(int userId) async {
    final supabase = Supabase.instance;
    List<UserData> friendData = [];
    try {
      final response = await supabase.client
          .from('friendships')
          .select(
              'user_id, friend_id, user_profiles_friend:friend_id(username, email), user_profiles_user:user_id(username, email)')
          .or('user_id.eq.$userId,friend_id.eq.$userId');

      if (response.isNotEmpty) {
        final Set<int> uniqueFriendIds = {}; // Ensure no duplicates

        for (var friend in response) {
          int friendUserId;
          Map<String, dynamic> userProfile;

          // Determine the friend's user_id and profile details
          if (friend['user_id'] == userId) {
            friendUserId = friend['friend_id'];
            userProfile =
                friend['user_profiles_friend'] as Map<String, dynamic>;
          } else {
            friendUserId = friend['user_id'];
            userProfile = friend['user_profiles_user'] as Map<String, dynamic>;
          }

          // Add unique friends to the list
          if (uniqueFriendIds.add(friendUserId)) {
            friendData.add(UserData.fromJson({
              'friend_id': friendUserId,
              'user_id': userId,
              'username': userProfile['username'] ?? 'Unknown User',
              'email': userProfile['email'] ?? 'Unknown Email',
            }));
          }
        }
      }
      print("from profile cubit $friendData");
      print("from profile cubit ${friendData.length}");
      return friendData;
    } catch (e) {
      print("Error fetching friends: $e");
    }
    return friendData; // Ensure a return statement at the end
  }
}
