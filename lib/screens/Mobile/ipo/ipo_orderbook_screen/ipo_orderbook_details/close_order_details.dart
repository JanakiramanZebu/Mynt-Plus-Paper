// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../../provider/iop_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../routes/route_names.dart';
import '../../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../../sharedWidget/functions.dart';

class IpoCloseOrderDetails extends ConsumerStatefulWidget {
  final IpoOrderBookModel ipoclose;
  const IpoCloseOrderDetails({
    super.key,
    required this.ipoclose,
  });

  @override
  ConsumerState<IpoCloseOrderDetails> createState() =>
      _IpoCloseOrderDetailsState();
}

class _IpoCloseOrderDetailsState extends ConsumerState<IpoCloseOrderDetails> {
  @override
  Widget build(BuildContext context) {
    int currentYear = DateTime.now().year;
    final currentDate = DateTime.now();
    print("currentDate :: $currentDate");

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
                body: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: theme.isDarkMode
                        ? colors.colorBlack
                        : colors.colorWhite,
                    border: Border(
                      top: BorderSide(
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.5)
                            : colors.colorWhite,
                      ),
                      left: BorderSide(
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.5)
                            : colors.colorWhite,
                      ),
                      right: BorderSide(
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.5)
                            : colors.colorWhite,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      const CustomDragHandler(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextWidget.headText(
                          text:
                              "${widget.ipoclose.companyName.toString()} ${widget.ipoclose.symbol.toString()}",
                          theme: false,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          maxLines: 2,
                          fw: 0,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (currentDate.isBetween(
                              convertIpoDates(widget.ipoclose.biddingstartdate!,
                                  "dd-mm-yyyy"),
                              convertIpoDates(
                                  widget.ipoclose.type == "BSE"
                                      ? widget.ipoclose.biddingendDate!
                                      : widget.ipoclose.biddingenddate!,
                                  "dd-mm-yyyy")) ==
                          true) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () async {
                              await ref.read(ipoProvide).getSmeIpo();
                              await ref.read(ipoProvide).getmainstreamipo(context);
                              await ref
                                  .read(ipoProvide)
                                  .getipoperfomance(currentYear);
                              Navigator.pushNamed(context, Routes.ipo);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: theme.isDarkMode
                                  ? colors.textSecondaryDark.withOpacity(0.6)
                                  : colors.btnBg,
                              minimumSize: const Size.fromHeight(45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              side: theme.isDarkMode
                                  ? null
                                  : BorderSide(
                                      color: colors.primaryLight,
                                      width: 1,
                                    ),
                            ),
                            child: TextWidget.subText(
                              text: "Place New Order",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.primaryLight,
                              fw: 2,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(
                                      "Order Id",
                                      widget.ipoclose.applicationNumber
                                          .toString(),
                                      theme),
                                  const SizedBox(height: 8),
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     TextWidget.subText(
                                  //       text: "Order Status",
                                  //       theme: false,
                                  //       color: theme.isDarkMode
                                  //           ? colors.textSecondaryDark
                                  //           : colors.textSecondaryLight,
                                  //       fw: 3,
                                  //     ),
                                  //     Container(
                                  //       padding: const EdgeInsets.symmetric(
                                  //           horizontal: 8, vertical: 4),
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(4),
                                  //         color:
                                  //             widget.ipoclose.reponseStatus ==
                                  //                     "new success"
                                  //                 ? theme.isDarkMode
                                  //                     ? colors.profitDark
                                  //                         .withOpacity(0.1)
                                  //                     : colors.profitLight
                                  //                         .withOpacity(0.1)
                                  //                 : colors.pending
                                  //                     .withOpacity(0.1),
                                  //       ),
                                  //       child: TextWidget.subText(
                                  //         text:
                                  //             widget.ipoclose.reponseStatus ==
                                  //                     "new success"
                                  //                 ? "Success"
                                  //                 : "Pending",
                                  //         theme: false,
                                  //         color:
                                  //             widget.ipoclose.reponseStatus ==
                                  //                     "new success"
                                  //                 ? theme.isDarkMode
                                  //                     ? colors.profitDark
                                  //                     : colors.profitLight
                                  //                 : colors.pending,
                                  //         fw: 3,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // const SizedBox(height: 8),
                                  // Divider(
                                  //     color: theme.isDarkMode
                                  //         ? colors.dividerDark
                                  //         : colors.dividerLight,
                                  //     thickness: 0),
                                  // const SizedBox(height: 8),
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
                                          color: widget
                                                      .ipoclose.reponseStatus ==
                                                  "cancel success"
                                              ? colors.pending.withOpacity(0.1)
                                              : theme.isDarkMode
                                                  ? colors.lossDark
                                                      .withOpacity(0.1)
                                                  : colors.lossLight
                                                      .withOpacity(0.1),
                                        ),
                                        child: TextWidget.subText(
                                          text: widget.ipoclose.reponseStatus ==
                                                  "cancel success"
                                              ? "Cancelled"
                                              : "Failed",
                                          theme: false,
                                          color:
                                              widget.ipoclose.reponseStatus ==
                                                      "cancel success"
                                                  ? theme.isDarkMode
                                                      ? colors.pending
                                                      : colors.pending
                                                  : theme.isDarkMode
                                                      ? colors.lossDark
                                                      : colors.lossLight,
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
                                    widget.ipoclose.type == "BSE"
                                        ? widget.ipoclose.bidReferenceNumber
                                            .toString()
                                        : widget.ipoclose.respBid != null
                                            ? widget.ipoclose.respBid![0]
                                                .bidReferenceNumber
                                                .toString()
                                            : " - ",
                                    theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    "Qty",
                                    widget.ipoclose.bidDetail != null
                                        ? widget.ipoclose.bidDetail![0].quantity
                                            .toString()
                                        : "-",
                                    theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    "Price",
                                    (widget.ipoclose.bidDetail != null &&
                                            widget
                                                .ipoclose.bidDetail!.isNotEmpty)
                                        ? widget.ipoclose.type == "BSE"
                                            ? widget.ipoclose.bidDetail![0].rate
                                                .toString()
                                            : "${double.tryParse(widget.ipoclose.bidDetail![0].price.toString())?.toInt() ?? "-"}"
                                        : "-",
                                    theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    "Total amount",
                                    widget.ipoclose.type == "BSE"
                                        ? "${getFormatter(noDecimal: true, v4d: false, value: double.parse(widget.ipoclose.bidDetail![0].rate!) * double.parse(widget.ipoclose.bidDetail![0].quantity!)).toString()}"
                                        : "${getFormatter(
                                            noDecimal: true,
                                            v4d: false,
                                            value: double.parse(widget.ipoclose
                                                    .bidDetail![0].amount!)
                                                .toDouble(),
                                          )}",
                                    theme,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                      "Bid Date & Time",
                                      widget.ipoclose.responseDatetime
                                                  .toString() ==
                                              ""
                                          ? "-"
                                          : ipodateres(widget
                                              .ipoclose.responseDatetime
                                              .toString()),
                                      theme),
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                      "Reason",
                                      widget.ipoclose.failReason == ""
                                          ? " - "
                                          : widget.ipoclose.failReason
                                              .toString(),
                                      theme),
                                  const SizedBox(height: 8),

                                  TextWidget.subText(
                                    text: widget.ipoclose.bidDetail!.length == 1
                                        ? "Single bid order"
                                        : widget.ipoclose.bidDetail!.length == 2
                                            ? "Double bid order"
                                            : "Triple bid order",
                                    theme: false,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    fw: 3,
                                  ),
                                  const SizedBox(height: 8),
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
                                            dataTextStyle:
                                                TextStyle(color: Colors.white),
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
                                                width: 0.8), // Horizontal lines
                                          ),
                                          columns: [
                                            DataColumn(
                                              label: Align(
                                                alignment: Alignment.centerLeft,
                                                child: TextWidget.subText(
                                                  text: "Bid",
                                                  theme: false,
                                                  color: theme.isDarkMode
                                                      ? colors.textPrimaryDark
                                                      : colors
                                                          .textPrimaryLight,
                                                  fw: 3,
                                                ),
                                              ),
                                            ),
                                            DataColumn(
                                              label: TextWidget.subText(
                                                text: "Qty",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 3,
                                              ),
                                            ),
                                            DataColumn(
                                              label: TextWidget.subText(
                                                text: "Price",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 3,
                                              ),
                                            ),
                                            DataColumn(
                                              label: TextWidget.subText(
                                                text: "Amount",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 3,
                                              ),
                                            ),
                                            DataColumn(
                                              label: TextWidget.subText(
                                                text: "Cut off",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 3,
                                              ),
                                            ),
                                          ],
                                          rows: List<DataRow>.generate(
                                            widget.ipoclose.bidDetail!.length,
                                            (index) {
                                              final bid = widget
                                                  .ipoclose.bidDetail![index];
                                              final isCutOff =
                                                  widget.ipoclose.type == "BSE"
                                                      ? (bid.cuttoffflag! !=
                                                          "0")
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
                                                    fw: 3,
                                                  ),
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
                                                    fw: 3,
                                                  ),
                                                ),
                                                DataCell(
                                                  TextWidget.subText(
                                                    text:
                                                        widget.ipoclose.type ==
                                                                "BSE"
                                                            ? bid.rate!
                                                            : bid.price!,
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 3,
                                                  ),
                                                ),
                                                DataCell(
                                                  TextWidget.subText(
                                                    text: widget.ipoclose
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
                                                    fw: 3,
                                                  ),
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
                                ],
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

                              // data(
                              //     "App no",
                              //     widget.ipoclose.applicationNumber.toString(),
                              //     theme),
                              // data(
                              //     "Quantity",
                              //     widget.ipoclose.bidDetail![0].quantity
                              //         .toString(),
                              //     theme),

                              // data(
                              //     "Price",
                              //     widget.ipoclose.type == "BSE"
                              //         ? "₹${double.parse(widget.ipoclose.bidDetail![0].rate!).toInt()}"
                              //         : "₹${widget.ipoclose.bidDetail![0].price}",
                              //     theme),

                              // data(
                              //     "Total amount",
                              //     widget.ipoclose.type == "BSE"
                              //         ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(widget.ipoclose.bidDetail![0].rate!) * double.parse(widget.ipoclose.bidDetail![0].quantity!))}"
                              //         : "₹${getFormatter(
                              //             noDecimal: true,
                              //             v4d: false,
                              //             value: double.parse(widget.ipoclose
                              //                     .bidDetail![0].amount!)
                              //                 .toDouble(),
                              //           )}",
                              //     theme),
                              // data(
                              //     "Bid Date & Time",
                              //     widget.ipoclose.responseDatetime.toString() ==
                              //             ""
                              //         ? "----"
                              //         : ipodateres(widget
                              //             .ipoclose.responseDatetime
                              //             .toString()),
                              //     theme),

                              // Padding(
                              //   padding:
                              //       const EdgeInsets.only(left: 16, top: 16),
                              //   child:
                              //   ),
                              // ),
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
}
