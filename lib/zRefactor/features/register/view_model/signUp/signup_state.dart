
abstract class SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {

}

class SignUpFailure extends SignUpState {
  final String errorMessage;

  SignUpFailure(this.errorMessage);
}
