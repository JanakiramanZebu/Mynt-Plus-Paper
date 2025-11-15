import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../provider/thems.dart';
import '../../res/res.dart';
import '../res/global_font_web.dart';
import '../res/global_state_text.dart';
import '../res/web_colors.dart';

class NoDataFoundWeb extends ConsumerWidget {
  const NoDataFoundWeb({super.key});

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
        Text(
          "No Data Found",
          style: WebTextStyles.para(
          isDarkTheme: theme.isDarkMode,
          color: theme.isDarkMode
              ? WebDarkColors.textSecondary
              : WebColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          
        ),
      ]
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
