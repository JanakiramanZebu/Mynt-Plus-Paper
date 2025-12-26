import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';
import '../res/global_state_text.dart';

class CustomTextBtn extends ConsumerWidget {
  final String label;
  final Function onPress;
  final String icon;
  const CustomTextBtn(
      {super.key,
      required this.label,
      required this.onPress,
      required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
   return SizedBox(
      height: 35,
      child: TextButton(
        style: TextButton.styleFrom(
          elevation: 0.0,
          minimumSize: const Size(0, 40),
          foregroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(0),
          side: BorderSide.none,
          backgroundColor: Colors.transparent,
        ),
        onPressed: () {
          onPress();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget.subText(
                text: label,
                color: theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight,
                theme: theme.isDarkMode,
                fw:0
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(icon,
                  color: theme.isDarkMode
                      ? colors.secondaryDark
                      : colors.secondaryLight)
            ],
          ),
        ),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}
