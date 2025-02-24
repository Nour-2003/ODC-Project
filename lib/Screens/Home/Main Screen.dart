import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odc_project/Shared/Constants.dart';
import 'package:odc_project/main.dart';
import 'package:sizer/sizer.dart';
import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = ShopCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: defaultcolor,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            centerTitle: true,
            title: Text(cubit.titles[cubit.currentIndex],style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),),
          ),
          body: cubit.screens[cubit.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            elevation: 10,
            items: const [
              BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.home), label: 'Home'),
              BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.search), label: 'Search'),
              BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.shoppingCart), label: 'Cart'),
              BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.userAlt), label: 'Profile'),
            ],
            currentIndex: cubit.currentIndex,
            showUnselectedLabels: false,
            iconSize: 22,
            selectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
            onTap: (index) => cubit.changeBottomNav(index),
          ),
        );
      },
    );
  }
}
