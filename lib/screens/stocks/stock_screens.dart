import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../screens/stocks/gridView/grid_view_screen.dart';
import '../../../../screens/stocks/indices/top_indices.dart'; 
import '../../../../screens/stocks/news/news_screen.dart'; 
import '../../../../screens/stocks/trade/trade_screen.dart';
// import '../../../../screens/stocks/tradeAction/trade_actions.dart';
import '../../res/res.dart';
 

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leadingWidth: 26,
          centerTitle: false,
          title: Text(
            "Stocks",
            style: textStyle(const Color(0xff000000), 18, FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          elevation: .3,
          iconTheme: const IconThemeData(color: Color(0xff000000)),
          backgroundColor: colors.colorWhite),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopIndices(),
            SizedBox(
              height: 16
            ),
            // TradeAction(),
            TradeScreen(),
            GridViewScreen(),
            NewsScreen(),
            SizedBox(
              height: 15,
            )
          ],
        ),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
