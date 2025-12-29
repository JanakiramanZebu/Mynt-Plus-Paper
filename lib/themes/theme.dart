import 'package:flutter/material.dart';

// Dark theme options

class MyThemes {
  static final darkTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.black,
    bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.black),
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
      shadowColor: Color(0xffECEFF3),
      centerTitle: false,
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xffB5C0CF).withOpacity(.15),
        dragHandleColor: Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
    dialogTheme:
        DialogThemeData(backgroundColor: const Color(0xffB5C0CF).withOpacity(.15)),
  );

// Light theme options
  static final lightTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
        shadowColor: Color(0xffECEFF3),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black)),
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.blue,
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
    iconTheme: const IconThemeData(color: Colors.black),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
  );

  static final darkThemebanner = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.black),
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
      shadowColor: Color(0xffECEFF3),
      centerTitle: false,
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xffB5C0CF).withOpacity(.15),
        dragHandleColor: Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
    dialogTheme:
        DialogThemeData(backgroundColor: const Color(0xffB5C0CF).withOpacity(.15)),
  );

// Light theme options
  static final lightThemebanner = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.white,
    primarySwatch: Colors.blue,
    appBarTheme: const AppBarTheme(
        shadowColor: Color(0xffECEFF3),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black)),
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.blue,
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
    iconTheme: const IconThemeData(color: Colors.black),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
  );
}
