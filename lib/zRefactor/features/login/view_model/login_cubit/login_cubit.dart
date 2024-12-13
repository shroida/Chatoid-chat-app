import 'dart:convert';
import 'package:chatoid/zRefactor/features/login/model/login_data.dart';
import 'package:chatoid/zRefactor/features/login/repository/login_repo_ilmpl.dart';
import 'package:chatoid/zRefactor/features/login/view_model/login_cubit/login_state.dart';
import 'package:chatoid/zRefactor/core/utlis/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInital());

  final LoginRepoImpl _repo = LoginRepoImpl();
  
  Future<void> recoverSession(BuildContext context) async {
    print("Recovering session...");
    await _repo.recoverSession(context);
    print("Recovered session, user: ${currentUser.username}");
  }

  late UserData currentUser =
      UserData(user_id: 0, username: '', email: '', friendId: 0);
  UserData get currentUserData => currentUser;

  User? userLoggedIn;
  bool _isLogin = false;
  bool _isLoading = false;
  String? _errorMessage;
  AuthResponse? _authResponse;

  AuthResponse get authResponse => _authResponse ?? AuthResponse();

  bool get isLogin => _isLogin;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final supabase = Supabase.instance;

  Future<void> onLogin(BuildContext context, LoginModel request,
      {required Function() success, required Function() failure}) async {
    try {
      _isLoading = true;
      emit(LoginLoading());
      final response = await _repo.onSingIn(request);
      _isLoading = false;

      if (response.session == null) {
        _errorMessage = "Login failed. Please check your credentials.";
        emit(LoginFailure(_errorMessage!));
        failure();
      } else {
        _isLogin = true;
        success();
        await _repo.fillCurrentUserDataByEmail(request.email, context);
        _repo.updateUser(currentUser, context);
        await Future.delayed(const Duration(seconds: 2));
        _repo.showSuccessLoginWidget(context, currentUser.username);
        await _repo.saveLoginSession();
        await _repo.saveOneSignalPlayerId(context);
        emit(LoginSuccess(currentUser));
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An error occurred: $e";
      emit(LoginFailure(_errorMessage!));
      failure();
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLogin = false;
    _authResponse = null;

    try {
      await _repo.clearLoginSession();
      await _repo.clearUserData();
    } catch (e) {
      const SnackBar(
        content: Text('Failed to log out'),
      );
    }
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currentUserJson = prefs.getString('currentuser');
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (currentUserJson != null && isLoggedIn) {
      currentUser = UserData.fromJson(jsonDecode(currentUserJson));
    } else {}
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<UserData?> getUserByUsername(String username) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select(
              'user_id, username, email') // Corrected the field name to 'friend_id'
          .eq('username', username)
          .single(); // Return a single record

      return UserData(
          user_id: response['user_id'] as int,
          username: response['username'] as String,
          email: response['email'] as String,
          friendId: 0);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isUserOnline(String email) async {
    final response = await supabase.client
        .from('user_profiles')
        .select('isOnline')
        .eq('email', email)
        .single();

    if (response['isOnline'] != null) {
      return response['isOnline'] as bool;
    }
    return false;
  }
}
