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
    final theme = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: _buildAppBar(context, theme),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(bondsCloseDetails: bondsCloseDetails, theme: theme),
            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            _ReasonSection(bondsCloseDetails: bondsCloseDetails, theme: theme),
            const SizedBox(height: 16),
            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            const SizedBox(height: 8),
            _OrderDetailsSection(bondsCloseDetails: bondsCloseDetails, theme: theme),
            _BidDetailsSection(bondsCloseDetails: bondsCloseDetails, theme: theme),
          ],
        ),
      ),
    );
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
      title: Text(
        "Order Details",
        style: _textStyle(
          theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          16,
          FontWeight.w600,
        ),
      ),
    );
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        fontWeight: fWeight,
        color: color,
        fontSize: fontSize,
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SymbolInfo(bondsCloseDetails: bondsCloseDetails, theme: theme),
          const SizedBox(height: 16),
          _OrderIdRow(bondsCloseDetails: bondsCloseDetails, theme: theme),
          const SizedBox(height: 16),
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
            Text(
              bondsCloseDetails.symbol.toString(),
              style: textStyles.scripNameTxtStyle.copyWith(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              bondsCloseDetails.symbol.toString(),
              style: textStyles.scripExchTxtStyle,
            ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Order Id : ",
                    style: BondsCloseOrderDetails._textStyle(
                      colors.colorGrey,
                      14,
                      FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: bondsCloseDetails.applicationNumber != ""
                        ? bondsCloseDetails.applicationNumber.toString()
                        : " - ",
                    style: BondsCloseOrderDetails._textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      12,
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        _StatusBadge(bondsCloseDetails: bondsCloseDetails, theme: theme),
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
        SvgPicture.asset(
          isSuccess 
              ? "assets/icon/failed.svg"
              : isFailed
                  ? "assets/icon/failed.svg"
                  : "assets/icon/pendingicon.svg",
        ),
        const SizedBox(width: 4),
        Text(
          isSuccess 
              ? "Cancelled"
              : isFailed
                  ? "Failed"
                  : "Pending",
          style: BondsCloseOrderDetails._textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w600,
          ),
        ),
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
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment",
              style: BondsCloseOrderDetails._textStyle(
                colors.colorGrey,
                14,
                FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SvgPicture.asset(
              isEmpty
                  ? "assets/icon/failed.svg"
                  : "assets/icon/success.svg",
            ),
            const SizedBox(width: 4),
            Text(
              isEmpty ? "Failed" : bondsCloseDetails.clearingStatus.toString(),
              style: BondsCloseOrderDetails._textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w600,
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reason",
            style: BondsCloseOrderDetails._textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bondsCloseDetails.failReason == ""
                ? " - "
                : bondsCloseDetails.failReason.toString(),
            style: BondsCloseOrderDetails._textStyle(
              colors.colorGrey,
              13,
              FontWeight.w500,
            ),
          ),
        ],
      ),
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
        _buildDetailRow("Order no", 
          bondsCloseDetails.orderNumber != null
              ? bondsCloseDetails.orderNumber!.toString()
              : " - ", 
          theme),
        _buildDetailRow("Quantity",
          "${(double.parse(bondsCloseDetails.totalAmountPayable!) / bondsCloseDetails.bidDetail!.price!).toStringAsFixed(0)}",
          theme),
        _buildDetailRow("Price", "${bondsCloseDetails.bidDetail!.price!}", theme),
        _buildDetailRow("Bid Date & Time",
          bondsCloseDetails.responseDatetime.toString() == ""
              ? "----"
              : ipodateres(bondsCloseDetails.responseDatetime.toString()),
          theme),
      ],
    );
  }

  Widget _buildDetailRow(String name, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: BondsCloseOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: BondsCloseOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  12,
                  FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            height: 0,
            color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
          ),
        ],
      ),
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
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            "Bid order Details",
            style: BondsCloseOrderDetails._textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bid Details",
                style: BondsCloseOrderDetails._textStyle(
                  colors.colorGrey,
                  12,
                  FontWeight.w500,
                ),
              ),
              _BidDetailsTable(bondsCloseDetails: bondsCloseDetails, theme: theme),
            ],
          ),
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
              label: Text(
                "Qty",
                style: BondsCloseOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Price",
                style: BondsCloseOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Amount",
                style: BondsCloseOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
            ),
          ],
          rows: [
            DataRow(cells: [
              DataCell(
                Text(
                  "${(double.parse(bondsCloseDetails.totalAmountPayable!) / bondsCloseDetails.bidDetail!.price!).toStringAsFixed(0)}",
                  style: BondsCloseOrderDetails._textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Text(
                  "${bondsCloseDetails.bidDetail!.price!}",
                  style: BondsCloseOrderDetails._textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
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
                    value: double.parse(bondsCloseDetails.totalAmountPayable!),
                  )}",
                  style: BondsCloseOrderDetails._textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
