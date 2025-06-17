import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class BondsOpenOrder extends ConsumerWidget {
  const BondsOpenOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final bonds = ref.watch(bondsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrdersList(bonds: bonds, theme: theme),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final BondsProvider bonds;
  final ThemesProvider theme;

  const _OrdersList({
    required this.bonds,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bonds.openOrderBook!.length,
      itemBuilder: (context, index) => _OrderItem(
        order: bonds.openOrderBook![index],
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
      onTap: () => _navigateToDetails(context),
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

  void _navigateToDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      Routes.bondsopendetailsscreen,
      arguments: order,
    );
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
        Text(
          order.symbol.toString(),
          style: textStyles.scripNameTxtStyle.copyWith(
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          ),
        ),
        Text(
          "₹${getFormatter(
            noDecimal: true,
            v4d: false,
            value: double.parse(order.investmentValue!),
          )}",
          style: _textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w600,
          ),
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
            Text(
              order.responseDatetime.toString() == ""
                  ? "----"
                  : ipodateres(order.responseDatetime.toString()),
              style: _textStyle(
                const Color(0xff666666),
                12,
                FontWeight.w600,
              ),
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
            SvgPicture.asset(
              order.reponseStatus == "new success"
                  ? "assets/icon/success.svg"
                  : "assets/icon/pendingicon.svg",
            ),
            const SizedBox(width: 5),
            Text(
              order.reponseStatus == "new success" ? "Success" : "Pending",
              style: _textStyle(
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

TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
  return GoogleFonts.inter(
    textStyle: TextStyle(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    ),
  );
}
