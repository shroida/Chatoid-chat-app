import 'package:chatoid/zRefactor/features/register/view_model/signUp/signup_state.dart';
import 'package:chatoid/zRefactor/features/register/model/signup_data.dart';
import 'package:chatoid/zRefactor/features/register/repository/register_repo_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupCubit extends Cubit<SignUpLoading> {
  SignupCubit() : super(SignUpLoading());
  final RegisterRepoImpl _repo = RegisterRepoImpl();
  
 

  Future<void> submitForm({
    required final RegisterModel userData,
    required final BuildContext context,
    required Function() failure,
    required Function() success,
  }) async {
    bool usernameExists = await _repo.isUsernameExist(userData.username);
    if (usernameExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username already exists. Please choose another one.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    bool isSignUpSuccess = await _repo.createUser(
      userData: userData,
      context: context,
      success: success,
      failure: failure,
    );

    if (isSignUpSuccess) {
      _repo.insertUserProfile(
          userData.email, userData.password, userData.username);
    }
  }










  Future<List<String>> searchUsernames(String query) async {
    try {
      final supabase = Supabase.instance;

      // Only perform search if the full name is typed
      if (query.isEmpty) {
        return [];
      }

      final response = await supabase.client
              .from('user_profiles')
              .select('username') // Only selecting the username field
              .eq('username', query) // Exact match on the username field
          ;

      // Map the result to a list of usernames
      final List<String> usernames =
          (response as List).map((user) => user['username'] as String).toList();

      return usernames;
    } catch (e) {
      return [];
    }
  }
}
