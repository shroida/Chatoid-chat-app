
import 'package:chatoid/data/models/userData/user_data.dart';
import 'package:chatoid/zRefactor/features/login/model/login_data.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chatoid/zRefactor/features/register/model/signup_data.dart';

mixin IAuthRepository {
  bool isLogin();
  late UserData currentUser =
      UserData(user_id: 0, username: '', email: '', friendId: 0);

  Future<AuthResponse> onSingIn(LoginModel request);

}

class AuthRepository with IAuthRepository {
  final supabase = Supabase.instance;

  Future<AuthResponse> onSingUpWithEmailPassword(RegisterModel request) {
    return supabase.client.auth.signUp(
        email: request.email,
        password: request.password); 
  }

  @override
  bool isLogin() => supabase.client.auth.currentSession != null;

  @override
  Future<AuthResponse> onSingIn(LoginModel request) {
    return supabase.client.auth
        .signInWithPassword(email: request.email, password: request.password);
 
  }

}
