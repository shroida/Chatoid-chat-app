import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/login/model/login_data.dart';
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
  Future<void> saveOneSignalPlayerId(BuildContext context) async {}
  Future<void> recoverSession(BuildContext context) async {}

  Future<void> clearLoginSession() async {}
  Future<void> clearUserData() async {}
  
}
