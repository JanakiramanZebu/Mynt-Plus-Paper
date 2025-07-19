import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/list_divider.dart';

class StrikePriceListCard extends ConsumerWidget {
  final List<OptionValues> strike;
  final bool isCallUp;
  
  const StrikePriceListCard({
    super.key,
    required this.strike,
    required this.isCallUp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final textColor = theme.isDarkMode ? colors.colorWhite : colors.colorBlack;
    
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isCallUp,
      itemCount: strike.length,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (BuildContext context, int index) {
        final strikePrice = strike[index].strprc;
        return Container(
          height: 65,
          alignment: Alignment.center,
          color: theme.isDarkMode
              ? const Color(0xffB5C0CF).withOpacity(.15)
              : const Color(0xffFAFBFF),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "$strikePrice",
            style: _getTextStyle(textColor),
          ),
        );
      },
    );
  }

  static final Map<Color, TextStyle> _textStyleCache = {};
  
  static TextStyle _getTextStyle(Color color) {
    // return _textStyleCache.putIfAbsent(
    //   color,
    //   () => GoogleFonts.inter(
    //     textStyle: 
return TextWidget.textStyle(
                 fontSize: 14 ,  theme: false , );


    //   ).copyWith(color: color),
    // );
  }
}
