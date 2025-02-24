import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odc_project/Cubit/Shop/Shop%20Cubit.dart';
import 'package:odc_project/Screens/Login-SignUp/Get%20Started.dart';
import 'package:odc_project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../Cubit/Login/Login Cubit.dart';
import '../../Cubit/Login/Login States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';
import '../../Shared/Constants.dart';
import '../Home/Main Screen.dart';
import 'Register Screen.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMe = prefs.getBool('rememberMe');

    if (rememberMe == true) {
      String? email = prefs.getString('email');
      String? password = prefs.getString('password');

      if (email != null && password != null) {
        try {
          setState(() {
            isLoading = true;
          });

          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } catch (e) {
          print('Auto-login failed: $e');
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _saveLoginState(bool rememberMe, String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', email);
      await prefs.setString('password', password);

    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => Shoplogincubit(),
      child: BlocConsumer<Shoplogincubit, LoginStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            body: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOGIN',
                          style: GoogleFonts.montserrat(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Login now to browse our hot offers',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              color: Colors.grey,
                            )),
                         SizedBox(height: 5.h),
                        defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          textController: emailController,
                          prefixIcon: const Icon(Icons.email_outlined),
                          label: 'Email',
                          type: TextInputType.emailAddress,
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Email must not be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        defaultTextFormField(
                          isDark: ThemeCubit.get(context).themebool,
                          textController: passwordController,
                          prefixIcon: const Icon(Icons.lock),
                          label: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () {
                              Shoplogincubit.get(context).changePasswordVisibility();
                            },
                            icon: Shoplogincubit.get(context).passwordObscure
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                          obscureText: Shoplogincubit.get(context).passwordObscure,
                          type: TextInputType.visiblePassword,
                          Validator: (value) {
                            if (value!.isEmpty) {
                              return 'Password is too short';
                            }
                            return null;
                          },
                        ),
                         SizedBox(height: 2.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Remember Me",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Checkbox(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                  checkColor: Colors.white,
                                  activeColor: defaultcolor,
                                  value: ThemeCubit.get(context).rememberMe,
                                  onChanged: (value) {
                                    ThemeCubit.get(context).toggleRememberMe(value!);
                                  },
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                if (emailController.text.isEmpty) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    title: 'Forget Password',
                                    titleTextStyle: GoogleFonts
                                        .montserrat(
                                      fontSize: 20,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                                    ),
                                    descTextStyle:GoogleFonts
                                        .montserrat(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                                    ) ,
                                    dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
                                    desc: 'Please enter your email to reset your password',
                                  ).show();
                                  return;
                                }
                                try {
                                  await FirebaseAuth.instance.sendPasswordResetEmail(
                                    email: emailController.text,
                                  );
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.success,
                                    title: 'Forget Password',
                                    titleTextStyle: GoogleFonts
                                        .montserrat(
                                      fontSize: 20,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                                    ),
                                    descTextStyle:GoogleFonts
                                        .montserrat(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                                    ) ,
                                    dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
                                    desc: 'Check your email to reset your password',
                                  ).show();
                                } catch (e) {
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    title: 'Forget Password',
                                    titleTextStyle: GoogleFonts
                                        .montserrat(
                                      fontSize: 20,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                                    ),
                                    descTextStyle:GoogleFonts
                                        .montserrat(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      color: ThemeCubit.get(context).themebool ? Colors.white:Colors.black,
                                    ) ,
                                    dialogBackgroundColor: ThemeCubit.get(context).themebool ? Colors.grey[800]:Colors.white,
                                    desc: 'Please enter a valid email',
                                  ).show();
                                }
                              },
                              child:  Text(
                                'Forget Password?',
                                style: GoogleFonts.montserrat(color: defaultcolor,fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  final credential = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                                  // Save login state
                                  _saveLoginState(
                                    ThemeCubit
                                        .get(context)
                                        .rememberMe,
                                    emailController.text,
                                    passwordController.text,
                                  );


                                  ShopCubit.get(context).initializeData();

                                  // Navigate to main screen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GetStarted()),
                                  );
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.error,
                                    title: 'Login Error',
                                    desc: 'The supplied auth credential is incorrect.',
                                  ).show();
                                }
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                defaultcolor,
                              ),
                              padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              'LOGIN',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                                );
                              },
                              child:  Text(
                                'REGISTER NOW',
                                style: GoogleFonts.montserrat(color: defaultcolor,fontWeight: FontWeight.w600),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
