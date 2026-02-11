import 'package:flutter/material.dart';
import '../res/mynt_web_color_styles.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: MyntColors.backgroundColorDark, // #0D1117
    bottomAppBarTheme: BottomAppBarThemeData(color: MyntColors.backgroundColorDark),
    primaryColor: MyntColors.primaryDark, // #58A6FF
    appBarTheme: AppBarTheme(
      shadowColor: MyntColors.dividerDark,
      centerTitle: false,
      backgroundColor: MyntColors.backgroundColorDark, // #0D1117
      iconTheme: IconThemeData(color: MyntColors.textPrimaryDark),
    ),
    bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: MyntColors.cardDark, // #161B22
        dragHandleColor: MyntColors.textSecondaryDark),
    iconTheme: IconThemeData(color: MyntColors.textPrimaryDark),
    dialogTheme: DialogThemeData(backgroundColor: MyntColors.cardDark),
    dividerColor: MyntColors.dividerDark, // #30363D
    cardColor: MyntColors.cardDark, // #161B22
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
    scaffoldBackgroundColor: MyntColors.backgroundColorDark, // #0D1117
    bottomAppBarTheme: BottomAppBarThemeData(color: MyntColors.backgroundColorDark),
    primaryColor: MyntColors.primaryDark, // #58A6FF
    appBarTheme: AppBarTheme(
      shadowColor: MyntColors.dividerDark,
      centerTitle: false,
      backgroundColor: MyntColors.backgroundColorDark,
      iconTheme: IconThemeData(color: MyntColors.textPrimaryDark),
    ),
    bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: MyntColors.cardDark, // #161B22
        dragHandleColor: MyntColors.textSecondaryDark),
    iconTheme: IconThemeData(color: MyntColors.textPrimaryDark),
    dialogTheme: DialogThemeData(backgroundColor: MyntColors.cardDark),
    dividerColor: MyntColors.dividerDark,
    cardColor: MyntColors.cardDark,
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
