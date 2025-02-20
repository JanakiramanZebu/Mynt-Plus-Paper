// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
// import '../../sharedWidget/loader_ui.dart';
import '../mutual_fund_old/cancle_xsip_resone.dart';
// import '../mutual_fund_old/mf_order_filter_sheet.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';

class MfOrderBookScreen extends StatefulWidget {
  const MfOrderBookScreen({super.key});
  @override
  State<MfOrderBookScreen> createState() => _MfOrderBookScreen();
}

class _MfOrderBookScreen extends State<MfOrderBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController1;
  final tablistitems = [
    {
      "Aimgpath": "",
      "imgpath": assets.exportIcon,
      "title": "Portfolio",
      "index": 0,
    },
    {
      "Aimgpath": "",
      "imgpath": assets.bookmarkLineIcon,
      "title": "Orders",
      "index": 1,
    }
  ];
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);
      final mforderbook = watch(mfProvider);
      return Scaffold(
          appBar: AppBar(
            elevation: .2,
            centerTitle: false,
            leadingWidth: 41,
            titleSpacing: 6,
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: SvgPicture.asset(
                  assets.backArrow,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                ),
              ),
            ),
            backgroundColor:
                theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            shadowColor: const Color(0xffECEFF3),
            title: Text("MF Portfolio",
                style: textStyles.appBarTitleTxt.copyWith(
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack)),
            // actions: [
            //   Padding(
            //     padding: const EdgeInsets.only(right: 10),
            //     child: InkWell(
            //         onTap: () {
            //           showModalBottomSheet(
            //               useSafeArea: true,
            //               isScrollControlled: true,
            //               shape: const RoundedRectangleBorder(
            //                   borderRadius:
            //                       BorderRadius.vertical(top: Radius.circular(16))),
            //               context: context,
            //               builder: (context) {
            //                 return const MfOrderBookFilter();
            //               });
            //         },
            //         child: SvgPicture.asset(assets.filterlines)),
            //   )
            // ],
          ),
          body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // const CustomDragHandler(),
            Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.only(bottom: 0, left: 20, top: 2),
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0.4),
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0.4))),
                // height: 60,
                child: TabBar(
                    labelPadding: const EdgeInsets.only(right: 16, bottom: 0),
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Colors.transparent,
                    controller: _tabController1,
                    isScrollable: true,
                    tabs: List.generate(
                        tablistitems.length,
                        (tab) => tabConstruce(
                            tablistitems[tab]['imgpath'].toString(),
                            tablistitems[tab]['title'].toString(),
                            theme,
                            tab,
                            () {})))),
            Expanded(
                child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _tabController1,
                    children: [
                  const MFHoldingScreen(),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        mforderbook.mfOrderbookfilter == "All"
                            ? mforderbook.mflumpsumorderbook!.allMFLumpSumOrderbook == [] ||
                                    mforderbook.mflumpsumorderbook!
                                        .allMFLumpSumOrderbook.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 280),
                                    child: Center(child: NoDataFound()),
                                  )
                                : ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (mforderbook
                                                  .mflumpsumorderbook!
                                                  .allMFLumpSumOrderbook[index]
                                                  .transactionType ==
                                              "X-SIP") {
                                            mforderbook.fetchXsipcancelResone();
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 500), () {
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return XsipAlertCancelResoneAlert(
                                                        mfdata: mforderbook
                                                            .mflumpsumorderbook!
                                                            .allMFLumpSumOrderbook[index]);
                                                  });
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child:Text(
  "${mforderbook.mflumpsumorderbook!.allMFLumpSumOrderbook[index].schemeName}",
  maxLines: 2,
  style: textStyles.scripNameTxtStyle.copyWith(
    color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
    height: 1.5, 
  ),
),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      SvgPicture.asset(
                                                        mforderbook
                                                                    .mflumpsumorderbook!
                                                                    .allMFLumpSumOrderbook[
                                                                        index]
                                                                    .transactionTypeOrderStatus ==
                                                                "Success"
                                                            ? assets
                                                                .completedIcon
                                                            : assets
                                                                .warningIcon,
                                                        width: 20,
                                                      ),
                                                      Text(
                                                        mforderbook
                                                            .mflumpsumorderbook!
                                                            .allMFLumpSumOrderbook[
                                                                index]
                                                            .transactionTypeOrderStatus,
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            13,
                                                            FontWeight.w600),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              Row(
                                                children: [
                                                  CustomExchBadge(
                                                    exch:
                                                        "${mforderbook.mflumpsumorderbook!.allMFLumpSumOrderbook[index].date}",
                                                  ),
                                                  const SizedBox(width: 6),

                                                  CustomExchBadge(
                                                    exch:
                                                        "Order no:${mforderbook.mflumpsumorderbook!.allMFLumpSumOrderbook[index].orderNumber}",
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                            Divider(
                                            color: theme.isDarkMode
                                                ? colors.darkColorDivider
                                                : colors.colorDivider),
                                        const SizedBox(height: 3),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '${mforderbook.mflumpsumorderbook!.allMFLumpSumOrderbook[index].transactionType}',
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            14,
                                                            FontWeight.w500),
                                                      ),
                                                      const SizedBox(height:3),
                                                      Text(
                                                        'Transaction',
                                                        style: textStyle(
                                                            colors.colorGrey,
                                                            13,
                                                            FontWeight.w500),
                                                      ),
                                                      
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                     
                                                      Text(
                                                        '00.0',
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            14,
                                                            FontWeight.w500),
                                                      ),
                                                      const SizedBox(height: 4),
                                                       Text(
                                                        'Units',
                                                        style: textStyle(
                                                            colors.colorGrey,
                                                            13,
                                                            FontWeight.w500),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      
                                                      Text(
                                                        mforderbook
                                                                        .mflumpsumorderbook!
                                                                        .allMFLumpSumOrderbook[
                                                                            index]
                                                                        .amount ==
                                                                    "" ||
                                                                double.tryParse(mforderbook
                                                                        .mflumpsumorderbook!
                                                                        .allMFLumpSumOrderbook[
                                                                            index]
                                                                        .amount
                                                                        .toString()) ==
                                                                    null
                                                            ? '0.00'
                                                            : mforderbook
                                                                .mflumpsumorderbook!
                                                                .allMFLumpSumOrderbook[
                                                                    index]
                                                                .amount
                                                                .toString(),
                                                        style: textStyle(
                                                            theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            14,
                                                            FontWeight.w500),
                                                      ),
const SizedBox(height: 4),
                                                      Text(
                                                        'Invest amt',
                                                        style: textStyle(
                                                            colors.colorGrey,
                                                            13,
                                                            FontWeight.w500),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: 8),
                                            Divider(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : const Color(0xffECEDEE),
                            thickness: 5.0, // Increase the thickness here
                          ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                          color: theme.isDarkMode
                                              ? colors.darkGrey
                                              : const Color(0xffF1F3F8),
                                          height: 6);
                                    },
                                    itemCount: mforderbook.mflumpsumorderbook!
                                        .allMFLumpSumOrderbook.length)
                            : mforderbook.mfOrderbookfilter == "Lumpsum"
                                ? mforderbook.mflumpsumorderbook!.pusrchaseNotListed! == [] ||
                                        mforderbook.mflumpsumorderbook!
                                            .pusrchaseNotListed!.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.only(top: 280),
                                        child: Center(child: NoDataFound()),
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                          "${mforderbook.mflumpsumorderbook!.pusrchaseNotListed![index].schemeName}",
                                                          //overflow: TextOverflow.ellipsis,
                                                          maxLines: 2,
                                                          style: textStyles
                                                              .scripNameTxtStyle
                                                              .copyWith(
                                                                  color: theme.isDarkMode
                                                                      ? colors
                                                                          .colorWhite
                                                                      : colors
                                                                          .colorBlack)),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        SvgPicture.asset(
                                                          mforderbook
                                                                      .mflumpsumorderbook!
                                                                      .pusrchaseNotListed![
                                                                          index]
                                                                      .mfStatus ==
                                                                  "0"
                                                              ? assets
                                                                  .completedIcon
                                                              : assets
                                                                  .cancelledIcon,
                                                          width: 20,
                                                        ),
                                                        Text(
                                                          mforderbook
                                                                      .mflumpsumorderbook!
                                                                      .pusrchaseNotListed![
                                                                          index]
                                                                      .mfStatus ==
                                                                  "0"
                                                              ? "Success"
                                                              : "Failed ",
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              12,
                                                              FontWeight.w500),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    CustomExchBadge(
                                                      exch:
                                                          "${mforderbook.mflumpsumorderbook!.pusrchaseNotListed![index].date}",
                                                    ),
                                                    CustomExchBadge(
                                                      exch:
                                                          "Order no:${mforderbook.mflumpsumorderbook!.pusrchaseNotListed![index].orderNumber}",
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Transaction',
                                                          style: textStyle(
                                                              colors.colorGrey,
                                                              11,
                                                              FontWeight.w500),
                                                        ),
                                                        Text(
                                                          '${mforderbook.mflumpsumorderbook!.pusrchaseNotListed![index].transactionType}',
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              13,
                                                              FontWeight.w500),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          'Units',
                                                          style: textStyle(
                                                              colors.colorGrey,
                                                              11,
                                                              FontWeight.w500),
                                                        ),
                                                        Text(
                                                          '00.0',
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              13,
                                                              FontWeight.w500),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          'Invest amt',
                                                          style: textStyle(
                                                              colors.colorGrey,
                                                              11,
                                                              FontWeight.w500),
                                                        ),
                                                        Text(
                                                          mforderbook
                                                                          .mflumpsumorderbook!
                                                                          .pusrchaseNotListed![
                                                                              index]
                                                                          .amount ==
                                                                      "" ||
                                                                  double.tryParse(mforderbook
                                                                          .mflumpsumorderbook!
                                                                          .pusrchaseNotListed![
                                                                              index]
                                                                          .amount
                                                                          .toString()) ==
                                                                      null
                                                              ? '0.00'
                                                              : mforderbook
                                                                  .mflumpsumorderbook!
                                                                  .pusrchaseNotListed![
                                                                      index]
                                                                  .amount
                                                                  .toString(),
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack,
                                                              13,
                                                              FontWeight.w500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return Container(
                                              color: theme.isDarkMode
                                                  ? colors.darkGrey
                                                  : const Color(0xffF1F3F8),
                                              height: 6);
                                        },
                                        itemCount: mforderbook
                                            .mflumpsumorderbook!
                                            .pusrchaseNotListed!
                                            .length)
                                : mforderbook.mfOrderbookfilter == "X-SIP"
                                    ? mforderbook.mflumpsumorderbook!
                                                    .xsipPurchaseNotListed! ==
                                                [] ||
                                            mforderbook.mflumpsumorderbook!
                                                .xsipPurchaseNotListed!.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.only(top: 280),
                                            child: Center(child: NoDataFound()),
                                          )
                                        : ListView.separated(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () {
                                                  mforderbook
                                                      .fetchXsipcancelResone();
                                                  Future.delayed(
                                                      const Duration(
                                                          milliseconds: 500),
                                                      () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return XsipAlertCancelResoneAlert(
                                                              mfdata: mforderbook
                                                                  .mflumpsumorderbook!
                                                                  .xsipPurchaseNotListed![index]);
                                                        });
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                                "${mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index].schemeName}",
                                                                //overflow: TextOverflow.ellipsis,
                                                                maxLines: 2,
                                                                style: textStyles
                                                                    .scripNameTxtStyle
                                                                    .copyWith(
                                                                        color: theme.isDarkMode
                                                                            ? colors.colorWhite
                                                                            : colors.colorBlack)),
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              SvgPicture.asset(
                                                                mforderbook
                                                                            .mflumpsumorderbook!
                                                                            .xsipPurchaseNotListed![
                                                                                index]
                                                                            .orderStatus ==
                                                                        "NEW"
                                                                    ? assets
                                                                        .completedIcon
                                                                    : assets
                                                                        .cancelledIcon,
                                                                width: 20,
                                                              ),
                                                              Text(
                                                                mforderbook
                                                                            .mflumpsumorderbook!
                                                                            .xsipPurchaseNotListed![index]
                                                                            .orderStatus ==
                                                                        "NEW"
                                                                    ? "Success"
                                                                    : "Failed ",
                                                                style: textStyle(
                                                                    theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack,
                                                                    12,
                                                                    FontWeight
                                                                        .w500),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          CustomExchBadge(
                                                            exch:
                                                                "${mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index].date}",
                                                          ),
                                                          CustomExchBadge(
                                                            exch:
                                                                "Order no:${mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index].orderNumber}",
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Transaction',
                                                                style: textStyle(
                                                                    colors
                                                                        .colorGrey,
                                                                    11,
                                                                    FontWeight
                                                                        .w500),
                                                              ),
                                                              Text(
                                                                '${mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index].transactionType}',
                                                                style: textStyle(
                                                                    theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack,
                                                                    13,
                                                                    FontWeight
                                                                        .w500),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              Text(
                                                                'Units',
                                                                style: textStyle(
                                                                    colors
                                                                        .colorGrey,
                                                                    11,
                                                                    FontWeight
                                                                        .w500),
                                                              ),
                                                              Text(
                                                                '00.0',
                                                                style: textStyle(
                                                                    theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack,
                                                                    13,
                                                                    FontWeight
                                                                        .w500),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Text(
                                                                'Invest amt',
                                                                style: textStyle(
                                                                    colors
                                                                        .colorGrey,
                                                                    11,
                                                                    FontWeight
                                                                        .w500),
                                                              ),
                                                              Text(
                                                                mforderbook
                                                                            .mflumpsumorderbook!
                                                                            .xsipPurchaseNotListed![index]
                                                                            .amount ==
                                                                        ""
                                                                    ? '0.00'
                                                                    : '0.00',
                                                                style: textStyle(
                                                                    theme.isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack,
                                                                    13,
                                                                    FontWeight
                                                                        .w500),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            separatorBuilder: (BuildContext context, int index) {
                                              return Container(
                                                  color: theme.isDarkMode
                                                      ? colors.darkGrey
                                                      : const Color(0xffF1F3F8),
                                                  height: 6);
                                            },
                                            itemCount: mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed!.length)
                                    : mforderbook.mfOrderbookfilter == "Redeem"
                                        ? mforderbook.mflumpsumorderbook!.redeemptionNotListed! == [] || mforderbook.mflumpsumorderbook!.redeemptionNotListed!.isEmpty
                                            ? const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 280),
                                                child: Center(
                                                    child: NoDataFound()),
                                              )
                                            : ListView.separated(
                                                shrinkWrap: true,
                                                physics: NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                  "${mforderbook.mflumpsumorderbook!.redeemptionNotListed![index].schemeName}",
                                                                  //overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                  style: textStyles
                                                                      .scripNameTxtStyle
                                                                      .copyWith(
                                                                          color: theme.isDarkMode
                                                                              ? colors.colorWhite
                                                                              : colors.colorBlack)),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  mforderbook
                                                                              .mflumpsumorderbook!
                                                                              .redeemptionNotListed![
                                                                                  index]
                                                                              .mfStatus ==
                                                                          "NEW"
                                                                      ? assets
                                                                          .completedIcon
                                                                      : assets
                                                                          .cancelledIcon,
                                                                  width: 20,
                                                                ),
                                                                Text(
                                                                  mforderbook
                                                                              .mflumpsumorderbook!
                                                                              .redeemptionNotListed![index]
                                                                              .mfStatus ==
                                                                          "NEW"
                                                                      ? "Success"
                                                                      : "Failed ",
                                                                  style: textStyle(
                                                                      theme.isDarkMode
                                                                          ? colors
                                                                              .colorWhite
                                                                          : colors
                                                                              .colorBlack,
                                                                      12,
                                                                      FontWeight
                                                                          .w500),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          children: [
                                                            CustomExchBadge(
                                                              exch:
                                                                  "${mforderbook.mflumpsumorderbook!.redeemptionNotListed![index].date}",
                                                            ),
                                                            CustomExchBadge(
                                                              exch:
                                                                  "Order no:${mforderbook.mflumpsumorderbook!.redeemptionNotListed![index].orderNumber}",
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Transaction',
                                                                  style: textStyle(
                                                                      colors
                                                                          .colorGrey,
                                                                      11,
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                                Text(
                                                                  'Redeem',
                                                                  style: textStyle(
                                                                      theme.isDarkMode
                                                                          ? colors
                                                                              .colorWhite
                                                                          : colors
                                                                              .colorBlack,
                                                                      13,
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  'Units',
                                                                  style: textStyle(
                                                                      colors
                                                                          .colorGrey,
                                                                      11,
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                                Text(
                                                                  '00.0',
                                                                  style: textStyle(
                                                                      theme.isDarkMode
                                                                          ? colors
                                                                              .colorWhite
                                                                          : colors
                                                                              .colorBlack,
                                                                      13,
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  'Invest amt',
                                                                  style: textStyle(
                                                                      colors
                                                                          .colorGrey,
                                                                      11,
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                                Text(
                                                                  mforderbook
                                                                              .mflumpsumorderbook!
                                                                              .redeemptionNotListed![index]
                                                                              .amount ==
                                                                          ""
                                                                      ? '0.00'
                                                                      : '0.00',
                                                                  style: textStyle(
                                                                      theme.isDarkMode
                                                                          ? colors
                                                                              .colorWhite
                                                                          : colors
                                                                              .colorBlack,
                                                                      13,
                                                                      FontWeight
                                                                          .w500),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                separatorBuilder: (BuildContext context, int index) {
                                                  return Container(
                                                      color: theme.isDarkMode
                                                          ? colors.darkGrey
                                                          : const Color(
                                                              0xffF1F3F8),
                                                      height: 6);
                                                },
                                                itemCount: mforderbook.mflumpsumorderbook!.redeemptionNotListed!.length)
                                        : const Padding(
                                            padding: EdgeInsets.only(top: 300),
                                            child: Center(child: NoDataFound()),
                                          )
                      ],
                    ),
                  ),
                ]))
          ]));
    });
  }

  Widget tabConstruce(String icon, String title, ThemesProvider theme, int tab,
      VoidCallback onPressed) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            activeTab = tab;
          });
          _tabController1.animateTo(tab);
          print("object act tab $tab");
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            backgroundColor: theme.isDarkMode
                ? tab == activeTab
                    ? colors.colorbluegrey
                    : const Color(0xffB5C0CF).withOpacity(.15)
                : tab == activeTab
                    ? const Color(0xff000000)
                    : const Color(0xffF1F3F8),
            shape: const StadiumBorder()),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                color: theme.isDarkMode
                    ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
                    : Color(tab == activeTab ? 0xffffffff : 0xff000000),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: textStyle(
                      theme.isDarkMode
                          ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
                          : Color(tab == activeTab ? 0xffffffff : 0xff000000),
                      14,
                      FontWeight.w500))
            ]));
  }
}


// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mynt_plus/sharedWidget/functions.dart';
// import 'package:mynt_plus/sharedWidget/no_data_found.dart';

// import '../../provider/mf_provider.dart';
// import '../../provider/thems.dart';
// import '../../res/res.dart';
// import '../../sharedWidget/custom_exch_badge.dart';
// import 'cancle_xsip_resone.dart';
// import 'mf_order_filter_sheet.dart';

// class MfOrderBookScreen extends ConsumerWidget {
//   const MfOrderBookScreen({super.key});

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final theme = watch(themeProvider);
//     final mforderbook = watch(mfProvider);
//     return Scaffold(
//       appBar: AppBar(
//         elevation: .2,
//         centerTitle: false,
//         leadingWidth: 41,
//         titleSpacing: 6,
//         leading: InkWell(
//           onTap: () {
//             Navigator.pop(context);
//           },
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 9),
//             child: SvgPicture.asset(
//               assets.backArrow,
//               color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
//             ),
//           ),
//         ),
//         backgroundColor:
//             theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
//         shadowColor: const Color(0xffECEFF3),
//         title: Text("MF Orderbook",
//             style: textStyles.appBarTitleTxt.copyWith(
//                 color:
//                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 10),
//             child: InkWell(
//                 onTap: () {
//                   showModalBottomSheet(
//                       useSafeArea: true,
//                       isScrollControlled: true,
//                       shape: const RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.vertical(top: Radius.circular(16))),
//                       context: context,
//                       builder: (context) {
//                         return const MfOrderBookFilter();
//                       });
//                 },
//                 child: SvgPicture.asset(assets.filterlines)),
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             mforderbook.mfOrderbookfilter == "Lumpsum"
//                 ? mforderbook.mflumpsumorderbook!.pusrchaseNotListed! == [] ||
//                         mforderbook
//                             .mflumpsumorderbook!.pusrchaseNotListed!.isEmpty
//                     ? const Padding(
//                         padding: EdgeInsets.only(top: 280),
//                         child: Center(child: NoDataFound()),
//                       )
//                     : ListView.separated(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemBuilder: (context, index) {
//                           return Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                           "${mforderbook.mflumpsumorderbook!.pusrchaseNotListed![index].schemeName}",
//                                           //overflow: TextOverflow.ellipsis,
//                                           maxLines: 2,
//                                           style: textStyles.scripNameTxtStyle
//                                               .copyWith(
//                                                   color: theme.isDarkMode
//                                                       ? colors.colorWhite
//                                                       : colors.colorBlack)),
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         SvgPicture.asset(
//                                           mforderbook
//                                                       .mflumpsumorderbook!
//                                                       .pusrchaseNotListed![
//                                                           index]
//                                                       .mfStatus ==
//                                                   "0"
//                                               ? assets.completedIcon
//                                               : assets.cancelledIcon,
//                                           width: 20,
//                                         ),
//                                         Text(
//                                           mforderbook
//                                                       .mflumpsumorderbook!
//                                                       .pusrchaseNotListed![
//                                                           index]
//                                                       .mfStatus ==
//                                                   "0"
//                                               ? "Success"
//                                               : "Failed ",
//                                           style: textStyle(
//                                               theme.isDarkMode
//                                                   ? colors.colorWhite
//                                                   : colors.colorBlack,
//                                               12,
//                                               FontWeight.w500),
//                                         )
//                                       ],
//                                     )
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,
//                                 ),
//                                 Row(
//                                   children: [
//                                     CustomExchBadge(
//                                       exch:
//                                           "${mforderbook.mflumpsumorderbook!.pusrchaseNotListed![index].date}",
//                                     ),
//                                     CustomExchBadge(
//                                       exch:
//                                           "Order no:${mforderbook.mflumpsumorderbook!.pusrchaseNotListed![index].orderNumber}",
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 15,
//                                 ),
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Text(
//                                           'Transaction',
//                                           style: textStyle(colors.colorGrey, 11,
//                                               FontWeight.w500),
//                                         ),
//                                         Text(
//                                           'Lumpsum',
//                                           style: textStyle(
//                                               theme.isDarkMode
//                                                   ? colors.colorWhite
//                                                   : colors.colorBlack,
//                                               13,
//                                               FontWeight.w500),
//                                         ),
//                                       ],
//                                     ),
//                                     Column(
//                                       children: [
//                                         Text(
//                                           'Units',
//                                           style: textStyle(colors.colorGrey, 11,
//                                               FontWeight.w500),
//                                         ),
//                                         Text(
//                                           '00.0',
//                                           style: textStyle(
//                                               theme.isDarkMode
//                                                   ? colors.colorWhite
//                                                   : colors.colorBlack,
//                                               13,
//                                               FontWeight.w500),
//                                         ),
//                                       ],
//                                     ),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                           'Invest amt',
//                                           style: textStyle(colors.colorGrey, 11,
//                                               FontWeight.w500),
//                                         ),
//                                         Text(
//                                           mforderbook
//                                                       .mflumpsumorderbook!
//                                                       .pusrchaseNotListed![
//                                                           index]
//                                                       .amount ==
//                                                   ""
//                                               ? ''
//                                               : double.parse(mforderbook
//                                                       .mflumpsumorderbook!
//                                                       .pusrchaseNotListed![
//                                                           index]
//                                                       .amount
//                                                       .toString())
//                                                   .toStringAsFixed(2),
//                                           style: textStyle(
//                                               theme.isDarkMode
//                                                   ? colors.colorWhite
//                                                   : colors.colorBlack,
//                                               13,
//                                               FontWeight.w500),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         separatorBuilder: (BuildContext context, int index) {
//                           return Container(
//                               color: theme.isDarkMode
//                                   ? colors.darkGrey
//                                   : const Color(0xffF1F3F8),
//                               height: 6);
//                         },
//                         itemCount: mforderbook
//                             .mflumpsumorderbook!.pusrchaseNotListed!.length)
//                 : mforderbook.mfOrderbookfilter == "X-SIP"
//                     ? mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed! ==
//                                 [] ||
//                             mforderbook.mflumpsumorderbook!
//                                 .xsipPurchaseNotListed!.isEmpty
//                         ? const Padding(
//                             padding: EdgeInsets.only(top: 280),
//                             child: Center(child: NoDataFound()),
//                           )
//                         : ListView.separated(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             itemBuilder: (context, index) {
//                               return InkWell(
//                                 onTap: () {
//                                   mforderbook.fetchXsipcancelResone();
//                                   Future.delayed(const Duration(milliseconds: 500),
//                                       () {
//                                     showDialog(
//                                         context: context,
//                                         builder: (BuildContext context) {
//                                           return  XsipAlertCancelResoneAlert(mfdata:mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index]);
//                                         });
//                                   });
//                                 },
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 12),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                                 "${mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index].schemeName}",
//                                                 //overflow: TextOverflow.ellipsis,
//                                                 maxLines: 2,
//                                                 style: textStyles
//                                                     .scripNameTxtStyle
//                                                     .copyWith(
//                                                         color: theme.isDarkMode
//                                                             ? colors.colorWhite
//                                                             : colors
//                                                                 .colorBlack)),
//                                           ),
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.end,
//                                             children: [
//                                               SvgPicture.asset(
//                                                 mforderbook
//                                                             .mflumpsumorderbook!
//                                                             .xsipPurchaseNotListed![
//                                                                 index]
//                                                             .orderStatus ==
//                                                         "NEW"
//                                                     ? assets.completedIcon
//                                                     : assets.cancelledIcon,
//                                                 width: 20,
//                                               ),
//                                               Text(
//                                                 mforderbook
//                                                             .mflumpsumorderbook!
//                                                             .xsipPurchaseNotListed![
//                                                                 index]
//                                                             .orderStatus ==
//                                                         "NEW"
//                                                     ? "Success"
//                                                     : "Failed ",
//                                                 style: textStyle(
//                                                     theme.isDarkMode
//                                                         ? colors.colorWhite
//                                                         : colors.colorBlack,
//                                                     12,
//                                                     FontWeight.w500),
//                                               )
//                                             ],
//                                           )
//                                         ],
//                                       ),
//                                       const SizedBox(
//                                         height: 5,
//                                       ),
//                                       Row(
//                                         children: [
//                                           CustomExchBadge(
//                                             exch:
//                                                 "${mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index].date}",
//                                           ),
//                                           CustomExchBadge(
//                                             exch:
//                                                 "Order no:${mforderbook.mflumpsumorderbook!.xsipPurchaseNotListed![index].orderNumber}",
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(
//                                         height: 15,
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'Transaction',
//                                                 style: textStyle(
//                                                     colors.colorGrey,
//                                                     11,
//                                                     FontWeight.w500),
//                                               ),
//                                               Text(
//                                                 'X-SIP',
//                                                 style: textStyle(
//                                                     theme.isDarkMode
//                                                         ? colors.colorWhite
//                                                         : colors.colorBlack,
//                                                     13,
//                                                     FontWeight.w500),
//                                               ),
//                                             ],
//                                           ),
//                                           Column(
//                                             children: [
//                                               Text(
//                                                 'Units',
//                                                 style: textStyle(
//                                                     colors.colorGrey,
//                                                     11,
//                                                     FontWeight.w500),
//                                               ),
//                                               Text(
//                                                 '00.0',
//                                                 style: textStyle(
//                                                     theme.isDarkMode
//                                                         ? colors.colorWhite
//                                                         : colors.colorBlack,
//                                                     13,
//                                                     FontWeight.w500),
//                                               ),
//                                             ],
//                                           ),
//                                           Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.end,
//                                             children: [
//                                               Text(
//                                                 'Invest amt',
//                                                 style: textStyle(
//                                                     colors.colorGrey,
//                                                     11,
//                                                     FontWeight.w500),
//                                               ),
//                                               Text(
//                                                 mforderbook
//                                                             .mflumpsumorderbook!
//                                                             .xsipPurchaseNotListed![
//                                                                 index]
//                                                             .amount ==
//                                                         ""
//                                                     ? '0.00'
//                                                     : '0.00',
//                                                 style: textStyle(
//                                                     theme.isDarkMode
//                                                         ? colors.colorWhite
//                                                         : colors.colorBlack,
//                                                     13,
//                                                     FontWeight.w500),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                             separatorBuilder:
//                                 (BuildContext context, int index) {
//                               return Container(
//                                   color: theme.isDarkMode
//                                       ? colors.darkGrey
//                                       : const Color(0xffF1F3F8),
//                                   height: 6);
//                             },
//                             itemCount: mforderbook.mflumpsumorderbook!
//                                 .xsipPurchaseNotListed!.length)
//                     : mforderbook.mfOrderbookfilter == "Redeem"
//                         ? mforderbook.mflumpsumorderbook!
//                                         .redeemptionNotListed! ==
//                                     [] ||
//                                 mforderbook.mflumpsumorderbook!
//                                     .redeemptionNotListed!.isEmpty
//                             ? const Padding(
//                                 padding: EdgeInsets.only(top: 280),
//                                 child: Center(child: NoDataFound()),
//                               )
//                             : ListView.separated(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   return Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 16, vertical: 12),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Expanded(
//                                               child: Text(
//                                                   "${mforderbook.mflumpsumorderbook!.redeemptionNotListed![index].schemeName}",
//                                                   //overflow: TextOverflow.ellipsis,
//                                                   maxLines: 2,
//                                                   style: textStyles
//                                                       .scripNameTxtStyle
//                                                       .copyWith(
//                                                           color: theme.isDarkMode
//                                                               ? colors
//                                                                   .colorWhite
//                                                               : colors
//                                                                   .colorBlack)),
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 SvgPicture.asset(
//                                                   mforderbook
//                                                               .mflumpsumorderbook!
//                                                               .redeemptionNotListed![
//                                                                   index]
//                                                               .mfStatus ==
//                                                           "NEW"
//                                                       ? assets.completedIcon
//                                                       : assets.cancelledIcon,
//                                                   width: 20,
//                                                 ),
//                                                 Text(
//                                                   mforderbook
//                                                               .mflumpsumorderbook!
//                                                               .redeemptionNotListed![
//                                                                   index]
//                                                               .mfStatus ==
//                                                           "NEW"
//                                                       ? "Success"
//                                                       : "Failed ",
//                                                   style: textStyle(
//                                                       theme.isDarkMode
//                                                           ? colors.colorWhite
//                                                           : colors.colorBlack,
//                                                       12,
//                                                       FontWeight.w500),
//                                                 )
//                                               ],
//                                             )
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           height: 5,
//                                         ),
//                                         Row(
//                                           children: [
//                                             CustomExchBadge(
//                                               exch:
//                                                   "${mforderbook.mflumpsumorderbook!.redeemptionNotListed![index].date}",
//                                             ),
//                                             CustomExchBadge(
//                                               exch:
//                                                   "Order no:${mforderbook.mflumpsumorderbook!.redeemptionNotListed![index].orderNumber}",
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           height: 15,
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   'Transaction',
//                                                   style: textStyle(
//                                                       colors.colorGrey,
//                                                       11,
//                                                       FontWeight.w500),
//                                                 ),
//                                                 Text(
//                                                   'Redeem',
//                                                   style: textStyle(
//                                                       theme.isDarkMode
//                                                           ? colors.colorWhite
//                                                           : colors.colorBlack,
//                                                       13,
//                                                       FontWeight.w500),
//                                                 ),
//                                               ],
//                                             ),
//                                             Column(
//                                               children: [
//                                                 Text(
//                                                   'Units',
//                                                   style: textStyle(
//                                                       colors.colorGrey,
//                                                       11,
//                                                       FontWeight.w500),
//                                                 ),
//                                                 Text(
//                                                   '00.0',
//                                                   style: textStyle(
//                                                       theme.isDarkMode
//                                                           ? colors.colorWhite
//                                                           : colors.colorBlack,
//                                                       13,
//                                                       FontWeight.w500),
//                                                 ),
//                                               ],
//                                             ),
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.end,
//                                               children: [
//                                                 Text(
//                                                   'Invest amt',
//                                                   style: textStyle(
//                                                       colors.colorGrey,
//                                                       11,
//                                                       FontWeight.w500),
//                                                 ),
//                                                 Text(
//                                                   mforderbook
//                                                               .mflumpsumorderbook!
//                                                               .redeemptionNotListed![
//                                                                   index]
//                                                               .amount ==
//                                                           ""
//                                                       ? '0.00'
//                                                       : '0.00',
//                                                   style: textStyle(
//                                                       theme.isDarkMode
//                                                           ? colors.colorWhite
//                                                           : colors.colorBlack,
//                                                       13,
//                                                       FontWeight.w500),
//                                                 ),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                                 separatorBuilder:
//                                     (BuildContext context, int index) {
//                                   return Container(
//                                       color: theme.isDarkMode
//                                           ? colors.darkGrey
//                                           : const Color(0xffF1F3F8),
//                                       height: 6);
//                                 },
//                                 itemCount: mforderbook.mflumpsumorderbook!
//                                     .redeemptionNotListed!.length)
//                         : const Padding(
//                             padding: EdgeInsets.only(top: 300),
//                             child: Center(child: NoDataFound()),
//                           )
//           ],
//         ),
//       ),
//     );
//   }
// }
