import 'package:chatoid/core/utlis/user_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return supabase.client.auth
        .signInWithPassword(email: request.email, password: request.password);
  }

  @override
  Future<void> fillCurrentUserDataByEmail(
      String email, BuildContext context) async {
    try {
      final loginCubit = context.read<LoginCubit>();
      final response = await supabase.client
          .from('user_profiles')
          .select('user_id, username, email, profile_image')
          .eq('email', email)
          .single();

      loginCubit.currentUser = UserData(
          friendId: -1,
          userId: response['user_id'] as int,
          username: response['username'] as String,
          profileImage: response['profile_image'] as String,
          email: response['email'] as String);
    } catch (e) {
      // Handle error
    }
  }

  @override
  void updateUser(UserData user, BuildContext context) {
    final loginCubit = context.read<LoginCubit>();
    loginCubit.currentUser = user;
    saveUserData(context);
  }

  @override
  Future<void> saveUserData(BuildContext context) async {
    final loginCubit = context.read<LoginCubit>();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', loginCubit.currentUser.email);
    await prefs.setString('username', loginCubit.currentUser.username);
    await prefs.setInt('userId', loginCubit.currentUser.userId);
    await prefs.setBool('isLoggedIn', true);
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
          Navigator.of(context, rootNavigator: true).pop();
        },
      );
    });
  }

  @override
  Future<void> saveLoginSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  Future<bool> checkLoginSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }

  @override
  Future<void> saveOneSignalPlayerId(int userId, String email) async {
    try {
      String? playerId = await OneSignal.User.getExternalId();
      if (playerId == null) {
        var status = OneSignal.User.pushSubscription;
        playerId = status.id;
      }

      if (playerId != null) {
        await supabase.client.from('user_profiles').upsert({
          'user_id': userId,
          'player_id': playerId,
          'email': email,
        });
      }
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
      final response = await supabase.client.auth.recoverSession(storedSession);
      if (response.session != null) {
        loginCubit.userLoggedIn = response.user;
        final email = loginCubit.userLoggedIn?.email;
        if (email != null) {
          await fillCurrentUserDataByEmail(email, context);
        }
      }
    }
  }

  @override
  Future<void> clearLoginSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
  }

  @override
  Future<void> clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
  }
}
