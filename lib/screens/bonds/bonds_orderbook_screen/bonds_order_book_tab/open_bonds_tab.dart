import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:mynt_plus/provider/bonds_provider.dart';
// import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
// import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';
import '../bonds_orderbook_details/open_order_details.dart';

class BondsOpenOrderList extends StatelessWidget {
  final List<dynamic> orders;
  final ThemesProvider theme;
  const BondsOpenOrderList({super.key, required this.orders, required this.theme});

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
              child: _navigateToDetails(context),),
        );
      },
      
      
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _OrderHeader(order: order, theme: theme),
            const SizedBox(height: 16),
            _OrderFooter(order: order, theme: theme),
          ],
        ),
      ),
    );
  }

   _navigateToDetails(BuildContext context) {

    return BondsOpenOrderDetails(bondsdetails: order);
    // Navigator.pushNamed(
    //   context,
    //   Routes.bondsopendetailsscreen,
    //   arguments: order,
    // );
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
        ),

         TextWidget.subText(
          text: "₹${getFormatter(
            noDecimal: true,
            v4d: false,
           value: double.parse(order.investmentValue!)
          )}",
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
        ),

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
            ),
          ],
        ),
        _StatusBadge(order: order, theme: theme),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [

             Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: order.reponseStatus == "new success"
                ? colors.success.withOpacity(0.1)
                : colors.pending.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextWidget.paraText(
            text: order.reponseStatus == "new success" ? "Success" : "Pending",
            theme: false,
            color: order.reponseStatus == "new success"
                ? colors.success
                : colors.pending,
          ),
        ),



            // SvgPicture.asset(
            //   order.reponseStatus == "new success"
            //       ? "assets/icon/success.svg"
            //       : "assets/icon/pendingicon.svg",
            // ),o
            // const SizedBox(width: 5),
            // Text(
            //   order.reponseStatus == "new success" ? "Success" : "Pending",
            //   style: _textStyle(
            //     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            //     14,
            //     FontWeight.w600,
            //   ),
            // ),
          ],
        ),
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


