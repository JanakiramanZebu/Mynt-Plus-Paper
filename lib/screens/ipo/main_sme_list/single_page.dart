import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:readmore/readmore.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/ipo_time_line.dart';
import 'finchart.dart';

class MainSmeSinglePage extends StatefulWidget {
  final String ipotype;
  final String startdate;
  final String enddate;
  final String mininv;
  final String pricerange;
  const MainSmeSinglePage({
    super.key,
    required this.ipotype,
    required this.startdate,
    required this.enddate,
    required this.mininv,
    required this.pricerange,
  });

  @override
  State<MainSmeSinglePage> createState() => _MainSmeSinglePageState();
}

class _MainSmeSinglePageState extends State<MainSmeSinglePage> {
  double initSize = 0.88;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final theme = watch(themeProvider);
        final singlepage = watch(ipoProvide);
        //final ipoLtp = watch(marketWatchProvider);
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: .99,
          expand: false,
          builder: (context, scrollController) {
            return singlepage.iposinglepage!.data == "no data"
                ? const Column(
                    children: [
                      CustomDragHandler(),
                      Padding(
                          padding: EdgeInsets.symmetric(vertical: 250),
                          child: NoDataFound()),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0xff999999),
                              blurRadius: 4.0,
                              offset: Offset(2.0, 0.0))
                        ]),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CustomDragHandler(),
                          const SizedBox(
                            height: 6,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xfffafbff)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              leading: ClipOval(
                                child: Container(
                                  color: colors.colorDivider.withOpacity(.3),
                                  width: 50,
                                  height: 50,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Image.network(
                                      singlepage
                                          .iposinglepage!.data!['image_link']
                                          .toString(),
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child; // Image fully loaded
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Text(
                                            'Failed to load image'); // Fallback if image fails to load
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${singlepage.iposinglepage!.data!['Company Name'].toUpperCase()} ",
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite,
                                          15,
                                          FontWeight.w600)),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: theme.isDarkMode
                                                  ? colors.colorGrey
                                                      .withOpacity(.1)
                                                  : const Color(0xffF1F3F8),
                                              // border: Border.all(
                                              //     color: const Color(0xffC1E7BA)),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Text(widget.ipotype,
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  9,
                                                  FontWeight.w500))),
                                      const SizedBox(width: 10),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: ipostartdate(
                                                          widget.startdate
                                                              .toString(),
                                                          widget.enddate
                                                              .toString()) ==
                                                      "Open"
                                                  ? theme.isDarkMode
                                                      ? const Color(0xffECF8F1)
                                                          .withOpacity(.3)
                                                      : const Color(0xffECF8F1)
                                                  : theme.isDarkMode
                                                      ? const Color(0xffFFF6E6)
                                                          .withOpacity(.3)
                                                      : const Color(0xffFFF6E6),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          child: Text(
                                              ipostartdate(
                                                  widget.startdate.toString(),
                                                  widget.enddate.toString()),
                                              style: textStyle(
                                                  Color(ipostartdate(widget.startdate.toString(), widget.enddate.toString()) == "Open" ? 0xff43A833 : 0xffB37702),
                                                  11,
                                                  FontWeight.w500))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Expanded(
                            child: ListView(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              controller: scrollController,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Fundamental Information",
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            16,
                                            FontWeight.w500),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      rowOfInfoData(
                                          "Lot Size",
                                          singlepage.iposinglepage!
                                                          .data!['Lot Size'] ==
                                                      "" ||
                                                  singlepage.iposinglepage!
                                                          .data!['Lot Size'] ==
                                                      null
                                              ? "--"
                                              : "${singlepage.iposinglepage!.data!['Lot Size']}",
                                          "Price Band",
                                          widget.pricerange,
                                          theme),
                                      // const SizedBox(
                                      //   height: 8,
                                      // ),
                                      // rowOfInfoData(
                                      //     "IPO Status",
                                      // ipostartdate(
                                      //             widget.startdate.toString(),
                                      //             widget.enddate
                                      //                 .toString()) ==
                                      //             "Open"
                                      //         ? "Live"
                                      //         : "Close",
                                      //     "Min Investment",
                                      //     widget.mininv,
                                      //     theme),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      rowOfInfoData(
                                          "Issue Size",
                                          singlepage.iposinglepage!.data![
                                                          'Issue Size'] ==
                                                      "" ||
                                                  singlepage.iposinglepage!
                                                              .data![
                                                          'Issue Size'] ==
                                                      null
                                              ? "--"
                                              : "${double.parse(singlepage.iposinglepage!.data!['Issue Size']).toInt()} Cr",
                                          "Min Investment",
                                          widget.mininv,
                                          theme)
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: theme.isDarkMode
                                        ? colors.darkColorDivider
                                        : colors.colorDivider,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Ipo TimeLine",
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            16,
                                            FontWeight.w500),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      ListView.builder(
                                        itemCount: singlepage.iposinglepage!
                                            .scripdata["IPO_Timeline"].length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final isFirst = index == 0;
                                          final isLasts = index ==
                                              singlepage
                                                      .iposinglepage!
                                                      .scripdata["IPO_Timeline"]
                                                      .length -
                                                  1;
                                          return IpoTimeLineWidget(
                                              isfFrist: isFirst,
                                              isLast: isLasts,
                                              orderHistoryData: singlepage
                                                      .iposinglepage!
                                                      .scripdata["IPO_Timeline"]
                                                  [index]);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: theme.isDarkMode
                                        ? colors.darkColorDivider
                                        : colors.colorDivider,
                                  ),
                                ),
                                // Padding(
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 16,
                                //     ),
                                //     child: Column(
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       children: [
                                //         Text(
                                //           "IPO Subscription Status",
                                //           style: textStyle(
                                //               theme.isDarkMode
                                //                   ? colors.colorWhite
                                //                   : colors.colorBlack,
                                //               16,
                                //               FontWeight.w500),
                                //         ),
                                //         const SizedBox(
                                //           height: 10,
                                //         ),
                                //         Text(
                                //           "${singlepage.iposinglepage!.scripdata["IPO_Subscription_Status"][6]['Subscription (times)']}X",
                                //           style: textStyle(colors.ltpgreen, 16,
                                //               FontWeight.w500),
                                //         ),
                                //         const SizedBox(
                                //           height: 10,
                                //         ),
                                //         Text(
                                //           "This IPO has been subscribed by 0.7005x in retail and 0.0003x in QIB.",
                                //           style: textStyle(colors.colorGrey, 13,
                                //               FontWeight.w400),
                                //         ),
                                //         const SizedBox(
                                //           height: 15,
                                //         ),
                                //         Text(
                                //           "Subscription Rate",
                                //           style: textStyle(
                                //               theme.isDarkMode
                                //                   ? colors.colorWhite
                                //                   : colors.colorBlack,
                                //               16,
                                //               FontWeight.w500),
                                //         ),
                                //         const SizedBox(
                                //           height: 15,
                                //         ),
                                //         Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceBetween,
                                //           children: [
                                //             Text(
                                //               "Total Subscription",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             ),
                                //             Text(
                                //               "${singlepage.iposinglepage!.scripdata["IPO_Subscription_Status"][6]['Subscription (times)']}X",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             )
                                //           ],
                                //         ),
                                //         Divider(
                                //           color: theme.isDarkMode
                                //               ? colors.darkColorDivider
                                //               : colors.colorDivider,
                                //         ),
                                //         const SizedBox(
                                //           height: 15,
                                //         ),
                                //         Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceBetween,
                                //           children: [
                                //             Text(
                                //               "Retail Individual Investors",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             ),
                                //             Text(
                                //               "${singlepage.iposinglepage!.scripdata["IPO_Subscription_Status"][4]['Subscription (times)']}X",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             )
                                //           ],
                                //         ),
                                //         Divider(
                                //           color: theme.isDarkMode
                                //               ? colors.darkColorDivider
                                //               : colors.colorDivider,
                                //         ),
                                //         const SizedBox(
                                //           height: 15,
                                //         ),
                                //         Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceBetween,
                                //           children: [
                                //             Text(
                                //               "Qualified Institutional Buyers",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             ),
                                //             Text(
                                //               "${singlepage.iposinglepage!.scripdata["IPO_Subscription_Status"][0]['Subscription (times)']}X",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             )
                                //           ],
                                //         ),
                                //         Divider(
                                //           color: theme.isDarkMode
                                //               ? colors.darkColorDivider
                                //               : colors.colorDivider,
                                //         ),
                                //         const SizedBox(
                                //           height: 15,
                                //         ),
                                //         Row(
                                //           mainAxisAlignment:
                                //               MainAxisAlignment.spaceBetween,
                                //           children: [
                                //             Text(
                                //               "Non Institutional Investors",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             ),
                                //             Text(
                                //               "${singlepage.iposinglepage!.scripdata["IPO_Subscription_Status"][1]['Subscription (times)']}X",
                                //               style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400),
                                //             )
                                //           ],
                                //         ),
                                //         Divider(
                                //           color: theme.isDarkMode
                                //               ? colors.darkColorDivider
                                //               : colors.colorDivider,
                                //         )
                                //       ],
                                //     )),

                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: theme.isDarkMode
                                        ? colors.darkColorDivider
                                        : colors.colorDivider,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Financial Information",
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            16,
                                            FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                IPOFinancialChart(
                                    theme: theme,
                                    data: singlepage.iposinglepage!.scripdata[
                                        "IPO_Financial_Information"]),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: theme.isDarkMode
                                        ? colors.darkColorDivider
                                        : colors.colorDivider,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      singlepage.iposinglepage!.scripdata[
                                                  "IPO_Promoter_Holding"] ==
                                              null
                                          ? Container()
                                          : Text(
                                              "Promoter Holding",
                                              style: textStyle(
                                                  !theme.isDarkMode
                                                      ? colors.colorBlack
                                                      : colors.colorWhite,
                                                  16,
                                                  FontWeight.w500),
                                            ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                singlepage.iposinglepage!.scripdata[
                                            "IPO_Promoter_Holding"] ==
                                        null
                                    ? Container()
                                    : ListView.builder(
                                        itemCount: singlepage
                                            .iposinglepage!
                                            .scripdata["IPO_Promoter_Holding"]
                                            .length,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "${singlepage.iposinglepage!.scripdata["IPO_Promoter_Holding"][index]['name']}",
                                                      style: textStyle(
                                                          !theme.isDarkMode
                                                              ? colors
                                                                  .colorBlack
                                                              : colors
                                                                  .colorWhite,
                                                          14,
                                                          FontWeight.w400),
                                                    ),
                                                    Text(
                                                      "${singlepage.iposinglepage!.scripdata["IPO_Promoter_Holding"][index]['value']}",
                                                      style: textStyle(
                                                          !theme.isDarkMode
                                                              ? colors
                                                                  .colorBlack
                                                              : colors
                                                                  .colorWhite,
                                                          14,
                                                          FontWeight.w400),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  color: theme.isDarkMode
                                                      ? colors.darkColorDivider
                                                      : colors.colorDivider,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                singlepage.iposinglepage!.scripdata[
                                            "IPO_Promoter_Holding"] ==
                                        null
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Divider(
                                          color: theme.isDarkMode
                                              ? colors.darkColorDivider
                                              : colors.colorDivider,
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "About Company",
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            16,
                                            FontWeight.w500),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: ReadMoreText(
                                            "${singlepage.iposinglepage!.data['about']}",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500),
                                            textAlign: TextAlign.left,
                                            trimLines: 4,
                                            moreStyle: theme.isDarkMode
                                                ? textStyles.darkmorestyle
                                                : textStyles.morestyle,
                                            lessStyle: theme.isDarkMode
                                                ? textStyles.darkmorestyle
                                                : textStyles.morestyle,
                                            colorClickableText:
                                                const Color(0xff0037B7),
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'Read more',
                                            trimExpandedText: ' Read less'),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ]),
                  );
          },
        );
      },
    );
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title1,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(value1,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600)),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
          const SizedBox(width: 18),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title2,
                    style: textStyle(
                        const Color(0xff666666), 10, FontWeight.w400)),
                const SizedBox(height: 4),
                Text(
                  value2,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Divider(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider)
              ])),
        ]);
  }
}
