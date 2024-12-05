import 'package:chatoid/data/models/auth/login_data.dart';

class SignupData extends LoginData {
  
  final String username;

  SignupData({required super.email, required super.password, required this.username});
  

}