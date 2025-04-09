import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/res.dart';

class TextWidget {
  static Widget heroText(
      {required String text,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: 20,
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
         fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }

  static Widget headText(
      {required String text,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: 18,
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
         fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }

  static Widget titleText(
      {required String text,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: 16,
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
         fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }

  static Widget subText(
      {required String text,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: 14,
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
         fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }

  static Widget paraText(
      {required String text,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: 12,
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
        fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }

  static Widget captionText(
      {required String text,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: 10,
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
         fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }

  static Widget overlineText(
      {required String text,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: 8,
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
         fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }

  static Widget custmText(
      {required String text,
      required int fs,
      required bool theme,
      Color? color,
      int? fw,
      int? maxLines,
      TextAlign? align,
      TextOverflow? textOverflow}) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: textOverflow,
      textAlign: align,
      style: GoogleFonts.inter(
          textStyle: TextStyle(
        fontSize: fs.toDouble(),
        color: (color != null)
            ? color
            : theme
                ? colors.colorWhite
                : colors.colorBlack,
         fontWeight: fw == 2
            ? FontWeight.bold
            : fw == 1
                ? FontWeight.w600
                :  fw == 0
                ? FontWeight.w500 : FontWeight.normal,
      )),
    );
  }
}