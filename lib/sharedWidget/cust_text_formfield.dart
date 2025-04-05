// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final TextStyle? style;
  TextEditingController textCtrl;
  final List<TextInputFormatter>? inputFormate;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffix;
  final Widget? prefix;
  TextAlign textAlign;

  final TextInputType? keyboardType;
  final Color? fillColor;
  final bool? isReadable;
  CustomTextFormField({
    super.key,
    this.hintText,
    this.hintStyle,
    this.labelStyle,
    this.style,
    required this.textCtrl,
    this.inputFormate,
    this.suffixIcon,
    this.onChanged,
    this.prefixIcon,
    this.suffix,
    this.prefix,
    this.isReadable,
    this.fillColor,
    this.keyboardType,
    required this.textAlign,
    // required String type
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
       
        controller: textCtrl,
        style: style,
        readOnly: isReadable ?? false,
        keyboardType: keyboardType,
        textAlign: textAlign,
        inputFormatters: inputFormate,
        decoration: InputDecoration(
            fillColor: fillColor ?? const Color(0xffF1F3F8),
            filled: true,
            hintText: hintText,
            hintStyle: hintStyle,
            labelStyle: labelStyle,
            prefixIconColor: const Color(0xff586279),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30)),
            disabledBorder: InputBorder.none,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30)),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(30))),
        onChanged: onChanged);
  }
}
