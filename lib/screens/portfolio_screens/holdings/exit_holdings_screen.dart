import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../provider/fund_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart'; 
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart'; 

class ExitHoldingsScreen extends ConsumerWidget {
  const ExitHoldingsScreen({super.key});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final holdings = watch(portfolioProvider);
    // final socketDatas = watch(websocketProvider).socketDatas;
    return WillPopScope(
      onWillPop: () async {
        holdings.selectExitAllPosition(false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
              onTap: () {
                holdings.selectExitAllHoldings(false);
                Navigator.pop(context);
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(assets.backArrow,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack))),
          title: Text(
            "Exit Holdings",
            style: textStyles.appBarTitleTxt.copyWith(
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
          ),
          actions: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    holdings.selectExitAllHoldings(
                        holdings.isExitAllHoldings ? false : true);
                  },
                  child: SvgPicture.asset(
                    theme.isDarkMode
                        ? holdings.isExitAllHoldings
                            ? assets.darkCheckedboxIcon
                            : assets.darkCheckboxIcon
                        : holdings.isExitAllHoldings
                            ? assets.ckeckedboxIcon
                            : assets.ckeckboxIcon,
                    width: 22,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    holdings.isExitAllPosition ? "Cancel" : "Select All",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorLightBlue
                            : colors.colorBlue,
                        14,
                        FontWeight.w500),
                  ),
                )
              ],
            ),
          ],
        ),
        body: ListView(
          children: [
            if (holdings.sealableHoldings.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                    color:
                        theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                    border: holdings.sealableHoldings[0].isExitHoldings!
                        ? Border(
                            bottom:
                                BorderSide(color: colors.colorWhite, width: 6))
                        : null),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                    "Sellable Holdings(${holdings.sealableHoldings.length})",
                    style: textStyles.appBarTitleTxt.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack)),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: holdings.sealableHoldings.length,
                itemBuilder: (BuildContext context, int index) {
                  // if (socketDatas.containsKey(
                  //     holdings.sealableHoldings[index].exchTsym![0].token)) {
                  //   holdings.sealableHoldings[index].exchTsym![0].lp =
                  //       "${socketDatas["${holdings.sealableHoldings[index].exchTsym![0].token}"]['lp']}";

                  //   holdings.sealableHoldings[index].exchTsym![0].perChange =
                  //       "${socketDatas["${holdings.sealableHoldings[index].exchTsym![0].token}"]['pc']}";

                  //   holdings.sealableHoldings[index].exchTsym![0].close =
                  //       "${socketDatas["${holdings.sealableHoldings[index].exchTsym![0].token}"]['c']}";
                  //   holdings.holdingCalc();
                  // }
                  return InkWell(
                      onTap: () {
                        holdings.selectExitHoldings(index);
                      },
                      child: Container(
                        color: theme.isDarkMode
                            ? holdings.sealableHoldings[index].isExitHoldings!
                                ? colors.darkGrey
                                : colors.colorBlack
                            : holdings.sealableHoldings[index].isExitHoldings!
                                ? const Color(0xffF1F3F8)
                                : colors.colorWhite,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${holdings.sealableHoldings[index].exchTsym![0].tsym} ",
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)),
                                Row(
                                  children: [
                                    Text(" LTP: ",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            13,
                                            FontWeight.w600)),
                                    Text(
                                        "₹${holdings.sealableHoldings[index].exchTsym![0].lp}",
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
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomExchBadge(
                                    exch:
                                        "${holdings.sealableHoldings[index].exchTsym![0].exch}"),
                                Text(
                                    " (${holdings.sealableHoldings[index].exchTsym![0].perChange}%)",
                                    style: textStyle(
                                        Color(holdings.sealableHoldings[index]
                                                .exchTsym![0].perChange!
                                                .startsWith("-")
                                            ? 0XFFFF1717
                                            : holdings
                                                        .sealableHoldings[index]
                                                        .exchTsym![0]
                                                        .perChange ==
                                                    "0.00"
                                                ? 0xff666666
                                                : 0xff43A833),
                                        12,
                                        FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Sellable: ",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            14,
                                            FontWeight.w500)),
                                    Text(
                                        "${holdings.sealableHoldings[index].saleableQty ?? 0} ",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500)),
                                    Text("/ Qty: ",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            14,
                                            FontWeight.w500)),
                                    Text(
                                        "${holdings.sealableHoldings[index].currentQty ?? 0} @ ₹${holdings.sealableHoldings[index].upldprc ?? holdings.sealableHoldings[index].exchTsym![0].close ?? 0.00}",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500)),
                                    if (holdings
                                            .sealableHoldings[index].btstqty !=
                                        "0")
                                      Text(
                                          " T1: ${holdings.sealableHoldings[index].btstqty}",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              12,
                                              FontWeight.w500))
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "₹${holdings.sealableHoldings[index].exchTsym![0].profitNloss}",
                                        style: textStyle(
                                            Color(holdings
                                                    .sealableHoldings[index]
                                                    .exchTsym![0]
                                                    .profitNloss!
                                                    .startsWith("-")
                                                ? 0XFFFF1717
                                                : 0xff43A833),
                                            14,
                                            FontWeight.w500)),
                                    Text(
                                        " (${holdings.sealableHoldings[index].exchTsym![0].pNlChng == "NaN" ? 0.0 : holdings.sealableHoldings[index].exchTsym![0].pNlChng}%)",
                                        style: textStyle(
                                            Color(holdings
                                                    .sealableHoldings[index]
                                                    .exchTsym![0]
                                                    .pNlChng!
                                                    .startsWith("-")
                                                ? 0XFFFF1717
                                                : holdings
                                                            .sealableHoldings[
                                                                index]
                                                            .exchTsym![0]
                                                            .pNlChng ==
                                                        "NaN"
                                                    ? 0xff666666
                                                    : 0xff43A833),
                                            12,
                                            FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                      color: theme.isDarkMode
                          ? !holdings.sealableHoldings[index].isExitHoldings!
                              ? colors.darkGrey
                              : colors.colorBlack
                          : !holdings.sealableHoldings[index].isExitHoldings!
                              ? const Color(0xffF1F3F8)
                              : colors.colorWhite,
                      height: 6);
                },
              ),
            ],
            if (holdings.nonSealableHoldings.isNotEmpty) ...[
              Container(
                  decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffF1F3F8),
                      border: holdings.isExitAllHoldings
                          ? Border(
                              top: BorderSide(
                                  color: colors.colorWhite, width: 6))
                          : null),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: holdings.showEdis ? 6 : 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Non-Sellable Holdings(${holdings.nonSealableHoldings.length})",
                          style: textStyles.appBarTitleTxt.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack)),
                      if (holdings.showEdis)
                        SizedBox(
                            height: 27,
                            child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32)))),
                                onPressed: () async {
                                  await context
                                      .read(fundProvider)
                                      .fetchHstoken(context);
                                  await context
                                      .read(fundProvider)
                                      .eDis(context);
                                },
                                child: Text("E-DIS",
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        12,
                                        FontWeight.w600)))),
                    ],
                  )),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: holdings.nonSealableHoldings.length,
                itemBuilder: (BuildContext context, int index) {
                  // if (socketDatas.containsKey(
                  //     holdings.nonSealableHoldings[index].exchTsym![0].token)) {
                  //   holdings.nonSealableHoldings[index].exchTsym![0].lp =
                  //       "${socketDatas["${holdings.nonSealableHoldings[index].exchTsym![0].token}"]['lp']}";

                  //   holdings.nonSealableHoldings[index].exchTsym![0].perChange =
                  //       "${socketDatas["${holdings.nonSealableHoldings[index].exchTsym![0].token}"]['pc']}";

                  //   holdings.nonSealableHoldings[index].exchTsym![0].close =
                  //       "${socketDatas["${holdings.nonSealableHoldings[index].exchTsym![0].token}"]['c']}";
                  //   holdings.holdingCalc();
                  // }
                  return InkWell(
                      onTap: () {
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
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child:  

Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
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
             
              Text('Verify Holdings',
                    overflow: TextOverflow.ellipsis,
                    style:
                        textStyle( theme.isDarkMode?colors.colorWhite:colors.colorBlack, 16, FontWeight.w600))
             
           ,   Column(children: [
                const SizedBox(height: 12),
               
                  Text(
                    
                    holdings.nonSealableHoldings[index]
                                                      .brkcolqty ==
                                                  null ||
                                              holdings
                                                      .nonSealableHoldings[
                                                          index]
                                                      .brkcolqty ==
                                                  "0"?
                      "You are unable to exit because there are no sealable quantity. Kindly do E-DIS.":"You are unable to exit because the stock is pledged. Kindly unpledge and do E-DIS.",
                      style: textStyle(
                          theme.isDarkMode?colors.colorWhite:colors.colorBlack, 12, FontWeight.w500))
             ,
               
                const SizedBox(height: 12)
              ]),
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                       if (holdings
                                                      .nonSealableHoldings[
                                                          index]
                                                      .brkcolqty ==
                                                  null ||
                                              holdings
                                                      .nonSealableHoldings[
                                                          index]
                                                      .brkcolqty ==
                                                  "0") {
                                            await context
                                                .read(fundProvider)
                                                .fetchHstoken(context);

                                            Navigator.pop(context);
                                            await context
                                                .read(fundProvider)
                                                .eDis(context);
                                          } else {
                                              await context
                                .read(fundProvider)
                                .fetchHstoken(context);   Navigator.pop(context);
                            Navigator.pushNamed(
                                context, Routes.reportWebViewApp,
                                arguments: "pledge");
                                         
                                          }
                       

                    
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor:  theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      child: Text("Continue",
                          style: textStyle(
                              ! theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)))),
              const SizedBox(height: 14)
            ]))

                ));       
                
                //  showDialog(
                //             context: context,
                //             builder: (BuildContext context) {
                //               return AlertDialog(
                //                 backgroundColor:
                //                     context.read(themeProvider).isDarkMode
                //                         ? const Color.fromARGB(255, 18, 18, 18)
                //                         : colors.colorWhite,
                //                 titleTextStyle: textStyles.appBarTitleTxt
                //                     .copyWith(
                //                         color: context
                //                                 .read(themeProvider)
                //                                 .isDarkMode
                //                             ? colors.colorWhite
                //                             : colors.colorBlack),
                //                 contentTextStyle: textStyles.menuTxt,
                //                 titlePadding: const EdgeInsets.symmetric(
                //                     horizontal: 14, vertical: 12),
                //                 shape: const RoundedRectangleBorder(
                //                     borderRadius:
                //                         BorderRadius.all(Radius.circular(14))),
                //                 scrollable: true,
                //                 contentPadding: const EdgeInsets.symmetric(
                //                   horizontal: 14,
                //                 ),
                //                 insetPadding:
                //                     const EdgeInsets.symmetric(horizontal: 20),
                //                 title: const Text("Verify Holdings"),
                //                 content: SizedBox(
                //                   width: MediaQuery.of(context).size.width,
                //                   child: Column(
                //                     crossAxisAlignment:
                //                         CrossAxisAlignment.start,
                //                     children: [
                //                       Text(holdings.nonSealableHoldings[index]
                //                                       .brkcolqty ==
                //                                   null ||
                //                               holdings
                //                                       .nonSealableHoldings[
                //                                           index]
                //                                       .brkcolqty ==
                //                                   "0"
                //                           ? "Did not done E-Dis"
                //                           : "This Stock was Pledged!")
                //                     ],
                //                   ),
                //                 ),
                //                 actions: [
                //                   SizedBox(
                //                     width: MediaQuery.of(context).size.width,
                //                     child: ElevatedButton(
                //                         onPressed: () async {
                //                           if (holdings
                //                                       .nonSealableHoldings[
                //                                           index]
                //                                       .brkcolqty ==
                //                                   null ||
                //                               holdings
                //                                       .nonSealableHoldings[
                //                                           index]
                //                                       .brkcolqty ==
                //                                   "0") {
                //                             await context
                //                                 .read(fundProvider)
                //                                 .fetchHstoken(context);

                //                             Navigator.pop(context);
                //                             await context
                //                                 .read(fundProvider)
                //                                 .eDis(context);
                //                           } else {
                //                             Navigator.pop(context);
                //                           }
                //                         },
                //                         style: ElevatedButton.styleFrom(
                //                             elevation: 0,
                //                             backgroundColor:
                //                                 const Color(0xff000000),
                //                             shape: RoundedRectangleBorder(
                //                               borderRadius:
                //                                   BorderRadius.circular(50),
                //                             )),
                //                         child: Text("Ok",
                //                             style: textStyle(
                //                                 !context
                //                                         .read(themeProvider)
                //                                         .isDarkMode
                //                                     ? colors.colorWhite
                //                                     : colors.colorBlack,
                //                                 14,
                //                                 FontWeight.w500))),
                //                   ),
                //                 ],
                //               );
                //             });
                      },
                      child: Container(
                        color: theme.isDarkMode
                            ? holdings
                                    .nonSealableHoldings[index].isExitHoldings!
                                ? colors.darkGrey
                                : colors.colorBlack
                            : holdings
                                    .nonSealableHoldings[index].isExitHoldings!
                                ? const Color(0xffF1F3F8)
                                : colors.colorWhite,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${holdings.nonSealableHoldings[index].exchTsym![0].tsym} ",
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)),
                                Row(
                                  children: [
                                    Text(" LTP: ",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            13,
                                            FontWeight.w600)),
                                    Text(
                                        "₹${holdings.nonSealableHoldings[index].exchTsym![0].lp}",
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
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomExchBadge(
                                    exch:
                                        "${holdings.nonSealableHoldings[index].exchTsym![0].exch}"),
                                Text(
                                    " (${holdings.nonSealableHoldings[index].exchTsym![0].perChange}%)",
                                    style: textStyle(
                                        Color(holdings
                                                .nonSealableHoldings[index]
                                                .exchTsym![0]
                                                .perChange!
                                                .startsWith("-")
                                            ? 0XFFFF1717
                                            : holdings
                                                        .nonSealableHoldings[
                                                            index]
                                                        .exchTsym![0]
                                                        .perChange ==
                                                    "0.00"
                                                ? 0xff666666
                                                : 0xff43A833),
                                        12,
                                        FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Qty: ",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            14,
                                            FontWeight.w500)),
                                    Text(
                                        "${holdings.nonSealableHoldings[index].currentQty ?? 0} @ ₹${holdings.nonSealableHoldings[index].upldprc ?? holdings.nonSealableHoldings[index].exchTsym![0].close ?? 0.00}",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500)),
                                    if (holdings.nonSealableHoldings[index]
                                            .btstqty !=
                                        "0")
                                      Text(
                                          " T1: ${holdings.nonSealableHoldings[index].btstqty}",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              12,
                                              FontWeight.w500))
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "₹${holdings.nonSealableHoldings[index].exchTsym![0].profitNloss}",
                                        style: textStyle(
                                            Color(holdings
                                                    .nonSealableHoldings[index]
                                                    .exchTsym![0]
                                                    .profitNloss!
                                                    .startsWith("-")
                                                ? 0XFFFF1717
                                                : 0xff43A833),
                                            14,
                                            FontWeight.w500)),
                                    Text(
                                        " (${holdings.nonSealableHoldings[index].exchTsym![0].pNlChng == "NaN" ? 0.0 : holdings.nonSealableHoldings[index].exchTsym![0].pNlChng}%)",
                                        style: textStyle(
                                            Color(holdings
                                                    .nonSealableHoldings[index]
                                                    .exchTsym![0]
                                                    .pNlChng!
                                                    .startsWith("-")
                                                ? 0XFFFF1717
                                                : holdings
                                                            .nonSealableHoldings[
                                                                index]
                                                            .exchTsym![0]
                                                            .pNlChng ==
                                                        "NaN"
                                                    ? 0xff666666
                                                    : 0xff43A833),
                                            12,
                                            FontWeight.w500)),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ));
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                      color: theme.isDarkMode
                          ? !holdings.nonSealableHoldings[index].isExitHoldings!
                              ? colors.darkGrey
                              : colors.colorBlack
                          : !holdings.nonSealableHoldings[index].isExitHoldings!
                              ? const Color(0xffF1F3F8)
                              : colors.colorWhite,
                      height: 6);
                },
              )
            ]
          ],
        ),
        bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const CircularNotchedRectangle(),
            child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                    color: holdings.exitHoldingsQty == 0
                        ? const Color(0XFFD34645).withOpacity(.8)
                        : const Color(0XFFD34645),
                    borderRadius: BorderRadius.circular(32)),
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: holdings.exitHoldingsQty == 0
                      ? () {}
                      : () async {
                          await holdings.exitAllHoldings(context);
                        },
                  child: Center(
                      child: Text(
                          holdings.exitHoldingsQty == 0
                              ? "Exit"
                              : "Exit (${holdings.exitHoldingsQty})",
                          style: textStyle(
                              const Color(0xffFFFFFF), 14, FontWeight.w600))),
                ))),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
