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
import '../../res/global_state_text.dart';
import 'ipo_performance/ipo_performance_screen.dart';
import 'main_sme_list/main_sme_list.dart';
import 'preclose_ipo/preclose_ipo_screen.dart';

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
  final List<Tab> tabItems = [
    const Tab(text: "Open"),
    const Tab(text: "Upcoming"),
    const Tab(text: "My Bids"),
  ];
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex ?? 0);
    _tabController.animation!.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final newIndex = _tabController.animation!.value.round();
    if (activeTab != newIndex) {
      setState(() {
        activeTab = newIndex;
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
          _TabBarSection(
            tabController: _tabController,
            theme: widget.theme,
            tabItems: tabItems,
          ),
          Divider(
            height: 1,
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
          Expanded(
            child: _TabBarViewSection(tabController: _tabController),
          ),
        ],
      ),
    );
  }
}

class _TabBarSection extends StatelessWidget {
  final TabController tabController;
  final ThemesProvider theme;
  final List<Tab> tabItems;

  const _TabBarSection({
    required this.tabController,
    required this.theme,
    required this.tabItems,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabAlignment: TabAlignment.start,
      indicatorSize: TabBarIndicatorSize.tab,
      isScrollable: true,
      indicatorColor:
          theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
      unselectedLabelColor: theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight,
      unselectedLabelStyle: TextWidget.textStyle(
        fontSize: 14,
        theme: false,
        color: theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        fw: 3,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
      labelColor:
          theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
      labelStyle: TextWidget.textStyle(
          fontSize: 14,
          theme: false,
          color:
              theme.isDarkMode ? colors.secondaryDark : colors.secondaryLight,
          fw: 2),
      controller: tabController,
      tabs: tabItems,
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
