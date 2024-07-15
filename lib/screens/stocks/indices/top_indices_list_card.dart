import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
 
import '../../../models/indices/index_list_model.dart';

class TopIndicesListCard extends ConsumerWidget {
  final IndexValue indicesData;
  const TopIndicesListCard({super.key, required this.indicesData});

  @override
  Widget build(BuildContext context, watch) {
    return topIndicesListData();
  }

  Container topIndicesListData() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffCCCCCC)),
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        width: 142,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              indicesData.idxname!.toUpperCase(),
              style: textStyle(const Color(0xff000000), 14, FontWeight.w600),
            ),
            const Divider(
              endIndent: 85,
              color: Color(0xff000000),
              thickness: 1,
            ),
            Text("₹${indicesData.ltp}",
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
            const SizedBox(height: 4),
            Text("${indicesData.change} (${indicesData.perChange}%)",
                style: textStyle(
                    indicesData.perChange.toString().startsWith("-") ||
                            indicesData.change.toString().startsWith("-")
                        ? const Color(0xffE00000)
                        : const Color(0xff43A833),
                    12,
                    FontWeight.w500))
          ],
        ));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
