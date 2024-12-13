import 'package:chatoid/zRefactor/core/utlis/user_data.dart';
import 'package:chatoid/zRefactor/features/profile/view/profile.dart';
import 'package:flutter/material.dart';

class MenuItems extends StatelessWidget {
  const MenuItems(
      {super.key, required this.themeData, required this.profileData});
  final ThemeData themeData;
  final UserData profileData;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.person,
            size: 30,
            color: themeData
                .iconTheme.color, // Adjust icon color for current theme
          ),
          title: Text(
            'Profile',
            style: TextStyle(
              fontSize: 18,
              color: themeData.textTheme.bodyLarge?.color,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Profile(userProfile: profileData),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.settings,
            size: 30,
            color: themeData.iconTheme.color,
          ),
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              color: themeData.textTheme.bodyLarge?.color,
            ),
          ),
          onTap: () {
            // Navigate to Settings screen
          },
        ),
        ListTile(
          leading: Icon(
            Icons.info,
            size: 30,
            color: themeData.iconTheme.color,
          ),
          title: Text(
            'Info',
            style: TextStyle(
              fontSize: 18,
              color: themeData.textTheme.bodyLarge?.color,
            ),
          ),
          onTap: () {
            // Navigate to Info screen
          },
        ),
      ],
    );
  }
}
