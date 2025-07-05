import 'package:flutter/material.dart';

class AppColors {
// ----------------------------------------------------------------------------------------------

  //new colors implementation

// === PRIMARY COLORS ===
  final primary = const Color(0xFF0037B7);
  final primaryLight = const Color(0xFF0037B7);
  final primaryDark = const Color(0xFF002A8F);

  // === SECONDARY COLORS ===
  final secondary = const Color(0xFF0052CC);
  final secondaryLight = const Color(0xFF0052CC);
  final secondaryDark = const Color(0xFF0052CC);

  // === SECONDARY COLORS ===
  final tertiary = const Color(0xFFC40024);
  // final tertiaryLight = const Color(0xFF0052CC);
  // final tertiaryDark = const Color(0xFF0052CC);

// === TEXT COLORS ===
  final textPrimary = const Color(0xFF121212);
  final textPrimaryLight = const Color(0xFF121212);
  final textSecondary = const Color(0xFF4A4A4A);
  final textSecondaryLight = const Color(0xFF4A4A4A);
  final textDisabled = const Color(0xFFBDBDBD);

// Dark theme text colors
  final textPrimaryDark = const Color(0xFFFFFFFF);
  final textSecondaryDark = const Color(0xFFFFFFFF);
  final textDisabledDark = const Color(0xFF404040);

// === STATUS COLORS ===
  final profit = const Color(0xFF00B14F);
  final profitLight = const Color(0xFF00B14F);
  final profitDark = const Color(0xFF2F855A);

  final loss = const Color(0xFFFF1717);
  final lossLight = const Color(0xFFFF1717);
  final lossDark = const Color(0xFFC53030);

  final error = const Color(0xFFFF1717);
  final errorLight = const Color(0xFFFF1717);
  final errorDark = const Color(0xFFC53030);

  final success = const Color(0xFF00B14F);
  final successLight = const Color(0xFF00B14F);
  final successDark = const Color(0xFF2F855A);

  final divider = const Color(0xffDDE2E7);
  final dividerLight = const Color(0xffDDE2E7);
  final dividerDark = const Color(0xffECEDEE).withOpacity(.1);

  final pending = const Color(0xFFFFB038);

  final listItembg = const Color(0xffECEDEE);
// === BACKGROUND COLORS ===
  final btnBg = const Color(0XFFF1F3F8);
  final searchBg = const Color(0XFFF9F9F9);

  final iconColor = const Color(0xff777777);

  // === BORDER COLORS ===
  final btnOutlinedBorder = const Color(0xFF0037B7);

  //inkwell splash color

  final splashColorLight = const Color(0xff000000).withOpacity(0.15);
  final splashColorDark = const Color(0xffFFFFFF).withOpacity(0.15);

// inkwell highlight color (tapfeedback)

  final highlightLight = const Color(0xff000000).withOpacity(0.08);
  final highlightDark = const Color(0xffFFFFFF).withOpacity(0.08);

  // static const Color info = Color(0xFF3182CE);
  // final infoLight = Color(0xFFBEE3F8);
  // static const Color infoDark = Color(0xFF2C5282);

// -----------------------------------------------------------------------------------------------------------

  // old colors

  final colorWhite = const Color(0xffFFFFFF);
  final colorBlack = const Color(0xff000000);
  final logoColor = const Color(0xff0037B7);

  final colorGrey = const Color(0xff666666);
  final colorBlue = const Color(0xff0037B7);
  final colorLightBlue = const Color(0xff2E65F6); //0xff99c3ff
  final colorbluegrey = const Color(0xffB0BEC5); //0xffB0BEC5
  final darkred = const Color(0xfff44336);
  final darkiconcolor = const Color(0xffBDBDBD);
  final ltpgrey = const Color(0xff999999);
  final ltpgreen = const Color(0xff43A833);
  final ltpred = const Color(0xffFF1717);

  final fundbuttonBg = const Color(0xffF1F3F8);

  final darkColorDivider = const Color(0xffECEDEE).withOpacity(.1);
  final colorDivider = const Color(0xffDDE2E7);

  final darkGrey = const Color(0xffB5C0CF).withOpacity(.15);

  final kColorBlack60 = Colors.black54;
  final kColorBlack80 = Colors.black87;
  final kColorWhite60 = Colors.white54;
  final kColorWhite70 = Colors.white70;
  final kColorLightBlackTableCell = const Color(0xffF2F2F2);
  final kColorAccentBlack = const Color(0xff454351);
  final kColorBackground = const Color(0xffE5E5E5);
  final kColorLightGrey = const Color(0xffFAFAFA);
  final kColorDarkBlueText = const Color(0xff1E3565);
  final kColorBlue = const Color(0xff0065BE);
  final kColorBlueText = const Color(0xff0075E1);
  final kColorBlueButton = const Color(0xff4184F5);
  final kColorLighBlue = const Color(0xffE7F1FD);
  final kColorRedText = const Color(0xffDF2525);
  final kColorRedButton = const Color(0xffDF514D);
  final kColorLightRed = const Color(0xffFFF4F0);
  final kColorGreenText = const Color(0xff00A400);
  final kColorGreenButton = const Color(0xff4CB050);
  final kColorLightGreen = const Color(0xffEFFFEF);

  final kColorBlueMain = const Color(0xff1A90FD);
  final kColorOrange = const Color(0xffF25652);

  final kColorLogoLightTheme = const Color(0xff1f3565);

  final kColorBlueBg = const Color(0xff1A90FD);
  // ignore: non_constant_identifier_names
  final KColorLightBlueBg = const Color(0xffe3edfa);
  final kColorLightGreyCardDarkTheme = const Color(0xff1a1a1a);
  final kColorCardGreyDarkTheme = const Color(0xff424242);
  final kColorAccentWhite = const Color(0xff888c91);

  final kColorRedDarkTheme = const Color(0xffdf514c);
  final kColorLightRedDarkTheme = const Color(0xff2d1e1e);
  final kColorBlueDarkTheme = const Color(0xff4987ee);
  final kColorLightBlueDarkTheme = const Color(0xff1d242f);
  final kColorGreyDarkTheme = const Color(0xffbbbbbb);
  final kColorLightGreyDarkTheme = const Color(0xff292929);
  final kColorGreenDarkTheme = const Color(0xff5b9a5d);
  final kColorLightGreenDarkTheme = const Color(0xff1e281e);
  final kColorVioletDarkTheme = const Color(0xffff8002);
  // final kColorLightVioletDarkTheme = const Color(0xff483c2f);
  final kColorLightVioletDarkTheme = const Color(0xff382e23);
  final kColorYellowLightTheme = const Color(0xffdf7c1a);
  final kColorLightYellowLightTheme = const Color(0xfffbf2e9);

  // ignore: non_constant_identifier_names
  final KColorWhiteFade = const Color(0xFFEEEEEE);

  final kColorLightRightButtonBg = const Color(0xFFde8885);
  final kColorLightGreyAlertHeaderBg = const Color(0xFFededed);
  final kColorLightGreyAlertHeaderButtonBg = const Color(0xFFd1d1d1);

  final kColorDarkThemeBackground = const Color(0xFF181818);
  final kColorlightThemeBackground = Colors.white;
}
