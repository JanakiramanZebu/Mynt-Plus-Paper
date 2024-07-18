import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus_testing/models/explore_model/stocks_model/sctor_thematic_model.dart';

import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';
import '../../../../../routes/route_names.dart';

class SectorThematicList extends StatelessWidget {
  final List<SectorThemeaticModel> data;

  const SectorThematicList({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    return Container(
      margin: EdgeInsets.only(top: 8),
      alignment: Alignment.topCenter,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 12),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () async {
              await context
                  .read(stocksProvide)
                  .fetchAdindices("${data[index].secName}");
              Navigator.pushNamed(context, Routes.sectorThematicDetail,
                  arguments: data[index]);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8)),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("${data[index].name}",
                            style: textStyle(
                                colors.colorBlack, 14, FontWeight.w500)),
                        Text(" (${data[index].secCount})",
                            style: textStyle(
                                colors.colorGrey, 14, FontWeight.w500)),
                      ],
                    ),
                    Text("${data[index].ltp}",
                        style:
                            textStyle(colors.colorBlack, 14, FontWeight.w500)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     SizedBox(
                      width: MediaQuery.of(context).size.width/1.7,
                        child: Row(
                          children: [

                            if(data[index].poistive!="0")...[
                            colorBar(
                                "${data[index].poistive}",Color(0xff43A833)),
                            SizedBox(width: 10)], if(data[index].nutral!="0")...[
                            colorBar(
                                "${data[index].nutral}", Color(0xff999999)),
                            SizedBox(width: 10)], if(data[index].negative!="0")...[
                            colorBar(
                                "${data[index].negative}",  Color(0xffFF1717)),
                            SizedBox(width: 10)]
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
          return SizedBox(height: 8);
        },
      ),
    );
  }

  Expanded colorBar(String value, Color color) {
    return Expanded(
        flex: double.parse(value == "null"|| value == ""  ? "0.0" : value).ceil(),
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
