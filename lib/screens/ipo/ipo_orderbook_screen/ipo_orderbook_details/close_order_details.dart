// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class IpoCloseOrderDetails extends ConsumerWidget {
  final IpoOrderBookModel ipoclose;
  const IpoCloseOrderDetails({
    super.key,
    required this.ipoclose,
  });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    int currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    print("currentDate :: $currentDate");

    final theme = watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: .2,
        centerTitle: false,
        // leadingWidth: 40,
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
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                size: 22,
              ),
            ),
          ),
        ),

        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        shadowColor: const Color(0xffECEFF3),
        title: Text(
          "Order Details",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              16,
              FontWeight.w600),
        ),
      ),
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
                            ipoclose.companyName.toString(),
                            style: textStyles.scripNameTxtStyle.copyWith(
                                color: theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack),
                          ),
                          const SizedBox(height: 4),
                          Text(ipoclose.symbol.toString(),
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
                          Text(
                            "Order Id : ${ipoclose.bidReferenceNumber != "" ? ipoclose.bidReferenceNumber.toString() : " - "}",
                            style: textStyle(
                                colors.colorGrey, 14, FontWeight.w600),
                          ),
                          // Text(
                          //   ipoclose.reponseStatus == "cancel success"
                          //       ? "Cancelled"
                          //       : ipoclose.reponseStatus == "new failed" || ipoclose.reponseStatus == "failed"
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                              ipoclose.reponseStatus == "cancel success"
                                  ? "assets/icon/failed.svg"
                                  : ipoclose.reponseStatus == "new failed" ||
                                          ipoclose.reponseStatus == "failed"
                                      ? "assets/icon/failed.svg"
                                      : "assets/icon/pendingicon.svg"),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            ipoclose.reponseStatus == "cancel success"
                                ? "Cancelled"
                                : ipoclose.reponseStatus == "new failed" ||
                                        ipoclose.reponseStatus == "failed"
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
                          //   ipoclose.upiPaymentStatus == ""
                          //       ? "Failed"
                          //       : ipoclose.upiPaymentStatus.toString(),
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
                          SvgPicture.asset(ipoclose.upiPaymentStatus == ""
                              ? "assets/icon/failed.svg"
                              : "assets/icon/success.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            ipoclose.upiPaymentStatus == ""
                                ? "Failed"
                                : ipoclose.upiPaymentStatus.toString(),
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
                padding: const EdgeInsets.all(16),
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
                      ipoclose.failReason == ""
                          ? " - "
                          : ipoclose.failReason
                              .toString(), //Order cancelled successfully
                      style: textStyle(colors.colorGrey, 14, FontWeight.w500),
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
            //             ipoclose.bidReferenceNumber != ""
            //                 ? ipoclose.bidReferenceNumber.toString()
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
            //           SvgPicture.asset(ipoclose.upiPaymentStatus == ""
            //               ? "assets/icon/failed.svg"
            //               : "assets/icon/success.svg"),
            //           const SizedBox(
            //             width: 4,
            //           ),
            //           Text(
            //             ipoclose.upiPaymentStatus == ""
            //                 ? "Failed"
            //                 : ipoclose.upiPaymentStatus.toString(),
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
            // ipoclose.biddingstartdate // for NSE and BSE
            // ipoclose.biddingendDate  // for BSE
            // ipoclose.biddingenddate  // for NSE

            if (currentDate.isBetween(
                    convertIpoDates(ipoclose.biddingstartdate!, "dd-mm-yyyy"),
                    convertIpoDates(
                        ipoclose.type == "BSE"
                            ? ipoclose.biddingendDate!
                            : ipoclose.biddingenddate!,
                        "dd-mm-yyyy")) ==
                true) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                          onPressed: () async {
                            await context.read(ipoProvide).getSmeIpo();
                            await context.read(ipoProvide).getmainstreamipo();
                            await context
                                .read(ipoProvide)
                                .getipoperfomance(currentYear);
                            Navigator.pushNamed(context, Routes.ipo);
                          },
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 1.4,
                                  color: theme.isDarkMode
                                      ? colors.colorGrey
                                      : colors.colorBlack),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)))),
                          child: Text("Place New order",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600))),
                    ),
                  ],
                ),
              ),
            ],

            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            SizedBox(
              height: 8,
            ),
            data("App no", ipoclose.applicationNumber.toString(), theme),
            data("Quantity", ipoclose.bidDetail![0].quantity.toString(), theme),

            data(
                "Price",
                ipoclose.type == "BSE"
                    ? "₹${double.parse(ipoclose.bidDetail![0].rate!).toInt()}"
                    : "₹${ipoclose.bidDetail![0].price}",
                theme),

            data(
                "Total amount",
                ipoclose.type == "BSE"
                    ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(ipoclose.bidDetail![0].rate!) * double.parse(ipoclose.bidDetail![0].quantity!))}"
                    : "₹${getFormatter(
                        noDecimal: true,
                        v4d: false,
                        value: double.parse(ipoclose.bidDetail![0].amount!)
                            .toDouble(),
                      )}",
                theme),
            data(
                "Bid Date & Time",
                ipoclose.responseDatetime.toString() == ""
                    ? "----"
                    : ipodateres(ipoclose.responseDatetime.toString()),
                theme),

            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16),
              child: Text(
                ipoclose.bidDetail!.length == 1
                    ? "Single bid order"
                    : ipoclose.bidDetail!.length == 2
                        ? "Double bid order"
                        : "Triple bid order",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
            ),
            // ListView.builder(
            //     itemCount: ipoclose.bidDetail!.length,
            //     physics: const NeverScrollableScrollPhysics(),
            //     shrinkWrap: true,
            //     itemBuilder: (context, index) {
            //       return Padding(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [

            //             Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [

            //                  Column(
            //                   crossAxisAlignment: CrossAxisAlignment.center,
            //                   children: [
            //                     Text(
            //               "bid ${index + 1}",
            //               style:
            //                   textStyle(colors.colorGrey, 14, FontWeight.w500),
            //             ),

            //                   ],
            //                 ),
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       ipoclose.type == "BSE"
            //                           ? "₹${getFormatter(noDecimal: true, v4d: false, value: (double.parse(ipoclose.bidDetail![index].rate!) * double.parse(ipoclose.bidDetail![index].quantity!)))}"
            //                           : "₹${getFormatter(
            //                               noDecimal: true,
            //                               v4d: false,
            //                               value: double.parse(ipoclose
            //                                       .bidDetail![index].amount!)
            //                                   .toDouble(),
            //                             )}",
            //                       style: textStyle(
            //                           theme.isDarkMode
            //                               ? colors.colorWhite
            //                               : colors.colorBlack,
            //                           14,
            //                           FontWeight.w600),
            //                     ),
            //                     const SizedBox(height: 2),
            //                     Text(
            //                       "Amount",
            //                       style: textStyle(
            //                           colors.colorGrey, 14, FontWeight.w500),
            //                     ),
            //                   ],
            //                 ),
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       ipoclose.type == "BSE"
            //                           ? ipoclose.bidDetail![index].rate!
            //                           : ipoclose.bidDetail![index].price!,
            //                       style: textStyle(
            //                           theme.isDarkMode
            //                               ? colors.colorWhite
            //                               : colors.colorBlack,
            //                           14,
            //                           FontWeight.w600),
            //                     ),
            //                     const SizedBox(height: 2),
            //                     Text(
            //                       "Price",
            //                       style: textStyle(
            //                           colors.colorGrey, 14, FontWeight.w500),
            //                     ),
            //                   ],
            //                 ),
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       ipoclose.bidDetail![index].quantity!
            //                           .toString(),
            //                       style: textStyle(
            //                           theme.isDarkMode
            //                               ? colors.colorWhite
            //                               : colors.colorBlack,
            //                           14,
            //                           FontWeight.w600),
            //                     ),
            //                     const SizedBox(height: 2),
            //                     Text(
            //                       "Quantity",
            //                       style: textStyle(
            //                           colors.colorGrey, 14, FontWeight.w500),
            //                     ),
            //                   ],
            //                 ),
            //                 Column(
            //                   crossAxisAlignment: CrossAxisAlignment.start,
            //                   children: [
            //                     Text(
            //                       ipoclose.type == "BSE"
            //                           ? ipoclose.bidDetail![index]
            //                                       .cuttoffflag! ==
            //                                   "0"
            //                               ? "false"
            //                               : "true"
            //                           : ipoclose.bidDetail![index].atCutOff!
            //                               .toString(),
            //                       style: textStyle(
            //                           theme.isDarkMode
            //                               ? colors.colorWhite
            //                               : colors.colorBlack,
            //                           14,
            //                           FontWeight.w600),
            //                     ),
            //                     const SizedBox(height: 2),
            //                     Text(
            //                       "Cut off",
            //                       style: textStyle(
            //                           colors.colorGrey, 14, FontWeight.w500),
            //                     ),
            //                   ],
            //                 ),
            //               ],
            //             ),
            //             const SizedBox(
            //               height: 8,
            //             ),
            //             Divider(
            //               color: theme.isDarkMode
            //                   ? colors.darkColorDivider
            //                   : colors.colorDivider,
            //             )
            //           ],
            //         ),
            //       );
            //     }),

            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Theme(

                   data: Theme.of(context).copyWith(
        cardColor: Colors.transparent, // To ensure background matches
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)),
        dataTableTheme: const DataTableThemeData(
          headingTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          dataTextStyle: TextStyle(color: Colors.white),
          
          
          dividerThickness: 1.0,
          
           
        ),
      ),
                  child: DataTable(
                    columnSpacing: 16.0,
                    horizontalMargin: 0,
                     headingRowHeight: 40.0,
                     border: TableBorder(
          horizontalInside: BorderSide(color: Colors.white54, width: 0.8), // Horizontal lines
        ),
                   columns: [
          DataColumn(
            label: Align(
              alignment: Alignment.centerLeft,
              child: Text("Bid", style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,)),
            ),
          ),
          DataColumn(label: Text("Qty", style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,))),
          DataColumn(label: Text("Price", style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,))),
          DataColumn(label: Text("Amount", style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,))),       
          DataColumn(label: Text("Cut off", style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,))),
        ],
                    rows: List<DataRow>.generate(
                      ipoclose.bidDetail!.length,
                      (index) {
                        final bid = ipoclose.bidDetail![index];
                        final isCutOff = ipoclose.type == "BSE"
                            ? (bid.cuttoffflag! != "0")
                            : bid.atCutOff!;
                        return DataRow(cells: [
                          DataCell(Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text("${index + 1}" , style: textStyle(
                                                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                                                12,
                                                FontWeight.w500,)),
                          )),
                          DataCell(Text(bid.quantity!,  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,))),
                          DataCell(Text(
                              ipoclose.type == "BSE" ? bid.rate! : bid.price! , style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,))),
                          DataCell(Text(ipoclose.type == "BSE"
                              ? "₹${getFormatter(noDecimal: true, v4d: false, value: (double.parse(bid.rate!) * double.parse(bid.quantity!)))}"
                              : "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(bid.amount!).toDouble())}" , style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,))),
                          DataCell(Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              isCutOff ? Icons.check_circle : Icons.cancel,
                              color: isCutOff ? Colors.green : Colors.red,
                            ),
                          )),
                        ]);
                      },
                    ),
                  ),
                ),
              ),
            )

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
            //     ipoclose.failReason.toString(),
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
