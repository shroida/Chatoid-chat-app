import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileSection extends StatefulWidget {
  const UserProfileSection({super.key, required this.profileData});
  final UserData profileData;

  @override
  State<UserProfileSection> createState() => _UserProfileSectionState();
}

class _UserProfileSectionState extends State<UserProfileSection> {
  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
          // Fallback to default image if profileImage is empty or null
          String profileImage = widget.profileData.profileImage.isNotEmpty
              ? widget.profileData.profileImage
              : 'assets/profile.gif';

          if (state is LoginSuccess) {
            profileImage = state.currentUser.profileImage.isNotEmpty
                ? state.currentUser.profileImage
                : 'assets/profile.gif';
          }

          return ClipOval(
            child: Image.asset(
              profileImage,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/profile.gif', 
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                );
              },
            ),
          );
        }),
        const SizedBox(width: 16),
      ],
    );
  }
}
