import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 

import '../../../../../../models/explore_model/stocks_model/sctor_thematic_model.dart';
import '../../../../../../provider/stocks_provider.dart';
import '../../../../../../provider/thems.dart';
import '../../../../../../res/res.dart';
import '../../../../../../routes/route_names.dart';

class SectorThematicList extends ConsumerWidget {
  final List<SectorThemeaticModel> data;
  final bool isscollable;

  const SectorThematicList(
      {super.key, required this.data, required this.isscollable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      alignment: Alignment.topCenter,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shrinkWrap: true,
        physics: isscollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          data[index].chng =
              data[index].chng!.isEmpty ? "0.00" : data[index].chng;
          data[index].perChng =
              data[index].perChng!.isEmpty ? "0.00" : data[index].perChng;
          return InkWell(
            onTap: () async {
              await ref.read(stocksProvide)
                  .fetchAdindices("${data[index].secName}");
              Navigator.pushNamed(context, Routes.sectorThematicDetail,
                  arguments: data[index]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8)),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 1.7,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                                "${data[index].name!.isEmpty ? data[index].secName : data[index].name}",
                                overflow: TextOverflow.ellipsis,
                                style: textStyle(
                                    colors.colorBlack, 14, FontWeight.w500)),
                          ),
                          Text(" (${data[index].secCount})",
                              style: textStyle(
                                  colors.colorGrey, 14, FontWeight.w500)),
                        ],
                      ),
                    ),
                    Text(
                        "${data[index].ltp!.isEmpty ? "0.00" : data[index].ltp}",
                        style:
                            textStyle(colors.colorBlack, 14, FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.7,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                if (data[index].poistive != "0") ...[
                                  colorBar("${data[index].poistive}",
                                      const Color(0xff43A833)),
                                  const SizedBox(width: 10)
                                ],
                                if (data[index].nutral != "0") ...[
                                  colorBar("${data[index].nutral}",
                                      const Color(0xff999999)),
                                  const SizedBox(width: 10)
                                ],
                                if (data[index].negative != "0") ...[
                                  colorBar("${data[index].negative}",
                                      const Color(0xffFF1717)),
                                  const SizedBox(width: 10)
                                ]
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (data[index].poistive != "0") ...[
                                  colorBarText("${data[index].poistive}",
                                      const Color(0xff43A833)),
                                  const SizedBox(width: 10)
                                ],
                                if (data[index].nutral != "0") ...[
                                  colorBarText("${data[index].nutral}",
                                      const Color(0xff999999)),
                                  const SizedBox(width: 10)
                                ],
                                if (data[index].negative != "0") ...[
                                  colorBarText("${data[index].negative}",
                                      const Color(0xffFF1717)),
                                  const SizedBox(width: 10)
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(" ${data[index].chng} (${data[index].perChng}%)",
                          style: textStyle(
                              Color(data[index]
                                          .chng
                                          .toString()
                                          .startsWith("-") ||
                                      data[index]
                                          .perChng
                                          .toString()
                                          .startsWith('-')
                                  ? 0xffFF1717
                                  : (data[index].chng.toString() == "0.00" ||
                                          data[index].perChng.toString() ==
                                              "0.00")
                                      ? 0xff999999
                                      : 0xff43A833),
                              12,
                              FontWeight.w500)),
                    ]),
              ]),
            ),
          );
        },
        itemCount: data.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(height: 8);
        },
      ),
    );
  }

  Expanded colorBar(String value, Color color) {
    return Expanded(
        flex:
            double.parse(value == "null" || value == "" ? "0.0" : value).ceil(),
        child: Container(
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(30)),
            height: 7));
  }

  Expanded colorBarText(String value, Color color) {
    return Expanded(
      flex: double.parse(value == "null" || value == "" ? "0.0" : value).ceil(),
      child: Text(value, style: textStyle(color, 12, FontWeight.w600)),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
