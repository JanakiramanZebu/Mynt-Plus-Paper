// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/bonds/bonds_orderbook_screen/bond_cancel_alert/bonds_cancel_alert.dart';
import 'package:mynt_plus/screens/ipo/ipo_cancel_alert/cancel_alert.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';

class BondsOpenOrderDetails extends ConsumerWidget {
  final BondsOrderBookModel bondsdetails;
  const BondsOpenOrderDetails({
    super.key,
    required this.bondsdetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    // final upi = ref.watch(transcationProvider);
    return Scaffold(
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          // leadingWidth: 41,
          titleSpacing: -8,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_back_ios,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  size: 22,
                ),
              ),
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("Order Details",
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  16,
                  FontWeight.w600))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bondsdetails.symbol.toString(),
                            style: textStyles.scripNameTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack),
                          ),
                          const SizedBox(height: 5),
                          Text(bondsdetails.symbol.toString(),
                              style: textStyles.scripExchTxtStyle),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Order Id : ${bondsdetails.applicationNumber != "" ? bondsdetails.applicationNumber.toString() : " - "}",
                          //   style: textStyle(
                          //       colors.colorGrey, 14, FontWeight.w600),
                          // ),

                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Order Id : ",
                                  style: textStyle(
                                      colors.colorGrey, 14, FontWeight.w600),
                                ),
                                TextSpan(
                                  text: bondsdetails.applicationNumber != ""
                                      ? bondsdetails.applicationNumber
                                          .toString()
                                      : " - ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      12,
                                      FontWeight.w600),
                                ),
                              ],
                            ),
                          ),

                          // Text(
                          //   bondsdetails.reponseStatus == "new success"
                          //       ? "Success"
                          //       : "Pending",
                          //   style: textStyle(
                          //       theme.isDarkMode
                          //           ? colors.colorWhite
                          //           : colors.colorBlack,
                          //       14,
                          //       FontWeight.w600),
                          // )
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                              bondsdetails.reponseStatus == "success"
                                  ? "assets/icon/success.svg"
                                  : "assets/icon/pendingicon.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            bondsdetails.reponseStatus == "success"
                                ? "Success"
                                : "Pending",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment",
                            style: textStyle(
                                colors.colorGrey, 14, FontWeight.w600),
                          ),
                          // Text(
                          //   bondsdetails.upiPaymentStatus == ""
                          //       ? "Pending"
                          //       : bondsdetails.upiPaymentStatus.toString(),
                          //   style: textStyle(
                          //       theme.isDarkMode
                          //           ? colors.colorWhite
                          //           : colors.colorBlack,
                          //       14,
                          //       FontWeight.w600),
                          // )
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(bondsdetails.clearingStatus == ""
                              ? "assets/icon/pendingicon.svg"
                              : "assets/icon/success.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            bondsdetails.clearingStatus == ""
                                ? "Pending"
                                : bondsdetails.clearingStatus.toString(),
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            // const SizedBox(
            //   height: 10,
            // ),

            Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reason",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      bondsdetails.failReason == ""
                          ? "Order placed successfully"
                          : bondsdetails.failReason.toString(),
                      style: textStyle(colors.colorGrey, 14, FontWeight.w500),
                    ),
                  ],
                )),

            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return BondCancelAlert(
                                    bondcancel: bondsdetails);
                              });
                        },
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 1.4,
                                color: theme.isDarkMode
                                    ? colors.colorGrey
                                    : colors.colorBlack),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text("Cancel Order",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600)),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            SizedBox(
              height: 8,
            ),
            data(
                "Order no",
                bondsdetails.orderNumber != null
                    ? bondsdetails.orderNumber!.toString()
                    : " - ",
                theme),
            data(
                "Quantity",
                "${(double.parse(bondsdetails.totalAmountPayable!) / bondsdetails.bidDetail!.price!).toStringAsFixed(0)}",
                theme),

            data("Price", "${bondsdetails.bidDetail!.price!}", theme),

            data(
                "Total amount",
                "₹${getFormatter(
                  noDecimal: true,
                  v4d: false,
                  value:
                      double.parse(bondsdetails.totalAmountPayable!.toString())
                          .toDouble(),
                )}",
                theme),
            data(
                "Bid Date & Time",
                bondsdetails.responseDatetime.toString() == ""
                    ? "----"
                    : ipodateres(bondsdetails.responseDatetime.toString()),
                theme),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                "Bid order Details",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
            ),
            // ListView.builder(
            //     itemCount: bondsdetails.bidDetail!.length,
            //     physics: const NeverScrollableScrollPhysics(),
            // shrinkWrap: true,
            // itemBuilder: (context, index) {
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bid Details",
                    style: textStyle(colors.colorGrey, 12, FontWeight.w500),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: Colors.transparent,
                        textTheme: TextTheme(
                            bodyMedium: TextStyle(color: Colors.white)),
                        dataTableTheme: const DataTableThemeData(
                          headingTextStyle: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                          dataTextStyle: TextStyle(color: Colors.white),
                          dividerThickness: 1.0,
                        ),
                      ),
                      child: DataTable(
                        columnSpacing: 16.0,
                        horizontalMargin: 0,
                        headingRowHeight: 40.0,
                        border: TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.white54, width: 0.8),
                        ),
                        columns: [
                          DataColumn(
                              label: Text("Qty",
                                  style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600,
                                  ))),

                          DataColumn(
                              label: Text("Price",
                                  style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600,
                                  ))),
                          DataColumn(
                              label: Text("Amount",
                                  style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600,
                                  ))),

                          // DataColumn(
                          //     label: Text("Cut off",
                          //         style: textStyle(
                          //           theme.isDarkMode
                          //               ? colors.colorWhite
                          //               : colors.colorBlack,
                          //           14,
                          //           FontWeight.w600,
                          //         ))),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(
                              Text(
                                "${(double.parse(bondsdetails.totalAmountPayable!) / bondsdetails.bidDetail!.price!).toStringAsFixed(0)}",
                                style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  12,
                                  FontWeight.w500,
                                ),
                              ),
                            ),

                            DataCell(
                              Text(
                                "${bondsdetails.bidDetail!.price!}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    12,
                                    FontWeight.w500),
                              ),
                            ),

                            DataCell(
                              Text(
                                "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(
                                      bondsdetails.totalAmountPayable!,
                                    ))}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    12,
                                    FontWeight.w500),
                              ),
                            ),
                            // DataCell(
                            //   Text(
                            //     bondsdetails.totalAmountPayable.toString(),
                            //     style: textStyle(
                            //         theme.isDarkMode
                            //             ? colors.colorWhite
                            //             : colors.colorBlack,
                            //         14,
                            //         FontWeight.w600),
                            //   ),
                            // ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "₹${getFormatter(
                  //                   noDecimal: true,
                  //                   v4d: false,
                  //                   value: double.parse(bondsdetails.totalAmountPayable!)
                  //                       .toDouble(),
                  //                 )}",
                  //           style: textStyle(
                  //               theme.isDarkMode
                  //                   ? colors.colorWhite
                  //                   : colors.colorBlack,
                  //               14,
                  //               FontWeight.w600),
                  //         ),
                  //         const SizedBox(height: 2),
                  //         Text(
                  //           "Amount",
                  //           style: textStyle(
                  //               colors.colorGrey, 13, FontWeight.w500),
                  //         ),
                  //       ],
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //          "${double.parse(bondsdetails.totalAmountPayable.toString()).toInt()}",
                  //           style: textStyle(
                  //               theme.isDarkMode
                  //                   ? colors.colorWhite
                  //                   : colors.colorBlack,
                  //               14,
                  //               FontWeight.w600),
                  //         ),
                  //         const SizedBox(height: 2),
                  //         Text(
                  //           "Price",
                  //           style: textStyle(
                  //               colors.colorGrey, 13, FontWeight.w500),
                  //         ),
                  //       ],
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           bondsdetails.totalAmountPayable!
                  //               .toString(),
                  //           style: textStyle(
                  //               theme.isDarkMode
                  //                   ? colors.colorWhite
                  //                   : colors.colorBlack,
                  //               14,
                  //               FontWeight.w600),
                  //         ),
                  //         const SizedBox(height: 2),
                  //         Text(
                  //           "Quantity",
                  //           style: textStyle(
                  //               colors.colorGrey, 13, FontWeight.w500),
                  //         ),
                  //       ],
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //            bondsdetails.totalAmountPayable
                  //                   .toString(),
                  //           style: textStyle(
                  //               theme.isDarkMode
                  //                   ? colors.colorWhite
                  //                   : colors.colorBlack,
                  //               14,
                  //               FontWeight.w600),
                  //         ),
                  //         const SizedBox(height: 2),
                  //         Text(
                  //           "Cut off",
                  //           style: textStyle(
                  //               colors.colorGrey, 13, FontWeight.w500),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  //  const SizedBox(
                  //    height: 8,
                  //  ),
                  //  Divider(
                  //    height: 0,
                  //    color: theme.isDarkMode
                  //        ? colors.darkColorDivider
                  //        : colors.colorDivider,
                  //  )
                ],
              ),
            ),
            // }
            // ),
          ],
        ),
      ),
    );
  }

  Padding data(String name, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
              Text(
                value,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500),
              )
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Divider(
            height: 0,
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
          )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
