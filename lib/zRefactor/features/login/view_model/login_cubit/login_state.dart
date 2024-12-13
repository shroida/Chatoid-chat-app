// auth_state.dart
import 'package:chatoid/zRefactor/core/utlis/user_data.dart';

abstract class LoginState {}

class LoginLoading extends LoginState {}
class LoginInital extends LoginState {}
class LoginLogout extends LoginState {}

class LoginSuccess extends LoginState {
  final UserData currentUser; 

  LoginSuccess(this.currentUser);
}

class LoginFailure extends LoginState {
  final String errorMessage;

  LoginFailure(this.errorMessage);
}
