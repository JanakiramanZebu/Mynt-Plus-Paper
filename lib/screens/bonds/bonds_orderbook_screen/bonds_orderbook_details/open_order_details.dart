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
    
    return Scaffold(
      appBar: _buildAppBar(context, theme),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(bondsdetails: bondsdetails, theme: theme),
            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            _ReasonSection(bondsdetails: bondsdetails, theme: theme),
            _CancelOrderButton(bondsdetails: bondsdetails, theme: theme),
            Divider(
              height: 0,
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            const SizedBox(height: 8),
            _OrderDetailsSection(bondsdetails: bondsdetails, theme: theme),
            _BidDetailsSection(bondsdetails: bondsdetails, theme: theme),
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
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _HeaderSection({
    required this.bondsdetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SymbolInfo(bondsdetails: bondsdetails, theme: theme),
          const SizedBox(height: 16),
          _OrderIdRow(bondsdetails: bondsdetails, theme: theme),
          const SizedBox(height: 16),
          _PaymentStatusRow(bondsdetails: bondsdetails, theme: theme),
        ],
      ),
    );
  }
}

class _SymbolInfo extends StatelessWidget {
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _SymbolInfo({
    required this.bondsdetails,
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
              bondsdetails.symbol.toString(),
              style: textStyles.scripNameTxtStyle.copyWith(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              bondsdetails.symbol.toString(),
              style: textStyles.scripExchTxtStyle,
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderIdRow extends StatelessWidget {
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _OrderIdRow({
    required this.bondsdetails,
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
                    style: BondsOpenOrderDetails._textStyle(
                      colors.colorGrey,
                      14,
                      FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: bondsdetails.applicationNumber != ""
                        ? bondsdetails.applicationNumber.toString()
                        : " - ",
                    style: BondsOpenOrderDetails._textStyle(
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
        _StatusBadge(bondsdetails: bondsdetails, theme: theme),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _StatusBadge({
    required this.bondsdetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = bondsdetails.reponseStatus == "success";
    
    return Row(
      children: [
        SvgPicture.asset(
          isSuccess
              ? "assets/icon/success.svg"
              : "assets/icon/pendingicon.svg",
        ),
        const SizedBox(width: 4),
        Text(
          isSuccess ? "Success" : "Pending",
          style: BondsOpenOrderDetails._textStyle(
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
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _PaymentStatusRow({
    required this.bondsdetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = bondsdetails.clearingStatus == "";
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment",
              style: BondsOpenOrderDetails._textStyle(
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
              isPending
                  ? "assets/icon/pendingicon.svg"
                  : "assets/icon/success.svg",
            ),
            const SizedBox(width: 4),
            Text(
              isPending ? "Pending" : bondsdetails.clearingStatus.toString(),
              style: BondsOpenOrderDetails._textStyle(
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
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _ReasonSection({
    required this.bondsdetails,
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
            style: BondsOpenOrderDetails._textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bondsdetails.failReason == ""
                ? "Order placed successfully"
                : bondsdetails.failReason.toString(),
            style: BondsOpenOrderDetails._textStyle(
              colors.colorGrey,
              14,
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelOrderButton extends StatelessWidget {
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _CancelOrderButton({
    required this.bondsdetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  width: 1.4,
                  color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack,
                ),
                padding: const EdgeInsets.symmetric(vertical: 9),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Cancel Order",
                  style: BondsOpenOrderDetails._textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BondCancelAlert(bondcancel: bondsdetails);
      },
    );
  }
}

class _OrderDetailsSection extends StatelessWidget {
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _OrderDetailsSection({
    required this.bondsdetails,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDetailRow("Order no", 
          bondsdetails.orderNumber != null
              ? bondsdetails.orderNumber!.toString()
              : " - ", 
          theme),
        _buildDetailRow("Quantity",
          "${(double.parse(bondsdetails.totalAmountPayable!) / bondsdetails.bidDetail!.price!).toStringAsFixed(0)}",
          theme),
        _buildDetailRow("Price", "${bondsdetails.bidDetail!.price!}", theme),
        _buildDetailRow("Total amount",
          "₹${getFormatter(
            noDecimal: true,
            v4d: false,
            value: double.parse(bondsdetails.totalAmountPayable!.toString()).toDouble(),
          )}",
          theme),
        _buildDetailRow("Bid Date & Time",
          bondsdetails.responseDatetime.toString() == ""
              ? "----"
              : ipodateres(bondsdetails.responseDatetime.toString()),
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
                style: BondsOpenOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: BondsOpenOrderDetails._textStyle(
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
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _BidDetailsSection({
    required this.bondsdetails,
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
            style: BondsOpenOrderDetails._textStyle(
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
                style: BondsOpenOrderDetails._textStyle(
                  colors.colorGrey,
                  12,
                  FontWeight.w500,
                ),
              ),
              _BidDetailsTable(bondsdetails: bondsdetails, theme: theme),
            ],
          ),
        ),
      ],
    );
  }
}

class _BidDetailsTable extends StatelessWidget {
  final BondsOrderBookModel bondsdetails;
  final ThemesProvider theme;

  const _BidDetailsTable({
    required this.bondsdetails,
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
                style: BondsOpenOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Price",
                style: BondsOpenOrderDetails._textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                "Amount",
                style: BondsOpenOrderDetails._textStyle(
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
                  "${(double.parse(bondsdetails.totalAmountPayable!) / bondsdetails.bidDetail!.price!).toStringAsFixed(0)}",
                  style: BondsOpenOrderDetails._textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    12,
                    FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Text(
                  "${bondsdetails.bidDetail!.price!}",
                  style: BondsOpenOrderDetails._textStyle(
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
                    value: double.parse(bondsdetails.totalAmountPayable!),
                  )}",
                  style: BondsOpenOrderDetails._textStyle(
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
