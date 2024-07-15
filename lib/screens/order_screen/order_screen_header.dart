import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
 
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/res.dart';

class OrderScreenHeader extends ConsumerWidget {
  final OrderScreenArgs headerData;
  const OrderScreenHeader({super.key, required this.headerData});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final socketDatas = watch(websocketProvider).socketDatas;
    final theme=watch(themeProvider);
    if (socketDatas.containsKey(headerData.token)) {
      headerData.ltp = "${socketDatas[headerData.token]['lp']}";
      headerData.perChange = "${socketDatas[headerData.token]['pc']}";
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "₹${headerData.ltp} ",
           style: textStyle(theme.isDarkMode?colors.colorWhite:colors.colorBlack,
                                          16, FontWeight.w600)
        ),
        Text(
          " (${headerData.perChange ?? 0.00}%)",
          style: textStyle(
              Color(headerData.perChange!.startsWith("-")
                  ? 0xffFF1717
                  : 0xff43A833),
              13,
              FontWeight.w600),
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
