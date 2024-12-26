import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/index_list_provider.dart';
import '../../../res/res.dart';
// import '../../bonds/bond_screen.dart';
// import '../../ipo/ipo_main_screen.dart';
// import '../../mutual_fund/mutual_fund_screen.dart';
import '../../../sharedWidget/loader_ui.dart';
import 'stocks/stock_screens.dart';

class ExploreScreens extends StatefulWidget {
  final ThemesProvider theme;
  const ExploreScreens({super.key, required this.theme});

  @override
  State<ExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends State<ExploreScreens>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    context.read(authProvider).exploreTab = TabController(
        length: context.read(authProvider).exploreTabName.length,
        vsync: this,
        initialIndex: context.read(authProvider).selectedTab);

    context.read(authProvider).exploreTab.addListener(() async {
      context
          .read(authProvider)
          .changeTabIndex(context.read(authProvider).exploreTab.index);
      if (context.read(authProvider).selectedTab == 0) {
        await context.read(indexListProvider).fetchStockTopIndex();
      }
      context.read(authProvider).exploretabSize();
    });
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final explore = watch(authProvider);
        return TransparentLoaderScreen(
          isLoading: explore.loading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TabBar for navigation
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.only(bottom: 6, left: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: widget.theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0))),
                height: 40,
                child: TabBar(
                  // tabAlignment: TabAlignment.fill,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: colors.colorBlack,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: widget.theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack),
                  unselectedLabelColor: colors.colorGrey,
                  unselectedLabelStyle: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  labelColor: widget.theme.isDarkMode
                      ? colors.colorBlack
                      : colors.colorWhite,
                  labelStyle: GoogleFonts.inter(
                      textStyle: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  controller: explore.exploreTab,

                  isScrollable: true,
                  tabs: explore.exploreTabName,
                ),
              ),

              // TabBarView for tab content
              Expanded(
                child: TabBarView(
                  controller: explore.exploreTab,
                  children: const [
                    StockScreen(),
                    NoDataFound(),
                    NoDataFound(),
                    NoDataFound(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
