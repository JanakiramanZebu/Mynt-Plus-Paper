import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';

import '../../../provider/stocks_provider.dart';
import '../../bonds/bond_screen.dart';
import '../../ipo/ipo_main_screen.dart';
import '../../mutual_fund/mutual_fund_screen.dart';
import 'stocks/stock_screens.dart';

 

// ignore: must_be_immutable
class ExploreScreens extends ConsumerWidget {
  ExploreScreens({super.key});

  PageController controller = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final explore = watch(stocksProvide);

    return Stack(
      children: [
        PageView(
          // itemCount: explore.exploreNames.length,
          scrollDirection: Axis.horizontal,
          controller: controller,
          onPageChanged: (int index) async {
            // print(   _index);
            explore.chngExpName(explore.exploreNames[index], index);
          },
          // itemBuilder: (BuildContext context, int index) {
          //   print(" xzc ${_index} ${explore.exploreIndex}");
          //   return explore.exploreName == "Stock"
          //       ? StockScreen()
          //       : explore.exploreName == "Mutual Fund"
          //           ? Center(child: Text("Mutual Fund"))
          //           : explore.exploreName == "IPOs"
          //               ? Center(child: Text("IPOs"))
          //               : Center(child: Text("Bonds"));
          // },
          children: const [
            StockScreen(),
            MutualFundScreen(),
            IPOScreen(),
            BondScreen()
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: PageViewDotIndicator(
            currentItem: explore.exploreIndex,
            count: explore.exploreNames.length,
            unselectedColor: Colors.black26,
            selectedColor: Colors.blue,
            duration: const Duration(milliseconds: 200),
            boxShape: BoxShape.rectangle,
            onItemClicked: (index) {
              controller.animateToPage(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
              );
            },
          ),
        ),
      ],
    );
  }
}
