import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/authentication/password/forgot_pass_unblock_user.dart';

import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';

class LedgerBillBottom extends StatefulWidget {
  const LedgerBillBottom({super.key});

  @override
  State<LedgerBillBottom> createState() => _LedgerBillBottomState();
}

class _LedgerBillBottomState extends State<LedgerBillBottom> {
  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ledgerdata = watch(ledgerProvider);

      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: .4,
        maxChildSize: .99,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.isDarkMode
                    ? Color.fromARGB(255, 0, 0, 0)
                    : Color.fromARGB(255, 255, 255, 255)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: const Color.fromARGB(255, 219, 218, 218),
                    width: 40,
                    height: 4.0,
                    padding: EdgeInsets.only(
                        top: 10, bottom: 25, left: 20, right: 20),
                    margin: EdgeInsets.only(top: 16),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                child: TextWidget.heroText(
                    text: "Bill and Details",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 1),
              ),
              ledgerdata.ledgerBillData!.expenses == null
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ))
                  : Expanded(
                      // height: screenheight * 0.5,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              width: screenWidth,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.15)
                                        : const Color(0xffF1F3F8)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, left: 16.0, right: 16.0),
                                  child: Column(
                                    children: [
                                      for (var item in ledgerdata
                                                  .ledgerBillData!.expenses! !=
                                              null
                                          ? ledgerdata.ledgerBillData!.expenses!
                                          : [])
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextWidget.subText(
                                                  text: "${item.sCRIPNAME}",
                                                  color: Color(0xFF696969),
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  text: "${item.nETAMT}",
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 1),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ListView.separated(
                              physics: ScrollPhysics(),
                              itemCount: ledgerdata
                                  .ledgerBillData!.transactions!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,vertical : 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0),
                                            child: TextWidget.subText(
                                                text: ledgerdata
                                                    .ledgerBillData!
                                                    .transactions![index]
                                                    .sCRIPNAME!,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 1),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: const Color.fromARGB(
                                            255, 212, 212, 212),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 4.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    text: "BQty : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),

                                                TextWidget.subText(
                                                    text:
                                                        " ${double.tryParse(ledgerdata.ledgerBillData!.transactions![index].bQTY!)!.toInt()}",
                                                    color: double.tryParse(ledgerdata
                                                                    .ledgerBillData!
                                                                    .transactions![
                                                                        index]
                                                                    .bQTY!)!
                                                                .toInt() >
                                                            0
                                                        ? Colors.green
                                                        : double.tryParse(ledgerdata
                                                                        .ledgerBillData!
                                                                        .transactions![
                                                                            index]
                                                                        .bQTY!)!
                                                                    .toInt() <
                                                                0
                                                            ? Colors.red
                                                            : Colors.black,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),

                                                TextWidget.subText(
                                                    text:
                                                        " @ ₹${double.parse(ledgerdata.ledgerBillData!.transactions![index].bRATE.toString()).toStringAsFixed(2)}",
                                                    color: double.tryParse(ledgerdata
                                                                    .ledgerBillData!
                                                                    .transactions![
                                                                        index]
                                                                    .bQTY!)!
                                                                .toInt() >
                                                            0
                                                        ? Colors.green
                                                        : double.tryParse(ledgerdata
                                                                        .ledgerBillData!
                                                                        .transactions![
                                                                            index]
                                                                        .bQTY!)!
                                                                    .toInt() <
                                                                0
                                                            ? Colors.red
                                                            : Colors.black,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),

                                                // Text(
                                                //   ("${ledgerdata.ledgerBillData!.transactions![index].bAMT}"
                                                //                ) ,
                                                //   style: textStyle(
                                                //     double.tryParse(ledgerdata
                                                //                     .ledgerBillData!
                                                //                     .transactions![index]
                                                //                     .bAMT ??
                                                //                 "0")! <
                                                //             0
                                                //         ? Colors.red // Red for less than 0
                                                //         : Colors
                                                //             .green, // Green for greater than or equal to 0
                                                //     14,
                                                //     FontWeight.w500,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    text: "NQty :  ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    text:
                                                        "${double.tryParse((double.parse(ledgerdata.ledgerBillData!.transactions![index].bQTY!) - double.parse(ledgerdata.ledgerBillData!.transactions![index].sQTY!)).toString())!.toInt()} ",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    text: "SQty : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    text:
                                                        " ${double.tryParse(ledgerdata.ledgerBillData!.transactions![index].sQTY.toString())!.toInt()} @ ₹${double.parse(ledgerdata.ledgerBillData!.transactions![index].sRATE.toString()).toStringAsFixed(2)}",
                                                    color:double.tryParse(ledgerdata.ledgerBillData!.transactions![index].sQTY.toString())!.toInt() > 0 ? Colors.red : double.tryParse(ledgerdata.ledgerBillData!.transactions![index].sQTY.toString())!.toInt() < 0 ?Colors.red : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
                                                    
                                                 
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextWidget.subText(
                                                    text: "NAmt : ",
                                                    color: Color(0xFF696969),
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 0),
                                                TextWidget.subText(
                                                    text:
                                                        "₹ ${double.tryParse(ledgerdata.ledgerBillData?.transactions?[index].nETAMT?.toString() ?? "0")?.toStringAsFixed(2) ?? "0.00"}",
                                                    color: theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4.0,
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
                            )
                          ],
                        ),
                      ),
                    )
            ]),
          );
        },
      );
    });
  }
}
