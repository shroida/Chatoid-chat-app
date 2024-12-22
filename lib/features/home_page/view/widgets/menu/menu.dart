import 'package:chatoid/core/utlis/app_router.dart';
import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/home_page/view/widgets/menu/menu_items.dart';
import 'package:chatoid/features/home_page/view/widgets/menu/menu_user_info.dart';
import 'package:chatoid/features/home_page/view/widgets/menu/user_profile_section.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MenuScreen extends StatelessWidget {
  final UserData profileData;

  const MenuScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    final authProvider = BlocProvider.of<LoginCubit>(context);
    final themeCubit = BlocProvider.of<ThemeCubit>(context);

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, themeData) {
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                UserProfileSection(
                  profileData: profileData,
                ),
                const SizedBox(height: 20),
                MenuUserInfo(loginCubit: authProvider, themeCubit: themeCubit),
                const SizedBox(height: 20),
                // Menu items
                MenuItems(themeData: themeData, profileData: profileData),
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
