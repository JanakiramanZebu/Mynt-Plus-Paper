import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../locator/preference.dart';
import '../../../sharedWidget/snack_bar.dart';

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
  final double _tabWidth = 75.0;
  Preferences pref = Preferences();
  late bool scripisAscending;
  late bool pricepisAscending;
  late bool perchangisAscending;
  
  // Dragging state
  Offset? _position;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _tabCount = widget.isBasket == "Basket" ? 5 : 6;
    _tabController = TabController(length: _tabCount, vsync: this, initialIndex: 0);
    
    setState(() {
      scripisAscending = pref.isMWScripname ?? true;
      pricepisAscending = pref.isMWPrice ?? true;
      perchangisAscending = pref.isMWPerchang ?? true;
    });
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        ref.read(marketWatchProvider).searchClear();
        ref.read(marketWatchProvider).scripSearch(
          _searchValue, 
          context, 
          _tabController.index, 
          widget.isBasket
        );
        _scrollToSelectedTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabScrollController.dispose();
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scrollToSelectedTab(int index) {
    if (!_tabScrollController.hasClients) return;

    final double viewportWidth = _tabScrollController.position.viewportDimension;
    double totalOffset = 0.0;
    
    for (int i = 0; i < index; i++) {
      final String currentText = ref.read(marketWatchProvider).searchTabList[i].text ?? '';
      final bool isLongTab = (currentText == 'Currency' || currentText == 'Commodity');
      totalOffset += isLongTab ? 100.0 : _tabWidth;
    }

    final String currentTabText = ref.read(marketWatchProvider).searchTabList[index].text ?? '';
    final bool isCurrentLongTab = (currentTabText == 'Currency' || currentTabText == 'Commodity');
    final double currentTabWidth = isCurrentLongTab ? 100.0 : _tabWidth;
    final double targetOffset = totalOffset - (viewportWidth / 2) + (currentTabWidth / 2);
    final double scrollTo = targetOffset.clamp(0.0, _tabScrollController.position.maxScrollExtent);

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
    if (_position == null) {
      final screenSize = MediaQuery.of(context).size;
      const dialogWidth = 800.0;
      const dialogHeight = 600.0;
      _position = Offset(
        (screenSize.width - dialogWidth) / 2,
        (screenSize.height - dialogHeight) / 2,
      );
    }
    
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
          
          // Draggable Dialog
          Positioned(
            left: _position!.dx,
            top: _position!.dy,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  final newX = _position!.dx + details.delta.dx;
                  final newY = _position!.dy + details.delta.dy;
                  
                  // Get screen size
                  final screenSize = MediaQuery.of(context).size;
                  const dialogWidth = 800.0;
                  const dialogHeight = 600.0;
                  
                  // Constrain position to stay within screen bounds
                  _position = Offset(
                    newX.clamp(0.0, screenSize.width - dialogWidth),
                    newY.clamp(0.0, screenSize.height - dialogHeight),
                  );
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
              },
              child: Container(
                width: 800,
                height: 600,
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: _isDragging ? 30 : 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: _isDragging ? Border.all(
                    color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                    width: 2,
                  ) : null,
                ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Dialog Header
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search & Add Scrips',
                    style: WebTextStyles.title(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode 
                          ? WebDarkColors.textPrimary 
                          : WebColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      splashColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.15)
                          : Colors.black.withOpacity(.15),
                      highlightColor: theme.isDarkMode
                          ? Colors.white.withOpacity(.08)
                          : Colors.black.withOpacity(.08),
                      onTap: () {
                        ref.read(marketWatchProvider).searchClear();
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: theme.isDarkMode
                              ? WebDarkColors.iconSecondary
                              : WebColors.iconSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar Section
            Container(
              padding: const EdgeInsets.only(bottom: 16),
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
                        style: WebTextStyles.para(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode 
                              ? WebDarkColors.textPrimary 
                              : WebColors.textPrimary,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          UpperCaseTextFormatter(),
                          FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
                        ],
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Search stocks, indices, options...",
                          hintStyle: WebTextStyles.sub(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode 
                                ? WebDarkColors.textSecondary 
                                : WebColors.textSecondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, 
                            vertical: 12
                          ),
                        ),
                        onChanged: (value) async {
                          _searchValue = value;
                          if (value.isEmpty) {
                            searchScrip.searchClear();
                          } else {
                            searchScrip.scripSearch(
                              value, 
                              context, 
                              _tabController.index, 
                              widget.isBasket
                            );
                          }
                        },
                      ),
                    ),
                    if (_textController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () async {
                              _textController.clear();
                              await searchScrip.searchClear();
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
            ),
            
            // Always show tabs and content area
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
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
    )),
    ]));
  }

  Widget _buildSearchTabs(WidgetRef ref, ThemesProvider theme) {
    final searchTabList = ref.read(marketWatchProvider).searchTabList.sublist(0, _tabCount);

    return ListView.builder(
      controller: _tabScrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: searchTabList.length,
      itemBuilder: (context, index) {
        final tab = searchTabList[index];
        final isSelected = _tabController.index == index;
        final bool isLongTab = (tab.text == 'Currency' || tab.text == 'Commodity');
        final double dynamicWidth = isLongTab ? 100.0 : 80.0;

        return Container(
          width: dynamicWidth,
          margin: const EdgeInsets.only(right: 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                if (_tabController.index != index) {
                  _tabController.animateTo(index);
                  _scrollToSelectedTab(index);
                }
              },
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.text ?? '',
                      style: WebTextStyles.para(
                        isDarkTheme: theme.isDarkMode,
                        color: isSelected
                            ? theme.isDarkMode
                                ? WebDarkColors.navItemActive
                                : WebColors.navItemActive
                            : theme.isDarkMode
                                ? WebDarkColors.navItem
                                : WebColors.navItem,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      height: 2,
                      width: isSelected ? 60 : 0,
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? WebDarkColors.primary
                            : WebColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(MarketWatchProvider searchScrip, ThemesProvider theme) {
    if (searchScrip.allSearchScrip?.isEmpty ?? true) {
      return Container(
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: const Center(
          child: NoDataFound(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: searchScrip.allSearchScrip!.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: theme.isDarkMode 
              ? WebDarkColors.inputBorder 
              : WebColors.inputBorder,
        ),
        itemBuilder: (BuildContext context, int index) {
          final scrip = searchScrip.allSearchScrip![index];
          
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              highlightColor: theme.isDarkMode
                  ? Colors.white.withOpacity(0.02)
                  : Colors.black.withOpacity(0.02),
              onTap: () async {
                if (widget.isBasket == "Chart||Is") {
                  await searchScrip.fetchScripQuoteIndex(
                    scrip.token.toString(),
                    scrip.exch.toString(),
                    context,
                  );
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
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${scrip.symbol?.isNotEmpty == true ? scrip.symbol : scrip.tsym}".replaceAll("-EQ", "").toUpperCase(),
                                style: WebTextStyles.para(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (scrip.option != null && scrip.option.toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    "${scrip.option}",
                                    style: WebTextStyles.para(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textPrimary
                                          : WebColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Exchange and additional info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${scrip.exch}',
                                style: WebTextStyles.caption(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textSecondary
                                      : WebColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (scrip.expDate != null && scrip.expDate.toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    " ${scrip.expDate}",
                                    style: WebTextStyles.para(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textSecondary
                                          : WebColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (scrip.cname != null && scrip.cname.toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    "${scrip.cname}",
                                    style: WebTextStyles.para(
                                      isDarkTheme: theme.isDarkMode,
                                      color: theme.isDarkMode
                                          ? WebDarkColors.textSecondary
                                          : WebColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Save/Bookmark Icon
                    if (widget.isBasket != "Chart||Is" &&
                        widget.isBasket != "Option||Is" &&
                        widget.isBasket != "Basket" &&
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
                            if(!searchScrip.exarr.contains('"${scrip.exch}"')){
                              showResponsiveErrorMessage(context, "Segment is not active.");
                            } else {
                              if (searchScrip.isAdded![index]) {
                                await searchScrip.isActiveAddBtn(false, index);
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
                                await searchScrip.isActiveAddBtn(true, index);
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
                                  final currentSort = ref.read(marketWatchProvider).sortByWL;

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

                                  perchangisAscending = !perchangisAscending;
                                  pref.setMWPerchnage(perchangisAscending);
                                } catch (e) {
                                  print("Error in sorting: $e");
                                }
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: !searchScrip.exarr.contains('"${scrip.exch}"') ?
                            SvgPicture.asset(assets.dInfo,
                              color: Colors.red,
                              height: 20,
                              width: 20,
                            ) :
                            SvgPicture.asset(
                              searchScrip.isAdded![index]
                                  ? assets.bookmarkIcon
                                  : assets.bookmarkedIcon,
                              color: theme.isDarkMode &&
                                      searchScrip.isAdded![index]
                                  ? WebDarkColors.primary
                                  : searchScrip.isAdded![index]
                                      ? WebColors.primary
                                      : WebDarkColors.textSecondary,
                              height: 20,
                              width: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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