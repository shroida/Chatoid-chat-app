import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/login/model/login_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

mixin LoginRepo {
  Future<AuthResponse> onSingIn(LoginModel request);
  Future<void> fillCurrentUserDataByEmail(
      String email, BuildContext context) async {}
  void updateUser(UserData user, BuildContext context);
  Future<void> saveUserData(BuildContext context) async {}
  void showSuccessLoginWidget(BuildContext context, String username);
  Future<void> saveLoginSession() async {}
  Future<void> saveOneSignalPlayerId(int userId,String email) async {}
  Future<void> recoverSession(BuildContext context) async {}

  Future<void> clearLoginSession() async {}
  Future<void> clearUserData() async {}
  
}
