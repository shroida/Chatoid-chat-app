import 'package:chatoid/constants.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuUserInfo extends StatelessWidget {
  const MenuUserInfo({super.key, required this.themeData});
  final ThemeData themeData;
  @override
  Widget build(BuildContext context) {
    final authProvider = BlocProvider.of<LoginCubit>(context);
    final currentUser = authProvider.currentUser;
    return Column(
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
    );
  }
}
