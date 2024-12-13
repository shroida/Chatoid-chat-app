import 'package:chatoid/features/register/model/signup_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

mixin RegisterRepo {
  Future<bool> isUsernameExist(String username);
  Future<AuthResponse> onSingUpWithEmailPassword(RegisterModel request);
  Future<bool> createUser({
    required final RegisterModel userData,
    required BuildContext context,
    required Function() success,
    required Function() failure,
  });
  void showSuccessRegisterWidget(BuildContext context, String username);
  Future<void> insertUserProfile(
      String email, String password, String username) async {}
}
