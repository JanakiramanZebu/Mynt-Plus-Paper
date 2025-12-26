import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/global_state_text.dart';

class CurStrkprice extends ConsumerWidget {
  final String token;

  const CurStrkprice({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strikePrc = ref.watch(marketWatchProvider).getStikePrc ?? ref.watch(marketWatchProvider).getQuotes;
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStrikePriceWidget(strikePrc!.lp ?? "0.00", strikePrc.pc ?? "0.00");
        }
        
        final socketDatas = snapshot.data!;
        String price = strikePrc!.lp ?? "0.00";
        String pc = strikePrc.pc ?? "0.00";
        if (socketDatas.containsKey(token)) {
          price = "${socketDatas[token]['lp']}";
          pc = "${socketDatas[token]['pc']}";
        }
        
        ref.watch(marketWatchProvider).updateOptStrPrc(price);
        return _buildStrikePriceWidget(price, pc);
      },
    );
  }
  
  Widget _buildStrikePriceWidget(String price, String pc) {
    return Row(
      children: [
        const Expanded(
          child: Divider(height: 0, thickness: 2.5, color: Color(0xff666666)),
        ),
        Container(
            decoration: BoxDecoration(
                color: const Color(0xff666666),
                borderRadius: BorderRadius.circular(40)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: 
                    
                    
                     TextWidget.subText(
                      text:"₹$price (${double.parse(pc).toStringAsFixed(2)}%)" ,
                      color:const Color(0xffffffff) ,
                      theme: false,
                      fw: 0),
                    
                    
                    
                    ),
        const Expanded(
          child: Divider(height: 0, thickness: 2.5, color: Color(0xff666666)),
        ),
      ],
    );
  }

 
}
