
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'Login States.dart';

class Shoplogincubit extends Cubit<LoginStates> {
  Shoplogincubit() : super(LoginInitialState());

  static Shoplogincubit get(context) => BlocProvider.of(context);


  bool passwordObscure = true;
  bool signupPasswordObscure = true;
  bool signupConfirmPasswordObscure = true;
  void changePasswordVisibility() {
    passwordObscure = !passwordObscure;
    emit(ChangePasswordVisibilityState());
  }
  void changeSignupPasswordVisibility() {
    signupPasswordObscure = !signupPasswordObscure;
    emit(ChangeSignupPasswordVisibilityState());
  }

  void changeSignupConfirmPasswordVisibility() {
    signupConfirmPasswordObscure = !signupConfirmPasswordObscure;
    emit(ChangeSignupConfirmPasswordVisibilityState());
  }
}
