import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:odc_project/Shared/Constants.dart';

ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: HexColor("121212"),
  iconTheme: IconThemeData(color: Colors.white),
  primarySwatch: Colors.deepOrange,
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.black,
    unselectedItemColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    backgroundColor: Color(0xFFF83758),
  ),
  inputDecorationTheme: InputDecorationTheme(
    suffixIconColor: Colors.white,
    prefixIconColor: Colors.white,
    filled: true,
    iconColor: Colors.white,
    fillColor: Colors.grey.shade800,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Color(0xFFF83758),
      ),
    ),
    hintStyle: TextStyle(color: Colors.white),
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
    contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
    focusColor: Colors.white,
    helperStyle: TextStyle(color: Colors.white),
    errorStyle: TextStyle(color: Colors.red),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Color(0xFFF83758)),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      )),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Color(0xFFF83758)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      side: MaterialStateProperty.all(BorderSide(color: Color(0xFFF83758))),
      foregroundColor: MaterialStateProperty.all(Color(0xFFF83758)),
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.grey.shade800,
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
  listTileTheme: ListTileThemeData(
    iconColor: Colors.white,
    tileColor: Colors.grey.shade800,
    textColor: Colors.white,
    selectedTileColor: Color(0xFFF83758),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
  expansionTileTheme: ExpansionTileThemeData(
    backgroundColor: Colors.grey.shade800,
    collapsedBackgroundColor: HexColor("121212"),
    textColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    iconColor: Colors.white,
    collapsedTextColor: Colors.white,
    collapsedIconColor: Colors.white,
  ),
);

ThemeData lightTheme = ThemeData(
  expansionTileTheme: ExpansionTileThemeData(
    backgroundColor: Colors.white,
    collapsedBackgroundColor: Colors.white,
    textColor: Colors.black,
    iconColor: Colors.black,
    collapsedTextColor: Colors.black,
    collapsedIconColor: Colors.black,
  ),
  iconTheme: IconThemeData(color: Colors.black),
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Color(0xffF9F9F9),
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.black,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Color(0xFFF83758),
    unselectedItemColor: Colors.grey,
    type: BottomNavigationBarType.fixed,
    backgroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    suffixIconColor: Colors.black,
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Colors.grey,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(
        color: Color(0xFFF83758),
      ),
    ),
    hintStyle: TextStyle(color: Colors.grey),
    labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Color(0xFFF83758)),
      foregroundColor: MaterialStateProperty.all(Colors.white),
      shape: MaterialStateProperty.all(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      )),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Color(0xFFF83758)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      side: MaterialStateProperty.all(BorderSide(color: Color(0xFFF83758))),
      foregroundColor: MaterialStateProperty.all(Color(0xFFF83758)),
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 5.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
  listTileTheme: ListTileThemeData(
    iconColor: Colors.black,
    tileColor: Colors.white,
    textColor: Colors.black,
    selectedTileColor: Color(0xFFF83758),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ),
);
AwesomeDialog buildDarkThemeDialog(BuildContext context) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    borderSide: BorderSide(color: HexColor("FF5722"), width: 2),
    width: MediaQuery.of(context).size.width * 0.75,
    buttonsBorderRadius: BorderRadius.circular(15),
    dismissOnTouchOutside: true,
    dismissOnBackKeyPress: true,
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: 'Warning',
    desc: 'Are you sure you want to proceed?',
    btnCancelText: "Cancel",
    btnOkText: "Yes",
    btnCancelOnPress: () {},
    btnOkOnPress: () {},
    btnCancelColor: Colors.grey.shade800,
    btnOkColor: HexColor("00B96D"),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    descTextStyle: TextStyle(
      color: Colors.white70,
      fontSize: 16,
    ),
    buttonsTextStyle: TextStyle(color: Colors.white),
    dialogBackgroundColor: HexColor("121212"),
  );
}
AwesomeDialog buildLightThemeDialog(BuildContext context) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    borderSide: BorderSide(color: Colors.blue, width: 2),
    width: MediaQuery.of(context).size.width * 0.75,
    buttonsBorderRadius: BorderRadius.circular(15),
    dismissOnTouchOutside: true,
    dismissOnBackKeyPress: true,
    headerAnimationLoop: false,
    animType: AnimType.scale,
    title: 'Information',
    desc: 'This is an important notice.',
    btnCancelText: "Close",
    btnOkText: "Understood",
    btnCancelOnPress: () {},
    btnOkOnPress: () {},
    btnCancelColor: Colors.grey.shade300,
    btnOkColor: HexColor("00B96D"),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    descTextStyle: TextStyle(
      color: Colors.black54,
      fontSize: 16,
    ),
    buttonsTextStyle: TextStyle(color: Colors.black),
    dialogBackgroundColor: Colors.white,
  );
}
