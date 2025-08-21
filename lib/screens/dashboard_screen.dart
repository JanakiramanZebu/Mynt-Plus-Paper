import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/ipo/ipo_main_screen.dart';
// import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../res/res.dart';
import '../../provider/thems.dart';
import '../provider/auth_provider.dart';
import '../provider/bonds_provider.dart';
import '../provider/iop_provider.dart';
import '../provider/ledger_provider.dart';
import '../provider/market_watch_provider.dart';
import '../provider/mf_provider.dart';
// import '../provider/portfolio_provider.dart';
import 'package:mynt_plus/main.dart';
import '../provider/stocks_provider.dart';
import '../res/global_state_text.dart';
import '../sharedWidget/custom_text_form_field.dart';
import '../utils/no_emoji_inputformatter.dart';
import 'bonds/bonds_main_screen.dart';
import 'stocks/explore/stocks/stock_screens.dart';
import 'mutual_fund/mf_explore_screens.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0,
    );
    // Sync initial tab index with provider
    _tabController.addListener(() {
      setState(() {});
      // Sync with provider when tab changes
      if (mounted && _tabController.indexIsChanging) {
        ref.read(stocksProvide).syncTabIndex(_tabController.index);
      }
      // Clear search when switching tabs
      if (mounted) {
        ref.read(stocksProvide).searchController.clear();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(stocksProvide).syncTabIndex(0);
      }
      ProviderScope.containerOf(context).read(authProvider).setIposAPicalls(context);
      ref.read(bondsProvider).fetchAllBonds();
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Subscribe to route changes to unfocus search when returning
    routeObserver.subscribe(this, ModalRoute.of(context)!);

    // Initialize provider state after dependencies are available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final reportsprovider = ref.read(ledgerProvider);
      // await ref.read(stocksProvide).getNews();

      reportsprovider.calendarProvider();
      // Initialize calendar provider
      final currentFY = reportsprovider.availableFinancialYears.first;
      if ((reportsprovider.hasDataForAllSegments)) {
         reportsprovider.fetchDataForAllSegmentsIfEmpty(
          context,
          reportsprovider.startDate,
          reportsprovider.today,
        );
        // Calendar PnL data will be fetched when needed
      }
      await ref.read(mfProvider).fetchEtfCategory();
      // Immediately set the default year and segment to show correct data from cache
      reportsprovider.setFinancialYear(currentFY);
      reportsprovider.setSegment(reportsprovider.availableSegments.first);
      if (reportsprovider.ledgerAllData == null) {
        await reportsprovider.getCurrentDate('else');
        reportsprovider.fetchLegerData(
            context, reportsprovider.startDate, reportsprovider.endDate);
      }
      // Initialize mutual fund data
      // await ref.read(mfProvider).fetchBestMF();
      // await ref.read(mfProvider).fetchnewMFBestList();
      // await ref.read(mfProvider).fetchMFCategoryList("", "");
      // await ref.read(mfProvider).fetchmfallcatnew();
      // await ref.read(mfProvider).fetchmfholdingnew();
      // await ref.read(portfolioProvider).fetchMFHoldings(context);
      // await ref.read(mfProvider).fetchmfNFO(context);
      // await ref.read(mfProvider).fetchTopSchemes();
      // await ref.read(mfProvider).fetchMFWatchlist("", "", context, true, "");
      // await ref.read(mfProvider).fetchmfsiplist();
      // await ref.read(mfProvider).fetchmfsipnotlivelist();
      // await ref.read(mfProvider).fetchMfOrderbook(context);
      // await ref.read(mfProvider).fetchMFMandateDetail();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // RouteAware callbacks to unfocus when screens/popup close
  @override
  void didPopNext() {
    // A top route was popped and this route shows up again
    if (mounted) {
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void didPushNext() {
    // Another route has been pushed atop this one; ensure keyboard closed
    if (mounted) {
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final stocks = ref.watch(stocksProvide);

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          centerTitle: false,
          title: Row(
            children: [
              // SvgPicture.asset(
              //   assets.myntnewLogo,
              //   width: 46,
              //   height: 46,
              // ),
              // const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: theme.isDarkMode
                                  ? colors.searchBgDark
                                  : colors.searchBg,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: InkWell(
                      onTap: () {
                        if (_tabController.index == 1) {
                          // FocusScope.of(context).unfocus();
                          Navigator.pushNamed(context, Routes.mfsearchscreen);
                        } else if (_tabController.index == 0) {
                          FocusScope.of(context).unfocus();
                          final mw = ref.read(marketWatchProvider);
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            await mw.requestMWScrip(
                                context: context, isSubscribe: false);
                          });
                          Navigator.pushNamed(
                            context,
                            Routes.searchScrip,
                            arguments: ref.watch(
                                marketWatchProvider.select((p) => p.wlName)),
                          );
                        }
                      },
                      child: AbsorbPointer(
                        absorbing: _tabController.index == 1 ||
                            _tabController.index == 0,
                        child: TextField(
                          focusNode: _searchFocusNode,
                          controller: stocks.searchController,
                          autofocus: false,
                          style: TextWidget.textStyle(
                            fontSize: 14,
                            theme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                          ),
                          readOnly: _tabController.index == 2 ||
                                  _tabController.index == 3
                              ? false
                              : true,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            NoEmojiInputFormatter(),
                            FilteringTextInputFormatter.deny(
                                RegExp('[π£•₹€℅™∆√¶/.,]'))
                          ],
                          decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: TextWidget.textStyle(
                                  fontSize: 16,
                                  theme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight),
                              fillColor: theme.isDarkMode
                                  ? colors.searchBgDark
                                  : colors.searchBg,
                              filled: true,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(assets.searchIcon,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    fit: BoxFit.scaleDown,
                                    width: 20),
                              ),
                              suffixIcon:
                                  stocks.searchController.text.isNotEmpty
                                      ? Material(
                                          color: Colors.transparent,
                                          shape: const CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            splashColor: theme.isDarkMode
                                                ? colors.splashColorDark
                                                : colors.splashColorLight,
                                            highlightColor: theme.isDarkMode
                                                ? colors.highlightDark
                                                : colors.highlightLight,
                                            onTap: () async {
                                              // Future.delayed(const Duration(milliseconds: 150), () {
                                              stocks.searchController.clear();
                                              FocusScope.of(context).unfocus();
                                              stocks.clearsearchlist(context);
                                              if (_tabController.index == 2) {
                                                ref
                                                    .read(ipoProvide)
                                                    .setIpoSearchQuery("");
                                                ;
                                              } else if (_tabController.index ==
                                                  3) {
                                                ref
                                                    .read(bondsProvider)
                                                    .bondscommonsearchcontroller
                                                    .clear();
                                              }
                                              //   if (positionBook.positionSearchCtrl.text.isEmpty) {
                                              //     positionBook.showPositionSearch(false);
                                              //   }
                                              // });
                                            },
                                            child: SvgPicture.asset(
                                              assets.removeIcon,
                                              fit: BoxFit.scaleDown,
                                              width: 20,
                                              color: theme.isDarkMode
                                                  ? colors.textSecondaryDark
                                                  : colors.textSecondaryLight,
                                            ),
                                          ),
                                        )
                                      : null,
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)),
                              disabledBorder: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 5),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20))),
                          onChanged: (value) {
                            stocks.searchdashboard(value, context,
                                tabIndex: _tabController.index);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: TabBar(
                onTap: (index) {
                  // Sync the tab index with the provider
                  ref.read(stocksProvide).syncTabIndex(index);
                  FocusScope.of(context).unfocus();
                  stocks.searchController.clear();
                  stocks.clearsearchlist(context);
                },
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                indicatorColor: theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight,
                unselectedLabelColor: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                unselectedLabelStyle: TextWidget.textStyle(
                  fontSize: 14,
                  theme: false,
                  fw: 3,
                ),
                labelColor: theme.isDarkMode
                    ? colors.secondaryDark
                    : colors.secondaryLight,
                labelStyle:
                    TextWidget.textStyle(fontSize: 14, theme: false, fw: 2),
                controller: _tabController,
                tabs: stocks.exploreTabName,
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const StockScreen(),
            MFExploreScreens(theme: ref.watch(themeProvider)),
            const IPOScreen(initialTabIndex: 0, isIpo: false),
            const BondsScreen(isBonds: false),
          ],
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize);
  }
}
