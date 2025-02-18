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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // White at 10%
            Color(0xFFF1F3F8), // Light Gray at 60%
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.8], // 10% and 60%
        ),
            borderRadius: BorderRadius.circular(12)),
        width: 130,
        //width: 142,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(indicesData.idxname!.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyle(const Color(0xff000000), 14, FontWeight.w600)),
            const SizedBox(height: 10),
            Text("₹${indicesData.ltp}",
                maxLines: 1,
                style: textStyle(const Color(0xff666666), 14, FontWeight.w500)),
            const SizedBox(height: 4),
            Text("${indicesData.change} (${indicesData.perChange}%)",
                maxLines: 1,
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
