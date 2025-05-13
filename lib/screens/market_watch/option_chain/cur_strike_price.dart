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
    final strikePrc = watch(marketWatchProvider).getStikePrc ?? watch(marketWatchProvider).getQuotes;
    
    return StreamBuilder<Map>(
      stream: watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStrikePriceWidget(strikePrc!.lp ?? "0.00");
        }
        
        final socketDatas = snapshot.data!;
        String price = strikePrc!.lp ?? "0.00";
        
        if (socketDatas.containsKey(token)) {
          price = "${socketDatas[token]['lp']}";
        }
        
        watch(marketWatchProvider).updateOptStrPrc(price);
        return _buildStrikePriceWidget(price);
      },
    );
  }
  
  Widget _buildStrikePriceWidget(String price) {
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
            child: Text("₹$price",
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
