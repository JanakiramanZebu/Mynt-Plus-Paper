import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/Mobile/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../../provider/fund_provider.dart';
import '../../../../provider/profile_all_details_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../sharedWidget/snack_bar.dart';
import '../bottom_sheets/cp_action_orderscreen.dart';
import '../bottom_sheets/cp_cancelorder_screen.dart';
import '../bottom_sheets/ledger_filter.dart';

class CABuyback extends StatefulWidget {
  const CABuyback({super.key});

  @override
  State<CABuyback> createState() => _CABuybackState();
}

class _CABuybackState extends State<CABuyback> with TickerProviderStateMixin {
  late TabController tabCtrl;
  final ScrollController _tabScrollController = ScrollController();
  final double tabWidth = 80.0;
  int selectedTab = 0; // 0: CA, 1: OFS

  @override
  void initState() {
    super.initState();
    tabCtrl = TabController(length: 2, vsync: this, initialIndex: 0);
    tabCtrl.addListener(() {
      setState(() {
        selectedTab = tabCtrl.index;
      });
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    tabCtrl.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab(int index) {
    if (!_tabScrollController.hasClients) return;

    final double viewportWidth =
        _tabScrollController.position.viewportDimension;
    double totalOffset = 0.0;
    for (int i = 0; i < index; i++) {
      totalOffset += tabWidth;
    }

    final double targetOffset =
        totalOffset - (viewportWidth / 2) + (tabWidth / 2);
    final double scrollTo =
        targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> staticColumn = [
      'Row 1',
      'Row 2',
      'Row 3',
      'Row 4',
      'Row 4'
    ];
    final List<String> Header = [
      'Date',
      "Debit",
      "Credit",
      "Net Amount",
      "Details"
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      double crdamount = 0.0;
      double dtamount = 0.0;
      final ledgerprovider = ref.watch(ledgerProvider);
      final datalist = ledgerprovider.filteredCPActionData;
      final profiledetails = ref.watch(profileAllDetailsProvider);
      final fundState = ref.watch(fundProvider);

      String opbalance = ledgerprovider.ledgerAllData?.openingBalance ?? '0.0';
      // String tdebit = ledgerprovider.ledgerAllData?.drAmt ?? '0.0';
      // String tcredit = ledgerprovider.ledgerAllData?.crAmt ?? '0.0';
      String clbalance = ledgerprovider.ledgerAllData?.closingBalance ?? '0.0';

      return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            leadingWidth: 48,
            centerTitle: false,
            titleSpacing: 0,
            leading: const CustomBackBtn(),
            // elevation: 0.2,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.titleText(
                    text: "Corporate Action",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    color: !theme.isDarkMode
                        ? colors.textPrimaryLight
                        : colors.textPrimaryDark,
                    fw: 1),
                // Row(
                //   children: [
                //     Container(
                //       margin: const EdgeInsets.only(right: 10),
                //       decoration: BoxDecoration(
                //         color: profiledetails.clientAllDetails.clientData?.dDPI ==
                //                 "Y"
                //             ? colors.kColorGreenButton
                //             : colors.kColorRedButton,
                //         borderRadius: BorderRadius.circular(15),
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: TextWidget.paraText(
                //             text:
                //                 "DDPI${profiledetails.clientAllDetails.clientData?.dDPI}",
                //             theme: theme.isDarkMode,
                //             fw: 1,
                //             color: colors.colorWhite),
                //       ),
                //     ),
                //     Container(
                //       decoration: BoxDecoration(
                //         color:
                //             profiledetails.clientAllDetails.clientData?.pOA == "Y"
                //                 ? colors.kColorGreenButton
                //                 : colors.kColorRedButton,
                //         borderRadius: BorderRadius.circular(15),
                //       ),
                //       child: Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: TextWidget.paraText(
                //             text: "POA",
                //             theme: theme.isDarkMode,
                //             fw: 1,
                //             color: colors.colorWhite),
                //       ),
                //     )
                //   ],
                // ),

                // DropdownButtonHideUnderline(
                //     child: DropdownButton2(
                //         menuItemStyleData: MenuItemStyleData(
                //             customHeights: ledgerprovider.getCustItemsHeight()),
                //         buttonStyleData: ButtonStyleData(
                //             height: 36,
                //             width: MediaQuery.of(context).size.width,
                //             decoration: const BoxDecoration(
                //                 color: Color(0xffF1F3F8),
                //                 borderRadius:
                //                     BorderRadius.all(Radius.circular(32)))),
                //         dropdownStyleData: DropdownStyleData(
                //           padding: const EdgeInsets.symmetric(vertical: 6),
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(4),
                //           ),
                //           offset: const Offset(0, 8),
                //         ),
                //         isExpanded: true,
                //         style:
                //             textStyle(const Color(0XFF000000), 13, FontWeight.w500),
                //         hint: Text(mfOrder.paymentName,
                //             style: textStyle(
                //                 const Color(0XFF000000), 13, FontWeight.w500)),
                //         items: mfOrder.addDividers(),
                //         value: mfOrder.paymentName,
                //         onChanged: (value) async {
                //           mfOrder.chngPayName("$value");
                //         })),
              ],
            ),
            // leading: InkWell(
            //   onTap: () {

            //   },
            //   child: Icon(Icons.ios_share)),
          ),
          body: SafeArea(
            child: TransparentLoaderScreen(
              isLoading: ledgerprovider.cpactionloader,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text("${ddd}")
                  // Padding(
                  //     padding: EdgeInsets.only(left: 4.0, top: 10.0),
                  //     child: Text(
                  //       "Financial activities through debits and credits ",
                  //       style: textStyle(colors.colorBlack, 14, FontWeight.w600),
                  //     )),

                  // Padding(
                  //   padding: const EdgeInsets.only(left: 30 , right: 30),
                  //   child: Row(
                  //     children: [
                  //       // Static Column
                  //       Column(
                  //         children: [
                  //           Container(
                  //             margin: EdgeInsets.only(top: 20),
                  //             width: 100,
                  //             color: Colors
                  //                 .cardbgrey, // Header cell for the static column
                  //             padding: EdgeInsets.all(8.0),
                  //             child: Text(
                  //               'Exchange',
                  //               style: TextStyle(fontWeight: FontWeight.bold),
                  //             ),
                  //           ),
                  //           for (var item in ledgerprovider.ledgerAllData!.fullStat!)
                  //             Container(
                  //               width: 100, // Fixed width for the static column
                  //               height: 50,

                  //               padding: EdgeInsets.all(8.0),
                  //               decoration: BoxDecoration(
                  //                 border: Border.all(color: const Color.fromARGB(255, 224, 224, 224)),
                  //               ),
                  //               child: Text("${item.cOCD}",
                  //               style: textStyle(Colors.black, 14, FontWeight.w600),
                  //               ),
                  //             ),
                  //         ],
                  //       ),
                  //       // Scrollable Content

                  //       Expanded(
                  //         child: SingleChildScrollView(
                  //           scrollDirection: Axis.horizontal,
                  //           child: Column(
                  //             children: [
                  //               // Header Row for the scrollable content
                  //               Row(
                  //                 children: [
                  //                   for (int i = 0; i < Header.length; i++)
                  //                     Container(
                  //                        margin: EdgeInsets.only(top: 20),
                  //                       width: i == 4 ? 275 : 100, // Column width

                  //                       padding: EdgeInsets.all(8.0),
                  //                       color: Color(0xFFEEEEEE),
                  //                       child: Text(
                  //                         '${Header[i]}',
                  //                         style:
                  //                             TextStyle(fontWeight: FontWeight.bold),
                  //                       ),
                  //                     ),
                  //                 ],
                  //               ),
                  //               // Data Rows for the scrollable content
                  //               for (int rowIndex = 0;
                  //                   rowIndex <
                  //                       ledgerprovider
                  //                           .ledgerAllData!.fullStat!.length;
                  //                   rowIndex++)
                  //                 Row(
                  //                   children: [
                  //                     for (int colIndex = 0; colIndex < 5; colIndex++)
                  //                       Container(
                  //                          width: colIndex == 4 ? 275 : 100,  // Column width
                  //                         height: 50,
                  //                         padding: EdgeInsets.all(8.0),
                  //                         decoration: BoxDecoration(
                  //                           border: Border.all(color: Color.fromARGB(255, 224, 224, 224)),
                  //                         ),
                  //                         child: Text(colIndex == 0 ? dateFormatChangeForLedger(ledgerprovider
                  //                             .tablearray[rowIndex][colIndex]) : ledgerprovider
                  //                             .tablearray[rowIndex][colIndex] ,
                  //                             textAlign: colIndex == 1 ||colIndex == 2 || colIndex == 3  ? TextAlign.right : TextAlign.start ,
                  //                             ) ,
                  //                         //  child: Text(  ledgerprovider
                  //                         //     .tablearray[rowIndex][colIndex] ) ,
                  //                       ),
                  //                   ],
                  //                 ),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 40,
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCATabs(
                                  ref, theme, tabCtrl, ledgerprovider),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const ListDivider(),
                  datalist.isEmpty
                      ? const Expanded(child: Center(child: NoDataFound(
                        secondaryEnabled: false,
                      )))
                      : Expanded(
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                          child: ListView.separated(
                            physics: ClampingScrollPhysics(),
                            itemCount: datalist.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final dataval = datalist[index];
                              return InkWell(
                                onTap: () {
                                  // setState(() {
                                  //   ledgerprovider.selectedqtyforcpaction.text =
                                  //       dataval.havingqty == 'null'
                                  //           ? '0'
                                  //           : dataval.havingqty;
                                  //   ledgerprovider.selectedpriceforcpaction
                                  //       .text = dataval.minPrice;
                                  // });
                                  // showModalBottomSheet(
                                  //   context: context,
                                  //   isScrollControlled: true,
                                  //   shape: const RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.only(
                                  //       topLeft: Radius.circular(16),
                                  //       topRight: Radius.circular(16),
                                  //     ),
                                  //   ),
                                  //   builder: (context) =>
                                  //       CPActionOrderScreen(data: dataval),
                                  // );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // if (index != 0 &&
                                      //     ledgerprovider.ledgerAllData!
                                      //             .fullStat![index].vOUCHERDATE !=
                                      //         ledgerprovider
                                      //             .ledgerAllData!
                                      //             .fullStat![index - 1]
                                      //             .vOUCHERDATE) ...[
                                      //   Card(
                                      //     elevation: 0.0,
                                      //     color: theme.isDarkMode
                                      //         ? const Color(0xffB5C0CF)
                                      //             .withOpacity(.15)
                                      //         : const Color(0xffF1F3F8),
                                      //     child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.start,
                                      //       children: [
                                      //         Padding(
                                      //           padding: const EdgeInsets.all(8.0),
                                      //           child: Text(
                                      //               "${index == 0 ? dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString()) : ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE == ledgerprovider.ledgerAllData!.fullStat![index - 1].vOUCHERDATE ? '' : dateFormatChangeForLedger(ledgerprovider.ledgerAllData!.fullStat![index].vOUCHERDATE.toString())}",
                                      //               style: textStyle(
                                      //                   theme.isDarkMode
                                      //                       ? colors.colorWhite
                                      //                       : colors.colorBlack,
                                      //                   14,
                                      //                   FontWeight.w600)),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ],
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6,
                                            child: TextWidget.subText(
                                              text: "${dataval?.name}",
                                              color: theme.isDarkMode
                                                  ? colors.textPrimaryDark
                                                  : colors.textPrimaryLight,
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              maxLines: 2,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                          ),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              // border: Border.all(color: _getStatusColor()),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: _getStatusColor(
                                                      dataval.issueType, theme)
                                                  .withOpacity(0.2),
                                            ),
                                            child: TextWidget.paraText(
                                              text: _getTypeLabel(
                                                  dataval.issueType),
                                              color: _getStatusColor(
                                                  dataval.issueType, theme),
                                              textOverflow:
                                                  TextOverflow.ellipsis,
                                              theme: theme.isDarkMode,
                                              fw: 0,
                                            ),
                                          ),
                                          // const SizedBox(width: 4),
                                          // if (ledgerprovider.selectvalueofcpaction !=
                                          //     'OFS') ...[
                                          //   Row(
                                          //     children: [
                                          //       TextWidget.paraText(
                                          //         text: "Off.prc",
                                          //         color: theme.isDarkMode
                                          //             ? colors.textSecondaryDark
                                          //             : colors.textSecondaryLight,
                                          //         textOverflow: TextOverflow.ellipsis,
                                          //         theme: theme.isDarkMode,
                                          //       ),
                                          //       TextWidget.paraText(
                                          //         // align: TextAlign.right,
                                          //         text: " ${dataval?.cutOffPrice}",
                                          //         color: theme.isDarkMode
                                          //             ? colors.textSecondaryDark
                                          //             : colors.textSecondaryLight,
                                          //         textOverflow: TextOverflow.ellipsis,
                                          //         theme: theme.isDarkMode,
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ],
                                        ],
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.paraText(
                                                    text:
                                                        '${dataval.exchange == 'NSETender' ? 'NSE' : dataval.exchange} -',
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                const SizedBox(width: 4),
                                                if (ledgerprovider
                                                        .selectvalueofcpaction !=
                                                    'OFS') ...[
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          TextWidget.paraText(
                                                            align:
                                                                TextAlign.right,
                                                            text: "Closes on",
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight,
                                                            textOverflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            theme: theme
                                                                .isDarkMode,
                                                            fw: 0,
                                                          ),
                                                          TextWidget.paraText(
                                                            align:
                                                                TextAlign.right,
                                                            text:
                                                                " ${dataval?.biddingEndDate}",
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight,
                                                            textOverflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            theme: theme
                                                                .isDarkMode,
                                                            fw: 0,
                                                          ),
                                                        ],
                                                      ),
                                                      // Padding(
                                                      //   padding: const EdgeInsets.only(
                                                      //       top: 4.0, left: 4.0),
                                                      //   child: TextWidget.paraText(
                                                      //       align: TextAlign.right,
                                                      //       text:
                                                      //           "${dataval?.dailyEndTime}",
                                                      //       color: Color(0xFF696969),
                                                      //       textOverflow:
                                                      //           TextOverflow.ellipsis,
                                                      //       theme: theme.isDarkMode,
                                                      //       fw: 0),
                                                      // ),
                                                    ],
                                                  ),
                                                ]
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  splashColor: theme.isDarkMode
                                                      ? colors.splashColorDark
                                                      : colors.splashColorLight,
                                                  highlightColor: theme
                                                          .isDarkMode
                                                      ? colors.highlightDark
                                                      : colors.highlightLight,
                                                  onTap: () {
                                                    // print('Tapped item:');
                                                    // print('list type: ' + _getTypeLabel(dataval.issueType));
                                                    // print('eligibleornot: ${dataval.eligibleornot}');
                                                    // print('approvedqty: ${dataval.approvedqty}');
                                                    // print('selectvalueofcpaction: ${ledgerprovider.selectvalueofcpaction}');
                                                    if (ledgerprovider
                                                            .selectvalueofcpaction ==
                                                        'OFS') {
                                                      ledgerprovider
                                                          .setordervalueforofs(
                                                              '1',
                                                              dataval.baseprice,
                                                              fundState
                                                                      .fundDetailModel
                                                                      ?.cash ??
                                                                  '0');
                                                    } else {
                                                      ledgerprovider
                                                          .setCPActionQty(
                                                              '', '', '', '');
                                                      ledgerprovider
                                                          .setCPActionPrice(
                                                              '', 0, 0, '', '');
                                                    }
                                                    if (dataval.orderstatus ==
                                                        'pending') {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            dialogContext) {
                                                          return AlertDialog(
                                                            backgroundColor: theme
                                                                    .isDarkMode
                                                                ? const Color(
                                                                    0xFF121212)
                                                                : const Color(
                                                                    0xFFF1F3F8),
                                                            titlePadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        8),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8))),
                                                            scrollable: true,
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 12,
                                                              vertical: 12,
                                                            ),
                                                            actionsPadding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 16,
                                                                    right: 16,
                                                                    left: 16,
                                                                    top: 8),
                                                            insetPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        30,
                                                                    vertical:
                                                                        12),
                                                            title: Column(
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    Material(
                                                                      color: Colors
                                                                          .transparent,
                                                                      shape:
                                                                          const CircleBorder(),
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () async {
                                                                          if (ledgerprovider.listforpledge ==
                                                                              []) {
                                                                            ledgerprovider.changesegvaldummy('');
                                                                          }
                                                                          await Future.delayed(
                                                                              const Duration(milliseconds: 150));
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        borderRadius:
                                                                            BorderRadius.circular(20),
                                                                        splashColor: theme.isDarkMode
                                                                            ? colors.splashColorDark
                                                                            : colors.splashColorLight,
                                                                        highlightColor: theme.isDarkMode
                                                                            ? colors.splashColorDark
                                                                            : colors.splashColorLight,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              6.0),
                                                                          child:
                                                                              Icon(
                                                                            Icons.close_rounded,
                                                                            size:
                                                                                22,
                                                                            color: theme.isDarkMode
                                                                                ? colors.textSecondaryDark
                                                                                : colors.textSecondaryLight,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 12),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .end,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    TextWidget.subText(
                                                                        text:
                                                                            "Cancel Order",
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                        color: theme.isDarkMode
                                                                            ? colors.textSecondaryDark
                                                                            : colors.textPrimaryLight,
                                                                        fw: 3),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                                  child: Center(
                                                                    child: TextWidget.subText(
                                                                        text:
                                                                            "Do you want to Cancel this order?",
                                                                        theme: theme
                                                                            .isDarkMode,
                                                                        color: theme.isDarkMode
                                                                            ? colors.textSecondaryDark
                                                                            : colors.textPrimaryLight,
                                                                        fw: 3),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            actions: [
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    OutlinedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    ledgerprovider
                                                                        .putordercopaction(
                                                                      ledgerprovider
                                                                          .selectvalueofcpaction,
                                                                      dataval?.symbol ??
                                                                          '',
                                                                      dataval?.exchange ??
                                                                          '',
                                                                      dataval?.issueType ??
                                                                          '',
                                                                      dataval?.bidqty ??
                                                                          '',
                                                                      dataval?.orderprice ??
                                                                          '',
                                                                      context,
                                                                      'CR',
                                                                      dataval?.appno ??
                                                                          '',
                                                                    );
                                                                  },
                                                                  style: OutlinedButton
                                                                      .styleFrom(
                                                                    minimumSize:
                                                                        const Size(
                                                                            0,
                                                                            45), // width, height
                                                                    side: BorderSide(
                                                                        color: colors
                                                                            .btnOutlinedBorder), // Outline border color
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    backgroundColor:
                                                                        colors
                                                                            .primaryDark, // Transparent background
                                                                  ),
                                                                  child: TextWidget
                                                                      .titleText(
                                                                    text:
                                                                        "Cancel",
                                                                    color: colors
                                                                        .colorWhite,
                                                                    theme: theme
                                                                        .isDarkMode,
                                                                    fw: 2,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      // showModalBottomSheet(
                                                      //     context: context,
                                                      //     builder: (context) =>
                                                      //         cancelOrderScreenCopAction(
                                                      //             data:
                                                      //                 dataval));
                                                    } else {
                                                      if ((dataval.eligibleornot ==
                                                              'yes') ||
                                                          (dataval.approvedqty !=
                                                                  '0' &&
                                                              dataval.eligibleornot ==
                                                                  'yes') ||
                                                          (ledgerprovider
                                                                  .selectvalueofcpaction ==
                                                              'OFS')) {
                                                        showModalBottomSheet(
                                                            context: context,
                                                            builder: (context) =>
                                                                CPActionOrderScreen(
                                                                    data:
                                                                        dataval));
                                                      } else {
                                                        error(
                                                                context,
                                                                "Not Eligible");
                                                        return null;
                                                      }
                                                    }

                                                    // _showBottomSheet(
                                                    //     context, const LedgerBillBottom());
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: Column(
                                                      children: [
                                                        TextWidget.subText(
                                                          text:
                                                              dataval.orderstatus ==
                                                                      'pending'
                                                                  ? 'Cancel'
                                                                  : "Order",
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 2,
                                                          color: dataval
                                                                      .orderstatus ==
                                                                  'pending'
                                                              ? colors
                                                                  .kColorRedButton
                                                              : colors
                                                                  .secondary,
                                                        ),
                                                        if (dataval.bidqty !=
                                                            'null')
                                                          TextWidget.paraText(
                                                            text:
                                                                "${dataval.bidqty} qty bided",
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .textSecondaryDark
                                                                : colors
                                                                    .textSecondaryLight,
                                                            theme: theme
                                                                .isDarkMode,
                                                          ),
                                                        // const SizedBox(height: 4),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),

                                      // const ListDivider(),
                                      if (ledgerprovider
                                              .selectvalueofcpaction !=
                                          'OFS') ...[
                                        // const Padding(
                                        //   padding: EdgeInsets.only(
                                        //       left: 16.0,
                                        //       right: 16.0,
                                        //       top: 2.0,
                                        //       bottom: 4.0),
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.spaceBetween,
                                        //     children: [
                                        //       // Column(
                                        //       //   crossAxisAlignment:
                                        //       //       CrossAxisAlignment.start,
                                        //       //   children: [
                                        //       //     // Row(
                                        //       //     //   children: [
                                        //       //     //     TextWidget.subText(
                                        //       //     //         align: TextAlign.right,
                                        //       //     //         text: "Start Date : ",
                                        //       //     //         color: Color(0xFF696969),
                                        //       //     //         textOverflow:
                                        //       //     //             TextOverflow.ellipsis,
                                        //       //     //         theme: theme.isDarkMode,
                                        //       //     //         fw: 0),
                                        //       //     //     TextWidget.subText(
                                        //       //     //         align: TextAlign.right,
                                        //       //     //         text:
                                        //       //     //             " ${dataval?.biddingStartDate}",
                                        //       //     //         color: theme.isDarkMode
                                        //       //     //             ? Colors.white
                                        //       //     //             : Colors.black,
                                        //       //     //         textOverflow:
                                        //       //     //             TextOverflow.ellipsis,
                                        //       //     //         theme: theme.isDarkMode,
                                        //       //     //         fw: 0),
                                        //       //     //   ],
                                        //       //     // ),
                                        //       //     // Padding(
                                        //       //     //   padding: const EdgeInsets.only(
                                        //       //     //       top: 4.0, left: 4.0),
                                        //       //     //   child: TextWidget.paraText(
                                        //       //     //       align: TextAlign.right,
                                        //       //     //       text:
                                        //       //     //           "${dataval?.dailyStartTime}",
                                        //       //     //       color: Color(0xFF696969),
                                        //       //     //       textOverflow:
                                        //       //     //           TextOverflow.ellipsis,
                                        //       //     //       theme: theme.isDarkMode,
                                        //       //     //       fw: 0),
                                        //       //     // ),
                                        //       //   ],
                                        //       // ),
                                        //       // Column(
                                        //       //   crossAxisAlignment:
                                        //       //       CrossAxisAlignment.end,
                                        //       //   children: [
                                        //       //     Row(
                                        //       //       children: [
                                        //       //         TextWidget.subText(
                                        //       //             align: TextAlign.right,
                                        //       //             text: "Closes on : ",
                                        //       //             color: Color(0xFF696969),
                                        //       //             textOverflow:
                                        //       //                 TextOverflow.ellipsis,
                                        //       //             theme: theme.isDarkMode,
                                        //       //             fw: 0),
                                        //       //         TextWidget.subText(
                                        //       //             align: TextAlign.right,
                                        //       //             text:
                                        //       //                 " ${dataval?.biddingEndDate}",
                                        //       //             color: theme.isDarkMode
                                        //       //                 ? Colors.white
                                        //       //                 : Colors.black,
                                        //       //             textOverflow:
                                        //       //                 TextOverflow.ellipsis,
                                        //       //             theme: theme.isDarkMode,
                                        //       //             fw: 0),
                                        //       //       ],
                                        //       //     ),
                                        //       //     Padding(
                                        //       //       padding: const EdgeInsets.only(
                                        //       //           top: 4.0, left: 4.0),
                                        //       //       child: TextWidget.paraText(
                                        //       //           align: TextAlign.right,
                                        //       //           text:
                                        //       //               "${dataval?.dailyEndTime}",
                                        //       //           color: Color(0xFF696969),
                                        //       //           textOverflow:
                                        //       //               TextOverflow.ellipsis,
                                        //       //           theme: theme.isDarkMode,
                                        //       //           fw: 0),
                                        //       //     ),
                                        //       //   ],
                                        //       // ),
                                        //     ],
                                        //   ),
                                        // ),
                                        // Padding(
                                        //   padding: const EdgeInsets.only(top: 4.0),
                                        //   child: Row(
                                        //     mainAxisAlignment:
                                        //         MainAxisAlignment.spaceBetween,
                                        //     children: [

                                        //       dataval?.orderstatus != 'null' ?
                                        //       Row(
                                        //         children: [
                                        //           TextWidget.paraText(
                                        //               // align: TextAlign.right,
                                        //               text: "Status",
                                        //               color: theme.isDarkMode
                                        //                   ? colors.textSecondaryDark
                                        //                   : colors.textSecondaryLight,
                                        //               textOverflow:
                                        //                   TextOverflow.ellipsis,
                                        //               theme: theme.isDarkMode,
                                        //               ),
                                        //           TextWidget.paraText(
                                        //               // align: TextAlign.right,
                                        //               text:
                                        //                   " ${dataval?.orderstatus}",
                                        //                   // dataval?.orderstatus == 'null' ? '-' :
                                        //               color: theme.isDarkMode
                                        //                   ? colors.textSecondaryDark
                                        //                   : colors.textSecondaryLight,
                                        //               textOverflow:
                                        //                   TextOverflow.ellipsis,
                                        //               theme: theme.isDarkMode,
                                        //               ),
                                        //         ],
                                        //       ) : const SizedBox.shrink(),
                                        //     ],
                                        //   ),
                                        // ),
                                      ],
                                      if (ledgerprovider
                                              .selectvalueofcpaction ==
                                          'OFS') ...[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0, bottom: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                      text: "Size ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                  TextWidget.subText(
                                                      // align: TextAlign.right,
                                                      text:
                                                          " ${dataval?.issueSize}",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                      text: "Base Price ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                  TextWidget.subText(
                                                      text:
                                                          " ${dataval?.baseprice}",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0, bottom: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                      text: "Open Date ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                  TextWidget.subText(
                                                      text:
                                                          " ${dataval?.openondate}",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                      text: "Status ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                  TextWidget.subText(
                                                      text:
                                                          " ${dataval?.orderstatus == 'null' ? '-' : dataval?.orderstatus}",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 3),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              // if (index != 0 &&
                              //     ledgerprovider.ledgerAllData!.fullStat![index - 1]
                              //             .vOUCHERDATE ==
                              //         ledgerprovider.ledgerAllData!
                              //             .fullStat![index ].vOUCHERDATE) {
                              return ListDivider();
                              // }else{
                              // return SizedBox();
                              // }
                            },
                          ),
                        )),
                ],
              ),
            ),
          ));
    });
  }

  Widget _buildCATabs(
      WidgetRef ref, theme, TabController tabCtrl, ledgerprovider) {
    final List<String> tabLabels = ["CA", "OFS"];

    return ListView.builder(
      controller: _tabScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: tabLabels.length,
      itemBuilder: (context, index) {
        final tabLabel = tabLabels[index];
        final isCurrentSelected =
            ledgerprovider.selectvalueofcpaction == tabLabel;

        return Container(
          width: 100,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(right: 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.01)
                  : Colors.black.withOpacity(0.01),
              onTap: () {
                if (!isCurrentSelected) {
                  tabCtrl.animateTo(index);
                  ledgerprovider.setselectvalueofcpaction = tabLabel;
                  _scrollToSelectedTab(index);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: TextWidget.subText(
                        text: tabLabel,
                        color: isCurrentSelected
                            ? theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight
                            : theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        theme: theme.isDarkMode,
                        fw: isCurrentSelected ? 2 : 2),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 2,
                    width: isCurrentSelected ? 82 : 0,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.secondaryDark
                          : colors.secondaryLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(
      ledgerprovider, String label, bool value, ThemesProvider theme) {
    return InkWell(
      onTap: () {
        ledgerprovider.setselectvalueofcpaction = label;
      },
      child: Container(
        decoration: BoxDecoration(
          color: value ? colors.colorBlack : colors.colorWhite,
          border: Border.all(
            color: colors.colorBlack,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: TextWidget.paraText(
            text: "$label",
            theme: theme.isDarkMode,
            fw: 1,
            color: value ? colors.colorWhite : colors.colorBlack,
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: bottomSheet));
  }

  String _getTypeLabel(String? issueType) {
    switch (issueType) {
      case 'BB':
      case 'BUYBACK':
        return 'BUYBACK';
      case 'DLST':
      case 'DS':
        return 'DELISTING';
      case 'TAKEOVER':
      case 'TO':
        return 'TAKEOVER';
      case 'IS':
      case 'RS':
        return 'OFS';
      default:
        return issueType ?? '';
    }
  }

  Color _getStatusColor(String issueType, ThemesProvider theme) {
    switch (issueType) {
      case 'BB':
      case 'BUYBACK':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'DLST':
      case 'DS':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      case 'TAKEOVER':
      case 'TO':
        return theme.isDarkMode ? colors.profitDark : colors.profitLight;
      case 'IS':
      case 'RS':
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
      default:
        return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    }
  }
}
