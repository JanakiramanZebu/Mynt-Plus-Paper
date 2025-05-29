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

class BondsExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  const BondsExploreScreens({super.key, required this.theme});

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
  _allBondsTabController = TabController(length: 2, vsync: this, initialIndex: 0) ;

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
              // const CustomDragHandler(),
              Container(
                width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    border: Border(
                        // top: BorderSide(
                        //     color: widget.theme.isDarkMode
                        //         ? colors.darkColorDivider
                        //         : colors.colorDivider,
                        //     width: 0),
                        bottom: BorderSide(
                            color: widget.theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0))),
                // height: 60,
                child: TabBar(
               labelPadding: const EdgeInsets.only(right: 8),
                  tabAlignment: TabAlignment.start,
                 indicatorColor: const Color.fromARGB(255, 255, 255, 255),
                  controller: _allBondsTabController,
                  isScrollable: true,
                  tabs: List.generate(
                    tablistitems.length,
                    (tab) => tabConstruce(
                        // tablistitems[tab]['imgpath'].toString(),
                        tablistitems[tab]['title'].toString(),
                        theme,                       
                        tab,
                        () {}),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  // physics: const NeverScrollableScrollPhysics(),
                  controller: _allBondsTabController,
                  // children: List.generate(tablistitems.length,(tab) => const BondsListScreen())
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

  Widget tabConstruce( String title, ThemesProvider theme, int tab,
      VoidCallback onPressed) {
    return ValueListenableBuilder(
       valueListenable: _allBondsTabController.animation!,
       builder: (context, value, child) {
        final isActive = value.round() == tab; 
        return ElevatedButton(
          onPressed: () {
          _allBondsTabController.animateTo(tab);
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
      
          child: Text(title,
              style: textStyle(
            theme.isDarkMode
                ? Color(isActive ? 0xff000000 : 0xffffffff)
                : Color(isActive ? 0xffffffff : 0xff000000),
            14,
            FontWeight.w500,
          ),));
       },
      
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
  
}



 // SvgPicture.asset(
              //   icon,
              //   color: theme.isDarkMode
              //       ? Color(bonds.selectedBondTab["index"] == selectedtab["index"] ? 0xff000000 : 0xffffffff)
              //       : Color(bonds.selectedBondTab["index"] == selectedtab["index"] ? 0xffffffff : 0xff000000),
              // ),
              // const SizedBox(width: 8),