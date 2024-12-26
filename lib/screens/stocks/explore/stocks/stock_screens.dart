import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'indices/top_indices.dart';
// import 'news/news_screen.dart';
// import 'stock_monitor/stock_monitor_screen.dart';
// import 'trade_action/corporate_action.dart';
// import 'trade_action/trade_action_widget.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      // ExploreWidget(),
      TopIndices(),
      // SizedBox(height: 16),
      // TradeAction(),
      // StockMonitorScreen(),
      // // TradeScreen(),
      // // GridViewScreen(),
      // SizedBox(height: 16),
      // CorporateAction(),
      // NewsScreen(),
    ]);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
