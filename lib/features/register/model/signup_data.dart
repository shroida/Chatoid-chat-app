import 'package:chatoid/features/login/model/login_data.dart';

class RegisterModel extends LoginModel {
  
  final String username;

  RegisterModel({required super.email, required super.password, required this.username});
  

}