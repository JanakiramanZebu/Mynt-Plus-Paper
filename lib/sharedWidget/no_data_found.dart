import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';
import '../res/global_state_text.dart';

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
        color:   Color(0xff777777)
        ),
        const SizedBox(height: 2),
        TextWidget.subText(
            text: "No Data Found",
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
                fw:0,
            theme: theme.isDarkMode)
      ]
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
