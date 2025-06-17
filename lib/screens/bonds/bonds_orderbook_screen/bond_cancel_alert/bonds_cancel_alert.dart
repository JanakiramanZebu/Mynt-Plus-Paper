// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/bonds_model/bonds_order_book_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';

class BondCancelAlert extends ConsumerWidget {
  final BondsOrderBookModel bondcancel;
  const BondCancelAlert({super.key, required this.bondcancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final bonds = ref.watch(bondsProvider);
    
    return AlertDialog(
      backgroundColor: theme.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: _AlertIcon(),
      content: _AlertContent(bondcancel: bondcancel, theme: theme),
      actions: [
        _ActionButtons(
          bondcancel: bondcancel,
          bonds: bonds,
          theme: theme,
        ),
      ],
    );
  }
}

class _AlertIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
    );
  }
}

class _AlertContent extends StatelessWidget {
  final BondsOrderBookModel bondcancel;
  final ThemesProvider theme;

  const _AlertContent({
    required this.bondcancel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            "Are you sure you want to cancel the (${bondcancel.symbol} order)",
            textAlign: TextAlign.center,
            style: _textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              16,
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final BondsOrderBookModel bondcancel;
  final BondsProvider bonds;
  final ThemesProvider theme;

  const _ActionButtons({
    required this.bondcancel,
    required this.bonds,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _NoButton(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _YesButton(
            bondcancel: bondcancel,
            bonds: bonds,
            theme: theme,
          ),
        ),
      ],
    );
  }
}

class _NoButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(155, 40),
        elevation: 0,
        backgroundColor: const Color(0xffF1F3F8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text(
        "No",
        style: _textStyle(colors.colorGrey, 12, FontWeight.w500),
      ),
    );
  }
}

class _YesButton extends ConsumerWidget {
  final BondsOrderBookModel bondcancel;
  final BondsProvider bonds;
  final ThemesProvider theme;

  const _YesButton({
    required this.bondcancel,
    required this.bonds,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(155, 40),
        elevation: 0,
        backgroundColor: theme.isDarkMode
            ? colors.colorbluegrey
            : colors.colorBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onPressed: () => _handleCancelOrder(context, ref),
      child: Text(
        "Yes",
        style: _textStyle(
          theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          12,
          FontWeight.w500,
        ),
      ),
    );
  }

  void _handleCancelOrder(BuildContext context, WidgetRef ref) async {
    Map<String, dynamic> bondOrderData = {};
    bondOrderData["clientApplicationNumber"] = bondcancel.clientApplicationNumber;
    bondOrderData["orderNumber"] = bondcancel.orderNumber;
    bondOrderData["symbol"] = bondcancel.symbol;
    bondOrderData["investmentValue"] = bondcancel.investmentValue;
    bondOrderData["price"] = bondcancel.bidDetail?.price ?? 0;

    Navigator.pop(context);
    Navigator.pop(context);

    await ref.read(bondsProvider).cancelBondOrder(context, bondOrderData);
    print('cancel bond data :::::::; $bondOrderData');
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
