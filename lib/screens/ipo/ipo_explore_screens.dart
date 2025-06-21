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
  final int? initialTabIndex;
  const IpoExploreScreens({super.key, required this.theme, this.initialTabIndex});

  @override
  ConsumerState<IpoExploreScreens> createState() => _ExploreScreensState();
}

class _ExploreScreensState extends ConsumerState<IpoExploreScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static final List<Map<String, dynamic>> _tabItems = [
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
    _tabController = TabController(
      length: 3, 
      vsync: this, 
      initialIndex: widget.initialTabIndex ?? 0
    );
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
            onTabPressed: _onTabPressed,
          ),
          Expanded(
            child: _TabBarViewSection(tabController: _tabController),
          ),
        ],
      ),
    );
  }

  void _onTabPressed(int tab) {
    _tabController.animateTo(tab);
  }

  static TextStyle _textStyle(Color color, double fontSize, FontWeight fWeight) {
    return GoogleFonts.inter(
      textStyle: TextStyle(
        fontWeight: fWeight,
        color: color,
        fontSize: fontSize,
      ),
    );
  }
}

class _TabBarSection extends StatelessWidget {
  final TabController tabController;
  final ThemesProvider theme;
  final Function(int) onTabPressed;

  const _TabBarSection({
    required this.tabController,
    required this.theme,
    required this.onTabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TabBar(
        labelPadding: const EdgeInsets.only(right: 8),
        tabAlignment: TabAlignment.start,
        indicatorColor: const Color.fromARGB(255, 255, 255, 255),
        controller: tabController,
        isScrollable: true,
        tabs: List.generate(
          _ExploreScreensState._tabItems.length,
          (tab) => _TabButton(
            title: _ExploreScreensState._tabItems[tab]['title'].toString(),
            theme: theme,
            tab: tab,
            tabController: tabController,
            onPressed: () => onTabPressed(tab),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final ThemesProvider theme;
  final int tab;
  final TabController tabController;
  final VoidCallback onPressed;

  const _TabButton({
    required this.title,
    required this.theme,
    required this.tab,
    required this.tabController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: tabController.animation!,
      builder: (context, value, child) {
        final isActive = value.round() == tab;
        return ElevatedButton(
          onPressed: onPressed,
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
            style: _ExploreScreensState._textStyle(
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
