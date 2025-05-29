import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../provider/market_watch_provider.dart';
import '../../../res/res.dart';
// import '../../../provider/thems.dart';

class TexhDataWidget extends ConsumerWidget {
  const TexhDataWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techData = ref.watch(marketWatchProvider);
    // final theme =  ref.watch(themeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [  
        Text("Returns",
            style: textStyle(const Color(0xff000000), 14, FontWeight.w600)),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisSpacing: 12,
          mainAxisSpacing: 10,
          childAspectRatio: 1.9,
          children: List.generate(techData.returnsGridview.length, (index) {
            return Container(
              width: 120,
              padding: const EdgeInsets.symmetric(vertical:6, horizontal: 8),
              decoration: BoxDecoration(

                color: colors.KColorLightBlueBg,
                  // color: Color(techData.returnsGridview[index]['percent']
                  //         .toString()
                  //         .startsWith("-")
                  //     ? 0xffFFFCFB
                  //     : 0xffFBFFFA),

                
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xff999999), width: .2)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${techData.returnsGridview[index]['percent']}%",
                        style: textStyle(
                            techData.returnsGridview[index]['percent']
                                    .toString()
                                    .startsWith("-")
                                ? colors.darkred
                                : colors.ltpgreen,
                            18,
                            FontWeight.w500)),
                    const SizedBox(height: 12),
                    Text("${techData.returnsGridview[index]['duration']}",
                        textAlign: TextAlign.center,
                        style: textStyle(
                            const Color(0xff666666), 12, FontWeight.w500)),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
