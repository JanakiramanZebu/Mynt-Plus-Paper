import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/snack_bar.dart';
import 'bottom_sheets/pledge_details.dart';
import 'bottom_sheets/pledge_list.dart';

class PledgenUnpledge extends StatelessWidget {
  final String ddd;
  const PledgenUnpledge({super.key, required this.ddd});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      var cashstat = 0.0;
      var noncash = 0.0;
      var pledgedvalue = [];
      final ledgerprovider = ref.watch(ledgerProvider);
      Future<void> _refresh() async {
        await Future.delayed(Duration(seconds: 0)); // simulate refresh delay
        print("refresh ");
        ledgerprovider.getCurrentDate("pandu");
        ledgerprovider.fetchpledgeandunpledge(context);
      }
      // if (ledgerprovider.pledgeandunpledge?.data != null) {
      //   for (var i = 0;
      //       i < ledgerprovider.pledgeandunpledge!.data!.length;
      //       i++) {
      //     if (double.tryParse(ledgerprovider.pledgeandunpledge!.data![i].cOLQTY
      //                 .toString())!
      //             .toInt() >
      //         0) {
      //       pledgedvalue.add(ledgerprovider.pledgeandunpledge!.data![i].cOLQTY);
      //       print("${pledgedvalue} pledgedvaluepledgedvalue");
      //     }
      //     print(
      //         "${double.tryParse(ledgerprovider.pledgeandunpledge!.data![i].cOLQTY.toString())!.toInt()} ledgerprovider.pledgeandunpledge!.data![i].plegeQtyefeefefeefe");

      //     if ((ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq ==
      //                 'True'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq ==
      //                 'True'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq ==
      //                 'True'
      //             : true)) {
      //       cashstat += (ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   'nan' &&
      //               ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   '')
      //           ? (double.tryParse(ledgerprovider
      //                   .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS
      //                   .toString()) ??
      //               0.0)
      //           : 0.0;
      //     }
      //     if ((ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.foCashEq ==
      //                 'False'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.cdCashEq ==
      //                 'False'
      //             : true) &&
      //         (ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq !=
      //                 null
      //             ? ledgerprovider
      //                     .pledgeandunpledge!.data![i].cashEqColl!.comCashEq ==
      //                 'False'
      //             : true)) {
      //       noncash += (ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   'nan' &&
      //               ledgerprovider
      //                       .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS !=
      //                   '')
      //           ? (double.tryParse(ledgerprovider
      //                   .pledgeandunpledge!.data![i].nETVALUEAFTRLIMITS
      //                   .toString()) ??
      //               0.0)
      //           : 0.0;
      //     }
      //   }
      // }

      final List<dynamic> displaypledgedvalue = pledgedvalue;

      return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: const CustomBackBtn(),
          elevation: 0.2,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.heroText(
                  text: "Pledge and Unpledge",
                  textOverflow: TextOverflow.ellipsis,
                  theme: theme.isDarkMode,
                  fw: 1),
              IconButton(
                  onPressed: () async {
                    await ledgerprovider.fetchunpledgehistory(context);
                    ledgerprovider.fetchpledgehistory(context);
                    ledgerprovider.taxpnlExTabchange(0);
                    Navigator.pushNamed(context, Routes.pledgehistorymainscreen,
                        arguments: "DDDDD");
                  },
                  icon: const Icon(Icons.history))
            ],
          ),

          // leading: InkWell(
          //   onTap: () {

          //   },
          //   child: Icon(Icons.ios_share)),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Stack(
            children: [
              TransparentLoaderScreen(
                isLoading: ledgerprovider.pledgeloader,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headingstat(
                                      "Total value",
                                      '${ledgerprovider.pledgeandunpledge?.stocksValue ?? 0}',
                                      theme,
                                      "left"),
                                  headingstat(
                                      "Est/Ava Mrg",
                                      " ${ledgerprovider.pledgeandunpledge?.marginTotalAvailable ?? 0} / ${ledgerprovider.pledgeandunpledge?.estTotalAvailable ?? 0}",
                                      theme,
                                      "right"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16.0, bottom: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headingstat(
                                      "Cash Equivalent ",
                                      "${ledgerprovider.pledgeandunpledge?.cashEquivalent ?? 0}",
                                      theme,
                                      "left"),
                                  headingstat(
                                      "Total/Pledged",
                                      "${ledgerprovider.pledgeandunpledge?.noOfStocks ?? 0} / ${displaypledgedvalue.length}",
                                      theme,
                                      "right"),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, right: 16.0, bottom: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  headingstat(
                                      "Cash Equivalent ",
                                      "${ledgerprovider.pledgeandunpledge?.noncashEquivalent ?? 0}",
                                      theme,
                                      "left"),
                                  headingstat(
                                      "Non-approved",
                                      '${ledgerprovider.pledgeandunpledge?.noOfNonApprovedStocks ?? 0}',
                                      theme,
                                      "right"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(
                    //     top: 2.0,
                    //     bottom: 0.0,
                    //   ),
                    //   child: Divider(
                    //     color: theme.isDarkMode
                    //         ? const Color(0xffB5C0CF).withOpacity(.15)
                    //         : const Color(0xffF1F3F8),
                    //     thickness: 7.0,
                    //   ),
                    // ),

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

                    ledgerprovider.pledgeandunpledge == null ||
                            ledgerprovider.pledgeandunpledge?.data == null
                        // Handle the null or empty case
                        ? Center(
                            child: Padding(
                            padding: EdgeInsets.only(top: 60),
                            child: NoDataFound(),
                          ))
                        : Expanded(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: ListView.separated(
                                  physics: ScrollPhysics(),
                                  itemCount: ledgerprovider
                                          .pledgeandunpledge?.data?.length ??
                                      0,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    final value = ledgerprovider
                                        .pledgeandunpledge!.data![index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, top: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: screenWidth * 0.55,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextWidget.subText(
                                                            align:
                                                                TextAlign.start,
                                                            text: value
                                                                    .nSESYMBOL ??
                                                                '-',
                                                            textOverflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            theme: theme
                                                                .isDarkMode,
                                                            color: theme
                                                                    .isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack,
                                                            fw: 1),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Row(
                                                      children: [
                                                        value.status == "Not_ok"
                                                            ? Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            4),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical:
                                                                        3),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                2),
                                                                    color: const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            236,
                                                                            214,
                                                                            214)
                                                                        .withOpacity(
                                                                            .3)),
                                                                child: Text(
                                                                    "Non-Approved",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style: textStyle(
                                                                        const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            255,
                                                                            60,
                                                                            60),
                                                                        10,
                                                                        FontWeight
                                                                            .w500)),
                                                              )
                                                            : SizedBox(),
                                                        ((((value.cashEqColl!
                                                                                    .foCashEq !=
                                                                                null
                                                                            ? value.cashEqColl!.foCashEq ==
                                                                                'True'
                                                                            : true) &&
                                                                        (value.cashEqColl!.cdCashEq !=
                                                                                null
                                                                            ? value.cashEqColl!.cdCashEq ==
                                                                                'True'
                                                                            : true) &&
                                                                        (value.cashEqColl!.comCashEq !=
                                                                                null
                                                                            ? value.cashEqColl!.comCashEq ==
                                                                                'True'
                                                                            : true)) &&
                                                                    value.cOLQTY !=
                                                                        '0.000') ||
                                                                (((value.cashEqColl!.foCashEq !=
                                                                                null
                                                                            ? value.cashEqColl!.foCashEq ==
                                                                                'False'
                                                                            : true) &&
                                                                        (value.cashEqColl!.cdCashEq != null
                                                                            ? value.cashEqColl!.cdCashEq ==
                                                                                'False'
                                                                            : true) &&
                                                                        (value.cashEqColl!.comCashEq !=
                                                                                null
                                                                            ? value.cashEqColl!.comCashEq ==
                                                                                'False'
                                                                            : true)) &&
                                                                    value.cOLQTY !=
                                                                        '0.000'))
                                                            ? Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            4),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical:
                                                                        3),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    color: value.cRnc ==
                                                                            'noncash'
                                                                        ? const Color(
                                                                            0xff007B7B)
                                                                        : const Color(
                                                                            0xff2069BB)),
                                                                child: Text(
                                                                    ((value.cashEqColl!.foCashEq != null ? value.cashEqColl!.foCashEq == 'True' : true) &&
                                                                            (value.cashEqColl!.cdCashEq != null
                                                                                ? value.cashEqColl!.cdCashEq ==
                                                                                    'True'
                                                                                : true) &&
                                                                            (value.cashEqColl!.comCashEq != null
                                                                                ? value.cashEqColl!.comCashEq ==
                                                                                    'True'
                                                                                : true))
                                                                        ? 'Cash'
                                                                        : 'Non Cash',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style: textStyle(
                                                                        const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255),
                                                                        10,
                                                                        FontWeight
                                                                            .w500)),
                                                              )
                                                            : SizedBox(),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              value.initiated == "0" &&
                                                      value.status == 'Ok' &&
                                                      (double.parse(value.nSOHQTY.toString())
                                                                  .toInt()) +
                                                              (double.parse(value
                                                                      .sOHQTY
                                                                      .toString())
                                                                  .toInt()) !=
                                                          0
                                                  ? InkWell(
                                                      onTap: () {
                                                        print(
                                                            "${ledgerprovider.pledgeorunpledge} fdaedfaefwef");
                                                        if (ledgerprovider
                                                                .pledgeorunpledge !=
                                                            'unpledge') {
                                                          print(double.parse(value
                                                                  .initiated
                                                                  .toString())
                                                              .toInt());
                                                          if (double.parse(value
                                                                      .initiated
                                                                      .toString())
                                                                  .toInt() ==
                                                              0) {
                                                            ledgerprovider
                                                                    .screenclickedpledge =
                                                                'pledge';
                                                            String val =
                                                                "${double.parse(value.nSOHQTY.toString()).toInt() + double.parse(value.sOHQTY.toString()).toInt()}";
                                                            String val2 =
                                                                "${value.dummvalue != 'null' ? double.parse(value.dummvalue.toString()).toInt() : "null"}";
                                                            ledgerprovider
                                                                .setselectnetpledge(
                                                                    val2 == 'null'
                                                                        ? val
                                                                        : val2,
                                                                    val2 == 'null'
                                                                        ? val
                                                                        : val2);
                                                            _showBottomSheet(
                                                                context,
                                                                PledgeDeytails(
                                                                  data: index,
                                                                ));
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              warningMessage(
                                                                  context,
                                                                  '${value.initiated} Qty is processing'),
                                                            );
                                                          }
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            warningMessage(
                                                                context,
                                                                'Unpledged initiated so can\'t pledge'),
                                                          );
                                                        }
                                                        // ledgerprovider
                                                        //     .changesegval("");
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 16),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            color: value.dummvalue ==
                                                                    'null'
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    211,
                                                                    225,
                                                                    255)
                                                                : const Color(
                                                                    0xffF6EFD9)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: TextWidget
                                                              .subText(
                                                            text:
                                                                "${value.dummvalue != 'null' ? "${value.dummvalue!} /" : ''} ${(double.parse(value.nSOHQTY.toString()).toInt()) + (double.parse(value.sOHQTY.toString()).toInt())} +",
                                                            textOverflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            theme: theme
                                                                .isDarkMode,
                                                            color: value.dummvalue ==
                                                                    'null'
                                                                ? const Color(
                                                                    0xff2F6AD9)
                                                                : const Color(
                                                                    0xffFFC107),
                                                            fw: 1,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : int.tryParse(value.initiated
                                                                  .toString()) !=
                                                              0 &&
                                                          value.status ==
                                                              'Ok' &&
                                                          (double.parse(value.nSOHQTY.toString())
                                                                      .toInt()) +
                                                                  (double.parse(
                                                                          value.sOHQTY.toString())
                                                                      .toInt()) !=
                                                              0
                                                      ? Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 16),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  216,
                                                                  226,
                                                                  248)),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: TextWidget
                                                                .subText(
                                                              text:
                                                                  "${(double.parse(value.nSOHQTY.toString()).toInt()) + (double.parse(value.sOHQTY.toString()).toInt())} / ${value.initiated} +",
                                                              textOverflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              theme: theme
                                                                  .isDarkMode,
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  162,
                                                                  191,
                                                                  247),
                                                              fw: 1,
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Divider(
                                            color: const Color.fromARGB(
                                                255, 212, 212, 212),
                                            thickness: 0.5,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 16.0, right: 16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                      text: "Qty :  ",
                                                      color: Color(0xFF696969),
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                  TextWidget.subText(
                                                      text:
                                                          "${double.parse(value.nET.toString()).toInt()}",
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 1),

                                                  //         Text(
                                                  // " (${value.tRADEDATE})",
                                                  // style: textStyle(
                                                  //     theme.isDarkMode
                                                  //         ? colors.colorWhite
                                                  //         : colors.colorBlack,
                                                  //     12,
                                                  //     FontWeight.w600)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      TextWidget.subText(
                                                          text: "Value : ",
                                                          color:
                                                              Color(0xFF696969),
                                                          textOverflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 0),
                                                      TextWidget.subText(
                                                          text: value.aMOUNT !=
                                                                  null
                                                              ? double.parse(value
                                                                      .aMOUNT
                                                                      .toString())
                                                                  .toStringAsFixed(
                                                                      2)
                                                              : "0.0",
                                                          color: theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          textOverflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 1),
                                                    ],
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
                                              top: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Row(
                                                    children: [
                                                      TextWidget.subText(
                                                          text: (double.parse(value
                                                                          .cOLQTY
                                                                          .toString())
                                                                      .toInt()) ==
                                                                  0
                                                              ? 'Est : '
                                                              : "Mrg : ",
                                                          color:
                                                              Color(0xFF696969),
                                                          textOverflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 0),
                                                      TextWidget.subText(
                                                          text: (double.parse(value
                                                                          .cOLQTY
                                                                          .toString())
                                                                      .toInt()) ==
                                                                  0
                                                              ? value.estimated !=
                                                                      null
                                                                  ? "${double.parse(value.estimated.toString()).toStringAsFixed(2)} "
                                                                  : "0.0"
                                                              : value.margin !=
                                                                      null
                                                                  ? "${double.parse(value.margin.toString()).toStringAsFixed(2)} "
                                                                  : "0.0",
                                                          color: theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          textOverflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 1),
                                                      TextWidget.captionText(
                                                          text: value.estimated !=
                                                                  null
                                                              ? "(${double.parse(value.estPercentage.toString()).toInt()}%)"
                                                              : "0.0",
                                                          color: theme.isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          textOverflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          theme:
                                                              theme.isDarkMode,
                                                          fw: 0),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              (double.parse(value.cOLQTY
                                                              .toString())
                                                          .toInt()) !=
                                                      0
                                                  ? Row(
                                                      children: [
                                                        TextWidget.subText(
                                                            text:
                                                                "Pledged Qty : ",
                                                            color: Color(
                                                                0xFF696969),
                                                            textOverflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            theme: theme
                                                                .isDarkMode,
                                                            fw: 0),
                                                        (double.parse(value
                                                                        .cOLQTY
                                                                        .toString())
                                                                    .toInt()) !=
                                                                0
                                                            ? InkWell(
                                                                onTap: () {
                                                                  print(
                                                                      "${ledgerprovider.pledgeorunpledge} fdaedfaefwef");
                                                                  if (value.deleteselected !=
                                                                          'selected' &&
                                                                      value.unPlegeQty ==
                                                                          '') {
                                                                    if (ledgerprovider
                                                                            .pledgeorunpledge !=
                                                                        'pledge') {
                                                                      ledgerprovider
                                                                              .screenclickedpledge =
                                                                          'unpledge';
                                                                      String
                                                                          val =
                                                                          "${double.parse(value.cOLQTY.toString()).toInt()}";
                                                                      String
                                                                          val2 =
                                                                          "${value.dummunpledgevalue != 'null' ? double.parse(value.dummunpledgevalue.toString()).toInt() : "null"}";
                                                                      ledgerprovider.setselectnetpledge(
                                                                          val2 == 'null'
                                                                              ? val
                                                                              : val2,
                                                                          val2 == 'null'
                                                                              ? val
                                                                              : val2);
                                                                      _showBottomSheet(
                                                                          context,
                                                                          PledgeDeytails(
                                                                            data:
                                                                                index,
                                                                          ));
                                                                      // ledgerprovider
                                                                      //     .setselectnetpledge(
                                                                      //         "${(double.parse(value.cOLQTY.toString()).toInt())}",
                                                                      //         "${(double.parse(value.cOLQTY.toString()).toInt())}");
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        warningMessage(
                                                                            context,
                                                                            'Pledged initiated so can\'t unpledge'),
                                                                      );
                                                                    }
                                                                  } else {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      warningMessage(
                                                                          context,
                                                                          'Already pledged cant edit'),
                                                                    );
                                                                  }

                                                                  print(
                                                                      "value.cOLQTY.toString() ${value.cOLQTY.toString()}");
                                                                },
                                                                child:
                                                                    Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                      color: value.dummunpledgevalue !=
                                                                                  'null' ||
                                                                              value.deleteselected ==
                                                                                  'selected'
                                                                          ? const Color(
                                                                              0xffF6EFD9)
                                                                          : const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              196,
                                                                              196)),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child: TextWidget
                                                                        .paraText(
                                                                      text:
                                                                          "${(value.unPlegeQty != "0" && value.unPlegeQty != "") ? "${value.unPlegeQty! + " /"} " : value.dummunpledgevalue != 'null' ? "${value.dummunpledgevalue!} /" : ''} ${(double.parse(value.cOLQTY.toString()).toInt())} -",
                                                                      textOverflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      theme: theme
                                                                          .isDarkMode,
                                                                      color: value.dummunpledgevalue !=
                                                                                  'null' ||
                                                                              value.deleteselected ==
                                                                                  'selected'
                                                                          ? const Color(
                                                                              0xffFFC107)
                                                                          : const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              97,
                                                                              97),
                                                                      fw: 1,
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : Text("-"),
                                                        if ((value.unPlegeQty !=
                                                                "0" &&
                                                            value.unPlegeQty !=
                                                                ""))
                                                          InkWell(
                                                            onTap: () {
                                                              ledgerprovider
                                                                  .unpledgedeletereqfun(
                                                                      context,
                                                                      value.iSIN
                                                                          .toString(),
                                                                      index);
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          8.0),
                                                              child: SvgPicture
                                                                  .asset(assets
                                                                      .cancelledIcon),
                                                            ),
                                                          )
                                                        // TextWidget.subText(
                                                        //     text:
                                                        //         "${(double.parse(value.cOLQTY.toString()).toInt()) > 0 ? (double.parse(value.cOLQTY.toString()).toInt()) : ''} ",
                                                        //     color: theme.isDarkMode
                                                        //         ? colors.colorWhite
                                                        //         : colors.colorBlack,
                                                        //     textOverflow:
                                                        //         TextOverflow.ellipsis,
                                                        //     theme: theme.isDarkMode,
                                                        //     fw: 1),

                                                        //         Text(
                                                        // " (${value.tRADEDATE})",
                                                        // style: textStyle(
                                                        //     theme.isDarkMode
                                                        //         ? colors.colorWhite
                                                        //         : colors.colorBlack,
                                                        //     12,
                                                        //     FontWeight.w600)),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: 2.0,
                                        bottom: 0.0,
                                      ),
                                      child: Divider(
                                        color: theme.isDarkMode
                                            ? const Color(0xffB5C0CF)
                                                .withOpacity(.15)
                                            : const Color(0xffF1F3F8),
                                        thickness: 7.0,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                    if (ledgerprovider.listforpledge.length > 0)
                      Container(
                        height: screenheight * 0.07,
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? const Color(0xffB5C0CF).withOpacity(.15)
                                : const Color(0xffF1F3F8)),
                      ),
                  ],
                ),
              ),
              if (ledgerprovider.listforpledge.length > 0)
                Positioned(
                  bottom: 1,
                  left: 1,
                  right: 1,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: TextWidget.subText(
                                text:
                                    "You ${ledgerprovider.listforpledge.length} Script For ${ledgerprovider.pledgeoruppledgedelete == 'unpledgedelete' ? 'Delete' : ledgerprovider.screenpledge == 'pledge' ? "Pledge" : "Unpledge"}",
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 1),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                    height: 35,
                                    width: 75,
                                    margin: const EdgeInsets.only(
                                        right: 12, top: 15),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            backgroundColor: theme.isDarkMode
                                                ? colors.colorbluegrey
                                                : colors.colorBlack,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50))),
                                        onPressed: () {
                                          ledgerprovider.cancelpledgetotal(
                                              ledgerprovider.screenpledge);
                                          ledgerprovider.changesegvaldummy('');
                                          // ledgerprovider.screenclickedpledge = '';
                                        },
                                        child: Text("Cancel",
                                            textAlign: TextAlign.center,
                                            style: textStyle(
                                                !theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                12,
                                                FontWeight.w500)))),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                    height: 35,
                                    width: 75,
                                    margin: const EdgeInsets.only(
                                        right: 12, top: 15),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            elevation: 0,
                                            shadowColor: Colors.transparent,
                                            backgroundColor: theme.isDarkMode
                                                ? colors.colorbluegrey
                                                : colors.colorBlack,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50))),
                                        onPressed: () {
                                          ledgerprovider.changesegvaldummy('');
                                          print(
                                              "${ledgerprovider.pledgeoruppledgedelete} ${ledgerprovider.pledgeorunpledge == 'unpledge'} loakdsdejkvh ");
                                          if (ledgerprovider
                                                  .pledgeoruppledgedelete ==
                                              'unpledgedelete') {
                                            print("loakdsdejkvh");
                                            ledgerprovider.unpldgedeletefun(
                                                context,
                                                ledgerprovider
                                                    .pledgeandunpledge!
                                                    .cLIENTCODE
                                                    .toString(),
                                                ledgerprovider.listforpledge);
                                          } else {
                                            if (ledgerprovider
                                                    .pledgeorunpledge ==
                                                'unpledge') {
                                              ledgerprovider
                                                  .sendunpledgerequest(
                                                      context,
                                                      ledgerprovider
                                                          .pledgeandunpledge!
                                                          .cLIENTCODE
                                                          .toString(),
                                                      ledgerprovider
                                                          .pledgeandunpledge!
                                                          .bOID
                                                          .toString(),
                                                      ledgerprovider
                                                          .pledgeandunpledge!
                                                          .cLIENTNAME
                                                          .toString(),
                                                      ledgerprovider
                                                          .listforpledge);
                                            } else if (ledgerprovider
                                                    .pledgeorunpledge ==
                                                'pledge') {
                                              _showBottomSheet(
                                                  context, PledgeList());
                                            }
                                          }
                                        },
                                        child: Text("Submit",
                                            textAlign: TextAlign.center,
                                            style: textStyle(
                                                !theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                12,
                                                FontWeight.w500)))),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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

  int getDisplayQty(dynamic value) {
    final unPledge = int.tryParse(value.unPlegeQty.toString()) ?? 0;
    final nsoh = int.tryParse(value.nSOHQTY.toString()) ?? 0;
    final soh = int.tryParse(value.sOHQTY.toString()) ?? 0;

    if (unPledge > 0) return unPledge;
    if (nsoh > 0) return nsoh;
    if (soh > 0) return soh;

    return 0;
  }

  headingstat(String heading, String value, theme, String side) {
    return Column(
      crossAxisAlignment:
          side == 'right' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
            text: heading,
            color: Color(0xFF696969),
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
        // Text(
        //   "Opening Balance",
        //   style: textStyle(Color(0xFF696969), 14,
        //       FontWeight.w500),
        // ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextWidget.titleText(
              text: "₹ $value",
              textOverflow: TextOverflow.ellipsis,
              theme: theme.isDarkMode,
              fw: 1),
        ),
      ],
    );
  }
}
