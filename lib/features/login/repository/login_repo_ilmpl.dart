import 'dart:convert';

import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/core/utlis/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

import 'package:chatoid/features/login/model/login_data.dart';
import 'package:chatoid/features/login/repository/login_repo.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_cubit.dart';

class LoginRepoImpl with LoginRepo {
  final supabase = Supabase.instance;
  static const String sessionKey = 'supabase_session';

  @override
  Future<AuthResponse> onSingIn(LoginModel request) {
    final supabase = Supabase.instance;
    return supabase.client.auth
        .signInWithPassword(email: request.email, password: request.password);
  }

  @override
  Future<void> fillCurrentUserDataByEmail(
      String email, BuildContext context) async {
    try {
      final loginCubit = context.read<LoginCubit>();
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('user_profiles')
          .select('user_id, username, email, profile_image')
          .eq('email', email)
          .single();
      loginCubit.currentUser.userId = response['user_id'] as int;
      loginCubit.currentUser.username = response['username'] as String;
      loginCubit.currentUser.profileImage = response['profile_image'] as String;
      loginCubit.currentUser.email = response['email'] as String;
    } catch (e) {
      SnackBar(
        content: Text('faild fill user by email: $e'),
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  void updateUser(UserData user, BuildContext context) async {
    final loginCubit = context.read<LoginCubit>();

    loginCubit.currentUser = user;
    await saveUserData(context);
  }

  @override
  Future<void> saveUserData(BuildContext context) async {
    final loginCubit = context.read<LoginCubit>();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'currentuser', jsonEncode(loginCubit.currentUser.toJson()));
    await prefs.setBool('isLoggedIn', true); // Store login state
  }

  @override
  void showSuccessLoginWidget(BuildContext context, String username) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Welcome back $username!',
        text: 'You are ready to use our app',
        confirmBtnText: 'Let\'s Go!',
        onConfirmBtnTap: () {
          saveUserData(context);
          Navigator.of(context).pop();
          GoRouter.of(context).push(AppRouter.kHomePage);
        },
      );
    });
  }

  @override
  Future<void> saveLoginSession() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setBool('isLoggedIn', true);
  }

  @override
  Future<void> saveOneSignalPlayerId(int userId, String email) async {
    try {
      String? playerId = await OneSignal.User.getExternalId();

      // Get the player's subscription ID as a fallback
      if (playerId == null) {
        var status = OneSignal.User.pushSubscription;
        playerId = status.id; // This will give you the player ID
      }

      // Debug statement to check the retrieved playerId

      if (playerId != null) {
        await Supabase.instance.client.from('user_profiles').upsert({
          'user_id': userId,
          'player_id': playerId,
          'email': email, // Make sure to include email here
        });
      } else {}
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> recoverSession(BuildContext context) async {
    final loginCubit = context.read<LoginCubit>();
    final prefs = await SharedPreferences.getInstance();

    final storedSession = prefs.getString(sessionKey);

    if (storedSession != null) {
      final response =
          await Supabase.instance.client.auth.recoverSession(storedSession);

      if (response.session != null) {
        // Check if the widget is still mounted

        loginCubit.userLoggedIn = response.user;

        // Avoid async gaps with context usage
        final email = loginCubit.userLoggedIn?.email;
        if (email != null) {
          await fillCurrentUserDataByEmail(email, context);
        }
      }
    }
  }

  @override
  Future<void> clearLoginSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }

  @override
  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }
}
