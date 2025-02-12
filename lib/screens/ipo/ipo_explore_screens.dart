import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/loader_ui.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'main_sme_list/main_sme_list.dart';
import 'preclose_ipo/preclose_ipo_screen.dart';

class IpoExploreScreens extends StatefulWidget {
  final ThemesProvider theme;
  const IpoExploreScreens({super.key, required this.theme});

  @override
  State<IpoExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends State<IpoExploreScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tablistitems = [
    {
      "Aimgpath": "",
      "imgpath": assets.exportIcon,
      "title": "Live / pre open",
      "index": 0,
    },
    {
      "Aimgpath": "",
      "imgpath": assets.bookmarkLineIcon,
      "title": "Closed",
      "index": 1,
    },
    {
      "Aimgpath": "",
      "imgpath": assets.bag,
      "title": "Listed",
      "index": 2,
    }
  ];
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
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
                  padding: const EdgeInsets.only(bottom: 0, left: 14, top: 2),
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
                  children: const [
                    MainSmeListCard(),
                    ClosedIPOScreen(),
                    IPOPerformance()
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
