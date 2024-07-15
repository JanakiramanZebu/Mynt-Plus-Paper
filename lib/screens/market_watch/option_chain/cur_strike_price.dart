import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/websocket_provider.dart';

class CurStrkprice extends ConsumerWidget {
  final String token;

  const CurStrkprice({super.key, required this.token});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final strikePrc = watch(marketWatchProvider).getStikePrc?? watch(marketWatchProvider).getQuotes;
    final socketDatas = watch(websocketProvider).socketDatas;
    strikePrc!.lp = strikePrc.lp ?? "0.00";
    if (socketDatas.containsKey(token)) {
      strikePrc.lp = "${socketDatas[token]['lp']}";
    }

    watch(marketWatchProvider).updateOptStrPrc("${strikePrc.lp}");
    return Row(
      children: [
        const Expanded(
          child: Divider(height: 0, thickness: 2.5, color: Color(0xff666666)),
        ),
        Container(
            decoration: BoxDecoration(
                color: const Color(0xff666666),
                borderRadius: BorderRadius.circular(40)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text("₹${strikePrc.lp}",
                style:
                    textStyle(const Color(0xffffffff), 13, FontWeight.w600))),
        const Expanded(
          child: Divider(height: 0, thickness: 2.5, color: Color(0xff666666)),
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
