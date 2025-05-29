// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class BondsCloseOrderDetails extends ConsumerWidget {
  final BondsOrderBookModel bondsCloseDetails;
  const BondsCloseOrderDetails({
    super.key,
    required this.bondsCloseDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    print("currentDate :: $currentDate");

    final theme = ref.watch(themeProvider);
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
                            bondsCloseDetails.symbol.toString(),
                            style: textStyles.scripNameTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack),
                          ),
                          const SizedBox(height: 5),
                          Text(bondsCloseDetails.symbol.toString(),
                              style: textStyles.scripExchTxtStyle),
                          const SizedBox(height: 16),
                        ],
                      ),
                      //  const SizedBox(width: 5),
                      //  InkWell(
                      //   onTap: (){

                      //   },
                      //   // child:SvgPicture.asset(assets.dInfo),
                      //   child:Text(
                      //       "Info",
                      //       style: textStyle(
                      //           colors.colorBlue, 13, FontWeight.w600),
                      //     ),
                      // ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   "Order Id : ${bondsCloseDetails.applicationNumber != "" ? bondsCloseDetails.applicationNumber.toString() : " - "}",
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
                                  text: bondsCloseDetails.applicationNumber != ""
                                      ? bondsCloseDetails.applicationNumber
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
                          //   bondsCloseDetails.reponseStatus == "cancel success"
                          //       ? "Cancelled"
                          //       : bondsCloseDetails.reponseStatus == "new failed" || bondsCloseDetails.reponseStatus == "failed"
                          //           ? "Failed"
                          //           : "Success",
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
                              bondsCloseDetails.reponseStatus == "success"
                                  ? "assets/icon/failed.svg"
                                  : bondsCloseDetails.reponseStatus ==
                                              "new failed" ||
                                          bondsCloseDetails.reponseStatus ==
                                              "failed"
                                      ? "assets/icon/failed.svg"
                                      : "assets/icon/pendingicon.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            bondsCloseDetails.reponseStatus == "success"
                                ? "Cancelled"
                                : bondsCloseDetails.reponseStatus ==
                                            "new failed" ||
                                        bondsCloseDetails.reponseStatus ==
                                            "failed"
                                    ? "Failed"
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
                          //   bondsCloseDetails.upiPaymentStatus == ""
                          //       ? "Failed"
                          //       : bondsCloseDetails.upiPaymentStatus.toString(),
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
                              bondsCloseDetails.clearingStatus == ""
                                  ? "assets/icon/failed.svg"
                                  : "assets/icon/success.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            bondsCloseDetails.clearingStatus == ""
                                ? "Failed"
                                : bondsCloseDetails.clearingStatus.toString(),
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
                      bondsCloseDetails.failReason == ""
                          ? " - "
                          : bondsCloseDetails.failReason
                              .toString(), //Order cancelled successfully
                      style: textStyle(colors.colorGrey, 13, FontWeight.w500),
                    ),
                  ],
                )),

            // const SizedBox(
            //   height: 10,
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             "Order Id",
            //             style: textStyle(colors.colorGrey, 13, FontWeight.w600),
            //           ),
            //           Text(
            //             bondsCloseDetails.bidReferenceNumber != ""
            //                 ? bondsCloseDetails.bidReferenceNumber.toString()
            //                 : " - ",
            //             style: textStyle(
            //                 theme.isDarkMode
            //                     ? colors.colorWhite
            //                     : colors.colorBlack,
            //                 14,
            //                 FontWeight.w600),
            //           )
            //         ],
            //       ),
            //       Row(
            //         children: [
            //           SvgPicture.asset(bondsCloseDetails.upiPaymentStatus == ""
            //               ? "assets/icon/failed.svg"
            //               : "assets/icon/success.svg"),
            //           const SizedBox(
            //             width: 4,
            //           ),
            //           Text(
            //             bondsCloseDetails.upiPaymentStatus == ""
            //                 ? "Failed"
            //                 : bondsCloseDetails.upiPaymentStatus.toString(),
            //             style: textStyle(
            //                 theme.isDarkMode
            //                     ? colors.colorWhite
            //                     : colors.colorBlack,
            //                 14,
            //                 FontWeight.w600),
            //           ),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // bondsCloseDetails.biddingstartdate // for NSE and BSE
            // bondsCloseDetails.biddingendDate  // for BSE
            // bondsCloseDetails.biddingenddate  // for NSE

            // if (currentDate.isBetween(
            //         convertIpoDates(bondsCloseDetails.biddingstartdate!, "dd-mm-yyyy"),
            //         convertIpoDates(
            //             bondsCloseDetails.type == "BSE"
            //                 ? bondsCloseDetails.biddingendDate!
            //                 : bondsCloseDetails.biddingenddate!,
            //             "dd-mm-yyyy")) ==
            //     true)
            //      ...[
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Row(
            //       // mainAxisAlignment: MainAxisAlignment.spaceAround,
            //       children: [
            //         Expanded(
            //           child: OutlinedButton(
            //               onPressed: () async {
            //                 // await ref.read(ipoProvide).getSmeIpo();
            //                 // await ref.read(ipoProvide).getmainstreamipo();
            //                 await context
            //                     .read(ipoProvide)
            //                     .getipoperfomance(currentYear);
            //                 Navigator.pushNamed(context, Routes.ipo);
            //               },
            //               style: OutlinedButton.styleFrom(
            //                   side: BorderSide(
            //                       width: 1.4,
            //                       color: theme.isDarkMode
            //                           ? colors.colorGrey
            //                           : colors.colorBlack),
            //                   padding:
            //                       const EdgeInsets.symmetric(vertical: 10.5),
            //                   shape: const RoundedRectangleBorder(
            //                       borderRadius:
            //                           BorderRadius.all(Radius.circular(30)))),
            //               child: Padding(
            //                 padding: const EdgeInsets.symmetric(horizontal: 20),
            //                 child: Text("Place New order",
            //                     style: textStyle(
            //                         theme.isDarkMode
            //                             ? colors.colorWhite
            //                             : colors.colorBlack,
            //                         14,
            //                         FontWeight.w600)),
            //               )),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],

            const SizedBox(
              height: 16,
            ),
            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider
            ),
            SizedBox(
              height: 8,
            ),
            data(
                "Order no",
                bondsCloseDetails.orderNumber != null
                    ? bondsCloseDetails.orderNumber!.toString()
                    : " - ",
                theme),
            data("Quantity",   "${(double.parse(bondsCloseDetails.totalAmountPayable!) / bondsCloseDetails.bidDetail!.price!).toStringAsFixed(0)}",
                theme),

            data(
                "Price",
             "${bondsCloseDetails.bidDetail!.price!}",
                theme),

            // data(
            //     "Total amount",
            //     "₹${getFormatter(
            //       noDecimal: true,
            //       v4d: false,
            //       value: double.parse(
            //               bondsCloseDetails.totalAmountPayable!.toString())
            //           .toDouble(),
            //     )}",
            //     theme),
            data(
                "Bid Date & Time",
                bondsCloseDetails.responseDatetime.toString() == ""
                    ? "----"
                    : ipodateres(bondsCloseDetails.responseDatetime.toString()),
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
            //     itemCount: bondsCloseDetails.bidDetail!.length,
            //     physics: const NeverScrollableScrollPhysics(),
            //     shrinkWrap: true,
            //     itemBuilder: (context, index) {
            //       return
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bid Details",
                    style: textStyle(colors.colorGrey, 12, FontWeight.w500),
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //          "₹${getFormatter(
                  //                   noDecimal: true,
                  //                   v4d: false,
                  //                   value: double.parse(bondsCloseDetails.totalAmountPayable!)
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
                  //            "${double.parse(bondsCloseDetails.totalAmountPayable.toString()).toInt()}",
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
                  //            bondsCloseDetails.totalAmountPayable
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
                  //           bondsCloseDetails.totalAmountPayable
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

                  SizedBox(
                    width: double.infinity,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: Colors.transparent,
                        textTheme: const TextTheme(
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
                        border: const TableBorder(
                          horizontalInside:
                              BorderSide(color: Colors.white54, width: 0.8),
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              "Qty",
                              style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Price",
                              style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              "Amount",
                              style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600,
                              ),
                            ),
                          ),
                          // DataColumn(
                          //   label: Text(
                          //     "Cut off",
                          //     style: textStyle(
                          //       theme.isDarkMode
                          //           ? colors.colorWhite
                          //           : colors.colorBlack,
                          //       14,
                          //       FontWeight.w600,
                          //     ),
                          //   ),
                          // ),
                        ],
                        rows: [
                          DataRow(cells: [
                           DataCell(
  Text(
    "${(double.parse(bondsCloseDetails.totalAmountPayable!) / bondsCloseDetails.bidDetail!.price!).toStringAsFixed(0)}",
    style: textStyle(
      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
      12,
      FontWeight.w500,
    ),
  ),
),

                            DataCell(
                              Text(
                                 "${bondsCloseDetails.bidDetail!.price!}",
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
                                "₹${getFormatter(
                                  noDecimal: true,
                                  v4d: false,
                                  value: 
                                          double.parse(bondsCloseDetails.totalAmountPayable!,
                                      
                                ))}",
                                style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  12,
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                            // DataCell(
                            //   Text(
                            //     bondsCloseDetails.totalAmountPayable.toString(),
                            //     style: textStyle(
                            //       theme.isDarkMode
                            //           ? colors.colorWhite
                            //           : colors.colorBlack,
                            //       12,
                            //       FontWeight.w500,
                            //     ),
                            //   ),
                            // ),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  // Divider(
                  //   height: 0,
                  //   color: theme.isDarkMode
                  //       ? colors.darkColorDivider
                  //       : colors.colorDivider,
                  // )
                ],
              ),
            ),
            // }),
            // Padding(
            //   padding: const EdgeInsets.only(top: 8, left: 16, bottom: 5),
            //   child: Text(
            //     "Reason",
            //     style: textStyle(
            //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            //         14,
            //         FontWeight.w600),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 2, left: 16, bottom: 10),
            //   child: Text(
            //     bondsCloseDetails.failReason.toString(),
            //     style: textStyle(colors.colorGrey, 13, FontWeight.w500),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Padding data(String name, String value, ThemesProvider theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                : colors.colorDivider
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
