import 'package:chatoid/core/utlis/app_router.dart';
import 'package:chatoid/features/register/model/signup_data.dart';
import 'package:chatoid/features/register/repository/register_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterRepoImpl with RegisterRepo {
  final supabase = Supabase.instance;

  @override
  Future<bool> isUsernameExist(String username) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthResponse> onSingUpWithEmailPassword(RegisterModel request) {
    return supabase.client.auth
        .signUp(email: request.email, password: request.password);
  }

  @override
  Future<bool> createUser({
    required final RegisterModel userData,
    required BuildContext context,
    required Function() success,
    required Function() failure,
  }) async {
    try {
      RegisterModel request = RegisterModel(
          email: userData.email,
          password: userData.password,
          username: userData.username);
      final response = await onSingUpWithEmailPassword(request);

      if (response.session != null) {
        showSuccessRegisterWidget(context, userData.email);
        success();
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-up failed'),
            backgroundColor: Colors.red,
          ),
        );
        failure();
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('There is a problem'),
        backgroundColor: Colors.red,
      ));
      failure();
      return false;
    }
  }

  @override
  void showSuccessRegisterWidget(BuildContext context, String username) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Welcome $username!',
      text:
          'Congratulations, You have successfully signed up. Get ready to log in and start your journey with us.',
      confirmBtnText: 'Let\'s Go!',
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        GoRouter.of(context).push(AppRouter.kLoginView);
      },
    );
  }

  @override
  Future<void> insertUserProfile(
      String email, String password, String username) async {
    await Supabase.instance.client.from('user_profiles').insert({
      'email': email,
      'password': password,
      'username': username,
    });
  }
}
