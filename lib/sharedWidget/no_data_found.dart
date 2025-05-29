import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';

class NoDataFound extends ConsumerWidget {
  const NoDataFound({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(assets.noDatafound,
        color:  theme.isDarkMode?colors.darkColorDivider: colors.colorDivider
        ),
        const SizedBox(height: 2),
        Text("No Data Found",
            style: textStyle(  const Color(0xff777777), 15, FontWeight.w500))
      ]
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
