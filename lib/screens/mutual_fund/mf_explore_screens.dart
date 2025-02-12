import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/loader_ui.dart';
import 'mutual_fund_screen_new.dart';

class MFExploreScreens extends StatefulWidget {
  final ThemesProvider theme;
  const MFExploreScreens({super.key, required this.theme});

  @override
  State<MFExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends State<MFExploreScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tablistitems = [
    {
      "Aimgpath": "",
      "imgpath": assets.exportIcon,
      "title": "Explore",
      "index": 0,
    },
    {
      "Aimgpath": "",
      "imgpath": assets.bookmarkLineIcon,
      "title": "Watchlist",
      "index": 1,
    }
  ];
  int activeTab = 0;

  final bestMFList = [
    {
      "funds": "46 funds",
      "image": "assets/explore/loan.svg",
      "subtitle": "Build wealth and save taxes",
      "title": "Save taxes"
    },
    {
      "funds": "90 funds",
      "image": "assets/explore/transactions.svg",
      "subtitle": "Stable income and growth",
      "title": "Equity + Debt"
    },
    {
      "funds": "56 funds",
      "image": "assets/explore/goldcoin.svg",
      "subtitle": "Hybrid of active and passive",
      "title": "Smart beta"
    },
    {
      "funds": "120 funds",
      "image": "assets/explore/globe.svg",
      "subtitle": "Diversify your portfolio globally",
      "title": "International funds"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final explore = watch(authProvider);
        final theme = context.read(themeProvider);

        return TransparentLoaderScreen(
          isLoading: explore.loading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const CustomDragHandler(),
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(bottom: 0, left: 20, top: 2),
                  decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                              color: widget.theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 0.4),
                          bottom: BorderSide(
                              color: widget.theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              width: 0.4))),
                  // height: 60,
                  child: TabBar(
                      labelPadding: const EdgeInsets.only(right: 16, bottom: 0),
                      tabAlignment: TabAlignment.start,
                      indicatorColor: Colors.transparent,
                      controller: _tabController,
                      isScrollable: true,
                      tabs: List.generate(
                          tablistitems.length,
                          (tab) => tabConstruce(
                              tablistitems[tab]['imgpath'].toString(),
                              tablistitems[tab]['title'].toString(),
                              theme,
                              tab,
                              () {})))),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    MutualFundNewScreen(bestMFList: bestMFList),
                    const NoDataFound()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget tabConstruce(String icon, String title, ThemesProvider theme, int tab,
      VoidCallback onPressed) {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            activeTab = tab;
          });
          _tabController.animateTo(tab);
          print("object act tab $tab");
        },
        style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            backgroundColor: theme.isDarkMode
                ? tab == activeTab
                    ? colors.colorbluegrey
                    : const Color(0xffB5C0CF).withOpacity(.15)
                : tab == activeTab
                    ? const Color(0xff000000)
                    : const Color(0xffF1F3F8),
            shape: const StadiumBorder()),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                color: theme.isDarkMode
                    ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
                    : Color(tab == activeTab ? 0xffffffff : 0xff000000),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: textStyle(
                      theme.isDarkMode
                          ? Color(tab == activeTab ? 0xff000000 : 0xffffffff)
                          : Color(tab == activeTab ? 0xffffffff : 0xff000000),
                      14,
                      FontWeight.w500))
            ]));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
