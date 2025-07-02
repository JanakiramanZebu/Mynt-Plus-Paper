import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../provider/fund_provider.dart';
import '../../../provider/profile_all_details_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../bottom_sheets/cp_action_orderscreen.dart';
import '../bottom_sheets/cp_cancelorder_screen.dart';
import '../bottom_sheets/ledger_filter.dart';

class CABuyback extends StatelessWidget {
  const CABuyback({super.key});

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
          // automaticallyImplyLeading: false,
          elevation: 0.2,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.heroText(
                  text: "Corporate Action",
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 1),
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: profiledetails.clientAllDetails.clientData?.dDPI ==
                              "Y"
                          ? colors.kColorGreenButton
                          : colors.kColorRedButton,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextWidget.paraText(
                          text:
                              "DDPI${profiledetails.clientAllDetails.clientData?.dDPI}",
                          theme: theme.isDarkMode,
                          fw: 1,
                          color: colors.colorWhite),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          profiledetails.clientAllDetails.clientData?.pOA == "Y"
                              ? colors.kColorGreenButton
                              : colors.kColorRedButton,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextWidget.paraText(
                          text: "POA",
                          theme: theme.isDarkMode,
                          fw: 1,
                          color: colors.colorWhite),
                    ),
                  )
                ],
              ),

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
        body: TransparentLoaderScreen(
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
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildStatusChip(
                        ledgerprovider,
                        "Buyback",
                        ledgerprovider.selectvalueofcpaction == 'Buyback',
                        theme,
                      ),
                      const SizedBox(width: 10),
                      _buildStatusChip(
                        ledgerprovider,
                        "Delisting",
                        ledgerprovider.selectvalueofcpaction == 'Delisting',
                        theme,
                      ),
                      const SizedBox(width: 10),
                      _buildStatusChip(
                        ledgerprovider,
                        "Takeover",
                        ledgerprovider.selectvalueofcpaction == 'Takeover',
                        theme,
                      ),
                      const SizedBox(width: 10),
                      _buildStatusChip(
                        ledgerprovider,
                        "OFS",
                        ledgerprovider.selectvalueofcpaction == 'OFS',
                        theme,
                      ),
                      const SizedBox(width: 10),
                      // _buildStatusChip(
                      //   ledgerprovider,
                      //   "RIGHTS",
                      //   ledgerprovider.selectvalueofcpaction == 'RIGHTS',
                      //   theme,
                      // ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 2.0,
                  bottom: 0.0,
                ),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 7.0,
                ),
              ),
              datalist.isEmpty
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ))
                  : Expanded(
                      child: SingleChildScrollView(
                        child: ListView.separated(
                          physics: ScrollPhysics(),
                          itemCount: datalist.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final dataval = datalist[index];
                            return Column(
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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, top: 8.0, right: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: screenWidth * 0.40,
                                            child: TextWidget.subText(
                                                text: "${dataval?.name}",
                                                color: theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 1),
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 8),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 5),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: const Color(0xff2069BB)),
                                            child: Text('${dataval.exchange}',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: textStyle(
                                                    const Color.fromARGB(
                                                        255, 255, 255, 255),
                                                    10,
                                                    FontWeight.w500)),
                                          )
                                        ],
                                      ),
                                      InkWell(
                                        onTap: () {
                                          if (ledgerprovider
                                                  .selectvalueofcpaction ==
                                              'OFS') {
                                            ledgerprovider.setordervalueforofs(
                                                '1', dataval.baseprice,fundState.fundDetailModel?.cash ?? '0');
                                          } else {
                                            ledgerprovider.setCPActionQty(
                                                '', '', '', '');
                                            ledgerprovider.setCPActionPrice(
                                                '', 0, 0, '', '');
                                          }
                                          if (dataval.orderstatus ==
                                              'pending') {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) =>
                                                    cancelOrderScreenCopAction(
                                                        data: dataval));
                                          } else {
                                            if ((dataval.eligibleornot ==
                                                    'yes') ||
                                                (dataval.approvedqty != '0' &&
                                                    dataval.eligibleornot ==
                                                        'yes') ||
                                                (ledgerprovider
                                                        .selectvalueofcpaction ==
                                                    'OFS')) {
                                              showModalBottomSheet(
                                                  context: context,
                                                  builder: (context) =>
                                                      CPActionOrderScreen(
                                                          data: dataval));
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(error(
                                                      context, "Not Eligible"));
                                              return null;
                                            }
                                          }

                                          // _showBottomSheet(
                                          //     context, const LedgerBillBottom());
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: dataval.eligibleornot ==
                                                        'yes'
                                                    ? colors.colorWhite
                                                    : colors.colorWhite,
                                                border: Border.all(
                                                  color: dataval.orderstatus ==
                                                          'pending'
                                                      ? colors.kColorRedButton
                                                      : colors.colorBlack,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8.0),
                                                child: TextWidget.paraText(
                                                  text:
                                                      "${dataval.orderstatus == 'pending' ? 'Cancel' : "Order"}",
                                                  theme: theme.isDarkMode,
                                                  fw: 1,
                                                  color: dataval.orderstatus ==
                                                          'pending'
                                                      ? colors.kColorRedButton
                                                      : colors.colorBlack,
                                                ),
                                              ),
                                            ),
                                            if (dataval.bidqty != 'null')
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4.0),
                                                child: TextWidget.captionText(
                                                    text:
                                                        "${dataval.bidqty} qty bided",
                                                    theme: theme.isDarkMode,
                                                    fw: 1,
                                                    color: colors.colorBlack),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Divider(
                                    color: const Color.fromARGB(
                                        255, 212, 212, 212),
                                    thickness: 0.5,
                                  ),
                                ),
                                if (ledgerprovider.selectvalueofcpaction !=
                                    'OFS') ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 2.0,
                                        bottom: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: "Start Date : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:
                                                        " ${dataval?.biddingStartDate}",
                                                    color: theme.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0, left: 4.0),
                                              child: TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text:
                                                      "${dataval?.dailyStartTime}",
                                                  color: Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text: "End Date : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:
                                                        " ${dataval?.biddingEndDate}",
                                                    color: theme.isDarkMode
                                                        ? Colors.white
                                                        : Colors.black,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0, left: 4.0),
                                              child: TextWidget.paraText(
                                                  align: TextAlign.right,
                                                  text:
                                                      "${dataval?.dailyEndTime}",
                                                  color: Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 2.0,
                                        bottom: .0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Price offered : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text:
                                                    " ${dataval?.cutOffPrice}",
                                                color: theme.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Status : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text:
                                                    " ${dataval?.orderstatus == 'null' ? '-' : dataval?.orderstatus}",
                                                color: theme.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (ledgerprovider.selectvalueofcpaction ==
                                    'OFS') ...[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 2.0,
                                        bottom: 4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Size : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: " ${dataval?.issueSize}",
                                                color: theme.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Base Price : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: " ${dataval?.baseprice}",
                                                color: theme.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0,
                                        right: 16.0,
                                        top: 8.0,
                                        bottom: .0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Open Date : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: " ${dataval?.openondate}",
                                                color: theme.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text: "Status : ",
                                                color: Color(0xFF696969),
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                            TextWidget.subText(
                                                align: TextAlign.right,
                                                text:
                                                    " ${dataval?.orderstatus == 'null' ? '-' : dataval?.orderstatus}",
                                                color: theme.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            // if (index != 0 &&
                            //     ledgerprovider.ledgerAllData!.fullStat![index - 1]
                            //             .vOUCHERDATE ==
                            //         ledgerprovider.ledgerAllData!
                            //             .fullStat![index ].vOUCHERDATE) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 2.0,
                                bottom: 0.0,
                              ),
                              child: Divider(
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                                thickness: 7.0,
                              ),
                            );
                            // }else{
                            // return SizedBox();
                            // }
                          },
                        ),
                      ),
                    )
            ],
          ),
        ),
      );
    });
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
}
