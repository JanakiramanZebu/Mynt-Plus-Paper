import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../../models/desk_reports_model/pledge_unpledge_model.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../bottom_sheets/pledge_details.dart';
import '../bottom_sheets/pledge_list.dart';

class PledgeFilter extends StatefulWidget {
  final String activetabe;
  final String searchQuery;
  const PledgeFilter(
      {super.key, required this.activetabe, this.searchQuery = ''});

  @override
  State<PledgeFilter> createState() => _PledgeFilterState();
}

class _PledgeFilterState extends State<PledgeFilter>
    with SingleTickerProviderStateMixin {
  // late TabController tabController;
  @override
  // void initState() {
  //   super.initState();
  //   tabController = TabController(length: 3, vsync: this);
  // }

  // @override
  // void dispose() {
  //   tabController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    List<Data> showlist = [];
    List<Tab> orderTabName = [
      Tab(text: "Pledge"),
      Tab(text: "Non-Pledge"),
      Tab(text: "Non-Approved"),
    ];

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      var cashstat = 0.0;
      var noncash = 0.0;
      var pledgedvalue = [];
      final ledgerprovider = ref.watch(ledgerProvider);
      if (ledgerprovider.pledgeandunpledge != null &&
          ledgerprovider.pledgeandunpledge!.data != null) {
        for (var i = 0;
            i < ledgerprovider.pledgeandunpledge!.data!.length;
            i++) {
          final value = ledgerprovider.pledgeandunpledge!.data![i];

          // Check if item matches the current tab filter
          bool matchesTab = false;
          if ((value.initiated == "0" &&
                  value.status == 'Ok' &&
                  (double.parse(value.nSOHQTY.toString()).toInt()) +
                          (double.parse(value.sOHQTY.toString()).toInt()) !=
                      0) &&
              (widget.activetabe == "0")) {
            matchesTab = true;
          } else if (((double.parse(value.cOLQTY.toString()).toInt()) != 0) &&
              widget.activetabe == "1") {
            matchesTab = true;
          } else if (value.status == "Not_ok" &&
              widget.activetabe == "2" &&
              ((double.parse(value.cOLQTY.toString()).toInt()) == 0)) {
            matchesTab = true;
          }

          // If matches tab, check search query
          if (matchesTab) {
            if (widget.searchQuery.isEmpty) {
              showlist.add(value);
            } else {
              // Search in multiple fields
              String searchQuery = widget.searchQuery.toLowerCase();
              String nseSymbol = (value.nSESYMBOL ?? '').toLowerCase();
              String scripName = (value.sCRIPNAME ?? '').toLowerCase();
              String bseSymbol = (value.bSESYMBOL ?? '').toLowerCase();
              String isin = (value.iSIN ?? '').toLowerCase();

              if (nseSymbol.contains(searchQuery) ||
                  scripName.contains(searchQuery) ||
                  bseSymbol.contains(searchQuery) ||
                  isin.contains(searchQuery)) {
                showlist.add(value);
              }
            }
          }
        }
      }

      // print("Tab tapped${showlist.length}") ;
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
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mainpage(ledgerprovider, theme, context, showlist,
                      widget.activetabe),

                  // OrderBook(orderBook: orderBook.allOrder!),

                  // if (ledgerprovider.listforpledge.isNotEmpty)
                  //   Container(
                  //     height: screenheight * 0.07,
                  //     decoration: BoxDecoration(
                  //         color: theme.isDarkMode
                  //             ? const Color(0xffB5C0CF).withOpacity(.15)
                  //             : const Color(0xffF1F3F8)),
                  //   ),
                ],
              ),
              // if (ledgerprovider.listforpledge.isNotEmpty)
              //   Positioned(
              //     bottom: 1,
              //     left: 1,
              //     right: 1,
              //     child: Column(
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Padding(
              //               padding: const EdgeInsets.only(left: 16.0),
              //               child: TextWidget.subText(
              //                   text:
              //                       "You ${showlist.length} Script For ${ledgerprovider.pledgeoruppledgedelete == 'unpledgedelete' ? 'Delete' : ledgerprovider.screenpledge == 'pledge' ? "Pledge" : "Unpledge"}",
              //                   textOverflow: TextOverflow.ellipsis,
              //                   theme: theme.isDarkMode,
              //                   fw: 1),
              //             ),
              //             Row(
              //               children: [
              //                 Padding(
              //                   padding: const EdgeInsets.only(bottom: 12.0),
              //                   child: Container(
              //                       height: 35,
              //                       width: 75,
              //                       margin: const EdgeInsets.only(
              //                           right: 12, top: 15),
              //                       child: ElevatedButton(
              //                           style: ElevatedButton.styleFrom(
              //                               elevation: 0,
              //                               shadowColor: Colors.transparent,
              //                               backgroundColor: theme.isDarkMode
              //                                   ? colors.colorbluegrey
              //                                   : colors.colorBlack,
              //                               shape: RoundedRectangleBorder(
              //                                   borderRadius:
              //                                       BorderRadius.circular(50))),
              //                           onPressed: () {
              //                             ledgerprovider.cancelpledgetotal(
              //                                 ledgerprovider.screenpledge);
              //                             ledgerprovider.changesegvaldummy('');
              //                             // ledgerprovider.screenclickedpledge = '';
              //                           },
              //                           child: Text("Cancel",
              //                               textAlign: TextAlign.center,
              //                               style: textStyle(
              //                                   !theme.isDarkMode
              //                                       ? colors.colorWhite
              //                                       : colors.colorBlack,
              //                                   12,
              //                                   FontWeight.w500)))),
              //                 ),
              //                 Padding(
              //                   padding: const EdgeInsets.only(bottom: 12.0),
              //                   child: Container(
              //                       height: 35,
              //                       width: 75,
              //                       margin: const EdgeInsets.only(
              //                           right: 12, top: 15),
              //                       child: ElevatedButton(
              //                           style: ElevatedButton.styleFrom(
              //                               elevation: 0,
              //                               shadowColor: Colors.transparent,
              //                               backgroundColor: theme.isDarkMode
              //                                   ? colors.colorbluegrey
              //                                   : colors.colorBlack,
              //                               shape: RoundedRectangleBorder(
              //                                   borderRadius:
              //                                       BorderRadius.circular(50))),
              //                           onPressed: () {
              //                             ledgerprovider.changesegvaldummy('');
              //                             print(
              //                                 "${ledgerprovider.pledgeoruppledgedelete} ${ledgerprovider.pledgeorunpledge == 'unpledge'} loakdsdejkvh ");
              //                             if (ledgerprovider
              //                                     .pledgeoruppledgedelete ==
              //                                 'unpledgedelete') {
              //                               print("loakdsdejkvh");
              //                               ledgerprovider.unpldgedeletefun(
              //                                   context,
              //                                   ledgerprovider
              //                                       .pledgeandunpledge!
              //                                       .cLIENTCODE
              //                                       .toString(),
              //                                   showlist);
              //                             } else {
              //                               if (ledgerprovider
              //                                       .pledgeorunpledge ==
              //                                   'unpledge') {
              //                                 ledgerprovider
              //                                     .sendunpledgerequest(
              //                                         context,
              //                                         ledgerprovider
              //                                             .pledgeandunpledge!
              //                                             .cLIENTCODE
              //                                             .toString(),
              //                                         ledgerprovider
              //                                             .pledgeandunpledge!
              //                                             .bOID
              //                                             .toString(),
              //                                         ledgerprovider
              //                                             .pledgeandunpledge!
              //                                             .cLIENTNAME
              //                                             .toString(),
              //                                         ledgerprovider
              //                                             .listforpledge);
              //                               } else if (ledgerprovider
              //                                       .pledgeorunpledge ==
              //                                   'pledge') {
              //                                 _showBottomSheet(
              //                                     context, PledgeList());
              //                               }
              //                             }
              //                           },
              //                           child: Text("Submit",
              //                               textAlign: TextAlign.center,
              //                               style: textStyle(
              //                                   !theme.isDarkMode
              //                                       ? colors.colorWhite
              //                                       : colors.colorBlack,
              //                                   12,
              //                                   FontWeight.w500)))),
              //                 ),
              //               ],
              //             ),
              //           ],
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),
        ),
      );
    });
  }

  _mainpage(LDProvider ledgerprovider, ThemesProvider theme,
      BuildContext context, dataval, String tab) {
    return dataval.length == 0 || dataval.isEmpty
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
                  itemCount: dataval.length ?? 0,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final value = dataval[index];

                    return InkWell(
                      onTap: () {
                        if (widget.activetabe == '0') {
                          if (ledgerprovider.pledgeorunpledge != 'unpledge') {
                            print(double.parse(value.initiated.toString())
                                .toInt());
                            if (double.parse(value.initiated.toString())
                                    .toInt() ==
                                0) {
                              ledgerprovider.screenclickedpledge = 'pledge';
                              String val =
                                  "${double.parse(value.nSOHQTY.toString()).toInt() + double.parse(value.sOHQTY.toString()).toInt()}";
                              String val2 =
                                  "${value.dummvalue != 'null' ? double.parse(value.dummvalue.toString()).toInt() : "null"}";
                              ledgerprovider.setselectnetpledge(
                                  val2 == 'null' ? val : val2,
                                  val2 == 'null' ? val : val2);
                              _showBottomSheet(
                                  context,
                                  PledgeDeytails(
                                    data: value,
                                  ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(context,
                                    '${value.initiated} Qty is processing'),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              warningMessage(context,
                                  'Unpledged initiated so can\'t pledge'),
                            );
                          }
                        } else if (widget.activetabe == '1') {
                          if (value.deleteselected != 'selected' &&
                              value.unPlegeQty == '') {
                            if (ledgerprovider.pledgeorunpledge != 'pledge') {
                              ledgerprovider.screenclickedpledge = 'unpledge';
                              String val =
                                  "${double.parse(value.cOLQTY.toString()).toInt()}";
                              String val2 =
                                  "${value.dummunpledgevalue != 'null' ? double.parse(value.dummunpledgevalue.toString()).toInt() : "null"}";
                              ledgerprovider.setselectnetpledge(
                                  val2 == 'null' ? val : val2,
                                  val2 == 'null' ? val : val2);
                              _showBottomSheet(
                                  context,
                                  PledgeDeytails(
                                    data: value,
                                  ));
                              // ledgerprovider
                              //     .setselectnetpledge(
                              //         "${(double.parse(value.cOLQTY.toString()).toInt())}",
                              //         "${(double.parse(value.cOLQTY.toString()).toInt())}");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(context,
                                    'Pledged initiated so can\'t unpledge'),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              warningMessage(
                                  context, 'Already pledged cant edit'),
                            );
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.55,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.subText(
                                                      align: TextAlign.start,
                                                      text: value.nSESYMBOL ??
                                                          '-',
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textPrimaryDark
                                                          : colors
                                                              .textPrimaryLight,
                                                      fw: 0),
                                                  SizedBox(width: 10.0),
                                                  //         ((((value.cashEqColl!.foCashEq != null
                                                  //                 ? value.cashEqColl!
                                                  //                         .foCashEq ==
                                                  //                     'True'
                                                  //                 : true) &&
                                                  //             (value.cashEqColl!.cdCashEq != null
                                                  //                 ? value.cashEqColl!
                                                  //                         .cdCashEq ==
                                                  //                     'True'
                                                  //                 : true) &&
                                                  //             (value.cashEqColl!.comCashEq !=
                                                  //                     null
                                                  //                 ? value.cashEqColl!
                                                  //                         .comCashEq ==
                                                  //                     'True'
                                                  //                 : true)) &&
                                                  //         value.cOLQTY != '0.000') ||
                                                  //     (((value.cashEqColl!.foCashEq !=
                                                  //                     null
                                                  //                 ? value.cashEqColl!
                                                  //                         .foCashEq ==
                                                  //                     'False'
                                                  //                 : true) &&
                                                  //             (value.cashEqColl!.cdCashEq != null
                                                  //                 ? value.cashEqColl!
                                                  //                         .cdCashEq ==
                                                  //                     'False'
                                                  //                 : true) &&
                                                  //             (value.cashEqColl!
                                                  //                         .comCashEq !=
                                                  //                     null
                                                  //                 ? value.cashEqColl!
                                                  //                         .comCashEq ==
                                                  //                     'False'
                                                  //                 : true)) &&
                                                  //         value.cOLQTY != '0.000'))
                                                  // ?
                                                  tab == "1"
                                                      ? Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 4),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 3),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      5),
                                                              color: theme
                                                                      .isDarkMode
                                                                  ? colors
                                                                      .textSecondaryDark
                                                                      .withOpacity(
                                                                          0.2)
                                                                  : colors
                                                                      .textSecondaryLight
                                                                      .withOpacity(
                                                                          0.1)),
                                                          child:
                                                          
                                                          TextWidget.paraText(
                                                            text:  // ((value.cashEqColl!
                                                              //                     .foCashEq !=
                                                              //                 null
                                                              //             ? value.cashEqColl!
                                                              //                     .foCashEq ==
                                                              //                 'True'
                                                              //             : true) &&
                                                              //         (value.cashEqColl!.cdCashEq != null
                                                              //             ? value.cashEqColl!.cdCashEq ==
                                                              //                 'True'
                                                              //             : true) &&
                                                              //         (value.cashEqColl!.comCashEq != null
                                                              //             ? value.cashEqColl!.comCashEq ==
                                                              //                 'True'
                                                              //             : true))
                                                              //     ? 'Cash'
                                                              //     : 'Non Cash',

                                                              value.status ==
                                                                      'Not_ok'
                                                                  ? 'Un-Approved'
                                                                  : value.cRnc ==
                                                                          'noncash'
                                                                      ? 'Non-Case'
                                                                      : value.cRnc ==
                                                                              'cash'
                                                                          ? 'Case'
                                                                          : '-',
                                                                          theme: false,
                                                                          fw: 0,
                                                                          textOverflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                          color: (value
                                                                          .status ==
                                                                      'Not_ok'
                                                                  ? theme
                                                                          .isDarkMode
                                                                      ? colors
                                                                          .lossDark
                                                                      : colors
                                                                          .lossLight
                                                                  : theme
                                                                          .isDarkMode
                                                                      ? colors
                                                                          .textPrimaryDark
                                                                      : colors
                                                                          .textPrimaryLight
                                                          ) 
                                                          
                                                          
                                                          
                                                          
                                                          ),
                                                        )
                                                      : SizedBox(),
                                                ],
                                              ),
                                              SizedBox(width: 10.0),
                                              (double.parse(value.cOLQTY
                                                                  .toString())
                                                              .toInt()) !=
                                                          0 &&
                                                      widget.activetabe == '0'
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
                                                            String val =
                                                                "${double.parse(value.cOLQTY.toString()).toInt()}";
                                                            String val2 =
                                                                "${value.dummunpledgevalue != 'null' ? double.parse(value.dummunpledgevalue.toString()).toInt() : "null"}";
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
                                                                  data: value,
                                                                ));
                                                            // ledgerprovider
                                                            //     .setselectnetpledge(
                                                            //         "${(double.parse(value.cOLQTY.toString()).toInt())}",
                                                            //         "${(double.parse(value.cOLQTY.toString()).toInt())}");
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
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
                                                      child: Container(
                                                        height: 25,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
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
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      8.0),
                                                          child: Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.lock,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    97,
                                                                    97),
                                                                size: 15.0,
                                                              ),
                                                              TextWidget
                                                                  .captionText(
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
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox()
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                widget.activetabe == '2'
                                    ? Container(
                                        margin:
                                            const EdgeInsets.only(right: 16),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: theme.isDarkMode
                                                ? colors.textSecondaryDark
                                                    .withOpacity(0.2)
                                                : colors.textSecondaryLight
                                                    .withOpacity(0.1)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: TextWidget.titleText(
                                            text:
                                                "${value.dummvalue != 'null' ? "${value.dummvalue!} /" : ''}${(double.parse(value.nSOHQTY.toString()).toInt()) + (double.parse(value.sOHQTY.toString()).toInt())}",
                                            textOverflow: TextOverflow.ellipsis,
                                            theme: theme.isDarkMode,
                                            color: value.dummvalue == 'null'
                                                ? const Color(0xff2F6AD9)
                                                : const Color(0xffFFC107),
                                            fw: 1,
                                          ),
                                        ),
                                      )
                                    : widget.activetabe == '1'
                                        ? (double.parse(value.cOLQTY.toString())
                                                    .toInt()) !=
                                                0
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 8.0),
                                                child: Row(
                                                  children: [
                                                    (double.parse(value.cOLQTY
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
                                                                  String val =
                                                                      "${double.parse(value.cOLQTY.toString()).toInt()}";
                                                                  String val2 =
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
                                                                            value,
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
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          8.0),
                                                              child: TextWidget
                                                                  .titleText(
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
                                                                    : theme
                                                                            .isDarkMode
                                                                        ? colors
                                                                            .lossDark
                                                                        : colors
                                                                            .lossLight,
                                                                fw: 1,
                                                              ),
                                                            ),
                                                          )
                                                        : Text("-"),
                                                    if ((value.unPlegeQty !=
                                                            "0" &&
                                                        value.unPlegeQty != ""))
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
                                                                  right: 16.0),
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
                                                ),
                                              )
                                            : SizedBox()
                                        : widget.activetabe == '0'
                                            ? value.initiated == "0" &&
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
                                                                data: value,
                                                              ));
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
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
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 8),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          color: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .textSecondaryDark
                                                                  .withOpacity(
                                                                      0.2)
                                                              : colors
                                                                  .textSecondaryLight
                                                                  .withOpacity(
                                                                      0.1)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: TextWidget
                                                            .titleText(
                                                          text:
                                                              "${value.dummvalue != 'null' ? "${value.dummvalue!} /" : ''}${(double.parse(value.nSOHQTY.toString()).toInt()) + (double.parse(value.sOHQTY.toString()).toInt())} +",
                                                          textOverflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          theme:
                                                              theme.isDarkMode,
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
                                                : int.tryParse(value.initiated.toString()) != 0 &&
                                                        value.status == 'Ok' &&
                                                        (double.parse(value.nSOHQTY.toString())
                                                                    .toInt()) +
                                                                (double.parse(
                                                                        value.sOHQTY.toString())
                                                                    .toInt()) !=
                                                            0
                                                    ? Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 16),
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            color: const Color
                                                                .fromARGB(255,
                                                                216, 226, 248)),
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
                                                                .fromARGB(255,
                                                                162, 191, 247),
                                                            fw: 1,
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox()
                                            : SizedBox(),
                              ],
                            ),
                            widget.activetabe == '1'
                                ? SizedBox(
                                    height: 8.0,
                                  )
                                : SizedBox(),
                            Row(
                              children: [
                                TextWidget.paraText(
                                    text: (double.parse(value.cOLQTY.toString())
                                                .toInt()) ==
                                            0
                                        ? 'Est : '
                                        : "Mrg : ",
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 0),
                                TextWidget.paraText(
                                    text: (double.parse(value.cOLQTY.toString())
                                                .toInt()) ==
                                            0
                                        ? value.estimated != null
                                            ? "${double.parse(value.estimated.toString()).toStringAsFixed(2)} "
                                            : "0.0"
                                        : value.margin != null
                                            ? "${double.parse(value.margin.toString()).toStringAsFixed(2)} "
                                            : "0.0",
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 0),
                                TextWidget.paraText(
                                    text: value.estimated != null
                                        ? "(${double.parse(value.estPercentage.toString()).toInt()}%)"
                                        : "0.0",
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return ListDivider();
                  },
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
