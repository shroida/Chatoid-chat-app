class UserData {
  late int friendId; // Use friend_id from response
  late int user_id; // Use user_id from response
  late String username;
  late String email;
  String profile_image = '';

  UserData({
    required this.friendId,
    required this.user_id,
    required this.username,
    required this.email,
    this.profile_image = '',
  });

  Map<String, dynamic> toJson() => {
        'friend_id': friendId,
        'user_id': user_id,
        'username': username,
        'email': email,
        'profile_image': profile_image,
      };

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      friendId: json['friend_id'] != null ? json['friend_id'] as int : 0, // Default value for friend_id if null
      user_id: json['user_id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      profile_image: json['profile_image'] != null ? json['profile_image'] as String : '', // Handle null for profile_image
    );
  }

  @override
  String toString() {
    return 'UserData(user_id: $user_id, username: $username, email: $email, profile_image: $profile_image)';
  }
}
