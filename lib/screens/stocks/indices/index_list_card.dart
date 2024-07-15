import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:google_fonts/google_fonts.dart'; 
import '../../../models/indices/index_list_model.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class IndexListCard extends ConsumerWidget {
  final IndexValue indicesData;
  const IndexListCard({super.key, required this.indicesData});

  @override
  Widget build(BuildContext context,ScopedReader watch) {      final theme = context.read(themeProvider);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      title:
          Text("${indicesData.idxname!.toUpperCase()} ", style: textStyles.scripNameTxtStyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,    
        children: [
          const SizedBox(height: 3),
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xffF1F3F8)),
            child: Text("${indicesData.exch}",
                overflow: TextOverflow.ellipsis,
                style: textStyle(const Color(0xff666666), 10, FontWeight.w500)),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("₹${indicesData.ltp=="0"?   indicesData.close :indicesData.ltp}",
              style: textStyle(const Color(0xff000000), 14, FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            "${indicesData.change == "null" ? "0.00 " : double.parse("${indicesData.change}").toStringAsFixed(2)} "
            "${indicesData.perChange == "null" ? "(0.00%)" : "(${indicesData.perChange ?? 0.00}%)"}",
            style: textStyle(
                Color(indicesData.change!.startsWith("-") ||
                        indicesData.perChange!.startsWith('-')
                    ? 0xffFF1717
                    : (indicesData.change == "null" ||
                                indicesData.perChange == "null") ||
                            (indicesData.change == "0.00" ||
                                indicesData.perChange == "0.00")
                        ? 0xff999999
                        : 0xff43A833),
                12,
                FontWeight.w600),
          ),
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
