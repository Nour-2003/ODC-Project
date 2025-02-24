
abstract class LoginStates {}
class LoginInitialState extends LoginStates{}
class LoginLoadingState extends LoginStates{}
class LoginSuccessState extends LoginStates{
}
class LoginErrorState extends LoginStates{
  final String error;
  LoginErrorState({required this.error});
}
class ChangePasswordVisibilityState extends LoginStates{}
class ChangeSignupPasswordVisibilityState extends LoginStates{}
class ChangeSignupConfirmPasswordVisibilityState extends LoginStates{}