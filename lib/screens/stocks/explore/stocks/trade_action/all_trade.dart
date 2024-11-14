import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../../../../provider/stocks_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/functions.dart';
import 'sector_themeatic_list.dart';

class AllTrade extends StatefulWidget {
  const AllTrade({super.key});

  @override
  State<AllTrade> createState() => _AllTradeState();
}

class _AllTradeState extends State<AllTrade> with TickerProviderStateMixin {
  late TabController tabCtrl;

  List<Tab> tabList = [];

  int selectedTabIndex = 0;

  @override
  void initState() {
    tabList = [
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const SizedBox(width: 10),
            Text("Sectoral (${context.read(stocksProvide).sectorsData.length})")
          ])),
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const SizedBox(width: 10),
            Text("Thematic (${context.read(stocksProvide).thematicDat.length})")
          ])),
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const SizedBox(width: 10),
            Text(
                "Strategy (${context.read(stocksProvide).strategicData.length})")
          ])),
      Tab(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const SizedBox(width: 10),
            Text("Nifty (${context.read(stocksProvide).niftyData.length})")
          ]))
    ];
    tabCtrl = TabController(
        length: tabList.length, vsync: this, initialIndex: selectedTabIndex);

    tabCtrl.addListener(() {
      setState(() {
        selectedTabIndex = tabCtrl.index;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    final tradeAcrion = context.read(stocksProvide);
    return WillPopScope(
      onWillPop: () async {
        await context.read(stocksProvide).defaultSectorThemematicData();
        // await context.read(stocksProvide).fetchIndicesAdvdec();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 0,
            leading: InkWell(
                onTap: () async {
                  await context
                      .read(stocksProvide)
                      .defaultSectorThemematicData();
                  // await context.read(stocksProvide).fetchIndicesAdvdec();
                  Navigator.pop(context);
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: SvgPicture.asset(assets.backArrow,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack))),
            elevation: .4,
            title: Text("All Data",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600))),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                height: 50,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0),
                        top: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0))),
                child: TabBar(
                    isScrollable: true,
                    indicatorColor: const Color(0xff0037B7),
                    indicatorSize: TabBarIndicatorSize.tab,
                    unselectedLabelColor: const Color(0XFF666666),
                    unselectedLabelStyle:
                        textStyle(const Color(0XFF666666), 14, FontWeight.w500),
                    labelColor: const Color(0XFF0037B7),
                    labelStyle:
                        textStyle(const Color(0XFF0037B7), 14, FontWeight.w600),
                    controller: tabCtrl,
                    tabs: tabList)),
            Expanded(
              child: TabBarView(controller: tabCtrl, children: [
                SectorThematicList(
                    data: tradeAcrion.sectorsData, isscollable: true),
                SectorThematicList(
                    data: tradeAcrion.thematicDat, isscollable: true),
                SectorThematicList(
                    data: tradeAcrion.strategicData, isscollable: true),
                SectorThematicList(
                    data: tradeAcrion.niftyData, isscollable: true)
              ]),
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  } 
}
