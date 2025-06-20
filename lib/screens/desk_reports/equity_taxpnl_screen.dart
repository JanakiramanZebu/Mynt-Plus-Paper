import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

import '../../provider/thems.dart';

class EqTaxpnlEq extends StatefulWidget {
  const EqTaxpnlEq({super.key});

  @override
  State<EqTaxpnlEq> createState() => EqTaxpnl();
}

class EqTaxpnl extends State<EqTaxpnlEq> {
  @override
  void initState() {
    setState(() {
      // _character = context.read(ledgerProvider).filterval;
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final eqtypestring = ref.watch(ledgerProvider).eqtypestring;
      final ledgerprovider = ref.watch(ledgerProvider);

      print("clickvalue${ledgerprovider.eqtypestring}");
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
              Text(
                "Tax P&L",
                style: textStyle(colors.colorBlack, 18, FontWeight.w700),
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
        body: Stack(
          children: [
            TransparentLoaderScreen(
              isLoading: ledgerprovider.taxderloading,
              child: ledgerprovider.taxpnleq?.data == null &&
                      ledgerprovider.taxpnldercomcur?.data == null
                  ? Center(
                      child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ))
                  : SingleChildScrollView(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_left,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack),
                              onPressed: () => {
                                ledgerprovider.fetchtaxpnleqdata(
                                    context, ledgerprovider.yearforTaxpnl - 1),
                                ledgerprovider.chargesforeqtaxpnl(
                                    context, ledgerprovider.yearforTaxpnl - 1)
                              },
                            ),
                            // Center(
                            //   child: Container(
                            //     width: screenWidth * 0.5,
                            //     alignment: Alignment.centerLeft,
                            //     padding: const EdgeInsets.symmetric(
                            //         vertical: 10, horizontal: 10),
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(30),
                            //         color: theme.isDarkMode
                            //             ? const Color(0xffB5C0CF).withOpacity(.15)
                            //             : const Color(0xffF1F3F8)),
                            //     child: Center(
                            //       child:
                            Text("${ledgerprovider.yearforTaxpnl}",
                                textAlign: TextAlign.right,
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w500)),

                            //     ),
                            //   ),
                            // ),
                            IconButton(
                              icon: Icon(Icons.arrow_right,
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack),
                              onPressed: () => {
                                ledgerprovider.fetchtaxpnleqdata(
                                    context, ledgerprovider.yearforTaxpnl + 1),
                                ledgerprovider.chargesforeqtaxpnl(
                                    context, ledgerprovider.yearforTaxpnl + 1),
                              },
                            ),
                          ],
                        ),
                        // Text("${ddd}")
                        // Padding(
                        //     padding: EdgeInsets.only(left: 4.0, top: 10.0),
                        //     child: Text(
                        //       "Financial activities through debits and credits ",
                        //       style: textStyle(colors.colorBlack, 14, FontWeight.w600),
                        //     )),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Equity",
                                style: textStyle(const Color(0xff666666), 15,
                                    FontWeight.w600)),
                          ),
                        ),
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
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Long Term Realized",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider.taxpnleq?.data
                                                              ?.longtermTotal !=
                                                          null &&
                                                      ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .longtermTotal!
                                                          .isNotEmpty)
                                                  ? num.parse(ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .longtermTotal!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              style: textStyle(
                                                  (ledgerprovider.taxpnleq?.data
                                                              ?.longtermTotal !=
                                                          null)
                                                      ? (double.parse(ledgerprovider
                                                                  .taxpnleq!
                                                                  .data!
                                                                  .longtermTotal!) >
                                                              0
                                                          ? Colors.green
                                                          : double.parse(ledgerprovider
                                                                      .taxpnleq!
                                                                      .data!
                                                                      .longtermTotal!) <
                                                                  0
                                                              ? Colors.red
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack)
                                                      : theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                  16,
                                                  FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Short Term Realized",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider.taxpnleq?.data
                                                              ?.shortermTotal !=
                                                          null &&
                                                      ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .shortermTotal!
                                                          .isNotEmpty)
                                                  ? num.parse(ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .shortermTotal!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              style: textStyle(
                                                  (ledgerprovider.taxpnleq?.data
                                                              ?.shortermTotal !=
                                                          null)
                                                      ? (double.parse(ledgerprovider
                                                                  .taxpnleq!
                                                                  .data!
                                                                  .shortermTotal!) >
                                                              0
                                                          ? Colors.green
                                                          : double.parse(ledgerprovider
                                                                      .taxpnleq!
                                                                      .data!
                                                                      .shortermTotal!) <
                                                                  0
                                                              ? Colors.red
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack)
                                                      : theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                  16,
                                                  FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Trading",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider.taxpnleq?.data
                                                              ?.tradingTotal !=
                                                          null &&
                                                      ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .tradingTotal!
                                                          .isNotEmpty)
                                                  ? num.parse(ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .tradingTotal!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                  (ledgerprovider.taxpnleq?.data
                                                              ?.tradingTotal !=
                                                          null)
                                                      ? (double.parse(ledgerprovider
                                                                  .taxpnleq!
                                                                  .data!
                                                                  .tradingTotal!) >
                                                              0
                                                          ? Colors.green
                                                          : double.parse(ledgerprovider
                                                                      .taxpnleq!
                                                                      .data!
                                                                      .tradingTotal!) <
                                                                  0
                                                              ? Colors.red
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack)
                                                      : theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                  16,
                                                  FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Assets",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider.taxpnleq?.data
                                                              ?.assetsTotal !=
                                                          null &&
                                                      ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .assetsTotal!
                                                          .isNotEmpty)
                                                  ? num.parse(ledgerprovider
                                                          .taxpnleq!
                                                          .data!
                                                          .assetsTotal!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                  (ledgerprovider.taxpnleq?.data
                                                              ?.assetsTotal !=
                                                          null)
                                                      ? (double.parse(ledgerprovider
                                                                  .taxpnleq!
                                                                  .data!
                                                                  .assetsTotal!) >
                                                              0
                                                          ? Colors.green
                                                          : double.parse(ledgerprovider
                                                                      .taxpnleq!
                                                                      .data!
                                                                      .assetsTotal!) <
                                                                  0
                                                              ? Colors.red
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack)
                                                      : theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                  16,
                                                  FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Trading Turnover",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                (ledgerprovider.taxpnleq?.data
                                                                ?.tradingTurnover !=
                                                            null &&
                                                        ledgerprovider
                                                            .taxpnleq!
                                                            .data!
                                                            .tradingTurnover!
                                                            .isNotEmpty)
                                                    ? num.parse(ledgerprovider
                                                            .taxpnleq!
                                                            .data!
                                                            .tradingTurnover!)
                                                        .toStringAsFixed(2)
                                                    : "0.00",
                                                textAlign: TextAlign.right,
                                                style: textStyle(
                                                  (ledgerprovider.taxpnleq?.data
                                                              ?.tradingTurnover !=
                                                          null)
                                                      ? (double.parse(ledgerprovider
                                                                  .taxpnleq!
                                                                  .data!
                                                                  .tradingTurnover!) >
                                                              0
                                                          ? Colors.green
                                                          : double.parse(ledgerprovider
                                                                      .taxpnleq!
                                                                      .data!
                                                                      .tradingTurnover!) <
                                                                  0
                                                              ? Colors.red
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .colorWhite
                                                                  : colors
                                                                      .colorBlack)
                                                      : theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                  16,
                                                  FontWeight.w600,
                                                ),
                                              ))
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Total Charges",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: ledgerprovider
                                                        .reportsloadingforcharges ==
                                                    true
                                                ? CircularProgressIndicator()
                                                : Text(
                                                    "${ledgerprovider.taxpnleqCharge?.total ?? 0.00}",
                                                    textAlign: TextAlign.right,
                                                    style: textStyle(Colors.red,
                                                        16, FontWeight.w600),
                                                  ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Derivative",
                                style: textStyle(const Color(0xff666666), 15,
                                    FontWeight.w600)),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Futures",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.derivatives
                                                              ?.derFutPnl ??
                                                          "0.0")
                                                      ?.toStringAsFixed(2)) ??
                                                  "0.00",
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.derivatives
                                                            ?.derFutPnl !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .derivatives!
                                                                .derFutPnl!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .derivatives!
                                                                    .derFutPnl!) <
                                                                0
                                                            ? Colors.red
                                                            : (theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack))
                                                    : (theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack),
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Futures Turnover",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.derivatives
                                                              ?.derFutTo ??
                                                          "0.0")
                                                      ?.toStringAsFixed(2)) ??
                                                  "0.00",
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.derivatives
                                                            ?.derFutTo !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .derivatives!
                                                                .derFutTo!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .derivatives!
                                                                    .derFutTo!) <
                                                                0
                                                            ? Colors.red
                                                            : (theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack))
                                                    : (theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack),
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Options",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.derivatives
                                                              ?.derOptPnl ??
                                                          "0.0")
                                                      ?.toStringAsFixed(2)) ??
                                                  "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.derivatives
                                                            ?.derOptPnl !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .derivatives!
                                                                .derOptPnl!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .derivatives!
                                                                    .derOptPnl!) <
                                                                0
                                                            ? Colors.red
                                                            : (theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack))
                                                    : (theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack),
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Options Turnover",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.derivatives
                                                              ?.derOptTo ??
                                                          "0.0")
                                                      ?.toStringAsFixed(2)) ??
                                                  "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.derivatives
                                                            ?.derOptTo !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .derivatives!
                                                                .derOptTo!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .derivatives!
                                                                    .derOptTo!) <
                                                                0
                                                            ? Colors.red
                                                            : (theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack))
                                                    : (theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack),
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Total Charges",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.charges
                                                              ?.derChargesTotal
                                                              ?.toString() ??
                                                          "0.0")
                                                      ?.toStringAsFixed(2)) ??
                                                  "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(Colors.red, 16,
                                                  FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Commodity",
                                style: textStyle(const Color(0xff666666), 15,
                                    FontWeight.w600)),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Futures",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider
                                                          .taxpnldercomcur
                                                          ?.data
                                                          ?.commodity
                                                          ?.commFutPnl !=
                                                      null)
                                                  ? double.parse(ledgerprovider
                                                          .taxpnldercomcur!
                                                          .data!
                                                          .commodity!
                                                          .commFutPnl!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.commodity
                                                            ?.commFutPnl !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .commodity!
                                                                .commFutPnl!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .commodity!
                                                                    .commFutPnl!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Futures Turnover",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider
                                                          .taxpnldercomcur
                                                          ?.data
                                                          ?.commodity
                                                          ?.commFutTo !=
                                                      null)
                                                  ? double.parse(ledgerprovider
                                                          .taxpnldercomcur!
                                                          .data!
                                                          .commodity!
                                                          .commFutTo!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.commodity
                                                            ?.commFutTo !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .commodity!
                                                                .commFutTo!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .commodity!
                                                                    .commFutTo!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Options",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider
                                                          .taxpnldercomcur
                                                          ?.data
                                                          ?.commodity
                                                          ?.commOptPnl !=
                                                      null)
                                                  ? double.parse(ledgerprovider
                                                          .taxpnldercomcur!
                                                          .data!
                                                          .commodity!
                                                          .commOptPnl!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.commodity
                                                            ?.commOptPnl !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .commodity!
                                                                .commOptPnl!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .commodity!
                                                                    .commOptPnl!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Options Turnover",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider
                                                          .taxpnldercomcur
                                                          ?.data
                                                          ?.commodity
                                                          ?.commOptTo !=
                                                      null)
                                                  ? double.parse(ledgerprovider
                                                          .taxpnldercomcur!
                                                          .data!
                                                          .commodity!
                                                          .commOptTo!)
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.commodity
                                                            ?.commOptTo !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .commodity!
                                                                .commOptTo!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .commodity!
                                                                    .commOptTo!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Total Charges",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (ledgerprovider
                                                          .taxpnldercomcur
                                                          ?.data
                                                          ?.charges
                                                          ?.commChargesTotal !=
                                                      null)
                                                  ? double.parse(ledgerprovider
                                                          .taxpnldercomcur!
                                                          .data!
                                                          .charges!
                                                          .commChargesTotal
                                                          .toString())
                                                      .toStringAsFixed(2)
                                                  : "0.00",
                                              textAlign: TextAlign.right,
                                              style: textStyle(Colors.red, 16,
                                                  FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Currency",
                                style: textStyle(const Color(0xff666666), 15,
                                    FontWeight.w600)),
                          ),
                        ),
                        Container(
                          width: screenWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.isDarkMode
                                  ? const Color(0xffB5C0CF).withOpacity(.15)
                                  : const Color(0xffF1F3F8),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Futures",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.currency
                                                              ?.currFutPnl ??
                                                          '0.0')
                                                      ?.toStringAsFixed(2)) ??
                                                  '0.00',
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.currency
                                                            ?.currFutPnl !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .currency!
                                                                .currFutPnl!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .currency!
                                                                    .currFutPnl!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Futures Turnover",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.currency
                                                              ?.currFutTo ??
                                                          '0.0')
                                                      ?.toStringAsFixed(2)) ??
                                                  '0.00',
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.currency
                                                            ?.currFutTo !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .currency!
                                                                .currFutTo!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .currency!
                                                                    .currFutTo!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Options",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.currency
                                                              ?.currOptPnl ??
                                                          '0.0')
                                                      ?.toStringAsFixed(2)) ??
                                                  '0.00',
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.currency
                                                            ?.currOptPnl !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .currency!
                                                                .currOptPnl!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .currency!
                                                                    .currOptPnl!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Options Turnover",
                                            textAlign: TextAlign.right,
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.currency
                                                              ?.currOptTo ??
                                                          '0.0')
                                                      ?.toStringAsFixed(2)) ??
                                                  '0.00',
                                              textAlign: TextAlign.right,
                                              style: textStyle(
                                                (ledgerprovider
                                                            .taxpnldercomcur
                                                            ?.data
                                                            ?.currency
                                                            ?.currOptTo !=
                                                        null)
                                                    ? (double.parse(ledgerprovider
                                                                .taxpnldercomcur!
                                                                .data!
                                                                .currency!
                                                                .currOptTo!) >
                                                            0
                                                        ? Colors.green
                                                        : double.parse(ledgerprovider
                                                                    .taxpnldercomcur!
                                                                    .data!
                                                                    .currency!
                                                                    .currOptTo!) <
                                                                0
                                                            ? Colors.red
                                                            : theme.isDarkMode
                                                                ? colors
                                                                    .colorWhite
                                                                : colors
                                                                    .colorBlack)
                                                    : theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                16,
                                                FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      top: 4.0,
                                      bottom: 18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Total Charges",
                                            style: textStyle(Color(0xFF696969),
                                                14, FontWeight.w500),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              (double.tryParse(ledgerprovider
                                                              .taxpnldercomcur
                                                              ?.data
                                                              ?.charges
                                                              ?.curChargesTotal
                                                              ?.toString() ??
                                                          '0.0')
                                                      ?.toStringAsFixed(2)) ??
                                                  '0.00',
                                              textAlign: TextAlign.right,
                                              style: textStyle(Colors.red, 16,
                                                  FontWeight.w600),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                        //               style: textStyle(theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack, 14, FontWeight.w600),
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

                        // Padding(
                        //   padding:
                        //       const EdgeInsets.only(right: 15, left: 15, bottom: 15.0),
                        //   child: SingleChildScrollView(
                        //     scrollDirection: Axis.horizontal,
                        //     child: Row(
                        //       children: [
                        //         tabsbutton('Asserts', ledgerprovider, theme),
                        //         tabsbutton('Liabilities', ledgerprovider, theme),
                        //         tabsbutton('Short Term', ledgerprovider, theme),
                        //         tabsbutton('Long Term', ledgerprovider, theme),

                        //       ],
                        //     ),
                        //   ),
                        // ),

                        // (ledgerprovider.taxpnleq == null ||  ledgerprovider.taxpnleq!.data == null)
                        //     ? Center(
                        //         child: Padding(
                        //         padding: EdgeInsets.only(top: 60),
                        //         child: NoDataFound(),
                        //       ))
                        //     : Expanded(
                        //         child: SingleChildScrollView(
                        //           child: ListView.builder(
                        //               physics: ScrollPhysics(),
                        //               itemCount: ledgerprovider.taxpnleqselectedtabdata ==
                        //                       null
                        //                   ? 0
                        //                   : ledgerprovider.taxpnleqselectedtabdata.length,
                        //               shrinkWrap: true,
                        //               itemBuilder: (context, index) {
                        //                 return Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: [
                        //                     Padding(
                        //                       padding: const EdgeInsets.only(
                        //                           right: 30.0, left: 30.0, top: 25.0),
                        //                       child: Text(
                        //                         "${ledgerprovider.taxpnleqselectedtabdata[index].sCRIPNAMEDATA}",
                        //                         style: textStyle(
                        //                             theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack, 14, FontWeight.w700),
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding: const EdgeInsets.only(
                        //                           right: 30.0, left: 30.0, top: 10.0),
                        //                       child: Divider(
                        //                         color: const Color.fromARGB(
                        //                             255, 117, 117, 117),
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding: const EdgeInsets.only(
                        //                           right: 30.0, left: 30.0, top: 10.0),
                        //                       child: Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.spaceBetween,
                        //                         children: [
                        //                           Row(
                        //                             children: [
                        //                               Text(
                        //                                 "Net Qty : ",
                        //                                 style: textStyle(
                        //                                     Color(0xFF696969),
                        //                                     13,
                        //                                     FontWeight.w500),
                        //                               ),
                        //                               Text(
                        //                                 "${ledgerprovider.taxpnleqselectedtabdata[index].nETAMOUNT}",
                        //                                 style: textStyle(theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack, 14,
                        //                                     FontWeight.w500),
                        //                               ),
                        //                             ],
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding: const EdgeInsets.only(
                        //                           right: 30.0, left: 30.0, top: 10.0),
                        //                       child: Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.spaceBetween,
                        //                         children: [
                        //                           Row(
                        //                             children: [
                        //                               Text(
                        //                                 "Buy Qty : ",
                        //                                 style: textStyle(
                        //                                     Color(0xFF696969),
                        //                                     13,
                        //                                     FontWeight.w500),
                        //                               ),
                        //                               Text(
                        //                                 "${ledgerprovider.taxpnleqselectedtabdata[index].bUYQTY}",
                        //                                 style: textStyle(theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack, 14,
                        //                                     FontWeight.w500),
                        //                               ),
                        //                             ],
                        //                           ),
                        //                           Row(
                        //                             children: [
                        //                               Row(
                        //                                 children: [
                        //                                   Text(
                        //                                     "Sell Qty : ",
                        //                                     style: textStyle(
                        //                                         Color(0xFF696969),
                        //                                         13,
                        //                                         FontWeight.w500),
                        //                                   ),
                        //                                   Text(
                        //                                     "${ledgerprovider.taxpnleqselectedtabdata[index].sALEQTY}",
                        //                                     style: textStyle(
                        //                                       theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack,
                        //                                       14,
                        //                                       FontWeight.w500,
                        //                                     ),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                             ],
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding: const EdgeInsets.only(
                        //                           right: 30.0, left: 30.0, top: 10.0),
                        //                       child: Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment.spaceBetween,
                        //                         children: [
                        //                           Row(
                        //                             children: [
                        //                               Row(
                        //                                 children: [
                        //                                   Text(
                        //                                     "Buy Rate : ",
                        //                                     style: textStyle(
                        //                                         Color(0xFF696969),
                        //                                         13,
                        //                                         FontWeight.w500),
                        //                                   ),
                        //                                   Text(
                        //                                     "${ledgerprovider.taxpnleqselectedtabdata[index].bUYRATE}",
                        //                                     style: textStyle(
                        //                                       theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack,
                        //                                       14,
                        //                                       FontWeight.w500,
                        //                                     ),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                             ],
                        //                           ),
                        //                           Row(
                        //                             children: [
                        //                               Row(
                        //                                 children: [
                        //                                   Text(
                        //                                     "Sell Rate : ",
                        //                                     style: textStyle(
                        //                                         Color(0xFF696969),
                        //                                         13,
                        //                                         FontWeight.w500),
                        //                                   ),
                        //                                   Text(
                        //                                     "${ledgerprovider.taxpnleqselectedtabdata[index].sALERATE}",
                        //                                     style: textStyle(
                        //                                       theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack,
                        //                                       14,
                        //                                       FontWeight.w500,
                        //                                     ),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                             ],
                        //                           ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                     Padding(
                        //                       padding: const EdgeInsets.only(top: 10),
                        //                       child: Divider(
                        //                         color: const Color.fromARGB(
                        //                             255, 212, 212, 212),
                        //                         thickness: 2.0,
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 );
                        //               }),
                        //         ),
                        //       ),

                        // Padding(
                        //   padding: const EdgeInsets.only(top: 120),
                        //   child: Center(
                        //     child: Column(children: [
                        //       // SvgPicture.asset(assets.noDatafound,
                        //       //     color: theme.isDarkMode
                        //       //         ? colors.darkColorDivider
                        //       //         : colors.colorDivider),
                        //       // const SizedBox(height: 2),
                        //       IconButton(
                        //         icon: Icon(Icons.download, color: theme.isDarkMode
                        // ? colors.colorWhite
                        // : colors.colorBlack),
                        //         onPressed: () => {},
                        //       ),
                        //       Text("Here you can download your ",
                        //           style: textStyle(const Color(0xff777777), 14,
                        //               FontWeight.w500)),
                        //       Padding(
                        //         padding: const EdgeInsets.only(top: 4.0),
                        //         child: Text("Tax p&l data",
                        //             style: textStyle(
                        //                 Color.fromARGB(255, 119, 119, 119),
                        //                 14,
                        //                 FontWeight.w500)),
                        //       )
                        //     ]),
                        //   ),
                        // )
                        const SizedBox(height: 65.0),
                      ],
                    )),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                  height: 35,
                  width: 65,
                  margin: const EdgeInsets.only(right: 12, top: 15),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: theme.isDarkMode
                              ? colors.colorbluegrey
                              : colors.colorBlack,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50))),
                      onPressed: () async {
                        ledgerprovider.pdfdownloadfortaxpnl(
                            context,
                            ledgerprovider.taxpnleq?.data?.toJson() ?? {},
                            ledgerprovider.taxpnldercomcur?.data?.toJson() ??
                                {},
                            ledgerprovider.taxpnleqCharge?.toJson() ?? {},
                            ledgerprovider.yearforTaxpnl);
                      },
                      child: Text("Download",
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

  tabsbutton(String text, LDProvider ledgerprovider, ThemesProvider theme) {
    if ((ledgerprovider.taxpnleq?.data!.aSSETS != null && text == 'Asserts') ||
        (ledgerprovider.taxpnleq?.data!.lIABILITIES != null &&
            text == 'Liabilities') ||
        (ledgerprovider.taxpnleq?.data!.sHORTTERM != null &&
            text == 'Short Term') ||
        (ledgerprovider.taxpnleq?.data!.tRADING != null &&
            text == 'Long Term')) {
      return Container(
          height: 35,
          margin: const EdgeInsets.only(right: 12, top: 15),
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor:
                      theme.isDarkMode || ledgerprovider.eqtypestring != text
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                setState(() {
                  // Ensure UI rebuilds when selection changes
                  ledgerprovider.clickedvalue = text;
                  ledgerprovider.taxpnleqselectedtab(text);
                });
              },
              child: Text("${text}",
                  textAlign: TextAlign.center,
                  style: textStyle(
                      !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w500))));
    } else {
      // print("${ledgerprovider.taxpnleq?.data!.aSSETS}");
      return SizedBox();
    }
  }

  headingstat(String heading, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "${heading}",
            style: textStyle(Color(0xFF696969), 14, FontWeight.w400),
          ),
          Text(
            "${value}",
            style: textStyle(colors.colorBlack, 13, FontWeight.w500),
          )
        ],
      ),
    );
  }
}
