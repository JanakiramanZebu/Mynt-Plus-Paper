import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import 'package:mynt_plus/res/res.dart';
import '../../models/order_book_model/sip_order_book.dart';
import '../../provider/thems.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';

class SipOrderBook extends ConsumerWidget {
  final List<SipDetails>? sipbook;
  const SipOrderBook({super.key, required this.sipbook});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    return sipbook == null
        ? const NoDataFound()
        : Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : const Color(0xffF1F3F8),
                            width: 6))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  dense: true,
                  title: Text("${sipbook!.length} Order · List by you",
                      style: textStyle(
                          const Color(0xff666666), 12, FontWeight.w600)),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () async {
                                context.read(orderProvider).fetchSipOrderHistory(context);
                                Navigator.pushNamed(context, Routes.sipDetails,
                                    arguments: sipbook![index]);
                              },
                              child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("${sipbook![index].sipName}",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  15,
                                                  FontWeight.w600)),
                                          Row(
                                            children: [
                                              Text("LTP: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  "${sipbook![index].scrips![0].ltp}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                              sipformatDateTime(
                                                  value:
                                                      "${sipbook![index].regDate}"),
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  13,
                                                  FontWeight.w600)),
                                          Text(
                                              " (${sipbook![index].scrips![0].perChange ?? 0.00}%)",
                                              style: textStyle(
                                                  sipbook![index]
                                                              .scrips![0]
                                                              .perChange ==
                                                          null
                                                      ? colors.ltpgrey
                                                      : sipbook![index]
                                                              .scrips![0]
                                                              .perChange!
                                                              .startsWith("-")
                                                          ? colors.darkred
                                                          : sipbook![index]
                                                                      .scrips![
                                                                          0]
                                                                      .perChange ==
                                                                  "0.00"
                                                              ? colors.ltpgrey
                                                              : colors.ltpgreen,
                                                  12,
                                                  FontWeight.w500))
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Divider(
                                          color: theme.isDarkMode
                                              ? colors.darkColorDivider
                                              : Color(0xffECEDEE)),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Start Date: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  duedateformate(
                                                      value:
                                                          "${sipbook![index].startDate}"),
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Due Date: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  duedateformate(
                                                      value:
                                                          "${sipbook![index].internal?.dueDate}"),
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text("Pending Period: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  "${sipbook![index].endPeriod}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text("Execution Date: ",
                                                  style: textStyle(
                                                      const Color(0xff5E6B7D),
                                                      13,
                                                      FontWeight.w600)),
                                              Text(
                                                  duedateformate(
                                                      value:
                                                          "${sipbook![index].internal?.execDate}"),
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  )));
                        },
                        itemCount: sipbook!.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : const Color(0xffF1F3F8),
                              height: 7);
                        },
                      )
                    ],
                  ),
                ),
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
