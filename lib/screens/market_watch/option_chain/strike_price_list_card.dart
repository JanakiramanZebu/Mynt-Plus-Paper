import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';

class StrikePriceListCard extends StatelessWidget {
  final List<OptionValues> strike;
  final bool isCallUp;
  const StrikePriceListCard(
      {super.key, required this.strike, required this.isCallUp});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isCallUp ? true : false,
      itemCount: strike.length * 2 - 1,
      itemBuilder: (BuildContext context, int index) {
        final itemIndex = index ~/ 2;
        if (index.isOdd) {
          return const ListDivider();
        }
        return Container(
            height: 58,
            alignment: Alignment.center,
            color: theme.isDarkMode
                ? const Color(0xffB5C0CF).withOpacity(.15)
                : const Color(0xffFAFBFF),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${strike[itemIndex].strprc}",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  13,
                  FontWeight.w500),
            ));
      },
      // separatorBuilder: (BuildContext context, int index) {
      //   return const ListDivider();
      // },
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ));
  }
}
