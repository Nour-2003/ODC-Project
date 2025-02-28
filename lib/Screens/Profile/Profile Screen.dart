import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../Cubit/Shop/Shop Cubit.dart';
import '../../Cubit/Shop/Shop States.dart';
import '../../Cubit/Theme/Theme Cubit.dart';
import '../../Cubit/Theme/Theme States.dart';
import '../../Shared/Constants.dart';
import '../Home/OnBoarding Screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocConsumer<ShopCubit, ShopStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final userData = ShopCubit.get(context).userData;
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.5),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'Images/Profile.jpg',
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  userData?['name'] ?? 'User Name',
                  style: GoogleFonts.montserrat(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  userData?['email'] ?? 'user@example.com',
                  style: GoogleFonts.montserrat(
                    fontSize: 15.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4.h),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Phone Number
                        _buildDetailTile(
                          icon: Icons.phone,
                          title: 'Phone',
                          value: userData?['phone'] ?? 'Not Provided',
                          iconColor: Colors.blue,
                        ),
                         Divider(height: 3.w, thickness: 1),
                        // Email
                        _buildDetailTile(
                          icon: Icons.email,
                          title: 'Email',
                          value: userData?['email'] ?? 'Not Provided',
                          iconColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Dark Mode",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        BlocBuilder<ThemeCubit, AppStates>(
                          builder: (context, state) => Switch(
                            value: ThemeCubit.get(context).themebool,
                            activeColor: Colors.blue,
                            onChanged: (value) {
                              ThemeCubit.get(context).changeThemeMode();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: defaultcolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();

                      // Clear shared preferences
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.remove('rememberMe');
                      prefs.remove('email');
                      prefs.remove('password');

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OnBoardingScreen()),
                      );
                    },
                    child: Text(
                      "Sign Out",
                      style: GoogleFonts.montserrat(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 1.3.h),
      child: Row(
        children: [

          SizedBox(
            width: 50,
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 8), // Spacing between title and value
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

}
