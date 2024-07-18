import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus_testing/models/explore_model/stocks_model/sctor_thematic_model.dart';

import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_back_btn.dart';
import '../../../../../sharedWidget/list_divider.dart';

class SectorThematicDetail extends ConsumerWidget {
  final SectorThemeaticModel data;

  const SectorThematicDetail({super.key, required this.data});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final tradeAcrion = context.read(stocksProvide).indicesData;
    final theme = context.read(themeProvider);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 41,
        centerTitle: false,
        titleSpacing: 0,
        leading: const CustomBackBtn(),
        elevation: .4,
        title: Container(
          margin: const EdgeInsets.only(right: 10),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("${data.secName}",
                        style:
                            textStyle(colors.colorBlack, 14, FontWeight.w500)),
                    Text(" (${data.secCount})",
                        style:
                            textStyle(colors.colorGrey, 14, FontWeight.w500)),
                  ],
                ),
                Text("${data.ltp}",
                    style: textStyle(colors.colorBlack, 14, FontWeight.w500)),
              ],
            ),
            SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
           SizedBox(
                      width: MediaQuery.of(context).size.width/1.7,
                child: Row(
                  children: [
                    if(data.poistive!="0")...[
                    colorBar("${data.poistive}",Color(0xff43A833) ),
                    SizedBox(width: 10)],
                           if(data.nutral!="0")...[
                    colorBar("${data.nutral}", Color(0xff999999)),
                    SizedBox(width: 10)],
                           if(data.negative!="0")...[
                    colorBar("${data.negative}", Color(0xffFF1717)),
                    SizedBox(width: 10)]
                  ],
                ),
              ),
              Text(" ${data.chng} (${data.perChng}%)",
                  style: textStyle(
                      Color(data.chng.toString().startsWith("-") ||
                              data.perChng.toString().startsWith('-')
                          ? 0xffFF1717
                          : (data.chng.toString() == "0.00" ||
                                  data.perChng.toString() == "0.00")
                              ? 0xff999999
                              : 0xff43A833),
                      12,
                      FontWeight.w500)),
            ]),
          ]),
        ),
      ),
      body: ListView.separated(
          itemCount: tradeAcrion.length,
          itemBuilder: (BuildContext context, int idx) {
            return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                dense: true,
                title: Text("${tradeAcrion[idx].sYMBOL!.substring(4)} ",
                    style: textStyles.scripNameTxtStyle.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 3),
                    Text("${tradeAcrion[idx].industry}",
                        style: textStyles.scripNameTxtStyle
                            .copyWith(color: const Color(0xff666666))),
                  ],
                ),
                trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("₹${tradeAcrion[idx].ltp}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(
                        "${tradeAcrion[idx].perChng} (${tradeAcrion[idx].change}%)",
                        style: textStyle(
                            Color(tradeAcrion[idx]
                                    .change
                                    .toString()
                                    .startsWith('-')
                                ? 0xffFF1717
                                : tradeAcrion[idx].change.toString() == "0.00"
                                    ? 0xff999999
                                    : 0xff43A833),
                            12,
                            FontWeight.w600),
                      )
                    ]));
          },
          separatorBuilder: (BuildContext context, int index) {
            return const ListDivider();
          }),
    );
  }

  Expanded colorBar(String value, Color color) {
    return Expanded(
        flex: double.parse(value == "null" || value == ""? "0.0" : value).ceil(),
        child: Container(
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(30)),
            height: 7));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
