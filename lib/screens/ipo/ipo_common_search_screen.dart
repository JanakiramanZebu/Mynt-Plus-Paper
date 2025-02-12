import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/models/marketwatch_model/get_quotes.dart';
import 'package:mynt_plus/provider/iop_provider.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/screens/ipo/main_sme_list/single_page.dart';
import 'package:mynt_plus/screens/market_watch/scrip_depth_info.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';

class IpoCommonSearch extends ConsumerWidget {
  const IpoCommonSearch({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final ipo = watch(ipoProvide);
    final theme = watch(themeProvider);
    final market = watch(marketWatchProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: .2,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: InkWell(
              onTap: () {
                ipo.clearCommonIpoSearch();
                Navigator.pop(context);
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(assets.backArrow,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack))),
          shadowColor: const Color(0xffECEFF3),
          title: Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextFormField(
                autofocus: true,
                controller: ipo.ipocommonsearchcontroller,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600),
                decoration: InputDecoration(
                    fillColor: theme.isDarkMode
                        ? colors.darkGrey
                        : const Color(0xffF1F3F8),
                    filled: true,
                    hintStyle:
                        textStyle(const Color(0xff69758F), 15, FontWeight.w500),
                    prefixIconColor: const Color(0xff586279),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SvgPicture.asset(assets.searchIcon,
                          color: const Color(0xff586279),
                          fit: BoxFit.contain,
                          width: 20),
                    ),
                    suffixIcon: InkWell(
                      onTap: () async {
                        ipo.clearCommonIpoSearch();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SvgPicture.asset(assets.removeIcon,
                            fit: BoxFit.scaleDown, width: 20),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    disabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    hintText: "Search IPOs",
                    contentPadding: const EdgeInsets.only(top: 20),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20))),
                onChanged: (value) async {
                  ipo.searchCommonIpo(value, context);
                },
              )),

          // Text("IPO Search",
          //     style: textStyles.appBarTitleTxt.copyWith(
          //         color: theme.isDarkMode
          //             ? colors.colorWhite
          //             : colors.colorBlack))
        ),
        body: SingleChildScrollView(
          child: ipo.ipoCommonSearchList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ipo.ipoCommonSearchList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final checkIpoStatus =
                        ipo.ipoCommonSearchList[index].ipostatus;
                    DepthInputArgs depthArgs = DepthInputArgs(
                        exch: "",
                        token: "",
                        tsym: '',
                        instname: "",
                        symbol: '',
                        expDate: '',
                        option: '');

                    return InkWell(
                        onTap: () async {
                          String pricerange = "";
                          String mininvVal = "";
                          String enddate = "";
                          String startdate = "";
                          String ipotype = "";

                          if (checkIpoStatus == "Listed") {
                            await market.fetchFundamentalData(
                                tradeSym:
                                    "${ipo.ipoCommonSearchList[index].symbol}");

                            await market.fetchScripQuote(
                                "${ipo.ipoCommonSearchList[index].token}",
                                "${ipo.ipoCommonSearchList[index].exchange}",
                                context);

                            await market.fetchTechData(
                                context: context,
                                exch: "${market.getQuotes!.exch}",
                                tradeSym: "${market.getQuotes!.tsym}",
                                lastPrc:
                                    "${market.getQuotes!.lp ?? market.getQuotes!.c ?? 0.00}");

                            market.chngDephBtn("Overview");

                            if (market.actDeptBtn == "Overview") {
                              await watch(websocketProvider).establishConnection(
                                  channelInput:
                                      "${market.getQuotes!.exch}|${market.getQuotes!.token}",
                                  task: "d",
                                  context: context);
                            }
                            depthArgs = DepthInputArgs(
                                exch: market.getQuotes!.exch ?? "",
                                token: market.getQuotes!.token ?? "",
                                tsym: '${market.getQuotes!.tsym}',
                                instname: market.getQuotes!.instname ?? "",
                                symbol: '${market.getQuotes!.symbol}',
                                expDate: '${market.getQuotes!.expDate}',
                                option: '${market.getQuotes!.option}');
                          } else if (checkIpoStatus == "Live") {
                            await ipo.getIpoSinglePage(
                                ipoName:
                                    "${ipo.ipoCommonSearchList[index].name}");
                            pricerange =
                                "₹${double.parse(ipo.ipoCommonSearchList[index].minPrice!).toInt()} - ₹${double.parse(ipo.ipoCommonSearchList[index].maxPrice!).toInt()}";
                            mininvVal =
                                "₹${convertCurrencyINRStandard(mininv(double.parse(ipo.ipoCommonSearchList[index].minPrice!).toDouble(), int.parse(ipo.ipoCommonSearchList[index].minBidQuantity!).toInt()).toInt())}";
                            startdate =
                                "${ipo.ipoCommonSearchList[index].biddingStartDate}";
                            enddate =
                                "${ipo.ipoCommonSearchList[index].biddingEndDate}";
                            ipotype = "${ipo.ipoCommonSearchList[index].key}";
                          } else {
                            await ipo.getIpoSinglePage(
                                ipoName:
                                    "${ipo.ipoCommonSearchList[index].companyName}");

                            pricerange =
                                "₹${ipo.ipoCommonSearchList[index].priceRange!}";
                            mininvVal =
                                "₹${convertCurrencyINRStandard(mininv(ipo.ipoCommonSearchList[index].minPrice!.toDouble(), ipo.ipoCommonSearchList[index].minBidQu!.toInt()).toInt())}";
                            enddate = convertClosedIpoDates(
                                ipo.ipoCommonSearchList[index].iPOEndDate!,
                                "MMM dd, yyyy",
                                "EEE, dd MMM yyyy HH:mm:ss");
                            startdate = convertClosedIpoDates(
                                ipo.ipoCommonSearchList[index].iPOStartDate!,
                                "MMM dd, yyyy",
                                "dd-MM-yyyy");
                          }

                          showModalBottomSheet(
                            isScrollControlled: true,
                            useSafeArea: true,
                            isDismissible: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16))),
                            context: context,
                            builder: (context) => Container(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: checkIpoStatus == "Listed"
                                  ? ScripDepthInfo(
                                      wlValue: depthArgs, isBasket: '')
                                  : MainSmeSinglePage(
                                      pricerange: pricerange,
                                      mininv: mininvVal,
                                      enddate: enddate,
                                      startdate: startdate,
                                      ipotype: ipotype,
                                      ipodetails:
                                          ipo.ipoCommonSearchList[index]),
                            ),
                          );
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                border: Border.symmetric(
                                    horizontal: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : Color(0xffEEF0F2),
                                        width: 1.5),
                                    vertical: BorderSide(
                                        color: theme.isDarkMode
                                            ? colors.darkGrey
                                            : Color(0xffEEF0F2),
                                        width: 1.5))),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                              Text(
                                                  "${ipo.ipoCommonSearchList[index].companyName == "" ? ipo.ipoCommonSearchList[index].name : ipo.ipoCommonSearchList[index].companyName}",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      14,
                                                      FontWeight.w500)),
                                              const SizedBox(height: 4),
                                              // SizedBox(
                                              //     height: 18,
                                              //     child: ListView(
                                              //         scrollDirection:
                                              //             Axis.horizontal,
                                              //         children: [
                                              //           CustomExchBadge(
                                              //               exch: ipo
                                              //                       .ipoCommonSearchList[index]
                                              //                       .key),
                                              //           // CustomExchBadge(
                                              //           //     exch: mfData
                                              //           //         .mutualFundsearchdata!
                                              //           //         .data![
                                              //           //             index]
                                              //           //         .sCHEMESUBCATEGORY!
                                              //           //         .replaceAll(
                                              //           //             "Fund",
                                              //           //             '')
                                              //           //         .replaceAll(
                                              //           //             "Hybrid",
                                              //           //             "")
                                              //           //         .toUpperCase())
                                              //         ]))
                                            ])),
                                      ]),
                                ])));
                  },
                )
              : const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(top: 250),
                    child: NoDataFound(),
                  ),
                ),
        ),
      ),
    );
  }
}
