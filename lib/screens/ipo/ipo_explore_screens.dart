import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/screens/ipo/ipo_orderbook_screen/ipo_order_book_main_screen.dart';
import 'package:mynt_plus/screens/ipo/upcoming/ipo_upcoming.dart';
import '../../../provider/auth_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/loader_ui.dart';
import '../../provider/iop_provider.dart';
import '../../res/global_state_text.dart';
import 'main_sme_list/main_sme_list.dart';

class IpoExploreScreens extends ConsumerStatefulWidget {
  final ThemesProvider theme;
  final int? initialTabIndex;
  const IpoExploreScreens(
      {super.key, required this.theme, this.initialTabIndex});

  @override
  ConsumerState<IpoExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<IpoExploreScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tablistitems = [
    {
      "title": "Open",
      "index": 0,
    },
    {
      "title": "Upcoming", 
      "index": 1,
    },
    {
      "title": "My Bids",
      "index": 2,
    }
  ];
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex ?? 0);
    _tabController.animation!.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final newIndex = _tabController.animation!.value.round();
    if (selectedTab != newIndex) {
      setState(() {
        selectedTab = newIndex;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final explore = ref.watch(authProvider);
    final theme = ref.watch(themeProvider);

    return TransparentLoaderScreen(
      isLoading: explore.loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        
                        ref.read(ipoProvide).clearCommonIpoSearch();
                        ref.read(ipoProvide).setIpoSearchQuery("");
                        FocusScope.of(context).unfocus();
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
            child: _TabBarViewSection(tabController: _tabController),
          ),
        ],
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
}

class _TabBarViewSection extends StatelessWidget {
  final TabController tabController;

  const _TabBarViewSection({required this.tabController});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: const [
        MainSmeListCard(),
        UpcomingIpo(),
        IpoOrderbookMainScreen(),
      ],
    );
  }
}
