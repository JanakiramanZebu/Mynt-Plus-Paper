import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../provider/thems.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../locator/preference.dart';
import '../../../sharedWidget/no_data_found_web.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../utils/responsive_navigation.dart';

class SearchDialogWeb extends ConsumerStatefulWidget {
  final String wlName;
  final String isBasket;

  const SearchDialogWeb({
    super.key,
    required this.wlName,
    required this.isBasket,
  });

  @override
  ConsumerState<SearchDialogWeb> createState() => _SearchDialogWebState();
}

class _SearchDialogWebState extends ConsumerState<SearchDialogWeb>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchValue = "";
  int _tabCount = 5;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _tabScrollController = ScrollController();
  final ScrollController _scrollController = ScrollController();
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool perchangisAscending;
  
  // Hover state tracking for each list item
  final Map<int, bool> _hoveredItems = {};

  // Dragging state - COMMENTED OUT (draggable functionality disabled)
  // Offset? _position;
  // bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _tabCount = widget.isBasket == "Basket" ? 5 : 6;
    _tabController =
        TabController(length: _tabCount, vsync: this, initialIndex: 0);

    setState(() {
      scripisAscending = pref.isMWScripname ?? true;
      pricepisAscending = pref.isMWPrice ?? true;
      perchangisAscending = pref.isMWPerchang ?? true;
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(marketWatchProvider).searchClear();
        ref.read(marketWatchProvider).scripSearch(
            _searchValue, context, _tabController.index, widget.isBasket);
        _scrollToSelectedTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab(int index) {
    if (!_tabScrollController.hasClients) return;

    // Simplified scroll calculation for dynamic-width tabs
    // Each tab has padding (16*2) + text width + spacing (6*2) = approximately 50-150px depending on text
    // We'll use an average width estimate
    final double estimatedTabWidth =
        120.0; // Average width for tabs with padding
    final double viewportWidth =
        _tabScrollController.position.viewportDimension;
    final double targetOffset = (index * estimatedTabWidth) -
        (viewportWidth / 2) +
        (estimatedTabWidth / 2);
    final double scrollTo =
        targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent);

    _tabScrollController.animateTo(
      scrollTo,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final searchScrip = ref.watch(marketWatchProvider);

    // Set initial position to center if not set
    // if (_position == null) {
    //   final screenSize = MediaQuery.of(context).size;
    //   const dialogWidth = 800.0;
    //   const dialogHeight = 600.0;
    //   _position = Offset(
    //     (screenSize.width - dialogWidth) / 2,
    //     (screenSize.height - dialogHeight) / 2,
    //   );
    // }

    return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  ref.read(marketWatchProvider).searchClear();
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),

            // Draggable Dialog - COMMENTED OUT
            // Positioned(
            //   left: _position!.dx,
            //   top: _position!.dy,
            //   child: GestureDetector(
            //     onPanStart: (details) {
            //       setState(() {
            //         _isDragging = true;
            //       });
            //     },
            //     onPanUpdate: (details) {
            //       setState(() {
            //         final newX = _position!.dx + details.delta.dx;
            //         final newY = _position!.dy + details.delta.dy;
            //
            //         // Get screen size
            //         final screenSize = MediaQuery.of(context).size;
            //         const dialogWidth = 800.0;
            //         const dialogHeight = 600.0;
            //
            //         // Constrain position to stay within screen bounds
            //         _position = Offset(
            //           newX.clamp(0.0, screenSize.width - dialogWidth),
            //           newY.clamp(0.0, screenSize.height - dialogHeight),
            //         );
            //       });
            //     },
            //     onPanEnd: (details) {
            //       setState(() {
            //         _isDragging = false;
            //       });
            //     },
            //     child: Container(
            //       width: 500,
            //       height: 600,
            //       decoration: BoxDecoration(
            //         color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
            //         borderRadius: BorderRadius.circular(5),
            //         border: _isDragging ? Border.all(
            //           color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
            //           width: 2,
            //         ) : null,
            //       ),
            //       child: Container(
            //         child: Column(
            //           mainAxisSize: MainAxisSize.min,
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            // Fixed Centered Dialog
            Center(
              child: Container(
                width: 560,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      //   decoration: BoxDecoration(
                      //     border: Border(
                      //       bottom: BorderSide(
                      //         color: theme.isDarkMode
                      //             ? WebDarkColors.divider
                      //             : WebColors.divider,
                      //       ),
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         'Stock Search',
                      //         style: WebTextStyles.sub(
                      //           isDarkTheme: theme.isDarkMode,
                      //           color: theme.isDarkMode
                      //               ? WebDarkColors.textPrimary
                      //               : WebColors.textPrimary,
                      //           fontWeight: FontWeight.w700,
                      //         ),
                      //       ),
                      //       Material(
                      //         color: Colors.transparent,
                      //         shape: const CircleBorder(),
                      //         child: InkWell(
                      //           customBorder: const CircleBorder(),
                      //           splashColor: theme.isDarkMode
                      //               ? Colors.white.withOpacity(.15)
                      //               : Colors.black.withOpacity(.15),
                      //           highlightColor: theme.isDarkMode
                      //               ? Colors.white.withOpacity(.08)
                      //               : Colors.black.withOpacity(.08),
                      //           onTap: () {
                      //             ref.read(marketWatchProvider).searchClear();
                      //             Navigator.of(context).pop();
                      //           },
                      //           child: Padding(
                      //             padding: const EdgeInsets.all(5),
                      //             child: Icon(
                      //               Icons.close,
                      //               size: 18,
                      //               color: theme.isDarkMode
                      //                   ? WebDarkColors.iconSecondary
                      //                   : WebColors.iconSecondary,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // Search Bar Section
                      Container(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: theme.isDarkMode
                                        ? WebDarkColors.inputBorder
                                        : WebColors.inputBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    SvgPicture.asset(
                                      assets.searchIcon,
                                      width: 16,
                                      height: 16,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.iconSecondary
                                          : WebColors.iconSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _textController,
                                        autofocus: true,
                                        style: WebTextStyles.formInput(
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                        ),
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        inputFormatters: [
                                          UpperCaseTextFormatter(),
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
                                              "Search stocks, indices, options",
                                          hintStyle: WebTextStyles.formInput(
                                            isDarkTheme: theme.isDarkMode,
                                            color: theme.isDarkMode
                                                ? WebDarkColors.textSecondary
                                                : WebColors.textSecondary,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 0, vertical: 12),
                                        ),
                                        onChanged: (value) async {
                                          setState(() {
                                            _searchValue = value;
                                          });
                                          if (value.isEmpty) {
                                            searchScrip.searchClear();
                                          } else {
                                            searchScrip.scripSearch(
                                                value,
                                                context,
                                                _tabController.index,
                                                widget.isBasket);
                                          }
                                        },
                                      ),
                                    ),
                                    // Clear search text icon (appears when text is not empty)
                                    ValueListenableBuilder<TextEditingValue>(
                                      valueListenable: _textController,
                                      builder: (context, value, child) {
                                        if (value.text.isNotEmpty)
                                          // ignore: curly_braces_in_flow_control_structures
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                hoverColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.1)
                                                    : Colors.black
                                                        .withOpacity(0.1),
                                                splashColor: theme.isDarkMode
                                                    ? Colors.white
                                                        .withOpacity(0.2)
                                                    : Colors.black
                                                        .withOpacity(0.2),
                                                onTap: () async {
                                                  _textController.clear();
                                                  await searchScrip
                                                      .searchClear();
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    // color: theme.isDarkMode
                                                    //     ? WebDarkColors.surface
                                                    //     : WebColors.surface,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: theme.isDarkMode
                                                          ? WebDarkColors
                                                              .inputBorder
                                                          : WebColors
                                                              .inputBorder,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: theme.isDarkMode
                                                        ? WebDarkColors
                                                            .iconSecondary
                                                        : WebColors
                                                            .iconSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Close dialog icon (always visible, outside search bar)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  hoverColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.black.withOpacity(0.1),
                                  splashColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.2),
                                  onTap: () {
                                    ref.read(marketWatchProvider).searchClear();
                                    Navigator.of(context).pop();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.iconSecondary
                                          : WebColors.iconSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Always show tabs and content area
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? WebDarkColors.inputBorder
                                  : WebColors.inputBorder,
                              width: 1,
                            ),
                          ),
                        ),
                        child: _buildSearchTabs(ref, theme),
                      ),

                      // Search Results or No Data
                      Expanded(
                        child: _buildSearchResults(searchScrip, theme),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildSearchTabs(WidgetRef ref, ThemesProvider theme) {
    final searchTabList =
        ref.read(marketWatchProvider).searchTabList.sublist(0, _tabCount);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left arrow button
        // _buildTabArrowButton(
        //   icon: Icons.chevron_left,
        //   onPressed: () => _scrollTabsLeft(),
        //   theme: theme,
        // ),
        // const SizedBox(width: 5),
        // Tabs scrollable area
        Expanded(
          child: SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int index = 0; index < searchTabList.length; index++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildSearchTab(
                      searchTabList[index].text ?? '',
                      index,
                      _tabController.index == index,
                      theme,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // const SizedBox(width: 5),
        // Right arrow button
        // _buildTabArrowButton(
        //   icon: Icons.chevron_right,
        //   onPressed: () => _scrollTabsRight(),
        //   theme: theme,
        // ),
      ],
    );
  }

  Widget _buildSearchTab(
    String title,
    int index,
    bool isSelected,
    ThemesProvider theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          if (_tabController.index != index) {
            _tabController.animateTo(index);
            _scrollToSelectedTab(index);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? (theme.isDarkMode
                    ? WebDarkColors.backgroundTertiary
                    : WebColors.backgroundTertiary)
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  : (theme.isDarkMode
                      ? WebDarkColors.textSecondary
                      : WebColors.textSecondary),
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: WebTextStyles.tab(
              isDarkTheme: theme.isDarkMode,
              color: isSelected
                  ? (theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary)
                  : (theme.isDarkMode
                      ? WebDarkColors.navItem
                      : WebColors.navItem),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
      MarketWatchProvider searchScrip, ThemesProvider theme) {
    if (searchScrip.allSearchScrip?.isEmpty ?? true) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const Center(
          child: NoDataFoundWeb(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(scrollbars: false),
        child: RawScrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(0),
          thumbColor: theme.isDarkMode
              ? WebDarkColors.textSecondary.withOpacity(0.5)
              : WebColors.textSecondary.withOpacity(0.5),
          child: ListView.separated(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            itemCount: searchScrip.allSearchScrip!.length,
            separatorBuilder: (context, index) => Divider(
              height: 0,
              color:
                  theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
            ),
            itemBuilder: (BuildContext context, int index) {
              final scrip = searchScrip.allSearchScrip![index];

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredItems[index] = true),
                onExit: (_) => setState(() => _hoveredItems[index] = false),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                    highlightColor: theme.isDarkMode
                        ? Colors.white.withOpacity(0.02)
                        : Colors.black.withOpacity(0.02),
                    onTap: () async {
                    if (widget.isBasket == "Chart||Is") {
                      // Create DepthInputArgs from selected scrip to update header and scrip info
                      final depthArgs = DepthInputArgs(
                        exch: scrip.exch.toString(),
                        token: scrip.token.toString(),
                        tsym: scrip.tsym.toString(),
                        instname: scrip.instname ?? "",
                        symbol: scrip.symbol ?? scrip.tsym.toString(),
                        expDate: scrip.expDate ?? "",
                        option: scrip.option ?? "",
                      );

                      // Update depth/scrip info panel and header
                      await searchScrip.calldepthApis(context, depthArgs, "");

                      // Update chart
                      searchScrip.setChartScript(
                        scrip.exch.toString(),
                        scrip.token.toString(),
                        scrip.tsym.toString(),
                      );

                      await searchScrip.searchClear();
                      Navigator.of(context).pop();
                    } else if (widget.isBasket == "Option||Is") {
                      searchScrip.setOptionScript(
                        context,
                        scrip.exch.toString(),
                        scrip.token.toString(),
                        scrip.tsym.toString(),
                      );
                      await searchScrip.searchClear();
                      Navigator.of(context).pop();
                    } else {
                      await searchScrip.calldepthApis(
                        context,
                        scrip,
                        widget.isBasket,
                      );
                      await searchScrip.searchClear();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        // Scrip Info
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Symbol name and option
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${scrip.symbol?.isNotEmpty == true ? scrip.symbol : scrip.tsym}"
                                        .replaceAll("-EQ", "")
                                        .toUpperCase(),
                                    style: WebTextStyles.symbolList(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                    ),
                                  ),
                                  if (scrip.option != null &&
                                      scrip.option.toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        "${scrip.option}",
                                        style: WebTextStyles.symbolList(
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  if (scrip.expDate != null &&
                                      scrip.expDate.toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Text(
                                        " ${scrip.expDate}",
                                        style: WebTextStyles.symbolList(
                                          isDarkTheme: theme.isDarkMode,
                                          color: theme.isDarkMode
                                              ? WebDarkColors.textPrimary
                                              : WebColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '${scrip.exch}',
                                      style: WebTextStyles.exchText(
                                          isDarkTheme: theme.isDarkMode,
                                          color: WebColors.textSecondary),
                                    ),
                                  ),
                                  // Buy/Sell buttons for Basket mode - shown next to symbol
                                  if (widget.isBasket == "Basket") ...[
                                    const SizedBox(width: 8),
                                    IgnorePointer(
                                      ignoring: !(_hoveredItems[index] ?? false),
                                      child: AnimatedOpacity(
                                        opacity: (_hoveredItems[index] ?? false) ? 1.0 : 0.0,
                                        duration: const Duration(milliseconds: 150),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Buy Button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(5),
                                                onTap: () async {
                                                  await _handleBuySellClick(
                                                      context, scrip, true, ref, theme);
                                                },
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: WebColors.primary,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'B',
                                                      style: WebTextStyles.buttonMd(
                                                        isDarkTheme: theme.isDarkMode,
                                                        color: Colors.white,
                                                        fontWeight: WebFonts.medium,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            // Sell Button
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(5),
                                                onTap: () async {
                                                  await _handleBuySellClick(
                                                      context, scrip, false, ref, theme);
                                                },
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: WebColors.tertiary,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      'S',
                                                      style: WebTextStyles.buttonSm(
                                                        isDarkTheme: theme.isDarkMode,
                                                        color: Colors.white,
                                                        fontWeight: WebFonts.medium,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // const SizedBox(height: 8),
                              // Exchange and additional info
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.start,
                              //   children: [

                              // if (scrip.cname != null && scrip.cname.toString().isNotEmpty)
                              //   Padding(
                              //     padding: const EdgeInsets.only(left: 8),
                              //     child: Text(
                              //       "${scrip.cname}",
                              //       style: WebTextStyles.caption(
                              //         isDarkTheme: theme.isDarkMode,
                              //         color: theme.isDarkMode
                              //             ? WebDarkColors.textSecondary
                              //             : WebColors.textSecondary,
                              //       ),
                              //       overflow: TextOverflow.ellipsis,
                              //     ),
                              //   ),
                              // ],
                              // ),
                            ],
                          ),
                        ),

                        // Save/Bookmark Icon for Watchlist mode
                        if (widget.isBasket != "Basket" &&
                            widget.isBasket != "Chart||Is" &&
                            widget.isBasket != "Option||Is" &&
                            searchScrip.isPreDefWLs != "Yes" &&
                            searchScrip.scrips.length < 50)
                          Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              splashColor: Colors.grey.withOpacity(0.2),
                              highlightColor: Colors.grey.withOpacity(0.1),
                              onTap: () async {
                                if (!searchScrip.exarr
                                    .contains('"${scrip.exch}"')) {
                                  showResponsiveErrorMessage(
                                      context, "Segment is not active.");
                                } else {
                                  if (searchScrip.isAdded![index]) {
                                    await searchScrip.isActiveAddBtn(
                                        false, index);
                                    await searchScrip.addDelMarketScrip(
                                      widget.wlName,
                                      "${scrip.exch}|${scrip.token}",
                                      context,
                                      false,
                                      false,
                                      false,
                                      false,
                                    );
                                  } else {
                                    await searchScrip.isActiveAddBtn(
                                        true, index);
                                    await searchScrip.addDelMarketScrip(
                                      widget.wlName,
                                      "${scrip.exch}|${scrip.token}",
                                      context,
                                      true,
                                      false,
                                      false,
                                      false,
                                    );

                                    try {
                                      final currentSort = ref
                                          .read(marketWatchProvider)
                                          .sortByWL;

                                      if (currentSort.isNotEmpty) {
                                        await ref
                                            .read(marketWatchProvider)
                                            .filterMWScrip(
                                              sorting: currentSort,
                                              wlName: widget.wlName,
                                              context: context,
                                            );
                                      }

                                      scripisAscending = !scripisAscending;
                                      pref.setMWScrip(scripisAscending);

                                      pricepisAscending = !pricepisAscending;
                                      pref.setMWPrice(pricepisAscending);

                                      perchangisAscending =
                                          !perchangisAscending;
                                      pref.setMWPerchnage(perchangisAscending);
                                    } catch (e) {
                                      print("Error in sorting: $e");
                                    }
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: !searchScrip.exarr
                                        .contains('"${scrip.exch}"')
                                    ? SvgPicture.asset(
                                        assets.dInfo,
                                        color: Colors.red,
                                        height: 18,
                                        width: 18,
                                      )
                                    : SvgPicture.asset(
                                        searchScrip.isAdded![index]
                                            ? assets.bookmarkIcon
                                            : assets.bookmarkedIcon,
                                        color: theme.isDarkMode &&
                                                searchScrip.isAdded![index]
                                            ? WebDarkColors.primary
                                            : searchScrip.isAdded![index]
                                                ? WebColors.primary
                                                : WebDarkColors.textSecondary,
                                        height: 18,
                                        width: 18,
                                      ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            },
          ),
        ),
      ),
    );
  }

  // Handle Buy/Sell click for basket mode
  Future<void> _handleBuySellClick(
    BuildContext context,
    dynamic scrip,
    bool isBuy,
    WidgetRef ref,
    ThemesProvider theme,
  ) async {
    try {
      final marketWatch = ref.read(marketWatchProvider);
      final orderProv = ref.read(orderProvider);

      // Check basket limit
      if (orderProv.bsktScripList.length >=
          orderProv.frezQtyOrderSliceMaxLimit) {
        showResponsiveErrorMessage(
          context,
          "Basket limit reached. Please create a new basket as you are exceeding the ${orderProv.frezQtyOrderSliceMaxLimit} item limit.",
        );
        return;
      }

      // Check if segment is active
      if (!marketWatch.exarr.contains('"${scrip.exch}"')) {
        showResponsiveErrorMessage(context, "Segment is not active.");
        return;
      }

      // Get root navigator context before closing dialog
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      final rootContext = rootNavigator.context;

      // Fetch scrip info first
      await marketWatch.fetchScripInfo(
        scrip.token.toString(),
        scrip.exch.toString(),
        context,
        true,
      );

      if (!context.mounted) return;

      // Check if scrip info was fetched
      if (marketWatch.scripInfoModel == null) {
        showResponsiveErrorMessage(
            context, "Failed to fetch scrip information.");
        return;
      }

      // Fetch depth data (getQuotes) to get LTP and percentage change
      await marketWatch.fetchScripQuote(
        scrip.token.toString(),
        scrip.exch.toString(),
        context,
      );

      if (!context.mounted) return;

      // Get LTP and percentage change from depth data (getQuotes)
      final depthData = marketWatch.getQuotes;
      final ltp =
          depthData?.lp?.toString() ?? depthData?.c?.toString() ?? "0.00";
      final perChange = depthData?.pc?.toString() ?? "0.00";

      // Create OrderScreenArgs
      // Note: ScripNewValue doesn't have prd, lp, pc properties - we get those from fetched data
      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: scrip.exch.toString(),
        tSym: scrip.tsym.toString(),
        isExit: false,
        token: scrip.token.toString(),
        transType: isBuy,
        lotSize: marketWatch.scripInfoModel?.ls?.toString() ?? "1",
        ltp: ltp,
        perChange: perChange,
        orderTpye: '',
        holdQty: '',
        isModify: false,
        prd:
            null, // prd is not available in search scrip model, will be set in order screen
        raw: {
          'exch': scrip.exch.toString(),
          'token': scrip.token.toString(),
          'tsym': scrip.tsym.toString(),
          'symbol': scrip.symbol?.toString() ?? scrip.tsym.toString(),
          'expDate': scrip.expDate?.toString() ?? '',
          'option': scrip.option?.toString() ?? '',
        },
      );

      // Close search dialog
      Navigator.of(context).pop();

      // Wait a bit to ensure dialog is closed
      await Future.delayed(const Duration(milliseconds: 150));

      // Navigate to order screen with basket context using root context
      await ResponsiveNavigation.toPlaceOrderScreen(
        context: rootContext,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": marketWatch.scripInfoModel!,
          "isBskt": "Basket",
        },
      );
    } catch (e, stackTrace) {
      print("Error in _handleBuySellClick: $e");
      print("Stack trace: $stackTrace");
      if (context.mounted) {
        showResponsiveErrorMessage(
            context, "Failed to open order screen: ${e.toString()}");
      }
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
