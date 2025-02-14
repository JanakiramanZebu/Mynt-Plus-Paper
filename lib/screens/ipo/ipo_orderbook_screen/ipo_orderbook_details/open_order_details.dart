// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';
import '../../ipo_cancel_alert/cancel_alert.dart';

class IpoOpenOrderDetails extends ConsumerWidget {
  final IpoOrderBookModel ipodetails;
  const IpoOpenOrderDetails({
    super.key,
    required this.ipodetails,
  });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = watch(themeProvider);
    final upi = watch(transcationProvider);
    return Scaffold(
       
      appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9),
              child: SvgPicture.asset(
                assets.backArrow,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("Order Details",
              style: textStyles.appBarTitleTxt.copyWith(
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ipodetails.companyName.toString(),
                    style: textStyles.scripNameTxtStyle.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack),
                  ),
                  const SizedBox(height: 5),
                  Text(ipodetails.symbol.toString(),
                      style: textStyles.scripExchTxtStyle),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order",
                            style: textStyle(
                                colors.colorGrey, 13, FontWeight.w600),
                          ),
                          // Text(
                          //   ipodetails.reponseStatus == "new success"
                          //       ? "Success"
                          //       : "Pending",
                          //   style: textStyle(
                          //       theme.isDarkMode
                          //           ? colors.colorWhite
                          //           : colors.colorBlack,
                          //       14,
                          //       FontWeight.w600),
                          // )
                          Text(
                        'Id : ${ipodetails.bidReferenceNumber != ""?ipodetails.bidReferenceNumber.toString():" - "}',
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600),
                      )
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                              ipodetails.reponseStatus == "new success"
                                  ? "assets/icon/success.svg"
                                  : "assets/icon/pendingicon.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            ipodetails.reponseStatus == "new success"
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
                    height: 15,
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
                                colors.colorGrey, 13, FontWeight.w600),
                          ),
                          // Text(
                          //   ipodetails.upiPaymentStatus == ""
                          //       ? "Pending"
                          //       : ipodetails.upiPaymentStatus.toString(),
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
                          SvgPicture.asset(ipodetails.upiPaymentStatus == ""
                              ? "assets/icon/pendingicon.svg"
                              : "assets/icon/success.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            ipodetails.upiPaymentStatus == ""
                                ? "Pending"
                                : ipodetails.upiPaymentStatus.toString(),
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
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            // const SizedBox(
            //   height: 10,
            // ),

            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, bottom: 5),
              child: Text(
                "Reason",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 16, bottom: 10),
              child: Text(
                ipodetails.failReason=="" ? "Order placed successfully" :ipodetails.failReason.toString(),
                style: textStyle(colors.colorGrey, 13, FontWeight.w500),
              ),
            ),


            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             "Start Date",
            //             style: textStyle(colors.colorGrey, 13, FontWeight.w600),
            //           ),
            //           Text(
            //             "End Date",
            //             style: textStyle(colors.colorGrey, 13, FontWeight.w600),
            //           ),
            //         ],
            //       ),
            //       const SizedBox(
            //         height: 5,
            //       ),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           Text(
            //             ipodetails.biddingstartdate.toString(),
            //             style: textStyle(
            //                 theme.isDarkMode
            //                     ? colors.colorWhite
            //                     : colors.colorBlack,
            //                 14,
            //                 FontWeight.w600),
            //           ),
            //           Text(
            //             ipodetails.type == "BSE"
            //                 ? ipodetails.biddingendDate.toString()
            //                 : ipodetails.biddingenddate.toString(),
            //             style: textStyle(
            //                 theme.isDarkMode
            //                     ? colors.colorWhite
            //                     : colors.colorBlack,
            //                 14,
            //                 FontWeight.w600),
            //           ),
            //         ],
            //       )
            //     ],
            //   ),
            // ),
            const SizedBox(
              height: 10,
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           "Order Id",
              //           style: textStyle(colors.colorGrey, 13, FontWeight.w600),
              //         ),
              //         Text(
              //           ipodetails.bidReferenceNumber != ""?ipodetails.bidReferenceNumber.toString():" - ",
              //           style: textStyle(
              //               theme.isDarkMode
              //                   ? colors.colorWhite
              //                   : colors.colorBlack,
              //               14,
              //               FontWeight.w600),
              //         )
              //       ],
              //     ),
              //     Row(
              //       children: [
              //         SvgPicture.asset(ipodetails.upiPaymentStatus == ""
              //             ? "assets/icon/pendingicon.svg"
              //             : "assets/icon/success.svg"),
              //         const SizedBox(
              //           width: 4,
              //         ),
              //         Text(
              //           ipodetails.upiPaymentStatus == ""
              //               ? "Pending"
              //               : ipodetails.upiPaymentStatus.toString(),
              //           style: textStyle(
              //               theme.isDarkMode
              //                   ? colors.colorWhite
              //                   : colors.colorBlack,
              //               14,
              //               FontWeight.w600),
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),



            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // modifyButtonStatus(
                  //           ipodetails.biddingstartdate.toString(),
                  //           ipodetails.type == "BSE"
                  //               ? ipodetails.biddingendDate.toString()
                  //               : ipodetails.biddingenddate.toString(),
                  //         ) ==
                  //         "Closed"
                  //     ? Container()
                  //     : 
                      // Expanded(
                      //     child: OutlinedButton(
                      //         onPressed: () async {
                      //           await upi.fetchupiIdView(
                      //             upi.bankdetails!.dATA![upi.indexss][1],
                      //             upi.bankdetails!.dATA![upi.indexss][2]);
                      //           await context
                      //               .read(ipoProvide)
                      //               .modifyipocategory();
                      //           Navigator.pushNamed(
                      //             context,
                      //             Routes.modifyipoorder,
                      //             arguments: ipodetails,
                      //           );
                      //         },
                      //         style: OutlinedButton.styleFrom(
                      //             side: BorderSide(
                      //                 width: 1.4,
                      //                 color: theme.isDarkMode
                      //                     ? colors.colorGrey
                      //                     : colors.colorBlack),
                      //             padding: const EdgeInsets.symmetric(
                      //                 vertical: 10.5),
                      //             shape: const RoundedRectangleBorder(
                      //                 borderRadius: BorderRadius.all(
                      //                     Radius.circular(30)))),
                      //         child: Padding(
                      //           padding:
                      //               const EdgeInsets.symmetric(horizontal: 20),
                      //           child: Text("Modify Order",
                      //               style: textStyle(
                      //                   theme.isDarkMode
                      //                       ? colors.colorWhite
                      //                       : colors.colorBlack,
                      //                   14,
                      //                   FontWeight.w600)),
                      //         )),
                      //   ),
                  // SizedBox(
                  //     width: modifyButtonStatus(
                  //               ipodetails.biddingstartdate.toString(),
                  //               ipodetails.type == "BSE"
                  //                   ? ipodetails.biddingendDate.toString()
                  //                   : ipodetails.biddingenddate.toString(),
                  //             ) ==
                  //             "Closed"
                  //         ? 0
                  //         : 20),

                  
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return IpoCancelAlert(ipocancel: ipodetails);
                              });
                        },
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 1.4,
                                color: theme.isDarkMode
                                    ? colors.colorGrey
                                    : colors.colorBlack),
                            padding: const EdgeInsets.symmetric(vertical: 10.5),
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
              height: 10,
            ),
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            data(
                "App no",
                ipodetails.type == "BSE"
                    ? "-"
                    : 
                    ipodetails.respBid!=null ?  ipodetails.respBid![0].bidReferenceNumber.toString():" - ",
                theme),
            data("Quantity", ipodetails.bidDetail![0].quantity.toString(),
                theme),

            data(
                "Price",
                ipodetails.type == "BSE"
                    ? ipodetails.bidDetail![0].rate.toString()
                    : "${double.parse(ipodetails.bidDetail![0].price.toString()).toInt()}",
                theme),

            data(
                "Total amount",
                ipodetails.type == "BSE"
                    ?"₹${getFormatter(noDecimal: true,v4d: false,value: double.parse(ipodetails.bidDetail![0].rate!) * double.parse(ipodetails.bidDetail![0].quantity!)).toString()}"
                    : "₹${getFormatter(
                        noDecimal: true,
                        v4d: false,
                        value: double.parse(ipodetails.bidDetail![0].amount!)
                            .toDouble(),
                      )}",
                theme),
            
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 15, bottom: 5),
              child: Text(
                ipodetails.bidDetail!.length == 1
                    ? "Single bid order"
                    : ipodetails.bidDetail!.length == 2
                        ? "Double bid order"
                        : "Triple bid order",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
            ),
            ListView.builder(
                itemCount: ipodetails.bidDetail!.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "bid ${index + 1}",
                          style:
                              textStyle(colors.colorGrey, 13, FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipodetails.type == "BSE"
                                      ? "₹${getFormatter(
                                          noDecimal: true,
                                          v4d: false,
                                          value: (double.parse(ipodetails.bidDetail![index].rate!) * double.parse(ipodetails.bidDetail![index].quantity!))
                                          )}"
                                      : "₹${getFormatter(
                                          noDecimal: true,
                                          v4d: false,
                                          value: double.parse(ipodetails
                                                  .bidDetail![index].amount!)
                                              .toDouble(),
                                        )}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Amount",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipodetails.type == "BSE"
                                      ? ipodetails.bidDetail![index].rate
                                          .toString()
                                      : "${double.parse(ipodetails.bidDetail![index].price.toString()).toInt()}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Price",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipodetails.bidDetail![index].quantity!
                                      .toString(),
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Quantity",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipodetails.type == "BSE"
                                      ? ipodetails.bidDetail![index].cuttoffflag
                                          .toString()
                                      : ipodetails.bidDetail![index].atCutOff
                                          .toString(),
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Cut off",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                        )
                      ],
                    ),
                  );
                }),
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
            //     ipodetails.failReason=="" ? "Order placed successfully" :ipodetails.failReason.toString(),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 12,
          ),
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
                    14,
                    FontWeight.w600),
              )
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
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
