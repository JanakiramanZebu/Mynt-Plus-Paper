import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_order_book_screen.dart';
// import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/loader_ui.dart';
// import '../../provider/mf_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/portfolio_provider.dart';
import '../../res/global_state_text.dart';
import 'mf_sip_screen.dart';
import 'mf_watchlist.dart';
import 'mutual_fund_screen_new.dart';

class MFExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  const MFExploreScreens({super.key, required this.theme});

  @override
  ConsumerState<MFExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<MFExploreScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedTab = 0;

  final tablistitems = [
    {
      "imgpath": "assets.exportIcon",
      "title": "Explore",
      "index": 0,
    },
    {
      "imgpath": "assets.bookmarkLineIcon",
      "title": "Watchlist",
      "index": 1,
    },
    {
      "imgpath": "assets.bookmarkLineIcon",
      "title": "Portfolio",
      "index": 2,
    },
    {
      "imgpath": "assets.bookmarkLineIcon",
      "title": "SIP",
      "index": 3,
    }
  ];

  // final bestMFList = [
  //   {
  //     "funds": "46 funds",
  //     "image": "assets/explore/loan.svg",
  //     "subtitle": "Build wealth and save taxes",
  //     "title": "Save taxes"
  //   },
  //   {
  //     "funds": "90 funds",
  //     "image": "assets/explore/transactions.svg",
  //     "subtitle": "Stable income and growth",
  //     "title": "Equity + Debt"
  //   },
  //   {
  //     "funds": "56 funds",
  //     "image": "assets/explore/goldcoin.svg",
  //     "subtitle": "Hybrid of active and passive",
  //     "title": "Smart beta"
  //   },
  //   {
  //     "funds": "120 funds",
  //     "image": "assets/explore/globe.svg",
  //     "subtitle": "Diversify your portfolio globally",
  //     "title": "International funds"
  //   }
  // ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4,
        vsync: this,
        initialIndex: ref.read(mfProvider).activeTab ?? 0);
    selectedTab = ref.read(mfProvider).activeTab ?? 0;
    _tabController.animation!.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (selectedTab != newIndex) {
        setState(() {
          selectedTab = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final explore = ref.watch(authProvider);
    final theme = ref.read(themeProvider);
    final mfData = ref.watch(mfProvider);
    final portfolio = ref.watch(portfolioProvider);

    return TransparentLoaderScreen(
      isLoading: explore.loading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const CustomDragHandler(),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.isDarkMode
                        ? colors.darkColorDivider
                        : colors.colorDivider,
                    width: 0,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    tablistitems.length,
                    (tab) => Material(
                      color: Colors.transparent,
                      child: InkWell(
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
                          _tabController.animateTo(tab);
                        },
                        child: _tabConstruct(
                            tablistitems[tab]['title'].toString(), theme, tab),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                controller: _tabController,
                children: [
                  MutualFundNewScreen(
                    tabController: _tabController,
                  ),
                  const MFWatchlistScreen(),
                  const MfOrderBookScreen(),
                  const MFSipdetScreen()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabConstruct(String title, ThemesProvider theme, int tab) {
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
                : theme.isDarkMode
                    ? colors.textSecondaryDark
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

  Widget _buildTab(String title, ThemesProvider theme, int tab, mfData) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          mfData.mfExTabchange(tab);
        });
        _tabController.animateTo(tab);
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        backgroundColor: theme.isDarkMode
            ? tab == mfData.activeTab
                ? colors.colorbluegrey
                : const Color.fromARGB(255, 255, 255, 255).withOpacity(.15)
            : tab == mfData.activeTab
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
              ? Color(tab == mfData.activeTab ? 0xff000000 : 0xffffffff)
              : Color(tab == mfData.activeTab ? 0xffffffff : 0xff000000),
          13,
          FontWeight.w500,
        ),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
