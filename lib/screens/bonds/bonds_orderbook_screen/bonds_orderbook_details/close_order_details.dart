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
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../res/global_state_text.dart';

Widget data(String name, String value, ThemesProvider theme) {
  return Column(
    children: [
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.subText(
            text: name,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0,
          ),
          SizedBox(
            width: 200,
            child: TextWidget.subText(
              text: value,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              align: TextAlign.right,
              fw: 0,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Divider(
        thickness: 0,
        color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
      )
    ],
  );
}

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
    final theme = ref.watch(themeProvider);

    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        // minChildSize: 0.05,
        maxChildSize: 0.99,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, _) {
              return SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent,

                  // appBar: _buildAppBar(context, theme),
                  body: Container(
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
                        Expanded(
                          child: Column(
                            children: [
                              const CustomDragHandler(),
                              _HeaderSection(
                                  bondsCloseDetails: bondsCloseDetails,
                                  theme: theme),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Divider(
                                      //   height: 0,
                                      //   color: theme.isDarkMode
                                      //       ? colors.darkColorDivider
                                      //       : colors.colorDivider,
                                      // ),

                                      // const SizedBox(height: 16),
                                      // Divider(
                                      //   height: 0,
                                      //   color: theme.isDarkMode
                                      //       ? colors.darkColorDivider
                                      //       : colors.colorDivider,
                                      // ),
                                      // const SizedBox(height: 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: _OrderDetailsSection(
                                            bondsCloseDetails:
                                                bondsCloseDetails,
                                            theme: theme),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: _ReasonSection(
                                            bondsCloseDetails:
                                                bondsCloseDetails,
                                            theme: theme),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: _BidDetailsSection(
                                            bondsCloseDetails:
                                                bondsCloseDetails,
                                            theme: theme),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  AppBar _buildAppBar(BuildContext context, ThemesProvider theme) {
    return AppBar(
      elevation: .2,
      centerTitle: false,
      titleSpacing: -8,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: InkWell(
          onTap: () => Navigator.pop(context),
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
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      shadowColor: const Color(0xffECEFF3),
      title: TextWidget.titleText(
        text: "Order Details",
        theme: theme.isDarkMode,
        color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        fw: 2,
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _HeaderSection({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SymbolInfo(bondsCloseDetails: bondsCloseDetails, theme: theme),
          // const SizedBox(height: 16),
          _OrderIdRow(bondsCloseDetails: bondsCloseDetails, theme: theme),
          // const SizedBox(height: 16),
          _PaymentStatusRow(bondsCloseDetails: bondsCloseDetails, theme: theme),
        ],
      ),
    );
  }
}

class _SymbolInfo extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _SymbolInfo({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextWidget.titleText(
                text: bondsCloseDetails.symbol.toString(),
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
            ),
            // const SizedBox(height: 16),
            // TextWidget.paraText(
            //   text: bondsCloseDetails.symbol.toString(),
            //   theme: theme.isDarkMode,
            //   color: colors.textSecondaryLight,
            //   fw: 0,
            // ),
          ],
        ),
      ],
    );
  }
}

class _OrderIdRow extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _OrderIdRow({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = bondsCloseDetails.reponseStatus == "success";
    final isFailed = bondsCloseDetails.reponseStatus == "new failed" ||
        bondsCloseDetails.reponseStatus == "failed";
    return Column(
      children: [
        data(
          "Order Id",
          bondsCloseDetails.applicationNumber != ""
              ? bondsCloseDetails.applicationNumber.toString()
              : " - ",
          theme,
        ),
        Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.subText(
                  text: "Order Status",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
              fw: 0,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1)
                            : isFailed
                                ? theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1)
                                : colors.pending.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextWidget.paraText(
                        text: isSuccess
                            ? "Cancelled"
                            : isFailed
                                ? "Failed"
                                : "Pending",
                        theme: false,
                        color: isSuccess
                            ? theme.isDarkMode ? colors.lossDark : colors.lossLight
                            : isFailed
                                ? theme.isDarkMode ? colors.lossDark : colors.lossLight
                                : colors.pending,
                        fw: 0,
                      ),
                    ),

                    // SvgPicture.asset(
                    //   isSuccess
                    //       ? "assets/icon/failed.svg"
                    //       : isFailed
                    //           ? "assets/icon/failed.svg"
                    //           : "assets/icon/pendingicon.svg",
                    // ),
                    // const SizedBox(width: 4),
                    // TextWidget.subText(
                    //   text: isSuccess
                    // ? "Cancelled"
                    // : isFailed
                    //     ? "Failed"
                    //     : "Pending",
                    //   theme: theme.isDarkMode,
                    //   color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    // ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(
              thickness: 0,
              color:
                  theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            )
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _StatusBadge({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = bondsCloseDetails.reponseStatus == "success";
    final isFailed = bondsCloseDetails.reponseStatus == "new failed" ||
        bondsCloseDetails.reponseStatus == "failed";

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSuccess
                ? colors.error.withOpacity(0.1)
                : isFailed
                    ? colors.error.withOpacity(0.1)
                    : colors.pending.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextWidget.paraText(
            text: isSuccess
                ? "Cancelled"
                : isFailed
                    ? "Failed"
                    : "Pending",
            theme: false,
            color: isSuccess
                ? colors.error
                : isFailed
                    ? colors.error
                    : colors.pending,
          ),
        ),
        // SvgPicture.asset(
        //   isSuccess
        //       ? "assets/icon/failed.svg"
        //       : isFailed
        //           ? "assets/icon/failed.svg"
        //           : "assets/icon/pendingicon.svg",
        // ),
        // const SizedBox(width: 4),
        // TextWidget.subText(
        //   text: isSuccess
        //       ? "Cancelled"
        //       : isFailed
        //           ? "Failed"
        //           : "Pending",
        //   theme: theme.isDarkMode,
        //   color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        //   fw: 2,
        // ),
      ],
    );
  }
}

class _PaymentStatusRow extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _PaymentStatusRow({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = bondsCloseDetails.clearingStatus == "";
    return Column(
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextWidget.subText(
              text: "Payment",
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isEmpty
                        ? theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1)
                        : bondsCloseDetails.clearingStatus.toString() ==
                                "Fund Pending"
                            ? theme.isDarkMode ? colors.pending.withOpacity(0.1) : colors.pending.withOpacity(0.1)
                            : theme.isDarkMode ? colors.profit.withOpacity(0.1) : colors.profit.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextWidget.paraText(
                    text: isEmpty
                        ? "Failed"
                        : bondsCloseDetails.clearingStatus.toString() ==
                                "Fund Pending"
                            ? "Fund Pending"
                            : "Success",
                    theme: false,
                    color: isEmpty
                        ? theme.isDarkMode ? colors.lossDark : colors.lossLight
                        : bondsCloseDetails.clearingStatus.toString() ==
                                "Fund Pending"
                            ? theme.isDarkMode ? colors.pending : colors.pending
                            : theme.isDarkMode ? colors.profitDark : colors.profitLight,
                    fw: 0,
                  ),
                ),
                // SvgPicture.asset(
                //   isEmpty
                //       ? "assets/icon/failed.svg"
                //       : "assets/icon/success.svg",
                // ),
                // const SizedBox(width: 4),
                // TextWidget.subText(
                //   text: isEmpty
                //       ? "Failed"
                //       : bondsCloseDetails.clearingStatus.toString(),
                //   theme: theme.isDarkMode,
                //   color: theme.isDarkMode
                //       ? colors.textPrimaryDark
                //       : colors.textPrimaryLight,
                // ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          thickness: 0,
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        )
      ],
    );
  }
}

class _ReasonSection extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _ReasonSection({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return data(
      "Reason",
      bondsCloseDetails.failReason == ""
          ? " - "
          : bondsCloseDetails.failReason.toString(),
      theme,
    );
  }
}

class _OrderDetailsSection extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _OrderDetailsSection({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        data(
          "Quantity",
          // (bondsCloseDetails.bidDetail!.investmentValue! / bondsCloseDetails.bidDetail!.price!).toStringAsFixed(0),

          (double.parse(bondsCloseDetails.totalAmountPayable!) /
                  bondsCloseDetails.bidDetail!.price!)
              .toStringAsFixed(0),
          theme,
        ),
        data(
          "Price",
          "${bondsCloseDetails.bidDetail!.price!}",
          theme,
        ),
        data(
          "Order no",
          bondsCloseDetails.orderNumber != null
              ? bondsCloseDetails.orderNumber!.toString()
              : " - ",
          theme,
        ),
        data(
          "Bid Date & Time",
          bondsCloseDetails.responseDatetime.toString() == ""
              ? "----"
              : ipodateres(bondsCloseDetails.responseDatetime.toString()),
          theme,
        ),
      ],
    );
  }
}

class _BidDetailsSection extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _BidDetailsSection({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, top: 16, bottom: 8),
          child: TextWidget.subText(
            text: "Bid order Details",
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextWidget.paraText(
            //   text: "Bid Details",
            //   theme: false,
            //   color: colors.colorGrey,
            //   fw: 0,
            // ),
            _BidDetailsTable(
                bondsCloseDetails: bondsCloseDetails, theme: theme),
          ],
        ),
      ],
    );
  }
}

class _BidDetailsTable extends StatelessWidget {
  final BondsOrderBookModel bondsCloseDetails;
  final ThemesProvider theme;

  const _BidDetailsTable({
    required this.bondsCloseDetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(
          cardColor: Colors.transparent,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
          dataTableTheme: const DataTableThemeData(
            headingTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            dataTextStyle: TextStyle(color: Colors.white),
            dividerThickness: 1.0,
          ),
        ),
        child: DataTable(
          columnSpacing: 16.0,
          horizontalMargin: 0,
          headingRowHeight: 40.0,
          border: const TableBorder(
            horizontalInside: BorderSide(color: Colors.white54, width: 0.8),
          ),
          columns: [
            DataColumn(
              label: TextWidget.subText(
                text: "Qty",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ),
            DataColumn(
              label: TextWidget.subText(
                text: "Price",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ),
            DataColumn(
              label: TextWidget.subText(
                text: "Amount",
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ),
          ],
          rows: [
            DataRow(cells: [
              DataCell(
                TextWidget.paraText(
                  text:
                      // (bondsCloseDetails.bidDetail!.investmentValue! / bondsCloseDetails.bidDetail!.price!).toStringAsFixed(0),

                      "${(double.parse(bondsCloseDetails.totalAmountPayable!) / bondsCloseDetails.bidDetail!.price!).toStringAsFixed(0)}",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ),
              DataCell(
                TextWidget.paraText(
                  text: "${bondsCloseDetails.bidDetail!.price!}",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ),
              DataCell(
                TextWidget.paraText(
                  text: "₹${getFormatter(
                    noDecimal: true,
                    v4d: false,
                    value: double.parse(bondsCloseDetails.totalAmountPayable!),
                  )}",
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
