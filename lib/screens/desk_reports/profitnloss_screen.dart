// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/screens/desk_reports/bottom_sheets/ledger_bill.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../market_watch/tv_chart/resolution_bottom.dart';
import 'bottom_sheets/ledger_filter.dart';
import 'bottom_sheets/pnl_filter.dart';
import 'bottom_sheets/pnl_summary.dart';

enum SingingCharacter { all, eq, fno, com, cur }

class PnlScreen extends StatelessWidget {
  final String ddd;
  const PnlScreen({super.key, required this.ddd});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final ledgerprovider = watch(ledgerProvider);
      bool checkval = ledgerprovider.valforcheck;
      double allnotional = 0.0;
      // double eqnotional = 0.0;
      // double fnonotional = 0.0;
      // double comnotional = 0.0;
      // double curnotional = 0.0;
      if (ledgerprovider.pnlAllData?.transactions != null) {
        for (var val in ledgerprovider.pnlAllData!.transactions!) {
          double amount =
              double.tryParse(val.nOTPROFIT?.toString() ?? '0') ?? 0.0;
          allnotional += amount;
          // if (condition) {
          // if (val.companyCode == 'BSE_CASH' ||
          //     val.companyCode == 'NSE_CASH' ||
          //     val.companyCode == 'MF_BSE' ||
          //     val.companyCode == 'MF_NSE' ||
          //     val.companyCode == 'NSE_SLBM' ||
          //     val.companyCode == 'NSE_SPT') {
          //   double amount1 =
          //       double.tryParse(val.nOTPROFIT?.toString() ?? '0') ?? 0.0;
          //   eqnotional += amount1;
          // } else if (val.companyCode == 'NSE_FNO' ||
          //     val.companyCode == 'BSE_FNO') {
          //   double amount2 =
          //       double.tryParse(val.nOTPROFIT?.toString() ?? '0') ?? 0.0;
          //   fnonotional += amount2;
          // } else if (val.companyCode == 'MCX' ||
          //     val.companyCode == 'NCDEX' ||
          //     val.companyCode == 'NSE_COM' ||
          //     val.companyCode == 'BSE_COM') {
          //   double amount3 =
          //       double.tryParse(val.nOTPROFIT?.toString() ?? '0') ?? 0.0;
          //   comnotional += amount3;
          // } else if (val.companyCode == 'CD_NSE' ||
          //     val.companyCode == 'CD_MCX' ||
          //     val.companyCode == 'CD_USE' ||
          //     val.companyCode == 'CD_BSE') {
          //   double amount4 =
          //       double.tryParse(val.nOTPROFIT?.toString() ?? '0') ?? 0.0;
          //   curnotional += amount4;
          // }
          // }
        }
      }

      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading:  InkWell(
            onTap: () {
              ledgerprovider.falseloader('pnl');
            },
            child: const CustomBackBtn(),
          ),
          elevation: 0.2,
          title: 
           TextWidget.heroText(
              text: "Profit & Loss",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 1),
               
          // leading: InkWell(
          //   onTap: () {

          //   },
          //   child: Icon(Icons.ios_share)),
        ),
        body: TransparentLoaderScreen(
          isLoading: ledgerprovider.pnlloading,
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
              Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth,
                    child: Container(
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget.subText(
                                        text:  ledgerprovider.filterval.toString() ==
                                              'SingingCharacter.all'
                                          ? 'Net Notional'
                                          : ledgerprovider.filterval
                                                      .toString() ==
                                                  'SingingCharacter.eq'
                                              ? 'Equity'
                                              : ledgerprovider.filterval
                                                          .toString() ==
                                                      'SingingCharacter.fno'
                                                  ? 'FNO'
                                                  : ledgerprovider.filterval
                                                              .toString() ==
                                                          'SingingCharacter.com'
                                                      ? 'Commodity'
                                                      : ledgerprovider.filterval
                                                                  .toString() ==
                                                              'SingingCharacter.cur'
                                                          ? 'Currency'
                                                          : "-".toString(),
                                        color: Color(0xFF696969),
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                     
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child:
                                      TextWidget.titleText(
                                          text:
                                               "${allnotional.toStringAsFixed(2)}",
                                          color:   allnotional > 0 ? Colors.green :allnotional 
                                          < 0 ? Colors.red : Colors.black  ,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 1),
                                       
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                      TextWidget.subText(
                                        text: "Charges and Taxes",
                                        color: Color(0xFF696969),
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        fw: 0),
                                     
                                    ledgerprovider.reportsloadingforcharges ==
                                            true
                                        ? Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: SpinKitThreeBounce(
                                              color: Colors.grey,
                                              size: 24,
                                            ),
                                          )
                                        : Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: 
                                            TextWidget.titleText(
                                          text:
                                                "₹ ${ledgerprovider.pnlAllData == null || ledgerprovider.pnlAllData!.expenseAmt == 'null' ? '0.00' : double.parse(ledgerprovider.pnlAllData!.expenseAmt!).toStringAsFixed(2)}",
                                          color:   Colors.red,
                                          textOverflow: TextOverflow.ellipsis,
                                          theme: theme.isDarkMode,
                                          fw: 1),
                                           
                                          )
                                  ],
                                ),
                                // Column(
                                //   crossAxisAlignment: CrossAxisAlignment.end,
                                //   children: [
                                //     Text(
                                //       "Equity",
                                //       textAlign: TextAlign.right,
                                //       style: textStyle(Color(0xFF696969), 14,
                                //           FontWeight.w500),
                                //     ),
                                //     Padding(
                                //       padding: const EdgeInsets.only(top: 8.0),
                                //       child: Text(
                                //         "${eqnotional.toStringAsFixed(2)}",
                                //         style: textStyle(
                                //             Colors.red, 16, FontWeight.w600),
                                //       ),
                                //     )
                                //   ],
                                // ),
                              ],
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       left: 18.0,
                          //       right: 18.0,
                          //       top: 4.0,
                          //       bottom: 18.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Text(
                          //             "FNO",
                          //             style: textStyle(Color(0xFF696969), 14,
                          //                 FontWeight.w500),
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(top: 8.0),
                          //             child: Text(
                          //               "${fnonotional.toStringAsFixed(2)}",
                          //               textAlign: TextAlign.right,
                          //               style: textStyle(colors.colorBlack, 16,
                          //                   FontWeight.w600),
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.end,
                          //         children: [
                          //           Text(
                          //             "Commodity",
                          //             textAlign: TextAlign.right,
                          //             style: textStyle(Color(0xFF696969), 14,
                          //                 FontWeight.w500),
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(top: 8.0),
                          //             child: Text(
                          //               "${comnotional.toStringAsFixed(2)}",
                          //               textAlign: TextAlign.right,
                          //               style: textStyle(
                          //                   Colors.green, 16, FontWeight.w600),
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //       left: 18.0,
                          //       right: 18.0,
                          //       top: 4.0,
                          //       bottom: 18.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Text(
                          //             "Currency",
                          //             style: textStyle(Color(0xFF696969), 14,
                          //                 FontWeight.w500),
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(top: 8.0),
                          //             child: Text(
                          //               "${curnotional.toStringAsFixed(2)}",
                          //               textAlign: TextAlign.right,
                          //               style: textStyle(colors.colorBlack, 16,
                          //                   FontWeight.w600),
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //       Column(
                          //         crossAxisAlignment: CrossAxisAlignment.end,
                          //         children: [
                          //           Text(
                          //             "Charges and Taxes",
                          //             textAlign: TextAlign.right,
                          //             style: textStyle(Color(0xFF696969), 14,
                          //                 FontWeight.w500),
                          //           ),
                          //           Padding(
                          //             padding: const EdgeInsets.only(top: 8.0),
                          //             child: Text(
                          //               "${ledgerprovider.pnlAllData?.expenseAmt  }",
                          //               textAlign: TextAlign.right,
                          //               style: textStyle(
                          //                   Colors.green, 16, FontWeight.w600),
                          //             ),
                          //           )
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),

                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(14.0),
                  //     child: TextField(

                  //       decoration: InputDecoration(
                  //         filled: true,
                  //          fillColor: const Color(0xffF1F3F8),
                  //       hintText: "Search",
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(30.0),
                  //         ),
                  //         focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(30.0),
                  //           borderSide: BorderSide(color:  Colors.grey, width: 2.0),
                  //         ),
                  //         enabledBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(30.0),
                  //           borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  //         ),
                  //         contentPadding: EdgeInsets.symmetric(
                  //           horizontal: 20.0,
                  //           vertical: 15.0,
                  //         ),
                  //         prefixIconColor: const Color(0xff586279),
                  //         prefixIcon: SvgPicture.asset(
                  //           "assets/icon/appbarIcon/search.svg",
                  //           color: const Color(0xff586279),
                  //           fit: BoxFit.scaleDown,
                  //           width: 14,
                  //           height: 14,
                  //         ),
                  //       ),
                  //     ),
                  //   ),

                  // ),
                ],
              ),

              Padding(
                padding:
                    const EdgeInsets.only(right: 16.0, left: 16.0, top: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          ledgerprovider.datePickerStart(context, theme);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Start Date",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    12,
                                    FontWeight.w500)),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                              ),
                              child: Text("${ledgerprovider.startDate}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      11,
                                      FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          ledgerprovider.datePickerEnd(context, theme);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("End Date",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    12,
                                    FontWeight.w500)),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                              ),
                              child: Text("${ledgerprovider.endDate}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      11,
                                      FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                      child: SizedBox(
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
                                ledgerprovider.fetchpnldata(context,
                                    ledgerprovider.startDate,
                                    ledgerprovider.endDate,
                                    ledgerprovider.valforcheck);
                              },
                              child: Text("Get",
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.colorWhite,
                                      12,
                                      FontWeight.w600)))),
                    ),

                    // Container(
                    //     height: 35,
                    //     width: 45,
                    //     margin: const EdgeInsets.only(right: 12, top: 15),
                    //     child: ElevatedButton(
                    //         style: ElevatedButton.styleFrom(
                    //             elevation: 0,
                    //             shadowColor: Colors.transparent,
                    //             backgroundColor: theme.isDarkMode
                    //                 ? colors.colorbluegrey
                    //                 : colors.colorBlack,
                    //             shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(50))),
                    //         onPressed: () async {
                    //           _showBottomSheet(
                    //             context,
                    //             const PnlFliter(),
                    //           );
                    //         },
                    //         child: Text("",
                    //             textAlign: TextAlign.center,
                    //             style: textStyle(
                    //                 !theme.isDarkMode
                    //                     ? colors.colorWhite
                    //                     : colors.colorBlack,
                    //                 12,
                    //                 FontWeight.w500))))
                    InkWell(
                        onTap: ()  {
                          ledgerprovider.setfilterpage = 'pnl';

                          _showBottomSheet(context, LedgerFilter());
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SvgPicture.asset(assets.filterLines,
                              color: theme.isDarkMode
                                  ? const Color(0xffBDBDBD)
                                  : colors.colorGrey),
                        )),
                    SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 14.0),
                      child: IconButton(
                        iconSize: 20,
                        icon: Icon(Icons.download,
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack),
                        onPressed: () => {
                          ledgerprovider.pdfdownloadforpnl(
                              context,
                              ledgerprovider.pnlAllData?.toJson() ?? {},
                              ledgerprovider.startDate,
                              ledgerprovider.endDate,
                              ledgerprovider.filterval.toString() ==
                                      'SingingCharacter.all'
                                  ? 'Net Notional'
                                  : ledgerprovider.filterval.toString() ==
                                          'SingingCharacter.eq'
                                      ? 'Equity'
                                      : ledgerprovider.filterval.toString() ==
                                              'SingingCharacter.fno'
                                          ? 'FNO'
                                          : ledgerprovider.filterval
                                                      .toString() ==
                                                  'SingingCharacter.com'
                                              ? 'Commodity'
                                              : ledgerprovider.filterval
                                                          .toString() == 
                                                      'SingingCharacter.cur'
                                                  ? 'Currency'
                                                  : "-".toString(),
                                                  allnotional.toString(),
                              double.parse(ledgerprovider.pnlAllData!.expenseAmt!).toStringAsFixed(2)), // Ensure expenseAmt is not null
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Row(children: [
                  IconButton(
                      onPressed: () {
                        checkval = !checkval;
                        ledgerprovider.fetchpnldata(context,ledgerprovider.startDate,
                            ledgerprovider.endDate, checkval);
                        //   if (isOco) {
                        //     orderInput.chngAlert("LTP");
                        //     orderInput.chngCond("Less");
                        //     orderInput.chngOCOPriceType(
                        //         "Limit");
                        //     orderInput
                        //         .disableCondGTT(true);
                        //   } else {
                        //     orderInput
                        //         .disableCondGTT(false);
                        //   }
                        // });

                        // context
                        //     .read(ordInputProvider)
                        //     .chngInvesType(
                        //         widget.scripInfo.seg ==
                        //                 "EQT"
                        //             ? InvestType.delivery
                        //             : InvestType
                        //                 .carryForward,
                        //         "OCO");
                      },
                      icon: SvgPicture.asset(theme.isDarkMode
                          ? checkval == false
                              ? assets.darkCheckedboxIcon
                              : assets.darkCheckboxIcon
                          : checkval == true
                              ? assets.checkedbox
                              : assets.checkbox)),
                  Text("With opening balance ",
                      style: textStyle(
                          const Color(0xff666666), 14, FontWeight.w500)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8.0,
                ),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 7.0,
                ),
              ),

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

              ledgerprovider.pnlAllData == null ||
                      ledgerprovider.pnlAllData?.transactions == null
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ))
                  : Expanded(
                      child: SingleChildScrollView(
                        child: ListView.separated(
                          physics: ScrollPhysics(),
                          itemCount:
                              ledgerprovider.pnlAllData?.transactions?.length ??
                                  0,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final pnldata =
                                ledgerprovider.pnlAllData!.transactions![index];
                            return InkWell(
                              onTap: () async {
                                // Handle the onTap event here

                                final pnlval = ledgerprovider
                                    .pnlAllData?.transactions?[index];

                                if (pnlval != null) {
                                  await ledgerprovider.fetchpnlSummary(context,
                                      pnlval.sCRIPSYMBOL ?? '',
                                      pnlval.companyCode ??
                                          '', // Provide a default value
                                      ledgerprovider
                                          .startDate, // Provide a default value
                                      ledgerprovider
                                          .endDate // Provide a default value

                                      // Provide a default value
                                      // Ensure formatted date is not null
                                      );

                                  _showBottomSheet(
                                    context,
                                    const PnlSummarBottom(),
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0,
                                            right: 16.0,
                                            top: 8.0,
                                            bottom: 16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            SizedBox(
                                              width: screenWidth *
                                                  0.65, // Ensures text takes the available width
                                              child:
                                              
                                               TextWidget.subText(
                                        text: "${pnldata.sCRIPSYMBOL}",
                                        color:  theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                        // softWrap:
                                        //             true, // Allows text to wrap
                                                 
                                                maxLines:
                                                    2, // Limits text to 2 lines, change as needed
                                        fw: 0),
                                        
                                          
                                            ),
                                               TextWidget.subText(
                                        text:   "₹ ${(double.tryParse(pnldata.nOTPROFIT ?? '')?.toStringAsFixed(2) ?? '0.00')}",
 // Ensure it doesn’t break if null
                                        color:   (double.tryParse(pnldata
                                                                .nOTPROFIT
                                                                .toString()) ??
                                                            0) >
                                                        0
                                                    ? Colors.green
                                                    : Colors.red,
                                        textOverflow: TextOverflow.ellipsis,
                                        theme: theme.isDarkMode,
                                     
                                                 
                                                
                                        fw: 0),
                                            

                                            // Text((ledgerprovider
                                            //               .ledgerAllData!
                                            //               .fullStat![index]
                                            //               .cRAMT) !=
                                            //           "0.0"
                                            //       ? "Credit : "
                                            //       : "Debit : ",
                                            //     style: textStyle(
                                            //         theme.isDarkMode
                                            //             ? colors.colorWhite
                                            //             : Color(0xFF696969),
                                            //         14,
                                            //         FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(top: 2.0),
                                      //   child: Divider(
                                      //     color: const Color.fromARGB(
                                      //         255, 212, 212, 212),
                                      //     thickness: 0.5,
                                      //   ),
                                      // ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       left: 16.0, right: 16.0, bottom: 8.0),
                                      //   child: Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Row(
                                      //         children: [
                                      //           Text("Buy Qty : ",
                                      //               style: textStyle(
                                      //                   theme.isDarkMode
                                      //                       ? colors.colorWhite
                                      //                       : Color(0xFF696969),
                                      //                   13,
                                      //                   FontWeight.w500)),
                                      //           Text(
                                      //             "${pnldata.bUYQUANTITY}",
                                      //             style: textStyle(Colors.black,
                                      //                 14, FontWeight.w500),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //       Row(
                                      //         children: [
                                      //           Text("Sell Qty : ",
                                      //               style: textStyle(
                                      //                   theme.isDarkMode
                                      //                       ? colors.colorWhite
                                      //                       : Color(0xFF696969),
                                      //                   13,
                                      //                   FontWeight.w500)),
                                      //           Text(
                                      //             "${pnldata.sALEQUANTITY}",
                                      //             style: textStyle(Colors.black,
                                      //                 14, FontWeight.w500),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       left: 16.0, right: 16.0, bottom: 8.0),
                                      //   child: Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Row(
                                      //         children: [
                                      //           Text("Buy Rate : ",
                                      //               style: textStyle(
                                      //                   theme.isDarkMode
                                      //                       ? colors.colorWhite
                                      //                       : Color(0xFF696969),
                                      //                   13,
                                      //                   FontWeight.w500)),
                                      //           Text(
                                      //             "${pnldata.bUYRATE}",
                                      //             style: textStyle(Colors.black,
                                      //                 14, FontWeight.w500),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //       Row(
                                      //         children: [
                                      //           Text("Sell Rate : ",
                                      //               style: textStyle(
                                      //                   theme.isDarkMode
                                      //                       ? colors.colorWhite
                                      //                       : Color(0xFF696969),
                                      //                   13,
                                      //                   FontWeight.w500)),
                                      //           Text(
                                      //             "${pnldata.sALERATE}",
                                      //             style: textStyle(Colors.black,
                                      //                 14, FontWeight.w500),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 2.0,
                                bottom: 8.0,
                              ),
                              child: Divider(
                                color: theme.isDarkMode
                                    ? const Color(0xffB5C0CF).withOpacity(.15)
                                    : const Color(0xffF1F3F8),
                                thickness: 7.0,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    });
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
