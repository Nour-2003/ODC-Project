import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'Cubit/Shop/Shop Cubit.dart';
import 'Cubit/Theme/Theme Cubit.dart';
import 'Cubit/Theme/Theme States.dart';
import 'Screens/Home/Main Screen.dart';
import 'Screens/Home/OnBoarding Screen.dart';
import 'Screens/Splash/Splash.dart';
import 'Shared/Constants.dart';
import 'Shared/Themes.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotification.init();
  await _requestNotificationPermissions();
  await Firebase.initializeApp();
  Bloc.observer = MyBlocObserver();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? rememberMe = prefs.getBool('rememberMe');
  String? email = prefs.getString('email');
  String? password = prefs.getString('password');

  bool isLoggedIn = false;

  if (rememberMe == true && email != null && password != null) {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      isLoggedIn = true;
    } catch (e) {
      print('Auto-login failed: $e');
    }
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<ShopCubit>(
          create: (context) => ShopCubit()..initializeData(),
        ),
      ],
      child: BlocConsumer<ThemeCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Sizer(
            builder: (context, orientation, deviceType) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: ThemeCubit.get(context).themebool
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: isLoggedIn ? MainScreen() : SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
Future<void> _requestNotificationPermissions() async {
  final status = await Permission.notification.request();
  if (status.isDenied) {
    print('Notification permission denied');
  }
}
