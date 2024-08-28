import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../provider/iop_provider.dart';
import '../../../res/res.dart';

class IpoCancelAlert extends ConsumerWidget {
  final IpoOrderBookModel ipocancel;
  const IpoCancelAlert({super.key, required this.ipocancel});
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
      ),
      content: Column(
        children: [
          Text(
              "Are you sure you want to cancel the (${ipocancel.symbol} order)",
              textAlign: TextAlign.center,
              style: textStyle(const Color(0xff000000), 16, FontWeight.w600))
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xffF1F3F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("No",
                      style: textStyle(colors.colorGrey, 12, FontWeight.w600))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: colors.colorBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () async {
                    MenuData menudata = MenuData(
                      flow: "can",
                      type: ipocancel.type.toString(),
                      symbol: ipocancel.symbol.toString(),
                      category: "",
                      name: ipocancel.companyName.toString(),
                      applicationNumber:
                          ipocancel.applicationNumber.toString(),
                      respBid: [BidReference(bidReferenceNumber: '67890')],
                    );

                    List<IposBid> iposbids = [];

                    await context
                        .read(ipoProvide)
                        .getipoplaceorder(context, menudata, iposbids, "");
                  },
                  child: Text("Yes",
                      style:
                          textStyle(colors.colorWhite, 12, FontWeight.w600))),
            )
          ],
        ),
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
