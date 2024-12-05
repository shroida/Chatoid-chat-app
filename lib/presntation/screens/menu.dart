import 'package:chatoid/constants.dart';
import 'package:chatoid/zRefactor/core/utlis/app_router.dart';
import 'package:chatoid/zRefactor/features/login/view/login.dart';
import 'package:chatoid/cubits/themeCubit/theme_cubit.dart';
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/presntation/screens/profile.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends StatelessWidget {
  final UserData profileData;

  const MenuScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    final authProvider = BlocProvider.of<LoginCubit>(context);
    final currentUser = authProvider.currentUser;

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, themeData) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // User profile section
                Row(
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
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeData.textTheme.bodyLarge
                            ?.color, // Adjust text color for current theme
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeData.textTheme.bodySmall?.color ??
                            ChatAppColors.timestampColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Menu items
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
                const Spacer(),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.logout, size: 30, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  onTap: () {
                    authProvider.logout(context);
                    GoRouter.of(context).push(AppRouter.kLoginView);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
