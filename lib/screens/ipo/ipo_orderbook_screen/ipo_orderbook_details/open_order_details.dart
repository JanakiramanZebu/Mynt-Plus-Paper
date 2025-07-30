// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../ipo_cancel_alert/cancel_alert.dart';

class IpoOpenOrderDetails extends ConsumerStatefulWidget {
  final IpoOrderBookModel ipodetails;
  const IpoOpenOrderDetails({
    super.key,
    required this.ipodetails,
  });

  @override
  ConsumerState<IpoOpenOrderDetails> createState() =>
      _IpoOpenOrderDetailsState();
}

class _IpoOpenOrderDetailsState extends ConsumerState<IpoOpenOrderDetails> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 400) {
          Navigator.of(context).pop();
        }
      },
      child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.05,
          maxChildSize: 0.99,
          builder: (context, scrollController) {
            return Consumer(builder: (context, ref, _) {
              return Scaffold(
                backgroundColor: Colors.transparent,

                // appBar: AppBar(
                //   elevation: .2,
                //   centerTitle: false,
                //   // leadingWidth: 40,
                //   titleSpacing: -8,
                //   leading: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 8),
                //     child: InkWell(
                //       onTap: () {
                //         Navigator.pop(context);
                //       },
                //       child: Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 10),
                //         child: Icon(
                //           Icons.arrow_back_ios,
                //           color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //           size: 22,
                //         ),
                //       ),
                //     ),
                //   ),
                //   backgroundColor:
                //       theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                //   shadowColor: const Color(0xffECEFF3),
                //   title: Text(
                //     "Order Details",
                //     style: textStyle(
                //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                //         16,
                //         FontWeight.w600),
                //   ),
                // ),
                body: Container(
                  decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CustomDragHandler(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget.headText(
                                      text:
                                          "${widget.ipodetails.companyName.toString()} ${widget.ipodetails.symbol.toString()}",
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      fw: 0,
                                      textOverflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return IpoCancelAlert(
                                                    ipocancel:
                                                        widget.ipodetails);
                                              });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: colors.btnBg,
                                          minimumSize:
                                              const Size.fromHeight(45),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          side: BorderSide(
                                            width: 1,
                                            color: colors.btnOutlinedBorder,
                                          ),
                                        ),
                                        child: TextWidget.subText(
                                          text: "Cancel Order",
                                          theme: false,
                                          color: theme.isDarkMode
                                              ? colors.primaryDark
                                              : colors.primaryLight,
                                          fw: 2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInfoRow(
                                        "Order Id",
                                        widget.ipodetails.applicationNumber
                                            .toString(),
                                        theme),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget.subText(
                                          text: "Order Status",
                                          theme: false,
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          fw: 3,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: widget.ipodetails
                                                        .reponseStatus ==
                                                    "new success"
                                                ? theme.isDarkMode
                                                    ? colors.profitDark
                                                        .withOpacity(0.1)
                                                    : colors.profitLight
                                                        .withOpacity(0.1)
                                                : colors.pending
                                                    .withOpacity(0.1),
                                          ),
                                          child: TextWidget.subText(
                                            text: widget.ipodetails
                                                        .reponseStatus ==
                                                    "new success"
                                                ? "Success"
                                                : "Pending",
                                            theme: false,
                                            color: widget.ipodetails
                                                        .reponseStatus ==
                                                    "new success"
                                                ? theme.isDarkMode
                                                    ? colors.profitDark
                                                    : colors.profitLight
                                                : colors.pending,
                                            fw: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.dividerDark
                                            : colors.dividerLight,
                                        thickness: 0),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextWidget.subText(
                                          text: "Payment",
                                          theme: false,
                                          color: theme.isDarkMode
                                              ? colors.textSecondaryDark
                                              : colors.textSecondaryLight,
                                          fw: 3,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: widget.ipodetails
                                                        .upiPaymentStatus ==
                                                    ""
                                                ? colors.pending
                                                    .withOpacity(0.1)
                                                : colors.profitLight
                                                    .withOpacity(0.1),
                                          ),
                                          child: TextWidget.subText(
                                            text: widget.ipodetails
                                                        .upiPaymentStatus ==
                                                    ""
                                                ? "Pending"
                                                : widget
                                                    .ipodetails.upiPaymentStatus
                                                    .toString(),
                                            theme: false,
                                            color: widget.ipodetails
                                                        .upiPaymentStatus ==
                                                    ""
                                                ? colors.pending
                                                : colors.profitLight,
                                            fw: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.dividerDark
                                            : colors.dividerLight,
                                        thickness: 0),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      "App no",
                                      widget.ipodetails.type == "BSE"
                                          ? widget.ipodetails.bidReferenceNumber
                                              .toString()
                                          : widget.ipodetails.respBid != null
                                              ? widget.ipodetails.respBid![0]
                                                  .bidReferenceNumber
                                                  .toString()
                                              : " - ",
                                      theme,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      "Qty",
                                      (widget.ipodetails.respBid != null &&
                                              widget.ipodetails.respBid!
                                                  .isNotEmpty)
                                          ? widget
                                              .ipodetails.respBid![0].quantity
                                              .toString()
                                          : "-",
                                      theme,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      "Price",
                                      (widget.ipodetails.bidDetail != null &&
                                              widget.ipodetails.bidDetail!
                                                  .isNotEmpty)
                                          ? widget.ipodetails.type == "BSE"
                                              ? widget
                                                  .ipodetails.bidDetail![0].rate
                                                  .toString()
                                              : "${double.tryParse(widget.ipodetails.bidDetail![0].price.toString())?.toInt() ?? "-"}"
                                          : "-",
                                      theme,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      "Total amount",
                                      widget.ipodetails.type == "BSE"
                                          ? "${getFormatter(noDecimal: true, v4d: false, value: double.parse(widget.ipodetails.bidDetail![0].rate!) * double.parse(widget.ipodetails.bidDetail![0].quantity!)).toString()}"
                                          : "${getFormatter(
                                              noDecimal: true,
                                              v4d: false,
                                              value: double.parse(widget
                                                      .ipodetails
                                                      .bidDetail![0]
                                                      .amount!)
                                                  .toDouble(),
                                            )}",
                                      theme,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                        "Bid Date & Time",
                                        widget.ipodetails.responseDatetime
                                                    .toString() ==
                                                ""
                                            ? "-"
                                            : ipodateres(widget
                                                .ipodetails.responseDatetime
                                                .toString()),
                                        theme),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                        "Reason",
                                        widget.ipodetails.failReason == ""
                                            ? "Order placed successfully"
                                            : widget.ipodetails.failReason
                                                .toString(),
                                        theme),
                                    const SizedBox(height: 8),
                                    TextWidget.subText(
                                      text:
                                          widget.ipodetails.bidDetail!.length ==
                                                  1
                                              ? "Single bid order"
                                              : widget.ipodetails.bidDetail!
                                                          .length ==
                                                      2
                                                  ? "Double bid order"
                                                  : "Triple bid order",
                                      theme: false,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                      fw: 3,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            cardColor: Colors
                                                .transparent, // To ensure background matches
                                            textTheme: TextTheme(
                                                bodyMedium: TextStyle(
                                                    color: Colors.white)),
                                            dataTableTheme:
                                                const DataTableThemeData(
                                              headingTextStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              dataTextStyle: TextStyle(
                                                  color: Colors.white),
                                              dividerThickness: 1.0,
                                            ),
                                          ),
                                          child: DataTable(
                                            columnSpacing: 16.0,
                                            horizontalMargin: 0,
                                            headingRowHeight: 40.0,
                                            border: TableBorder(
                                              horizontalInside: BorderSide(
                                                  color: Colors.white54,
                                                  width:
                                                      0.8), // Horizontal lines
                                            ),
                                            columns: [
                                              DataColumn(
                                                label: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: TextWidget.subText(
                                                      text: "Bid",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      fw: 3),
                                                ),
                                              ),
                                              DataColumn(
                                                label: TextWidget.subText(
                                                    text: "Qty",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3),
                                              ),
                                              DataColumn(
                                                label: TextWidget.subText(
                                                    text: "Price",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3),
                                              ),
                                              DataColumn(
                                                label: TextWidget.subText(
                                                    text: "Amount",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3),
                                              ),
                                              DataColumn(
                                                label: TextWidget.subText(
                                                    text: "Cut off",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3),
                                              ),
                                            ],
                                            rows: List<DataRow>.generate(
                                              widget
                                                  .ipodetails.bidDetail!.length,
                                              (index) {
                                                final bid = widget.ipodetails
                                                    .bidDetail![index];
                                                final isCutOff = widget
                                                            .ipodetails.type ==
                                                        "BSE"
                                                    ? (bid.cuttoffflag! != "0")
                                                    : bid.atCutOff!;
                                                return DataRow(cells: [
                                                  DataCell(Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: TextWidget.subText(
                                                        text: "${index + 1}",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                  )),
                                                  DataCell(
                                                    TextWidget.subText(
                                                        text: bid.quantity!,
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                  ),
                                                  DataCell(
                                                    TextWidget.subText(
                                                        text: widget.ipodetails
                                                                    .type ==
                                                                "BSE"
                                                            ? bid.rate
                                                                .toString()
                                                            : "${double.parse(bid.price.toString()).toInt()}",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                  ),
                                                  DataCell(
                                                    TextWidget.subText(
                                                        text: widget.ipodetails
                                                                    .type ==
                                                                "BSE"
                                                            ? "₹${getFormatter(noDecimal: true, v4d: false, value: (double.parse(bid.rate!) * double.parse(bid.quantity!)))}"
                                                            : "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(bid.amount!).toDouble())}",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 3),
                                                  ),
                                                  DataCell(Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12),
                                                    child: Icon(
                                                      isCutOff
                                                          ? Icons.check_circle
                                                          : Icons.cancel,
                                                      color: isCutOff
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                  )),
                                                ]);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Divider(
                                        color: theme.isDarkMode
                                            ? colors.dividerDark
                                            : colors.dividerLight,
                                        thickness: 0)
                                  ],
                                ),
                              ),

                              //     Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               "Order Id : ${widget.ipodetails.bidReferenceNumber != "" ? widget.ipodetails.bidReferenceNumber.toString() : " - "}",
                              //               style: textStyle(colors.colorGrey,
                              //                   14, FontWeight.w600),
                              //             ),
                              //             // Text(
                              //             //   ipodetails.reponseStatus == "new success"
                              //             //       ? "Success"
                              //             //       : "Pending",
                              //             //   style: textStyle(
                              //             //       theme.isDarkMode
                              //             //           ? colors.colorWhite
                              //             //           : colors.colorBlack,
                              //             //       14,
                              //             //       FontWeight.w600),
                              //             // )
                              //           ],
                              //         ),
                              //         Row(
                              //           children: [
                              //             SvgPicture.asset(widget.ipodetails
                              //                         .reponseStatus ==
                              //                     "new success"
                              //                 ? "assets/icon/success.svg"
                              //                 : "assets/icon/pendingicon.svg"),
                              //             const SizedBox(
                              //               width: 4,
                              //             ),
                              //             Text(
                              //               widget.ipodetails.reponseStatus ==
                              //                       "new success"
                              //                   ? "Success"
                              //                   : "Pending",
                              //               style: textStyle(
                              //                   theme.isDarkMode
                              //                       ? colors.colorWhite
                              //                       : colors.colorBlack,
                              //                   14,
                              //                   FontWeight.w600),
                              //             ),
                              //           ],
                              //         ),
                              //       ],
                              //     ),
                              //     const SizedBox(
                              //       height: 16,
                              //     ),
                              //     Row(
                              //       mainAxisAlignment:
                              //           MainAxisAlignment.spaceBetween,
                              //       children: [
                              //         Column(
                              //           crossAxisAlignment:
                              //               CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               "Payment",
                              //               style: textStyle(colors.colorGrey,
                              //                   14, FontWeight.w600),
                              //             ),
                              //             // Text(
                              //             //   ipodetails.upiPaymentStatus == ""
                              //             //       ? "Pending"
                              //             //       : ipodetails.upiPaymentStatus.toString(),
                              //             //   style: textStyle(
                              //             //       theme.isDarkMode
                              //             //           ? colors.colorWhite
                              //             //           : colors.colorBlack,
                              //             //       14,
                              //             //       FontWeight.w600),
                              //             // )
                              //           ],
                              //         ),
                              //         Row(
                              //           children: [
                              //             SvgPicture.asset(widget.ipodetails
                              //                         .upiPaymentStatus ==
                              //                     ""
                              //                 ? "assets/icon/pendingicon.svg"
                              //                 : "assets/icon/success.svg"),
                              //             const SizedBox(
                              //               width: 4,
                              //             ),
                              //             Text(
                              //               widget.ipodetails
                              //                           .upiPaymentStatus ==
                              //                       ""
                              //                   ? "Pending"
                              //                   : widget.ipodetails
                              //                       .upiPaymentStatus
                              //                       .toString(),
                              //               style: textStyle(
                              //                   theme.isDarkMode
                              //                       ? colors.colorWhite
                              //                       : colors.colorBlack,
                              //                   14,
                              //                   FontWeight.w600),
                              //             ),
                              //           ],
                              //         ),
                              //       ],
                              //     ),
                              //   ],
                              // ),
                              // ),
                              // Divider(
                              //   height: 0,
                              //   color: theme.isDarkMode
                              //       ? colors.darkColorDivider
                              //       : colors.colorDivider,
                              // ),
                              // const SizedBox(
                              //   height: 10,
                              // ),

                              // Padding(
                              //     padding: const EdgeInsets.only(
                              //         top: 16, left: 16, right: 16),
                              //     child: Column(
                              //       crossAxisAlignment:
                              //           CrossAxisAlignment.start,
                              //       children: [
                              //         Text(
                              //           "Reason",
                              //           style: textStyle(
                              //               theme.isDarkMode
                              //                   ? colors.colorWhite
                              //                   : colors.colorBlack,
                              //               14,
                              //               FontWeight.w600),
                              //         ),
                              //         SizedBox(
                              //           height: 8,
                              //         ),
                              //         Text(
                              //           widget.ipodetails.failReason == ""
                              //               ? "Order placed successfully"
                              //               : widget.ipodetails.failReason
                              //                   .toString(),
                              //           style: textStyle(colors.colorGrey, 14,
                              //               FontWeight.w500),
                              //         ),
                              //       ],
                              //     )),

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

                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 16, right: 16, top: 16, bottom: 0),
                              // child: Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceAround,
                              // children: [
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
                              //                       ? colors.cololorBlack,
                              //                   14,rWhite
                              //                       : colors.co
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
                              //     ],
                              //   ),
                              // ),
                              // const SizedBox(
                              //   height: 16,
                              // ),
                              // Divider(
                              //   height: 0,
                              //   color: theme.isDarkMode
                              //       ? colors.darkColorDivider
                              //       : colors.colorDivider,
                              // ),
                              // SizedBox(
                              //   height: 8,
                              // ),
                              // data(
                              //     "App no",
                              //     widget.ipodetails.type == "BSE"
                              //         ? "-"
                              //         : widget.ipodetails.respBid != null
                              //             ? widget.ipodetails.respBid![0]
                              //                 .bidReferenceNumber
                              //                 .toString()
                              //             : " - ",
                              //     theme),
                              // data(
                              //     "Quantity",
                              //     widget.ipodetails.bidDetail![0].quantity
                              //         .toString(),
                              //     theme),

                              // data(
                              //     "Price",
                              //     widget.ipodetails.type == "BSE"
                              //         ? widget.ipodetails.bidDetail![0].rate
                              //             .toString()
                              //         : "${double.parse(widget.ipodetails.bidDetail![0].price.toString()).toInt()}",
                              //     theme),

                              // data(
                              //     "Total amount",
                              //     widget.ipodetails.type == "BSE"
                              //         ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(widget.ipodetails.bidDetail![0].rate!) * double.parse(widget.ipodetails.bidDetail![0].quantity!)).toString()}"
                              //         : "₹${getFormatter(
                              //             noDecimal: true,
                              //             v4d: false,
                              //             value: double.parse(widget.ipodetails
                              //                     .bidDetail![0].amount!)
                              //                 .toDouble(),
                              //           )}",
                              //     theme),

                              // data(
                              //     "Bid Date & Time",
                              //     widget.ipodetails.responseDatetime
                              //                 .toString() ==
                              //             ""
                              //         ? "----"
                              //         : ipodateres(widget
                              //             .ipodetails.responseDatetime
                              //             .toString()),
                              //     theme),

                              // ListView.builder(
                              //     itemCount: ipodetails.bidDetail!.length,
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
                              //                 Column(
                              //                   crossAxisAlignment: CrossAxisAlignment.center,
                              //                   children: [
                              //                     Text(
                              //                       "bid ${index + 1}",
                              //                       style: textStyle(
                              //                           colors.colorGrey, 14, FontWeight.w500),
                              //                     ),
                              //                   ],
                              //                 ),
                              //                 Column(
                              //                   crossAxisAlignment: CrossAxisAlignment.start,
                              //                   children: [
                              //                     Text(
                              //                       ipodetails.type == "BSE"
                              //                           ? "₹${getFormatter(noDecimal: true, v4d: false, value: (double.parse(ipodetails.bidDetail![index].rate!) * double.parse(ipodetails.bidDetail![index].quantity!)))}"
                              //                           : "₹${getFormatter(
                              //                               noDecimal: true,
                              //                               v4d: false,
                              //                               value: double.parse(ipodetails
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
                              //                       ipodetails.type == "BSE"
                              //                           ? ipodetails.bidDetail![index].rate
                              //                               .toString()
                              //                           : "${double.parse(ipodetails.bidDetail![index].price.toString()).toInt()}",
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
                              //                       ipodetails.bidDetail![index].quantity!
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
                              //                       ipodetails.type == "BSE"
                              //                           ? ipodetails.bidDetail![index].cuttoffflag
                              //                               .toString()
                              //                           : ipodetails.bidDetail![index].atCutOff
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
                      ),
                    ],
                  ),
                ),
              );
            });
          }),
    );
  }

  Widget _buildInfoRow(String title1, String value1, ThemesProvider theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
              text: title1,
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: TextWidget.subText(
                text: value1,
                theme: false,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                softWrap: true,
                align: TextAlign.end,
                fw: 3),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 0)
    ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
