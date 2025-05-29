import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/iop_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/ipo/ipo_orderbook_screen/ipo_order_book_main_screen.dart';
import 'package:mynt_plus/screens/ipo/upcoming/ipo_upcoming.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/loader_ui.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'main_sme_list/main_sme_list.dart';
import 'preclose_ipo/preclose_ipo_screen.dart';

class IpoExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  const IpoExploreScreens({super.key, required this.theme});

  @override
  ConsumerState<IpoExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<IpoExploreScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tablistitems = [
    {
      "Aimgpath": "",
      "imgpath": assets.exportIcon,
      "title": "Open",
      "index": 0,
    },
    {
      "Aimgpath": "",
      "imgpath": assets.bookmarkLineIcon,
      "title": "Upcoming",
      "index": 1,
    },
    // {
    //   "Aimgpath": "",
    //   "imgpath": assets.bag,
    //   "title": "Listed",
    //   "index": 1,
    // },
    {
      "Aimgpath": "",
      "imgpath": assets.bag,
      "title": "My Bids",
      "index": 2,
    }
  ];
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);

     _tabController.animation!.addListener(() {
    final newIndex = _tabController.animation!.value.round();
    if (activeTab != newIndex) {
      setState(() {
        activeTab = newIndex; // Update activeTab immediately on swipe
      });
    }
  });

   
  }

  @override
  Widget build(BuildContext context) {
    final explore = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);

    return TransparentLoaderScreen(
      isLoading: explore.loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const CustomDragHandler(),
          Container(
              width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                    color: widget.theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    width: 0),
              )),
              child: TabBar(
                  labelPadding: const EdgeInsets.only(right: 8),
                  tabAlignment: TabAlignment.start,
                  indicatorColor: const Color.fromARGB(255, 255, 255, 255),
                  controller: _tabController,
                  isScrollable: true,
                  tabs: List.generate(
                      tablistitems.length,
                      (tab) => tabConstruce(
                          // tablistitems[tab]['imgpath'].toString(),
                          tablistitems[tab]['title'].toString(),
                          theme,
                          tab,
                          () {})))),
          Expanded(
            child: TabBarView(
              // physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: const [
                MainSmeListCard(),
                UpcomingIpo(),
                IpoOrderbookMainScreen()
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget tabConstruce(String title, ThemesProvider theme, int tab, VoidCallback onPressed) {
  return ValueListenableBuilder(
    valueListenable: _tabController.animation!,
    builder: (context, value, child) {
      final isActive = value.round() == tab; 
      return ElevatedButton(
       onPressed: () {        
  _tabController.animateTo(tab);
},

        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          backgroundColor: theme.isDarkMode
              ? isActive
                  ? colors.colorbluegrey
                  : const Color.fromARGB(255, 255, 255, 255).withOpacity(.15)
              : isActive
                  ? const Color(0xff000000)
                  : const Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          minimumSize: const Size(0, 30),
        ),
        child: Text(
          title,
          style: textStyle(
            theme.isDarkMode
                ? Color(isActive ? 0xff000000 : 0xffffffff)
                : Color(isActive ? 0xffffffff : 0xff000000),
            14,
            FontWeight.w500,
          ),
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
