import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';

import '../../../../../models/indices/index_list_model.dart';

class TopIndicesListCard extends ConsumerWidget {
  final IndexValue indicesData;
  const TopIndicesListCard({super.key, required this.indicesData});

  @override
  Widget build(BuildContext context, watch) {
    final theme = watch(themeProvider);
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 11),
        decoration: BoxDecoration(
            color: theme.isDarkMode
                ? const Color(0xffB5C0CF).withOpacity(.15)
                : const Color(0xffF1F3F8),
            borderRadius: BorderRadius.circular(5)),
        width: MediaQuery.of(context).size.width * 0.47,
        //width: 142,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(indicesData.idxname!.toUpperCase(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style:
                      textStyle(const Color(0xff000000), 14, FontWeight.w600)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("₹${indicesData.ltp}",
                    style: textStyle(
                        const Color(0xff666666), 14, FontWeight.w500)),
                const SizedBox(height: 2),
                Text("${indicesData.change} (${indicesData.perChange}%)",
                    style: textStyle(
                        indicesData.perChange.toString().startsWith("-") ||
                                indicesData.change.toString().startsWith("-")
                            ? const Color(0xffE00000)
                            : const Color(0xff43A833),
                        12,
                        FontWeight.w500))
              ],
            )
          ],
        ));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
