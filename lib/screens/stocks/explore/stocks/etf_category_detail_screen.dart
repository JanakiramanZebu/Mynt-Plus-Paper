import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mynt_plus/models/mf_model/mf_etf_category_model.dart';
import 'package:mynt_plus/provider/mf_provider.dart';
import 'package:mynt_plus/provider/market_watch_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';

import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/no_data_found.dart';

class ETFCategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryTitle;
  final String categoryIcon;
  final String categoryDescription;

  const ETFCategoryDetailScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.categoryDescription,
  });

  @override
  ConsumerState<ETFCategoryDetailScreen> createState() => _ETFCategoryDetailScreenState();
}

class _ETFCategoryDetailScreenState extends ConsumerState<ETFCategoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  int selectedTab = 0;

  // Define the tabs
  final List<String> tabTitles = [
    'Indices',
    'Sector & Theme',
    'Strategy Based',
    'Global',
    'Debt',
    'Gold & Silver',
  ];

  @override
  void initState() {
    super.initState();

    // Store ETF category information in MarketWatchProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketWatch = ref.read(marketWatchProvider);
      marketWatch.setETFCategory(
        widget.categoryTitle,
        widget.categoryIcon,
        widget.categoryDescription,
      );
    });

    // Find the initial tab index based on the title passed as argument
    int initialIndex = 0;
    for (int i = 0; i < tabTitles.length; i++) {
      if (tabTitles[i] == widget.categoryTitle) {
        initialIndex = i;
        break;
      }
    }

    _tabController = TabController(
        length: tabTitles.length, vsync: this, initialIndex: initialIndex);
    _scrollController = ScrollController();
    selectedTab = initialIndex;

    _tabController.animation!.addListener(() {
      final newIndex = _tabController.animation!.value.round();
      if (selectedTab != newIndex) {
        setState(() {
          selectedTab = newIndex;
        });
        // Scroll to center the active tab
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToActiveTab(newIndex);
        });
      }
    });

    // Scroll to center the initial tab after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveTab(selectedTab);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveTab(int index) {
    if (_scrollController.hasClients) {
      // Calculate cumulative width up to the current tab
      final double totalWidthUpToIndex = _calculateTotalWidthUpToIndex(index);
      final double currentTabWidth = _calculateTabWidth(tabTitles[index]);
      final double screenWidth = MediaQuery.of(context).size.width;

      // Calculate scroll position to center the active tab
      final double scrollPosition =
          totalWidthUpToIndex - (screenWidth / 2) + (currentTabWidth / 2);

      _scrollController.animateTo(
        scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  double _calculateTabWidth(String text) {
    // Base width for padding and minimum space
    const double baseWidth = 30.0;
    // Approximate character width (adjust based on your font)
    const double charWidth = 7.0;
    // Calculate width based on text length
    double textWidth = text.length * charWidth;
    // Add base width and ensure minimum width
    return (textWidth + baseWidth).clamp(100.0, 250.0);
  }

  double _calculateTotalWidthUpToIndex(int index) {
    double totalWidth = 0.0;
    for (int i = 0; i < index && i < tabTitles.length; i++) {
      totalWidth += _calculateTabWidth(tabTitles[i]);
    }
    return totalWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
       ref.read(marketWatchProvider).setETF(false);
       Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        appBar: AppBar(
            elevation: 0,
            leadingWidth: 41,
            centerTitle: false,
            titleSpacing: 6,
            leading: Material(
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
                    onTap: () {                  
                      ref.read(marketWatchProvider).setETF(false);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 44, // Increased touch area
                      height: 44,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_outlined,
                        size: 18,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
            title: TextWidget.titleText(
              text: "ETF Collections",
              color: theme.
                  isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 1,
              theme: theme.isDarkMode,
            ),
          ),
       
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom tabs section
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
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
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      tabTitles.length,
                      (tab) => Material(
                        color: Colors.transparent,
                        child: InkWell(
                          canRequestFocus: false,
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
                            // Scroll to center the active tab
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _scrollToActiveTab(tab);
                            });
                          },
                          child: tabConstruct(
                            tabTitles[tab],
                            theme,
                            tab,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          
              
              // TabBarView with ETF lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: tabTitles.map((tabTitle) {
                    return buildETFList(tabTitle, theme);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabConstruct(String title, ThemesProvider theme, int tab) {
    final isActive = selectedTab == tab;
    final double tabWidth = _calculateTabWidth(title);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: tabWidth,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
          width: isActive ? (tabWidth - 12) : 0,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: colors.colorBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget buildETFList(String selectedTab, ThemesProvider theme) {
    List<dynamic>? etfList;

    // Get the appropriate ETF list based on selected tab
    final mfProviderInstance = ref.read(mfProvider);
    if (mfProviderInstance.etfCategorydata != null) {
      switch (selectedTab) {
        case 'Indices':
          etfList = mfProviderInstance.etfCategorydata?.indices;
          break;
        case 'Sector & Theme':
          etfList = mfProviderInstance.etfCategorydata?.sectorTheme;
          break;
        case 'Strategy Based':
          etfList = mfProviderInstance.etfCategorydata?.strategyBased;
          break;
        case 'Global':
          etfList = mfProviderInstance.etfCategorydata?.global;
          break;
        case 'Debt':
          etfList = mfProviderInstance.etfCategorydata?.debt;
          break;
        case 'Gold & Silver':
          etfList = mfProviderInstance.etfCategorydata?.goldSilver;
          break;
        default:
          etfList = [];
      }
    }

    if (etfList == null || etfList.isEmpty) {
      return const Center(
        child: NoDataFound(),
      );
    }

    return _ETFListView(etfList: etfList);
  }

  Widget _buildETFItem(dynamic etf, ThemesProvider theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        canRequestFocus: false,
        onTap: () async {
          final marketWatch = ref.read(marketWatchProvider);
          final depthArgs = <String, dynamic>{
            'exch': (etf.exch ?? '').toString(),
            'token': (etf.zebuToken ?? '').toString(),
            'tsym': (etf.nSESymbol ?? '').toString().split(':').last,
            'instname': '',
            'symbol': (etf.sYMBOL ?? '').toString(),
            'expDate': '',
            'option': '',
          };
           marketWatch.calldepthApis(context, depthArgs, "");
          marketWatch.scripdepthsize(true);
          marketWatch.setETF(true);
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (etf.sYMBOL ?? 'N/A').toString().replaceAll("-EQ", '').toUpperCase(),
                  style: TextWidget.textStyle(
                    fontSize: 14,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                  ),
                ),
              ],
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                    (etf.uNDERLYINGASSET ?? 'N/A').toString().replaceAll("-EQ", '').toUpperCase(),
                    style: TextWidget.textStyle(
                      fontSize: 12,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          trailing: RepaintBoundary(
            child: _ETFPriceDataWidget(
              token: (etf.zebuToken ?? '').toString(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ETFListView extends ConsumerStatefulWidget {
  final List<dynamic> etfList;
  const _ETFListView({super.key, required this.etfList});

  @override
  ConsumerState<_ETFListView> createState() => _ETFListViewState();
}

class _ETFListViewState extends ConsumerState<_ETFListView> {
  String _subInput = '';
  late WebSocketProvider _websocket;

  @override
  void initState() {
    super.initState();
    _websocket = ref.read(websocketProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeTokens();
    });
  }

  @override
  void dispose() {
    _unsubscribeTokens();
    super.dispose();
  }

  void _subscribeTokens() {
    final contextVal = context;
    final tokens = <String>[];
    for (final item in widget.etfList) {
      final token = (item.zebuToken ?? '').toString();
      final exch = (item.exch ?? '').toString();
      if (token.isNotEmpty && exch.isNotEmpty) {
        tokens.add('$exch|$token');
      }
    }

    if (tokens.isEmpty) return;
    _subInput = tokens.join('#');
    _websocket.establishConnection(
          channelInput: _subInput,
          task: 't',
          context: contextVal,
        );
  }

  void _unsubscribeTokens() {
    if (_subInput.isEmpty) return;
    _websocket.establishConnection(
          channelInput: _subInput,
          task: 'u',
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return ListView.separated(
      itemCount: widget.etfList.length,
      separatorBuilder: (_, __) => const ListDivider(),
      itemBuilder: (context, index) {
        final etf = widget.etfList[index];
        return (context.findAncestorStateOfType<_ETFCategoryDetailScreenState>()
                    ?._buildETFItem(etf, theme)) ??
            const SizedBox.shrink();
      },
    );
  }
}

class _ETFPriceDataWidget extends ConsumerStatefulWidget {
  final String token;
  const _ETFPriceDataWidget({required this.token});

  @override
  ConsumerState<_ETFPriceDataWidget> createState() => _ETFPriceDataWidgetState();
}

class _ETFPriceDataWidgetState extends ConsumerState<_ETFPriceDataWidget> {
  late String ltp;
  late String change;
  late String perChange;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    ltp = '0.00';
    change = '0.00';
    perChange = '0.00';

    final socketData = ref.read(websocketProvider).socketDatas[widget.token];
    if (socketData != null) {
      ltp = socketData['lp']?.toString() ?? ltp;
      change = socketData['chng']?.toString() ?? change;
      perChange = socketData['pc']?.toString() ?? perChange;
    }

    _subscription = ref.read(websocketProvider).socketDataStream.listen((data) {
      if (!mounted) return;
      if (!data.containsKey(widget.token)) return;
      final newData = data[widget.token];
      if (newData == null) return;

      bool valueChanged = false;
      final newLtp = newData['lp']?.toString();
      final newChange = newData['chng']?.toString();
      final newPerChange = newData['pc']?.toString();

      if (newLtp != null && newLtp != ltp && newLtp != '0.00') {
        ltp = newLtp;
        valueChanged = true;
      }
      if (newChange != null && newChange != change) {
        change = newChange;
        valueChanged = true;
      }
      if (newPerChange != null && newPerChange != perChange) {
        perChange = newPerChange;
        valueChanged = true;
      }

      if (valueChanged && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    final displayLtp = ltp == 'null' || ltp.isEmpty ? '0.00' : ltp;
    final displayChange = change == 'null' || change.isEmpty ? '0.00' : change;
    final displayPerChange =
        perChange == 'null' || perChange.isEmpty ? '0.00' : perChange;

    final changeColor = displayChange.startsWith('-') || displayPerChange.startsWith('-')
        ? colors.lossLight
        : (displayChange == '0.00' || displayPerChange == '0.00')
            ? colors.textSecondaryLight
            : colors.profit;

    final changeTextStyle = TextWidget.textStyle(
      fontSize: 16,
      color: changeColor,
      theme: theme.isDarkMode,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            displayLtp,
            style: changeTextStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: TextWidget.paraText(
            text: '$displayChange ($displayPerChange%)',
            color: colors.textSecondaryLight,
            theme: theme.isDarkMode,
          ),
        ),
      ],
    );
  }
}
