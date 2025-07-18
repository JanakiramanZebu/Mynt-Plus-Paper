import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/bonds/bonds_orderbook_screen/bonds_order_book_main_screen.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/bonds_list.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/govt_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/sovereign_gold_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/state_bonds.dart';
import 'package:mynt_plus/screens/bonds/live_bonds/treasury_bonds.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/loader_ui.dart';
import '../../../res/global_state_text.dart';

class BondsExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  final int? initialTabIndex;
  const BondsExploreScreens({super.key, required this.theme, this.initialTabIndex});

  @override
  ConsumerState<BondsExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<BondsExploreScreens>
    with SingleTickerProviderStateMixin {
  late  TabController _allBondsTabController;

   final tablistitems = [
    {
      "Aimgpath": "",
      // "imgpath": assets.exportIcon,
      "title": "Bonds",
      "index": 0,
    },
    // {
    //   "Aimgpath": "",
    //   // "imgpath": assets.bookmarkLineIcon,
    //   "title": "T-bill",
    //   "index": 1,
    // },
    // {
    //   "Aimgpath": "",
    //   // "imgpath": assets.bag,
    //   "title": "SDL",
    //   "index": 2,
    // },
    // {
    //   "Aimgpath": "",
    //   // "imgpath": assets.bag,
    //   "title": "SGB",
    //   "index": 3,
    // },
     {
      "Aimgpath": "",
      // "imgpath": assets.bag,
      "title": "My Bids",
      "index": 1,
    }
  ];

  int selectedTab = 0;


  @override
  void initState() {
    super.initState();
    // _tabController = TabController(length: tablistitems.length, vsync: this, initialIndex: 0);
  _allBondsTabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex ?? 0) ;

   _allBondsTabController.animation!.addListener(() {
    final newIndex = _allBondsTabController.animation!.value.round();
    if (selectedTab != newIndex) {
      setState(() {
        selectedTab = newIndex; // Update activeTab immediately on swipe
      });
    }
   }
   );
  }


// TabController(
//           length: ref.read(bondsProvider).tablistitems.length,
//           vsync: this,
//           initialIndex: ref.read(bondsProvider).selectedBondTab["index"])
  

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final explore = ref.watch(authProvider);
        final bonds = ref.watch(bondsProvider);
        final theme = ref.read(themeProvider);
        //  List<Map<String, Object>> tablistitems = btablistitems;
        return TransparentLoaderScreen(
          isLoading: explore.loading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: widget.theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      width: 0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    tablistitems.length,
                    (tab) => Material(
                      color: Colors.transparent,
                      child: InkWell(
                        // borderRadius: BorderRadius.circular(6),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.black.withOpacity(0.05),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(0.01)
                            : Colors.black.withOpacity(0.01),
                        onTap: () {
                          setState(() {
                            selectedTab = tab;
                          });
                          _allBondsTabController.animateTo(tab);
                        },
                        child: tabConstruce(
                          tablistitems[tab]['title'].toString(),
                          theme,
                          tab,
                          () {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _allBondsTabController,
                  children: const [
                    BondsListScreen(),
                    BondsOrderbookMainScreen()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget tabConstruce(String title, ThemesProvider theme, int tab, VoidCallback onPressed) {
    final isActive = selectedTab == tab;
   
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: TextWidget.subText(
            text: title,
            color: isActive
                ? theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight
                : colors.textSecondaryLight,
            textOverflow: TextOverflow.ellipsis,
            maxLines: 1,
            theme: theme.isDarkMode,
            fw: isActive ? 2 : null,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 2,
          width: isActive ? 82 : 0, 
          margin: const EdgeInsets.only(top: 1),
          decoration: BoxDecoration(
            color: colors.colorBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }


}



 // SvgPicture.asset(
              //   icon,
              //   color: theme.isDarkMode
              //       ? Color(bonds.selectedBondTab["index"] == selectedtab["index"] ? 0xff000000 : 0xffffffff)
              //       : Color(bonds.selectedBondTab["index"] == selectedtab["index"] ? 0xffffffff : 0xff000000),
              // ),
              // const SizedBox(width: 8),