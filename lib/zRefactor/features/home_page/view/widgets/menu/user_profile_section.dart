import 'package:chatoid/zRefactor/core/utlis/user_data.dart';
import 'package:flutter/material.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key, required this.profileData});
  final UserData profileData;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            profileData.profile_image.isNotEmpty
                ? profileData.profile_image
                : 'assets/profile.gif', // Default profile image
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
