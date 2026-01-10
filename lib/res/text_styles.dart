import 'package:flutter/material.dart';

import 'colors.dart';

// Helper function to use Geist font instead of Inter
TextStyle geistFont({TextStyle? textStyle}) {
  return TextStyle(
    fontFamily: 'Geist',
    fontWeight: textStyle?.fontWeight,
    fontSize: textStyle?.fontSize,
    color: textStyle?.color,
    letterSpacing: textStyle?.letterSpacing,
    height: textStyle?.height,
    decoration: textStyle?.decoration,
    decorationColor: textStyle?.decorationColor,
    decorationStyle: textStyle?.decorationStyle,
    fontStyle: textStyle?.fontStyle,
  );
}

class AppTextStyles {
  final appBarTitleTxt = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors().colorBlack,
  ));
  final textFieldLabelStyleInterV = TextStyle(
    fontFamily: 'Geist',
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors().colorBlack,
  );
  final textFieldLabelStyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 15,
    color: AppColors().colorBlack,
  ));
  final notificationtextstyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors().colorBlack,
  ));
  final darkmorestyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors().colorLightBlue,
  ));
  final morestyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors().colorBlue,
  ));
  final notificationtimestyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors().colorGrey,
  ));
  final actMenuTxt = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors().colorBlue,
  ));
  final menuTxt = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors().colorGrey,
  ));

  final prdText = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors().colorGrey,
  ));
  final actPrdText = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors().colorBlue,
  ));

  final darktextBtn = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors().colorLightBlue,
  ));

  final textBtn = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors().colorBlue,
  ));

  final btnText = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 13,
    color: AppColors().colorWhite,
  ));

  final lengthtextstyle = geistFont(
      textStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xff666666)));

  final cnfrmvalidInfo = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors().colorBlack,
  ));

  final scripNameTxtStyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: AppColors().colorBlack,
  ));

  final scripExchTxtStyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 11,
    color: AppColors().colorGrey,
  ));

  final resendOtpstyle = geistFont(
      textStyle: TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors().colorBlue,
  ));
}
