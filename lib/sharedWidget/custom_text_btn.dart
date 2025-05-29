import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';

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
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: () {
        onPress();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                  textStyle:
                      textStyle( theme.isDarkMode?colors.colorLightBlue:colors.colorBlue, 14, FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              icon,
              color: theme.isDarkMode?colors.colorLightBlue:colors.colorBlue
            )
          ],
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
