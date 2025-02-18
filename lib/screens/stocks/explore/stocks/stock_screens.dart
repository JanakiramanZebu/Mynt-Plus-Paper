import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/screens/stocks/explore/carousel_screen.dart';

import 'indices/top_indices.dart';
import 'trade_action/trade_action_widget.dart';
// import 'news/news_screen.dart';
// import 'stock_monitor/stock_monitor_screen.dart';
// import 'trade_action/corporate_action.dart';
// import 'trade_action/trade_action_widget.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Expanded(
            //   child: ListView(children: const [
            //     // ExploreWidget(),
            //     TopIndices(),
            //     // SizedBox(height: 16),
            //     // TradeAction(),
            //     // StockMonitorScreen(),
            //     // // TradeScreen(),
            //     // // GridViewScreen(),
            //     // SizedBox(height: 16),
            //     // CorporateAction(),
            //     // NewsScreen(),
            //   ]),
            // ),
            const TopIndices(),

            const SizedBox(
              height: 32,
            ),

MyCarousel(),
            
            Text("Most products",
                style: GoogleFonts.inter(
                    textStyle: textStyle(
                        const Color(0xff000000), 16, FontWeight.w600))),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.24,
              children: [
                ServiceCard(
                  icon: "assets/icon/dashboard/ipo.svg",
                  title: "IPO's",
                  description: "A company's first public stock offering",
                ),
                ServiceCard(
                  icon: "assets/icon/dashboard/mf.svg",
                  title: "Mutual Fund's",
                  description: "Invest in experts managed portfolio",
                ),
                ServiceCard(
                  icon: "assets/icon/dashboard/op.svg",
                  title: "Option Chain",
                  description: "Option chain with real-time prices",
                ),
                ServiceCard(
                  icon: "assets/icon/dashboard/desk.svg",
                  title: "Desk",
                  description: "Your person info, reports, ledger & more",
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              TextButton(
                  onPressed: () async {},
                  child: Text("Most used products",
                      style: GoogleFonts.inter(
                          color: const Color(0xff0037B7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)))
            ]),

            const SizedBox(
              height: 16,
            ),
            // Text("Today's trade action",
            //     style: GoogleFonts.inter(
            //         textStyle: textStyle(
            //             const Color(0xff000000), 16, FontWeight.w600))),
            // const SizedBox(height: 8),
            const TradeAction(),

                    const SizedBox(height: 32),
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

  Widget ServiceCard(
      {required String icon,
      required String title,
      required String description}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF), // White at 10%
            Color(0xFFF1F3F8), // Light Gray at 60%
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.6], // 10% and 60%
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            icon,
            width: 50,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
