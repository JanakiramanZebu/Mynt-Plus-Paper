import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../provider/portfolio_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import 'holdings/holding_screen.dart';
import 'mfHoldings/mf_holding_screen.dart';
import 'positions/position_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    context.read(portfolioProvider).portTab = TabController(
        length: context.read(portfolioProvider).portTabName.length,
        vsync: this,
        initialIndex: context.read(portfolioProvider).selectedTab);

    context.read(portfolioProvider).portTab.addListener(() {
      context
          .read(portfolioProvider)
          .changeTabIndex(context.read(portfolioProvider).portTab.index);
      context.read(portfolioProvider).tabSize();
      if (context.read(portfolioProvider).selectedTab == 0) {

        context
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe:false);
        context
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: true);

      } else   if (context.read(portfolioProvider).selectedTab == 1){
          context
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: false);
        context
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: true);

      }else{
        context
            .read(portfolioProvider)
            .requestWSPosition(context: context, isSubscribe: false);
        context
            .read(portfolioProvider)
            .requestWSHoldings(context: context, isSubscribe: false);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final portfolio = watch(portfolioProvider);    final theme = context.read(themeProvider);
      return Column(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
             
              height: 46,
              child: TabBar(
                
                 tabAlignment:portfolio.mfHoldingsModel!.isNotEmpty&& portfolio.mfHoldingsModel![0].stat != "Not_Ok" ? TabAlignment.start:TabAlignment.fill,
                          indicatorSize: TabBarIndicatorSize.label,
                          isScrollable:portfolio.mfHoldingsModel!.isNotEmpty&& portfolio.mfHoldingsModel![0].stat != "Not_Ok" ,
                  indicatorColor:theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
                  unselectedLabelColor: const Color(0XFF777777),
                  unselectedLabelStyle: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.28)),
                  labelColor: theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
                  labelStyle: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  controller: portfolio.portTab,
                  tabs: portfolio.portTabName)),
          Expanded(
              child: TabBarView(controller: portfolio.portTab, children: [
            PositionScreen(listofPosition: portfolio.allPostionList),
            const HoldingScreen(),

               if (portfolio.mfHoldingsModel!.isNotEmpty)...[
        if (portfolio.mfHoldingsModel![0].stat != "Not_Ok")...[

         const MFHoldingScreen()
        ]]
          ]))
        ],
      );
    });
  }
}
