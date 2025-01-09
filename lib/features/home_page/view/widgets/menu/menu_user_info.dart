import 'package:chatoid/core/utlis/themeCubit/theme_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuUserInfo extends StatefulWidget {
  const MenuUserInfo(
      {super.key, required this.themeCubit, required this.loginCubit});
  final ThemeCubit themeCubit;
  final LoginCubit loginCubit;

  @override
  State<MenuUserInfo> createState() => _MenuUserInfoState();
}

class _MenuUserInfoState extends State<MenuUserInfo> {
  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        if (state is LoginSuccess) {
          final user = state.currentUser;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          );
        } else if (state is LoginLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Please log in.'));
        }
      },
    );
  }
}
