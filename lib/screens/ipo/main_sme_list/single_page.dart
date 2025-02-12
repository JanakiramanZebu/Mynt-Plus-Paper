import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mynt_plus/models/ipo_model/ipo_mainstream_model.dart';
import 'package:mynt_plus/models/ipo_model/ipo_sme_model.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final String ipodetails;
  const MainSmeSinglePage(
      {super.key,
      required this.ipotype,
      required this.startdate,
      required this.enddate,
      required this.mininv,
      required this.pricerange,
      required this.ipodetails});

  @override
  State<MainSmeSinglePage> createState() => _MainSmeSinglePageState();
}

class _MainSmeSinglePageState extends State<MainSmeSinglePage> {
  double initSize = 0.88;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    int? maxLines = _isExpanded ? null : 3;
    return Consumer(
      builder: (context, watch, child) {
        final theme = watch(themeProvider);
        final singlepage = watch(ipoProvide);
        final upi = watch(transcationProvider);
        //final ipoLtp = watch(marketWatchProvider);
        // print("iposymbol ::: ${iposymbol}");
        return DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: .99,
          expand: false,
          builder: (context, scrollController) {
            return singlepage.iposinglepage!.data == "no data"
                ? const Column(
                    children: [
                      CustomDragHandler(),
                      SizedBox(
                        height: 10,
                      ),
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
                          singlepage.iposinglepage!.data["status"] != "CLOSED"
                              ? Container(
                                  height: 35,
                                  color: const Color(0xFFE6F7E4),
                                  child: Center(
                                    child: Text(
                                        "This  IPO application is open for ${singlepage.iposinglepage!.data!['CloseAt']} days",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors
                                                    .colorBlack, // Fixes the logic
                                            12,
                                            FontWeight.w500)),
                                  ),
                                )
                              : const SizedBox(),
                          Container(
                            decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xfffafbff)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              trailing: ClipOval(
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
                                      "${singlepage.iposinglepage!.data!['Company Name']} ",
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite,
                                          15,
                                          FontWeight.w600)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
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
                                      const SizedBox(width: 10),
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
                                      // Text(
                                      //   "Fundamental Information",
                                      //   style: textStyle(
                                      //       !theme.isDarkMode
                                      //           ? colors.colorBlack
                                      //           : colors.colorWhite,
                                      //       16,
                                      //       FontWeight.w500),
                                      // ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text("IPO Details",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors
                                                      .colorBlack, // Fixes the logic
                                              15,
                                              FontWeight.w600)),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      // rowOfInfoData(
                                      //     "Lot Size",
                                      //     singlepage.iposinglepage!
                                      //                     .data!['Lot Size'] ==
                                      //                 "" ||
                                      //             singlepage.iposinglepage!
                                      //                     .data!['Lot Size'] ==
                                      //                 null
                                      //         ? "--"
                                      //         : "${singlepage.iposinglepage!.data!['Lot Size']}",
                                      //     "Price Band",
                                      //     widget.pricerange,
                                      //     theme),
                                      rowOfInfoData(
                                          "IPO date",
                                          singlepage.iposinglepage!
                                              .data["IpoDetails"]["IpoDate"],
                                          "Listing date",
                                          singlepage.iposinglepage!
                                              .data["IpoDetails"]["ListingDt"],
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
                                          "Price range",
                                          widget.pricerange,
                                          "Min. amount",
                                          (widget.mininv),
                                          theme),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      rowOfInfoData(
                                          "Total Issue Size",
                                          singlepage.iposinglepage!
                                              .data["IpoDetails"]["tlShares"],
                                          "Lot size",
                                          singlepage.iposinglepage!.data[
                                                              "IpoDetails"]
                                                          ["LotSize"] ==
                                                      "" ||
                                                  singlepage.iposinglepage!
                                                                  .data[
                                                              "IpoDetails"]
                                                          ["LotSize"] ==
                                                      null
                                              ? "--"
                                              : "${singlepage.iposinglepage!.data!["IpoDetails"]['LotSize']}",
                                          theme),

                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text("Listing at",
                                                      style: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          10,
                                                          FontWeight.w400)),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                      singlepage.iposinglepage!.data[
                                                                          "IpoDetails"]
                                                                      [
                                                                      "ListingAt"] ==
                                                                  "" ||
                                                              singlepage.iposinglepage!
                                                                              .data[
                                                                          "IpoDetails"]
                                                                      [
                                                                      "ListingAt"] ==
                                                                  null
                                                          ? "--"
                                                          : "${singlepage.iposinglepage!.data['IpoDetails']['ListingAt']}",
                                                      style: textStyle(
                                                          theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          14,
                                                          FontWeight.w600)),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : colors.colorDivider)
                                                ])),
                                            const SizedBox(width: 18),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                  Text("RHP DOC",
                                                      style: textStyle(
                                                          const Color(
                                                              0xff666666),
                                                          10,
                                                          FontWeight.w400)),
                                                  const SizedBox(height: 4),
                                                  TextButton(
                                                    onPressed: () => _launchURL(
                                                        singlepage.iposinglepage!
                                                                    .data![
                                                                'IpoDetails'][
                                                            'RHP']), // Add your onPressed callback here
                                                    style: TextButton.styleFrom(
                                                      minimumSize: Size(0, 20),
                                                      padding:
                                                          const EdgeInsets.only(
                                                        right: 16,
                                                        top: 0,
                                                        bottom: 0,
                                                      ),
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap, // Apply padding here
                                                      alignment: Alignment
                                                          .topLeft, // Align text to the left
                                                    ),
                                                    child: Text(
                                                      "Download",
                                                      style: textStyle(
                                                        theme.isDarkMode
                                                            ? colors.colorBlue
                                                            : colors.colorBlue,
                                                        14,
                                                        FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Divider(
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .darkColorDivider
                                                          : colors.colorDivider)
                                                ])),
                                          ]),
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

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  color: colors.kColorLightGrey,
                                  child: Builder(
                                    builder: (context) {
                                      final subscriptionData = singlepage
                                          .iposinglepage!.data['subsciption'];

                                      if (subscriptionData == null ||
                                          subscriptionData.isEmpty) {
                                        return Container();
                                      }

                                      return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Subscription Status",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors
                                                            .colorBlack, // Fixes the logic
                                                    15,
                                                    FontWeight.w600)),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              "The IPO has been subscribed ${singlepage.iposinglepage!.data['tlSub']['Subscription (times)']} times",
                                              style: textStyle(
                                                  !theme.isDarkMode
                                                      ? colors.colorGrey
                                                      : colors.colorWhite,
                                                  14,
                                                  FontWeight.w500),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            ListView.separated(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  subscriptionData.length,
                                              separatorBuilder:
                                                  (context, index) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3),
                                                child: Divider(
                                                  color: theme.isDarkMode
                                                      ? colors.darkColorDivider
                                                      : colors.colorDivider,
                                                ),
                                              ),
                                              itemBuilder: (context, index) {
                                                final category =
                                                    subscriptionData[index]
                                                            ["Category"] ??
                                                        "Unknown";
                                                final subscriptionTimes =
                                                    subscriptionData[index][
                                                                "Subscription (times)"]
                                                            ?.toString() ??
                                                        "N/A";

                                                return ipoDateDisplay(
                                                  theme,
                                                  singlepage,
                                                  category,
                                                  subscriptionTimes,
                                                );
                                              },
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            )
                                          ]);
                                    },
                                  ),
                                ),

                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    color: colors.kColorLightGrey,
                                    child: Builder(builder: (context) {
                                      final subscriptionData = singlepage
                                          .iposinglepage!.data['subsciption'];

                                      if (subscriptionData == null ||
                                          subscriptionData.isEmpty) {
                                        return Container();
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Divider(
                                          color: theme.isDarkMode
                                              ? colors.darkColorDivider
                                              : colors.colorDivider,
                                        ),
                                      );
                                    })),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "IPO TimeLine",
                                        style: textStyle(
                                            !theme.isDarkMode
                                                ? colors.colorBlack
                                                : colors.colorWhite,
                                            15,
                                            FontWeight.w600),
                                      ),
                                      ListView.builder(
                                        itemCount: singlepage.iposinglepage!
                                                .data['IPO_Timeline'].length -
                                            1,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final isFirst = index == 0;
                                          final isLasts = index ==
                                              singlepage
                                                      .iposinglepage!
                                                      .data['IPO_Timeline']
                                                      .length -
                                                  2;

                                          return IpoTimeLineWidget(
                                              isfFrist: isFirst,
                                              isLast: isLasts,
                                              orderHistoryData: singlepage
                                                  .iposinglepage!
                                                  .data['IPO_Timeline'][index]);
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    "About the company",
                                    style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      15,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, top: 10, bottom: 1),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        singlepage.iposinglepage!.data['about'],
                                        textAlign: TextAlign.justify,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.7,
                                        ),
                                        maxLines: _isExpanded
                                            ? null
                                            : 3, // Show only 3 lines initially, or full text when expanded
                                        overflow: _isExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow
                                                .ellipsis, // Show ellipsis when text is truncated
                                      ),
                                      const SizedBox(height: 0),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          minimumSize: Size(0, 0),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isExpanded =
                                                !_isExpanded; // Toggle the expanded state
                                          });
                                        },
                                        child: Text(
                                          _isExpanded
                                              ? 'Read Less'
                                              : 'Read More', // Toggle the button text
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF0037B7),
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Padding(
                                //   padding:
                                //       const EdgeInsets.symmetric(vertical: 10),
                                //   child: Divider(
                                //     color: theme.isDarkMode
                                //         ? colors.darkColorDivider
                                //         : colors.colorDivider,
                                //   ),
                                // ),

                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 16),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         "Subscription Status",
                                //         style: textStyle(
                                //           theme.isDarkMode
                                //               ? colors.colorWhite
                                //               : colors.colorBlack,
                                //           16,
                                //           FontWeight.w600,
                                //         ),
                                //       ),
                                //       const SizedBox(height: 15),
                                //       Container(
                                //         padding: const EdgeInsets.all(10),
                                //         color: colors.kColorLightGrey,
                                //         child: Builder(
                                //           builder: (context) {
                                //             final subscriptionData = singlepage
                                //                     .iposinglepage?.scripdata[
                                //                 "IPO_Subscription_Status"];

                                //             if (subscriptionData == null ||
                                //                 subscriptionData.isEmpty) {
                                //               return Text(
                                //                 "No Subscription Data Available",
                                //                 style: textStyle(
                                //                   theme.isDarkMode
                                //                       ? colors.colorWhite
                                //                       : colors.colorBlack,
                                //                   14,
                                //                   FontWeight.w400,
                                //                 ),
                                //               );
                                //             }

                                //             return ListView.separated(
                                //               shrinkWrap: true,
                                //               physics:
                                //                   const NeverScrollableScrollPhysics(),
                                //               itemCount:
                                //                   subscriptionData.length,
                                //               separatorBuilder:
                                //                   (context, index) => Padding(
                                //                 padding:
                                //                     const EdgeInsets.symmetric(
                                //                         vertical: 3),
                                //                 child: Divider(
                                //                   color: theme.isDarkMode
                                //                       ? colors.darkColorDivider
                                //                       : colors.colorDivider,
                                //                 ),
                                //               ),
                                //               itemBuilder: (context, index) {
                                //                 final category =
                                //                     subscriptionData[index]
                                //                             ["Category"] ??
                                //                         "Unknown";
                                //                 final subscriptionTimes =
                                //                     subscriptionData[index][
                                //                                 "Subscription (times)"]
                                //                             ?.toString() ??
                                //                         "N/A";

                                //                 return ipoDateDisplay(
                                //                   theme,
                                //                   singlepage,
                                //                   category,
                                //                   subscriptionTimes,
                                //                 );
                                //               },
                                //             );
                                //           },
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                // Padding(
                                //   padding:
                                //       const EdgeInsets.symmetric(vertical: 10),
                                //   child: Divider(
                                //     color: theme.isDarkMode
                                //         ? colors.darkColorDivider
                                //         : colors.colorDivider,
                                //   ),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 16,
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         "Date",
                                //         style: textStyle(
                                //             !theme.isDarkMode
                                //                 ? colors.colorBlack
                                //                 : colors.colorWhite,
                                //             16,
                                //             FontWeight.w600),
                                //       ),
                                //       const SizedBox(
                                //         height: 15,
                                //       ),
                                //       Container(
                                //         padding: const EdgeInsets.all(10),
                                //         color: colors.kColorLightGrey,
                                //         child: Column(
                                //           children: [
                                //             ipoDateDisplay(
                                //                 theme,
                                //                 singlepage,
                                //                 "Offer Start",
                                //                 getIPOTimelineValue(
                                //                     singlepage.iposinglepage!
                                //                             .scripdata[
                                //                         "IPO_Timeline"],
                                //                     0)),
                                //             Padding(
                                //               padding:
                                //                   const EdgeInsets.symmetric(
                                //                       vertical: 3),
                                //               child: Divider(
                                //                 color: theme.isDarkMode
                                //                     ? colors.darkColorDivider
                                //                     : colors.colorDivider,
                                //               ),
                                //             ),
                                //             ipoDateDisplay(
                                //                 theme,
                                //                 singlepage,
                                //                 "Offer End",
                                //                 getIPOTimelineValue(
                                //                     singlepage.iposinglepage!
                                //                             .scripdata[
                                //                         "IPO_Timeline"],
                                //                     1)),
                                //             Padding(
                                //               padding:
                                //                   const EdgeInsets.symmetric(
                                //                       vertical: 3),
                                //               child: Divider(
                                //                 color: theme.isDarkMode
                                //                     ? colors.darkColorDivider
                                //                     : colors.colorDivider,
                                //               ),
                                //             ),
                                //             ipoDateDisplay(
                                //                 theme,
                                //                 singlepage,
                                //                 "Allotment finalization",
                                //                 getIPOTimelineValue(
                                //                     singlepage.iposinglepage!
                                //                             .scripdata[
                                //                         "IPO_Timeline"],
                                //                     2)),
                                //             Padding(
                                //               padding:
                                //                   const EdgeInsets.symmetric(
                                //                       vertical: 3),
                                //               child: Divider(
                                //                 color: theme.isDarkMode
                                //                     ? colors.darkColorDivider
                                //                     : colors.colorDivider,
                                //               ),
                                //             ),
                                //             ipoDateDisplay(
                                //                 theme,
                                //                 singlepage,
                                //                 "Refund initiation",
                                //                 getIPOTimelineValue(
                                //                     singlepage.iposinglepage!
                                //                             .scripdata[
                                //                         "IPO_Timeline"],
                                //                     3)),
                                //             Padding(
                                //               padding:
                                //                   const EdgeInsets.symmetric(
                                //                       vertical: 3),
                                //               child: Divider(
                                //                 color: theme.isDarkMode
                                //                     ? colors.darkColorDivider
                                //                     : colors.colorDivider,
                                //               ),
                                //             ),
                                //             ipoDateDisplay(
                                //                 theme,
                                //                 singlepage,
                                //                 "Share create on account",
                                //                 getIPOTimelineValue(
                                //                     singlepage.iposinglepage!
                                //                             .scripdata[
                                //                         "IPO_Timeline"],
                                //                     4)),
                                //             Padding(
                                //               padding:
                                //                   const EdgeInsets.symmetric(
                                //                       vertical: 3),
                                //               child: Divider(
                                //                 color: theme.isDarkMode
                                //                     ? colors.darkColorDivider
                                //                     : colors.colorDivider,
                                //               ),
                                //             ),
                                //             ipoDateDisplay(
                                //                 theme,
                                //                 singlepage,
                                //                 "Listing",
                                //                 getIPOTimelineValue(
                                //                     singlepage.iposinglepage!
                                //                             .scripdata[
                                //                         "IPO_Timeline"],
                                //                     5)),
                                //             // Padding(
                                //             //   padding:
                                //             //       const EdgeInsets.symmetric(
                                //             //           vertical: 3),
                                //             //   child: Divider(
                                //             //     color: theme.isDarkMode
                                //             //         ? colors.darkColorDivider
                                //             //         : colors.colorDivider,
                                //             //   ),
                                //             // ),
                                //           ],
                                //         ),
                                //       ),
                                //       // ipoDateDisplay(
                                //       //     theme,
                                //       //     singlepage,
                                //       //     "Cut-off time",
                                //       //     (singlepage
                                //       //             .iposinglepage
                                //       //             ?.scripdata["IPO_Timeline"]
                                //       //             .length)
                                //       //         .toString()),
                                //     ],
                                //   ),
                                // )
                                // // Padding(
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

                                // Padding(
                                //   padding:
                                //       const EdgeInsets.symmetric(vertical: 10),
                                //   child: Divider(
                                //     color: theme.isDarkMode
                                //         ? colors.darkColorDivider
                                //         : colors.colorDivider,
                                //   ),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 16,
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         "Financial Information",
                                //         style: textStyle(
                                //             !theme.isDarkMode
                                //                 ? colors.colorBlack
                                //                 : colors.colorWhite,
                                //             16,
                                //             FontWeight.w500),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(
                                //   height: 15,
                                // ),
                                // IPOFinancialChart(
                                //     theme: theme,
                                //     data: singlepage.iposinglepage!.scripdata[
                                //         "IPO_Financial_Information"]),
                                // Padding(
                                //   padding:
                                //       const EdgeInsets.symmetric(vertical: 10),
                                //   child: Divider(
                                //     color: theme.isDarkMode
                                //         ? colors.darkColorDivider
                                //         : colors.colorDivider,
                                //   ),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 16,
                                //   ),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       singlepage.iposinglepage!.scripdata[
                                //                   "IPO_Promoter_Holding"] ==
                                //               null
                                //           ? Container()
                                //           : Text(
                                //               "Promoter Holding",
                                //               style: textStyle(
                                //                   !theme.isDarkMode
                                //                       ? colors.colorBlack
                                //                       : colors.colorWhite,
                                //                   16,
                                //                   FontWeight.w500),
                                //             ),
                                //     ],
                                //   ),
                                // ),
                                // const SizedBox(
                                //   height: 15,
                                // ),
                                // singlepage.iposinglepage!.scripdata[
                                //             "IPO_Promoter_Holding"] ==
                                //         null
                                //     ? Container()
                                //     : ListView.builder(
                                //         itemCount: singlepage
                                //             .iposinglepage!
                                //             .scripdata["IPO_Promoter_Holding"]
                                //             .length,
                                //         physics:
                                //             const NeverScrollableScrollPhysics(),
                                //         shrinkWrap: true,
                                //         itemBuilder:
                                //             (BuildContext context, int index) {
                                //           return Padding(
                                //             padding: const EdgeInsets.symmetric(
                                //               horizontal: 16,
                                //             ),
                                //             child: Column(
                                //               children: [
                                //                 Row(
                                //                   mainAxisAlignment:
                                //                       MainAxisAlignment
                                //                           .spaceBetween,
                                //                   children: [
                                //                     Text(
                                //                       "${singlepage.iposinglepage!.scripdata["IPO_Promoter_Holding"][index]['name']}",
                                //                       style: textStyle(
                                //                           !theme.isDarkMode
                                //                               ? colors
                                //                                   .colorBlack
                                //                               : colors
                                //                                   .colorWhite,
                                //                           14,
                                //                           FontWeight.w400),
                                //                     ),
                                //                     Text(
                                //                       "${singlepage.iposinglepage!.scripdata["IPO_Promoter_Holding"][index]['value']}",
                                //                       style: textStyle(
                                //                           !theme.isDarkMode
                                //                               ? colors
                                //                                   .colorBlack
                                //                               : colors
                                //                                   .colorWhite,
                                //                           14,
                                //                           FontWeight.w400),
                                //                     ),
                                //                   ],
                                //                 ),
                                //                 Divider(
                                //                   color: theme.isDarkMode
                                //                       ? colors.darkColorDivider
                                //                       : colors.colorDivider,
                                //                 ),
                                //                 const SizedBox(
                                //                   height: 5,
                                //                 ),
                                //               ],
                                //             ),
                                //           );
                                //         },
                                //       ),
                                // singlepage.iposinglepage!.scripdata[
                                //             "IPO_Promoter_Holding"] ==
                                //         null
                                //     ? Container()
                                //     : Padding(
                                //         padding: const EdgeInsets.symmetric(
                                //             vertical: 10),
                                //         child: Divider(
                                //           color: theme.isDarkMode
                                //               ? colors.darkColorDivider
                                //               : colors.colorDivider,
                                //         ),
                                //       ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 16),
                                //   child: Column(
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text(
                                //         "About Company",
                                //         style: textStyle(
                                //             !theme.isDarkMode
                                //                 ? colors.colorBlack
                                //                 : colors.colorWhite,
                                //             16,
                                //             FontWeight.w500),
                                //       ),
                                //       Padding(
                                //         padding: const EdgeInsets.symmetric(
                                //             vertical: 15),
                                //         child: ReadMoreText(
                                //             "${singlepage.iposinglepage!.data['about']}",
                                //             style: textStyle(
                                //                 const Color(0xff666666),
                                //                 13,
                                //                 FontWeight.w500),
                                //             textAlign: TextAlign.left,
                                //             trimLines: 4,
                                //             moreStyle: theme.isDarkMode
                                //                 ? textStyles.darkmorestyle
                                //                 : textStyles.morestyle,
                                //             lessStyle: theme.isDarkMode
                                //                 ? textStyles.darkmorestyle
                                //                 : textStyles.morestyle,
                                //             colorClickableText:
                                //                 const Color(0xff0037B7),
                                //             trimMode: TrimMode.Line,
                                //             trimCollapsedText: 'Read more',
                                //             trimExpandedText: ' Read less'),
                                //       ),
                                //     ],
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          singlepage.iposinglepage!.data['status'] != "CLOSED"
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Container(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              50), // Set border radius for rounded corners
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (widget.ipodetails.isNotEmpty) {
                                          try {
                                            final Map<String, dynamic>
                                                decodedJson =
                                                jsonDecode(widget.ipodetails);

                                            dynamic
                                                ipoOrderbookData; // Declare as dynamic to hold either SMEIPO or ApplyIpoScreen

                                            if (decodedJson['subType'] ==
                                                "SME") {
                                              ipoOrderbookData =
                                                  SMEIPO.fromJson(decodedJson);
                                            } else {
                                              ipoOrderbookData =
                                                  MainIPO.fromJson(decodedJson);
                                            }

                                            // Fetch UPI ID View
                                            await upi.fetchupiIdView(
                                              upi.bankdetails!
                                                  .dATA![upi.indexss][1],
                                              upi.bankdetails!
                                                  .dATA![upi.indexss][2],
                                            );

                                            // Determine IPO category based on `subType`
                                            if (decodedJson['subType'] ==
                                                "SME") {
                                              await context
                                                  .read(ipoProvide)
                                                  .smeipocategory();
                                              Navigator.pushNamed(
                                                  context, Routes.smeapplyIPO,
                                                  arguments: ipoOrderbookData);
                                            } else {
                                              await context
                                                  .read(ipoProvide)
                                                  .mainipocategory();
                                              Navigator.pushNamed(
                                                  context, Routes.applyIPO,
                                                  arguments: ipoOrderbookData);
                                            }
                                          } catch (e) {
                                            print(
                                                "Error decoding JSON or processing IPO details: $e");
                                          }
                                        }
                                      },
                                      child: Text(
                                        "Apply Now!",
                                        style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite,
                                          14,
                                          FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ))
                              : const SizedBox(),
                        ]),
                  );
          },
        );
      },
    );
  }

  Column ipoDateDisplay(
      ThemesProvider theme, IPOProvider singlepage, String text, String value) {
    // Ensure the value is valid before parsing
    double maxValue = 100.0; // Maximum value (100%)
    double convertedValue = 0.0;

    try {
      convertedValue = double.parse(value); // Convert value to double
    } catch (e) {
      // In case of invalid value, set to 0
      convertedValue = 0.0;
    }

    double progress =
        (convertedValue / maxValue); // Normalize to 0-1 for progress bar

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                getInvestorCategory(text),
                style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w500,
                ),
              ),
            ),
            Text(
              "$value x", // Display the subscription count
              style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: progress, // Use the normalized value
            backgroundColor: Colors.grey[300],
            color: Color(0xFFFF148564),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  String getInvestorCategory(String category) {
    switch (category) {
      case "QIB":
        return "Qualified Institution";
      case "NII*":
        return "Non Institution";
      case "Retail":
        return "Retail";
      default:
        return category;
    }
  }

  String formatIPODate(String startDate, String endDate) {
    DateFormat inputFormat = DateFormat("MMM dd, yyyy");
    DateTime start = inputFormat.parse(startDate);
    DateTime end = inputFormat.parse(endDate);
    DateFormat outputFormat = DateFormat("dd MMM");
    return "${outputFormat.format(start)} - ${outputFormat.format(end)} ${end.year}";
  }

  String formatDate(String isoDate) {
    DateTime date = DateTime.parse(isoDate);
    DateFormat outputFormat = DateFormat("dd MMM yyyy");
    return outputFormat.format(date);
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch "${url}"';
    }
  }

  String? getIPOTimelineValue(List<dynamic>? timeline, int index) {
    if (timeline == null || index >= timeline.length) {
      return "--";
    }
    DateTime parsedDate =
        DateFormat("EEEE, MMMM d, y").parse(timeline[index]["value"]);
    String formattedDate = DateFormat("MMM d, y").format(parsedDate);
    return formattedDate as String?;
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

  bool isBeforeOrEqualToToday(String dateStr) {
    try {
      DateFormat format = DateFormat("MMM dd, yyyy");
      DateTime parsedDate = format.parseStrict(dateStr);
      DateTime today = DateTime.now();
      DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);
      DateTime parsedDateWithoutTime =
          DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
      print("::::::::::::::::: ${parsedDateWithoutTime}");
      print("::::::::::::::::: ${todayWithoutTime}");
      print(
          "::::::::::::::::: ${parsedDateWithoutTime.isAfter(todayWithoutTime)}");
      print(
          "::::::::::::::::: ${parsedDateWithoutTime.isAtSameMomentAs(todayWithoutTime)}");
      // print("::::::::::::::::: ${parsedDateWithoutTime}");
      return parsedDateWithoutTime.isAfter(todayWithoutTime) ||
          parsedDateWithoutTime.isAtSameMomentAs(todayWithoutTime);
    } catch (e) {
      return false;
    }
  }

  String getSubscriptionCount(var singlepage) {
    if (singlepage?.iposinglepage?.scripdata != null &&
        singlepage.iposinglepage!.scripdata
            .containsKey("IPO_Subscription_Status")) {
      var ipoSubscriptionStatus =
          singlepage.iposinglepage!.scripdata["IPO_Subscription_Status"];

      if (ipoSubscriptionStatus is List && ipoSubscriptionStatus.isNotEmpty) {
        var lastScrip = ipoSubscriptionStatus.last;

        if (lastScrip is Map && lastScrip.containsKey("Subscription (times)")) {
          return lastScrip["Subscription (times)"]?.toString() ?? "N/A";
        }
      }
    }
    return "N/A";
  }
}
