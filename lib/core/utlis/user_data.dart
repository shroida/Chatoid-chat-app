class UserData {
  late int friendId; // Use friend_id from response
  late int userId; // Use user_id from response
  late String username;
  late String email;
  String profileImage = '';

  UserData({
    required this.friendId,
    required this.userId,
    required this.username,
    required this.email,
    this.profileImage = '',
  });

  Map<String, dynamic> toJson() => {
        'friend_id': friendId,
        'user_id': userId,
        'username': username,
        'email': email,
        'profile_image': profileImage,
      };

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      friendId: json['friend_id'] != null ? json['friend_id'] as int : 0, // Default value for friend_id if null
      userId: json['user_id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      profileImage: json['profile_image'] != null ? json['profile_image'] as String : '', // Handle null for profile_image
    );
  }

  @override
  String toString() {
    return 'UserData(user_id: $userId, username: $username, email: $email, profile_image: $profileImage)';
  }
}
