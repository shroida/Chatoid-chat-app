import 'package:chatoid/core/utlis/app_router.dart';
import 'package:chatoid/features/chat/view_model/chat_cubit/chats_cubit.dart';
import 'package:chatoid/features/login/model/login_data.dart';
import 'package:chatoid/features/login/repository/login_repo_ilmpl.dart';
import 'package:chatoid/features/login/view_model/login_cubit/login_state.dart';
import 'package:chatoid/core/utlis/user_data.dart';
import 'package:chatoid/features/posts/view_model/cubit/posts_cubit.dart';
import 'package:chatoid/features/story/view_model/cubit/story_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepoImpl _repo = LoginRepoImpl();
  final ChatsCubit chatsCubit;
  final PostsCubit postsCubit;
  final StoryCubit storyCubit;

  LoginCubit(this.chatsCubit, this.postsCubit, this.storyCubit)
      : super(LoginInitial());

  late UserData currentUser =
      UserData(userId: 0, username: '', email: '', friendId: 0);
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

  Future<void> recoverSession(BuildContext context) async {
    await _repo.recoverSession(context);
  }

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
        await _processLoginSuccess(request.email, context);
        await loadUserDataCubits();
        bool islogin = await _repo.checkLoginSession();
        print('isLoggedIn: $islogin');
        emit(LoginSuccess(currentUser));
        success();
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = "An error occurred: $e";
      emit(LoginFailure(_errorMessage!));
      failure();
    }
  }

  Future<void> loadUserDataCubits() async {
    try {
      await Future.wait([
        chatsCubit.fetchFriends(currentUser.userId),
        chatsCubit.fetchAllMessages(currentUser),
        chatsCubit.fetchAllMessagesInGroupForAllUsers(),
        postsCubit.getAllPosts(),
        storyCubit.fetchAllStories(),
      ]);
    } catch (e) {
      // Handle errors appropriately
    }
  }

  Future<void> _processLoginSuccess(String email, BuildContext context) async {
    currentUser = UserData(userId: 0, username: '', email: '', friendId: 0);
    await _repo.fillCurrentUserDataByEmail(email, context);
    _repo.updateUser(currentUser, context);
    _repo.showSuccessLoginWidget(context, currentUser.username);
    await _repo.saveLoginSession();
    await _repo.checkLoginSession();
  }

  Future<void> logout(BuildContext context) async {
    _isLogin = false;
    _authResponse = null;
    _errorMessage = null;
    currentUser = UserData(userId: 0, username: '', email: '', friendId: 0);

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('currentuser');

      await _repo.clearLoginSession();
      await _repo.clearUserData();
      await _repo.checkLoginSession();

      emit(LoginInitial());
      GoRouter.of(context).push(AppRouter.kLoginView);
    } catch (e) {
      // Handle logout error
    }
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? email = prefs.getString('email');
    String? username = prefs.getString('username');
    int? userId = prefs.getInt('userId');
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (email != null && username != null && userId != null && isLoggedIn) {
      currentUser = UserData(
          userId: userId, username: username, email: email, friendId: 0);
      emit(LoginSuccess(currentUser));
    } else {
      emit(LoginInitial());
    }
  }

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<UserData?> getUserByUsername(String username) async {
    try {
      final response = await supabase.client
          .from('user_profiles')
          .select('user_id, username, email')
          .eq('username', username)
          .single();

      return UserData(
          userId: response['user_id'] as int,
          username: response['username'] as String,
          email: response['email'] as String,
          friendId: currentUser.userId);
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

    return response['isOnline'] ?? false;
  }
}
