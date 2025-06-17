// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class IpoCancelAlert extends ConsumerWidget {
  final IpoOrderBookModel ipocancel;
  
  const IpoCancelAlert({super.key, required this.ipocancel});

  static const Color _greyButtonColor = Color(0xffF1F3F8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    
    return AlertDialog(
      backgroundColor: theme.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: const Padding(
        padding: EdgeInsets.all(10),
        child: _CancelIcon(),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Text(
                "Are you sure you want to cancel the (${ipocancel.symbol} order)",
                textAlign: TextAlign.center,
                style: _textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600))
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(155, 40),
                      elevation: 0,
                      backgroundColor: _greyButtonColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      )),
                  onPressed: () => Navigator.pop(context),
                  child: Text("No",
                      style: _textStyle(colors.colorGrey, 12, FontWeight.w500))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(155, 40),
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      )),
                  onPressed: () => _handleCancelOrder(context, ref),
                  child: Text("Yes",
                      style: _textStyle(
                          theme.isDarkMode
                              ? colors.colorBlack
                              : colors.colorWhite,
                          12,
                          FontWeight.w500))),
            )
          ],
        ),
      ],
    );
  }

  Future<void> _handleCancelOrder(BuildContext context, WidgetRef ref) async {
    final menudata = MenuData(
      flow: "can",
      type: ipocancel.type.toString(),
      symbol: ipocancel.symbol.toString(),
      category: "",
      name: ipocancel.companyName.toString(),
      applicationNumber: ipocancel.applicationNumber.toString(),
      respBid: [BidReference(bidReferenceNumber: '67890')],
    );

    const List<IposBid> iposbids = [];

    await ref
        .read(ipoProvide)
        .getipoplaceorder(context, menudata, iposbids, "");
    
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}

class _CancelIcon extends StatelessWidget {
  const _CancelIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset("assets/icon/ipo_cancel_icon.svg");
  }
}
