import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mynt_plus/provider/bonds_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';
// import '../../../../routes/route_names.dart';
import '../../../../../sharedWidget/functions.dart';
import '../bonds_orderbook_details/close_order_details.dart';
import '../../../../../res/global_state_text.dart';

class BondsCloseOrderList extends StatelessWidget {
  final List<dynamic> orders;
  final ThemesProvider theme;
  const BondsCloseOrderList({super.key, required this.orders, required this.theme});

  @override
  Widget build(BuildContext context) {
    return _OrdersList(orders: orders, theme: theme);
  }
}

class _OrdersList extends StatelessWidget {
  final List<dynamic> orders;
  final ThemesProvider theme;

  const _OrdersList({
    required this.orders,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const SizedBox();
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) => _OrderItem(
        order: orders[index],
        theme: theme,
      ),
      separatorBuilder: (context, index) => _OrderDivider(theme: theme),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final dynamic order;
  final ThemesProvider theme;

  const _OrderItem({
    required this.order,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          isDismissible: true,
          enableDrag: false,
          useSafeArea: true,
          context: context,
          builder: (context) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _navigateToDetails(context)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _OrderHeader(order: order, theme: theme),
            const SizedBox(height: 8),
            _OrderFooter(order: order, theme: theme),
          ],
        ),
      ),
    );
  }

  _navigateToDetails(BuildContext context) {
    return BondsCloseOrderDetails(bondsCloseDetails: order);
  }
}

class _OrderHeader extends StatelessWidget {
  final dynamic order;
  final ThemesProvider theme;

  const _OrderHeader({
    required this.order,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.subText(
          text: order.symbol.toString(),
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 0,
        ),
        _StatusBadge(order: order, theme: theme),
      ],
    );
  }
}

class _OrderFooter extends StatelessWidget {
  final dynamic order;
  final ThemesProvider theme;

  const _OrderFooter({
    required this.order,
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
            TextWidget.paraText(
              text: order.responseDatetime.toString() == ""
                  ? "----"
                  : ipodateres(order.responseDatetime.toString()),
              theme: false,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
          ],
        ),
        TextWidget.subText(
          text: getFormatter(
            noDecimal: true,
            v4d: false,
            value: double.parse(order.investmentValue.toString()).toDouble(),
          ),
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 0,
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final dynamic order;
  final ThemesProvider theme;

  const _StatusBadge({
    required this.order,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: order.reponseStatus == "Cancel Success"
                ? colors.loss.withOpacity(0.1)
                : colors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextWidget.paraText(
            text: order.reponseStatus == "Cancel Success"
                ? "Cancelled"
                : "Failed",
            theme: false,
            color: order.reponseStatus == "Cancel Success"
                ? colors.error
                : colors.error,
            fw: 0,
          ),
        ),

        // SvgPicture.asset(
        //   order.reponseStatus == "Cancel Success"
        //       ? "assets/icon/failed.svg"
        //       : "assets/icon/failed.svg",
        // ),
        // const SizedBox(width: 5),
        // TextWidget.subText(
        //   text: order.reponseStatus == "Cancel Success" ? "Cancelled" : "Failed",
        //   theme: theme.isDarkMode,
        //   color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        //   fw: 2,
        // ),
      ],
    );
  }
}

class _OrderDivider extends StatelessWidget {
  final ThemesProvider theme;

  const _OrderDivider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
    );
  }
}
