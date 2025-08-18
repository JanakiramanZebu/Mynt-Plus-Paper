import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../provider/market_watch_provider.dart';
import '../../provider/network_state_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/app_routes.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_internet_widget.dart';
import '../../utils/no_emoji_inputformatter.dart';
import 'search_scrip_list.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String wlName;
  final String isBasket;
  const SearchScreen({super.key, required this.wlName, required this.isBasket});

  @override
  ConsumerState<SearchScreen> createState() => _AddScripState();
}

class _AddScripState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  late TabController tabCtrl;
  String _searchvalue = "";
  int tabcount = 5;
  final ScrollController _tabScrollController = ScrollController();

  // Simple fixed width for each tab for reliable calculations
  final double tabWidth = 75.0;

  @override
  void initState() {
    tabcount = widget.isBasket == "Basket" ? 5 : 6;
    tabCtrl = TabController(length: tabcount, vsync: this, initialIndex: 0);
    super.initState();

    tabCtrl.addListener(() {
      if (tabCtrl.indexIsChanging) {
        ref.read(marketWatchProvider).searchClear();
        ref
            .read(marketWatchProvider)
            .scripSearch(_searchvalue, context, tabCtrl.index, widget.isBasket);

        // Center the selected tab when it changes
        _scrollToSelectedTab(tabCtrl.index);
      }
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    tabCtrl.dispose();
    super.dispose();
  }

  // Enhanced tab scrolling to ensure selected tab is always clearly visible
  void _scrollToSelectedTab(int index) {
    if (!_tabScrollController.hasClients) return;

    // Get the viewport width
    final double viewportWidth =
        _tabScrollController.position.viewportDimension;

    // Calculate the ideal position - center the tab in the viewport
    // Account for dynamic widths of Currency and Commodity tabs
    double totalOffset = 0.0;
    for (int i = 0; i < index; i++) {
      final String currentText =
          ref.read(marketWatchProvider).searchTabList[i].text ?? '';
      final bool isLongTab =
          (currentText == 'Currency' || currentText == 'Commodity');
      totalOffset += isLongTab ? 100.0 : tabWidth;
    }

    // Add half of the current tab's width
    final String currentTabText =
        ref.read(marketWatchProvider).searchTabList[index].text ?? '';
    final bool isCurrentLongTab =
        (currentTabText == 'Currency' || currentTabText == 'Commodity');
    final double currentTabWidth = isCurrentLongTab ? 100.0 : tabWidth;
    final double targetOffset =
        totalOffset - (viewportWidth / 2) + (currentTabWidth / 2);

    // Clamp the value to valid scroll range
    final double scrollTo =
        targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent);

    // Always scroll, even if tab is partially visible, to ensure it's centered
    _tabScrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic, // More pronounced animation curve
    );
  }

  TextEditingController textCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final searchScrip = ref.watch(marketWatchProvider);
      final internet = ref.watch(networkStateProvider);
      final theme = ref.read(themeProvider);
      return PopScope(
          canPop: true, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) async {
            // if (didPop) return; // If system handled back, do nothing

            if (!(["Option||Is", "Chart||Is"].contains(widget.isBasket))) {
              ref
                  .read(marketWatchProvider)
                  .requestMWScrip(context: context, isSubscribe: true);
            }
            await searchScrip.searchClear();
            currentRouteName = 'homeScreen';
            // Navigator.pop(context);
          },
          child: SafeArea(
            child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus!.unfocus(),
                child: Scaffold(
                    appBar: AppBar(
                      elevation: 0,
                      // backgroundColor: theme.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF1F3F8),
                      leadingWidth: 48,
                      titleSpacing: 0,
                      leading: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          splashColor: Colors.black.withOpacity(0.15),
                          highlightColor: Colors.black.withOpacity(0.08),
                          onTap: () {
                            if (!(["Option||Is", "Chart||Is"]
                                .contains(widget.isBasket))) {
                              ref.read(marketWatchProvider).requestMWScrip(
                                  context: context, isSubscribe: true);
                            }
                            searchScrip.searchClear();
                            searchScrip.setpageName("");
                            currentRouteName = 'homeScreen';
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 44,
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
                      title: Container(
                        // color: theme.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF1F3F8),
                        padding:
                            const EdgeInsets.only(right: 12, top: 8, bottom: 7),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                  ? colors.searchBgDark
                  : colors.searchBg,
                            borderRadius: BorderRadius.circular(5),
                            // border: Border.all(
                            //   color: theme.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE),
                            //   width: 1,
                            // ),
                          ),
                          child: Row(
                            children: [
                              // Search icon
                              const SizedBox(width: 12),
                              SvgPicture.asset(
                                assets.searchIcon,
                               color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              // Text input
                              Expanded(
                                child: TextFormField(
                                  autofocus: true,
                                  controller: textCtrl,
                                  style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                  ),
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  inputFormatters: [
                                    UpperCaseTextFormatter(),
                                    NoEmojiInputFormatter(),
                                    FilteringTextInputFormatter.deny(
                                        RegExp('[π£•₹€℅™∆√¶/.,]'))
                                  ],
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    hintText:
                                        "Search stocks, indices, options...",
                                    hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 12),
                                  ),
                                  onChanged: (value) async {
                                    _searchvalue = value;
                                    if (value.isEmpty) {
                                      searchScrip.searchClear();
                                    }
                                    if (internet.connectionStatus !=
                                        ConnectivityResult.none) {
                                      searchScrip.scripSearch(value, context,
                                          tabCtrl.index, widget.isBasket);
                                    }
                                  },
                                ),
                              ),
            
                              // Clear button
                              if (textCtrl.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      customBorder: const CircleBorder(),
                                      onTap: () async {
                                        textCtrl.clear();
                                        await searchScrip.searchClear();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SvgPicture.asset(
                                          assets.removeIcon,
                                          width: 20,
                                          height: 20,
                                          color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    body: Stack(children: [
                      Column(children: [
                        Container(
                          decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? colors.colorBlack
                                : colors.colorWhite,
                            // tab bottom border
                            border: Border(
                              bottom: BorderSide(
                                color: theme.isDarkMode
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFE0E0E0),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tabs content
                              Container(
                                height: 32,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildSearchTabs(ref, theme, tabCtrl,
                                          tabcount, searchScrip),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child:
                              // TabBarView(controller: tabCtrl, children: [
                              SearchScripList(
                                  wlName: widget.wlName,
                                  searchValue: searchScrip.allSearchScrip!,
                                  isBasket: widget.isBasket),
                          // SearchScripList(
                          //     wlName: widget.wlName,
                          //     searchValue: searchScrip.allSearchScrip!,
                          //     isBasket: widget.isBasket),
                          // SearchScripList(
                          //     wlName: widget.wlName,
                          //     searchValue: searchScrip.allSearchScrip!,
                          //     isBasket: widget.isBasket),
                          // SearchScripList(
                          //     wlName: widget.wlName,
                          //     searchValue: searchScrip.allSearchScrip!,
                          //     isBasket: widget.isBasket),
                          // SearchScripList(
                          //     wlName: widget.wlName,
                          //     searchValue: searchScrip.allSearchScrip!,
                          //     isBasket: widget.isBasket),
                          // SearchScripList(
                          //     wlName: widget.wlName,
                          //     searchValue: searchScrip.allSearchScrip!,
                          //     isBasket: widget.isBasket),
                          // ])
                        )
                      ]),
                      if (internet.connectionStatus ==
                          ConnectivityResult.none) ...[const NoInternetWidget()]
                    ]))),
          ));
    });
  }

  Widget _buildSearchTabs(
      WidgetRef ref, theme, TabController tabCtrl, int tabcount, searchScrip) {
    final searchTabList =
        ref.read(marketWatchProvider).searchTabList.sublist(0, tabcount);

    return ListView.builder(
      controller: _tabScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemCount: searchTabList.length,
      itemBuilder: (context, index) {
        final tab = searchTabList[index];
        final isSelected = tabCtrl.index == index;

        // Dynamically adjust width for Currency and Commodity tabs when selected
        final bool isLongTab =
            (tab.text == 'Currency' || tab.text == 'Commodity');
        final double dynamicWidth = isLongTab ? 120.0 : tabWidth;

        return Container(
          width: dynamicWidth,
          margin: const EdgeInsets.only(right: 0),
          child: Material(
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
                if (tabCtrl.index != index) {
                  tabCtrl.animateTo(index);
                  // Immediately scroll to center the tapped tab
                  _scrollToSelectedTab(index);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: TextWidget.subText(
                        text: tab.text ?? '',
                        color: isSelected
                            ? theme.isDarkMode
                                ? colors.secondaryDark
                                : colors.secondaryLight
                            : theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        theme: theme.isDarkMode,
                        fw: isSelected ? 2 : null),
                  ),
                  // Animated underline indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    height: 2,
                    width: isSelected ? dynamicWidth - 18 : 0,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(
                      color: colors.colorBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
