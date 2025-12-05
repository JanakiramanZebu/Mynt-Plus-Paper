import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/screens/Mobile/authentication/password/forgot_pass_unblock_user.dart';

import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../sharedWidget/no_data_found.dart';

class LedgerBillBottom extends StatefulWidget {
  const LedgerBillBottom({super.key});

  @override
  State<LedgerBillBottom> createState() => _LedgerBillBottomState();
}

class _LedgerBillBottomState extends State<LedgerBillBottom> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ledgerdata = ref.watch(ledgerProvider);
      final theme = ref.read(themeProvider);

      return DraggableScrollableSheet(
        initialChildSize: 0.88,
        minChildSize: .4,
        maxChildSize: .99,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SafeArea(
            child: Container(
             decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                     color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                     border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
            
                     
                    ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const CustomDragHandler(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
                  child: TextWidget.titleText(
                      text: "Bill and Details",
                      textOverflow: TextOverflow.ellipsis,
                      color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 1),
                ),
                ledgerdata.ledgerBillData?.expenses == null
                    ? Center(
                        child: Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: NoDataFound(
                          secondaryEnabled: false,
                        ),
                      ))
                    : Expanded(
                        // height: screenheight * 0.5,
                        child: SingleChildScrollView(
                          physics: ClampingScrollPhysics(),
                           controller: scrollController,
                          child: Column(
                            children: [
                              const ListDivider(),
                              Container(
                                width: screenWidth,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16.0, left: 16.0, right: 16.0),
                                  child: Column(
                                    children: [
                                      for (var item in ledgerdata.ledgerBillData?.expenses ?? [])
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextWidget.subText(
                                                  text: "${item.sCRIPNAME}",
                                                  color:  theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                              TextWidget.subText(
                                                  text: "${item.nETAMT}",
                                                  color: theme.isDarkMode
                                                          ? colors.textPrimaryDark
                                                          : colors.textPrimaryLight,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                  theme: theme.isDarkMode,
                                                  fw: 0),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                                ListDivider(),
                              ListView.separated(
                                physics: ClampingScrollPhysics(),
                                itemCount: ledgerdata
                                    .ledgerBillData!.transactions!.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            TextWidget.subText(
                                                text: ledgerdata
                                                    .ledgerBillData!
                                                    .transactions![index]
                                                    .sCRIPNAME!,
                                                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                theme: theme.isDarkMode,
                                                fw: 0),
                                          ],
                                        ),
                                         SizedBox(height: 8),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.paraText(
                                                      text: "BQty ",
                                                      color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
            
                                                  TextWidget.paraText(
                                                      text:
                                                          "${double.tryParse(ledgerdata.ledgerBillData!.transactions![index].bQTY!)!.toInt()}",
                                                      color: double.tryParse(ledgerdata
                                                                      .ledgerBillData!
                                                                      .transactions![
                                                                          index]
                                                                      .bQTY!)!
                                                                  .toInt() >
                                                              0
                                                          ? theme.isDarkMode
                                                              ? colors.profitDark
                                                              : colors.profitLight
                                                          : double.tryParse(ledgerdata
                                                                          .ledgerBillData!
                                                                          .transactions![
                                                                              index]
                                                                          .bQTY!)!
                                                                      .toInt() <
                                                                  0
                                                              ?  theme.isDarkMode
                                                              ? colors.lossDark
                                                              : colors.lossLight
                                                              : theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
            
                                                  TextWidget.paraText(
                                                      text:
                                                          " @ ₹${double.parse(ledgerdata.ledgerBillData!.transactions![index].bRATE.toString()).toStringAsFixed(2)}",
                                                      color: double.tryParse(ledgerdata
                                                                      .ledgerBillData!
                                                                      .transactions![
                                                                          index]
                                                                      .bQTY!)!
                                                                  .toInt() >
                                                              0
                                                          ? theme.isDarkMode
                                                              ? colors.profitDark
                                                              : colors.profitLight
                                                          : double.tryParse(ledgerdata
                                                                          .ledgerBillData!
                                                                          .transactions![
                                                                              index]
                                                                          .bQTY!)!
                                                                      .toInt() <
                                                                  0
                                                              ?  theme.isDarkMode
                                                              ? colors.lossDark
                                                              : colors.lossLight
                                                              : theme.isDarkMode
                                                              ? colors.textSecondaryDark
                                                              : colors.textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
            
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
                                                  TextWidget.paraText(
                                                      text: "NQty ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                  TextWidget.paraText(
                                                      text:
                                                          "${double.tryParse((double.parse(ledgerdata.ledgerBillData!.transactions![index].bQTY!) - double.parse(ledgerdata.ledgerBillData!.transactions![index].sQTY!)).toString())!.toInt()} ",
                                                      color: theme.isDarkMode
                                                          ? colors.textSecondaryDark
                                                          : colors.textSecondaryLight,
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
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.paraText(
                                                      text: "SQty ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                  TextWidget.paraText(
                                                      text:
                                                          "${double.tryParse(ledgerdata.ledgerBillData!.transactions![index].sQTY.toString())!.toInt()} @ ₹${double.parse(ledgerdata.ledgerBillData!.transactions![index].sRATE.toString()).toStringAsFixed(2)}",
                                                      color: double.tryParse(ledgerdata
                                                                      .ledgerBillData!
                                                                      .transactions![
                                                                          index]
                                                                      .sQTY
                                                                      .toString())!
                                                                  .toInt() >
                                                              0
                                                          ? theme.isDarkMode
                                                              ? colors.lossDark
                                                              : colors.lossLight
                                                          : double.tryParse(ledgerdata
                                                                          .ledgerBillData!
                                                                          .transactions![
                                                                              index]
                                                                          .sQTY
                                                                          .toString())!
                                                                      .toInt() <
                                                                  0
                                                              ? theme.isDarkMode
                                                              ? colors.lossDark
                                                              : colors.lossLight
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .textSecondaryDark
                                                                  : colors
                                                                      .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  TextWidget.paraText(
                                                      text: "NAmt ",
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      textOverflow:
                                                          TextOverflow.ellipsis,
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                  TextWidget.paraText(
                                                      text:
                                                          "₹ ${double.tryParse(ledgerdata.ledgerBillData?.transactions?[index].nETAMT?.toString() ?? "0")?.toStringAsFixed(2) ?? "0.00"}",
                                                      color: theme.isDarkMode
                                                          ? colors.textSecondaryDark
                                                          : colors.textSecondaryLight,
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
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return ListDivider();
                                },
                              )
                            ],
                          ),
                        ),
                      )
              ]),
            ),
          );
        },
      );
    });
  }
}
