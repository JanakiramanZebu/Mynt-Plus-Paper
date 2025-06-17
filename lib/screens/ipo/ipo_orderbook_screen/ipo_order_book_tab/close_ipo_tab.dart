import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class IpoCloseOrder extends ConsumerWidget {
  const IpoCloseOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ipo.closeorder!.length,
            itemBuilder: (context, index) => _CloseOrderItem(
              order: ipo.closeorder![index],
              theme: theme,
            ),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                  height: 0,
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider);
            },
          )
        ],
      ),
    );
  }
}

class _CloseOrderItem extends StatelessWidget {
  final dynamic order;
  final dynamic theme;

  const _CloseOrderItem({
    required this.order,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, Routes.ipoclosedetailsscreen,
            arguments: order);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTopRow(),
            const SizedBox(height: 16),
            _buildBottomRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 250,
          child: Text(
            order.companyName.toString(),
            style: textStyles.scripNameTxtStyle.copyWith(
                color: theme.isDarkMode
                    ? colors.colorWhite
                    : colors.colorBlack),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          _getInvestedAmount(),
          style: _textStyle(
              theme.isDarkMode
                  ? colors.colorWhite
                  : colors.colorBlack,
              14,
              FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          order.responseDatetime.toString() == ""
              ? "----"
              : ipodateres(order.responseDatetime.toString()),
          style: _textStyle(
              const Color(0xff666666),
              12,
              FontWeight.w600),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SvgPicture.asset(
                order.reponseStatus == "cancel success"
                    ? "assets/icon/failed.svg"
                    : "assets/icon/failed.svg"),
            const SizedBox(width: 4),
            Text(
              order.reponseStatus == "cancel success"
                  ? "Cancelled"
                  : "Failed",
              style: _textStyle(
                  theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                  14,
                  FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _getInvestedAmount() {
    return order.type == "BSE"
        ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(order.bidDetail![0].rate!) * double.parse(order.bidDetail![0].quantity!)).toString()}"
        : "₹${getFormatter(
            noDecimal: true,
            v4d: false,
            value: double.parse(order.bidDetail![0].amount.toString()).toDouble(),
          )}";
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
