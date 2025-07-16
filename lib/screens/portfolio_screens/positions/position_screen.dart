import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/screens/portfolio_screens/positions/position_detail_screen.dart';
// import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_switch_btn.dart';
import '../../../sharedWidget/custom_text_btn.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_data_found.dart';
import '../../../utils/no_emoji_inputformatter.dart';
import '../../home_screen.dart';
import 'filter_scrip_bottom_sheet.dart';
import 'group/create_group.dart';
import 'group/position_group_symbol.dart';

class PositionScreen extends ConsumerStatefulWidget {
  final List<PositionBookModel> listofPosition;
  const PositionScreen({super.key, required this.listofPosition});

  @override
  ConsumerState<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends ConsumerState<PositionScreen> {
  // Cache SVG icons to avoid rebuilds
  final Map<String, Widget> _cachedIcons = {};
  StreamSubscription? _socketSubscription;

  @override
  void initState() {
    super.initState();
    _setupSocketSubscription();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  void _setupSocketSubscription() {
    // Delayed to ensure context is available
    Future.microtask(() {
      final websocket = ref.read(websocketProvider);
      final positionBook = ref.read(portfolioProvider);

      _socketSubscription = websocket.socketDataStream.listen((socketDatas) {
        bool needsUpdate = false;

        for (var position in widget.listofPosition) {
          if (socketDatas.containsKey(position.token)) {
            final socketData = socketDatas[position.token];

            // FIX: Accept all valid values for LTP updates to ensure real-time prices
            final lp = socketData['lp']?.toString();
            if (lp != null && lp != "null" && lp != position.lp) {
              position.lp = lp;
              needsUpdate = true;
            }

            // Update percent change if available
            final pc = socketData['pc']?.toString();
            if (pc != null && pc != "null" && pc != position.perChange) {
              position.perChange = pc;
              needsUpdate = true;
            }
          }
        }

        // FIX: Always update UI immediately when price data changes
        if (needsUpdate) {
          positionBook.positionCal(positionBook.isDay);
          if (mounted) setState(() {});
        }
      });
    });
  }

  // Cache SVG icons for better performance
  Widget _getCachedIcon(String iconPath,
      {Color? color, double? width, String? fit}) {
    final key = "$iconPath${color?.value ?? ''}${width ?? ''}${fit ?? ''}";
    if (!_cachedIcons.containsKey(key)) {
      _cachedIcons[key] = SvgPicture.asset(
        iconPath,
        width: width ?? 19,
        fit: BoxFit.scaleDown,
        color: color,
      );
    }
    return _cachedIcons[key]!;
  }

  @override
  Widget build(BuildContext context) {
    final funds = ref.watch(fundProvider);

    // Only consume the necessary providers at the top level
    return Consumer(
      builder: (context, watch, _) {
        final positionBook = ref.watch(portfolioProvider);
        final theme = ref.read(themeProvider);

        if (positionBook.posloader) {
          return const Center(child: CircularProgressIndicator());
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: RefreshIndicator(
            onRefresh: () async {
              await positionBook.fetchPositionBook(context, false);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  // parent: BouncingScrollPhysics(),
                  ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with P&L info
                    _PositionHeaderSection(
                      theme: theme,
                      positionBook: positionBook,
                      listofPosition: widget.listofPosition,
                    ),

                    // Filter options section
                    // if (positionBook.postionBookModel!.isNotEmpty &&
                    //     widget.listofPosition.length > 1)
                    //   _buildFilterSection(context, theme, positionBook),

                    // Search section if enabled
                    // if (positionBook.showSearchPosition)
                    if (positionBook.postionBookModel!.isNotEmpty) ...[
                      _buildSearchSection(context, theme, positionBook, funds),
                      _buildSearchBar(),
                    ],
                    _buildPositionList(context, theme, positionBook),

                    // Position list section
                  ]),
            ),
          ),
        );
      },
    );
  }

  // Widget _buildFilterSection(BuildContext context, ThemesProvider theme,
  //     PortfolioProvider positionBook) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       if (widget.listofPosition.length > 1 && positionBook.posSelection == "All position") ...[
  //         PositionGroupActions(),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.end,
  //           children: [

  //             InkWell(
  //                 onTap: () {
  //                   // Prevent multiple taps on search button
  //                   if (positionBook.isFilterNavigating) return;

  //                   positionBook.showPositionSearch(true);
  //                 },
  //                 child: Padding(
  //                   padding: const EdgeInsets.only(right: 16, left: 10),
  //                   child: _getCachedIcon(
  //                     assets.searchIcon,
  //                     width: 19,
  //                     color: theme.isDarkMode
  //                         ? const Color(0xffBDBDBD)
  //                         : colors.colorGrey,
  //                   ),
  //                 )),
  //           ],
  //         )
  //       ] else if (positionBook.posSelection != "All position") ...[
  //         // CustomTextBtn(
  //         //     label: 'Create Group',
  //         //     onPress: () {
  //         //       // Prevent multiple dialog opens
  //         //       if (positionBook.isFilterNavigating) return;

  //         //       try {
  //         //         positionBook.setFilterNavigating(true);

  //         //       showDialog(
  //         //           context: context,
  //         //           builder: (BuildContext context) => const CreateGroupPos(),
  //         //         ).then((_) {
  //         //           // Reset navigation lock after dialog is closed
  //         //           positionBook.setFilterNavigating(false);
  //         //         });
  //         //       } catch (e) {
  //         //         positionBook.setFilterNavigating(false);
  //         //       }
  //         //     },
  //         //     icon: assets.addCircleIcon)
  //       ]
  //     ],
  //   );
  // }

  Widget _buildSearchSection(BuildContext context, ThemesProvider theme,
      PortfolioProvider positionBook, FundProvider funds) {
    final showSearch = ref.watch(portfolioProvider).showSearchPosition;

    if (showSearch) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: colors.searchBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        Material(
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
                              Future.delayed(const Duration(milliseconds: 150),
                                  () {
                                positionBook.showPositionSearch(true);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _getCachedIcon(
                                assets.searchIcon,
                                color: colors.textPrimaryLight,
                                width: 20,
                              ),
                            ),
                          ),
                        ),
                        if (positionBook.allPostionList!.length > 1)
                          Material(
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
                                Future.delayed(
                                    const Duration(milliseconds: 150), () {
                                  if (positionBook.isFilterNavigating) return;

                                  try {
                                    positionBook.setFilterNavigating(true);

                                    showModalBottomSheet(
                                      useSafeArea: true,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16)),
                                      ),
                                      context: context,
                                      builder: (context) =>
                                          const PositionScripFilterBottomSheet(),
                                    ).then((_) {
                                      positionBook.setFilterNavigating(false);
                                    });
                                  } catch (e) {
                                    positionBook.setFilterNavigating(false);
                                  }
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _getCachedIcon(
                                  assets.filterLinesDark,
                                  color: colors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (positionBook.exitPositionQty != 0)
                        Material(
                          color: Colors.transparent,
                          shape: const RoundedRectangleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            customBorder: const RoundedRectangleBorder(),
                            splashColor: theme.isDarkMode
                                ? colors.splashColorDark
                                : colors.splashColorLight,
                            highlightColor: theme.isDarkMode
                                ? colors.highlightDark
                                : colors.highlightLight,
                            onTap: positionBook.exitPositionQty == 0
                                ? () {}
                                : () async {
                                    try {
                                      await positionBook.exitPosition(
                                          context, false);
                                      if (context.mounted) {
                                        Navigator.of(context).maybePop();
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('Error: ${e.toString()}'),
                                        ),
                                      );
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: TextWidget.paraText(
                                text: positionBook.exitPositionQty == 0
                                    ? "Exit All"
                                    : "Exit (${positionBook.exitPositionQty})",
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.secondaryDark
                                    : colors.secondaryLight,
                                fw: 3,
                              ),
                            ),
                          ),
                        ),
                      Material(
                        color: Colors.transparent,
                        shape: const RoundedRectangleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          customBorder: const RoundedRectangleBorder(),
                          splashColor: theme.isDarkMode
                              ? colors.splashColorDark
                              : colors.splashColorLight,
                          highlightColor: theme.isDarkMode
                              ? colors.highlightDark
                              : colors.highlightLight,
                          onTap: () async {
                            Future.delayed(const Duration(milliseconds: 150),
                                () async {
                              await funds.fetchHstoken(context);
                              funds.optionZ(context);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: TextWidget.paraText(
                              text: "OptionZ",
                              theme: false,
                              color: theme.isDarkMode
                                  ? colors.secondaryDark
                                  : colors.secondaryLight,
                              fw: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // TextButton(
          //     onPressed: () {
          //       positionBook.showPositionSearch(false);
          //     },
          //     child: TextWidget.paraText(
          //         text: "Close",
          //         theme: false,
          //         color: theme.isDarkMode
          //             ? colors.colorLightBlue
          //             : colors.colorBlue,
          //         fw: 0))
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final positionBook = ref.watch(portfolioProvider);
    final showSearch = ref.watch(portfolioProvider).showSearchPosition;

    if (!showSearch) {
      return const SizedBox.shrink();
    }

    final theme = ref.read(themeProvider);

    return Consumer(builder: (context, watch, _) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        child: SizedBox(
          height: 40,
          child: TextFormField(
            autofocus: true,
            controller: positionBook.positionSearchCtrl,
            style: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              fw: 1,
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              UpperCaseTextFormatter(),
              NoEmojiInputFormatter(),
              FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
            ],
            decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    fw: 0,
                    color: colors.textSecondaryLight),
                fillColor: colors.searchBg,
                filled: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(assets.searchIcon,
                      color: colors.textPrimaryLight,
                      fit: BoxFit.scaleDown,
                      width: 20),
                ),
                suffixIcon: Material(
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
                      Future.delayed(const Duration(milliseconds: 150), () {
                        positionBook.clearPositionSearch();
                        if (positionBook.positionSearchCtrl.text.isEmpty) {
                          positionBook.showPositionSearch(false);
                        }
                      });
                    },
                    child: SvgPicture.asset(assets.removeIcon,
                        fit: BoxFit.scaleDown, width: 20),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
                disabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(20))),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // positionBook.showPositionSearch(false);
              } else {
                positionBook.showPositionSearch(false);
              }

              positionBook.positionSearch(value, context);
            },
          ),
        ),
      );
    });
  }

  Widget _buildPositionList(BuildContext context, ThemesProvider theme,
      PortfolioProvider positionBook) {
    // Check if search is active but the text field is empty
    final isSearchActive = positionBook.showSearchPosition;
    final searchText = positionBook.positionSearchCtrl.text;

    // Determine what items to display
    final itemsToDisplay = isSearchActive && searchText.isNotEmpty
        ? positionBook.positionSearchItem
        : widget.listofPosition;

    if (positionBook.posSelection == "Group by symbol") {
      return const PositionGroupSymbol();
    }

    if (itemsToDisplay.isEmpty) {
      return const Center(
        child: SizedBox(height: 600, child: NoDataFound()),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, idx) {
        final index = idx ~/ 2;

        // Return divider for odd indices
        if (idx.isOdd) {
          return Container(
              color:
                  theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
              height: 1);
        }

        // Wrap each position item with RepaintBoundary to isolate updates
        return _PositionItem(
          position: itemsToDisplay[index],
          isSearchItem: positionBook.positionSearchItem.isNotEmpty,
          showLongPressOption: positionBook.openPosition!.length > 1 &&
              itemsToDisplay[index].qty != "0",
        );
      },
      itemCount: itemsToDisplay.length * 2 - 1,
    );
  }
}

// Header section with P&L info
class _PositionHeaderSection extends ConsumerWidget {
  final ThemesProvider theme;
  final PortfolioProvider positionBook;
  final List<PositionBookModel> listofPosition;

  const _PositionHeaderSection({
    required this.theme,
    required this.positionBook,
    required this.listofPosition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // &&  listofPosition.length > 1
        if (positionBook.postionBookModel!.isNotEmpty) ...[
          Center(
            child: _PnLDisplay(
              isNetPnl: positionBook.isNetPnl,
              isDay: positionBook.isDay,
              totUnRealMtm: positionBook.totUnRealMtm,
              totMtM: positionBook.totMtM,
              totBookedPnL: positionBook.totBookedPnL,
              totPnL: positionBook.totPnL,
              theme: theme,
            ),
          ),
          // const SizedBox(height: 6),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
          //   child: Row(
          //     children: [
          //       Text("P&L",
          //           style: TextWidget.textStyle(
          //               fontSize: 13,
          //               theme: theme.isDarkMode,
          //               color: theme.isDarkMode
          //                   ? colors.colorWhite
          //                   : colors.colorGrey,
          //               fw: 0)),
          //       const SizedBox(width: 6),
          //       CustomSwitch(
          //           onChanged: (bool value) {
          //             positionBook.chngPositionPnl(!positionBook.isNetPnl);
          //           },
          //           color: !theme.isDarkMode
          //               ? colors.colorGrey.withOpacity(0.2)
          //               : colors.colorBlack,
          //           value: positionBook.isNetPnl),
          //       const SizedBox(width: 6),
          //       Text("MTM",
          //           style: TextWidget.textStyle(
          //               fontSize: 13,
          //               theme: theme.isDarkMode,
          //               color: theme.isDarkMode
          //                   ? colors.colorWhite
          //                   : colors.colorGrey,
          //               fw: 0)),
          //     ],
          //   ),
          // ),
        ] else ...[
          const SizedBox(),
        ]
      ],
    );
  }
}

// PnL display widget to isolate the frequently changing parts
class _PnLDisplay extends StatelessWidget {
  final bool isNetPnl;
  final bool isDay;
  final String totUnRealMtm;
  final String totMtM;
  final String totBookedPnL;
  final String totPnL;
  final ThemesProvider theme;

  const _PnLDisplay({
    required this.isNetPnl,
    required this.isDay,
    required this.totUnRealMtm,
    required this.totMtM,
    required this.totBookedPnL,
    required this.totPnL,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0, bottom: 15),
      child: Column(
        children: [
          TextWidget.paraText(
              text: !isNetPnl ? "Total MTM" : "Total P&L",
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3),
          const SizedBox(height: 4),
          !isNetPnl
              ? _buildValueText(isDay ? totUnRealMtm : totMtM,
                  isDay ? _getValueColor(totUnRealMtm) : _getValueColor(totMtM))
              : _buildValueText(isDay ? totBookedPnL : totPnL,
                  isDay ? _getValueColor(totBookedPnL) : _getValueColor(totPnL))
        ],
      ),
    );
  }

  Widget _buildValueText(String value, Color color) {
    return TextWidget.headText(
        text: "$value", fw: 0, theme: false, color: color);
  }

  Color _getValueColor(String value) {
    if (value.startsWith("-")) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else if (value == "0.00") {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    } else {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    }
  }
}

// Position item widget with integrated card functionality
class _PositionItem extends ConsumerStatefulWidget {
  final PositionBookModel position;
  final bool isSearchItem;
  final bool showLongPressOption;

  const _PositionItem({
    required this.position,
    required this.isSearchItem,
    required this.showLongPressOption,
  });

  @override
  ConsumerState<_PositionItem> createState() => _PositionItemState();
}

class _PositionItemState extends ConsumerState<_PositionItem> {
  // Add navigation lock to prevent multiple taps
  bool _isNavigating = false;
  StreamSubscription? _socketSubscription;
  late String _currentLp;
  bool _needsUpdate = false;

  // Cache text styles to avoid rebuilds
  final Map<String, TextStyle> _cachedStyles = {};

  @override
  void initState() {
    super.initState();
    _currentLp = widget.position.lp ?? '0.00';
    _setupSocketSubscription();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    super.dispose();
  }

  void _setupSocketSubscription() {
    // Slight delay to ensure context is available
    Future.microtask(() {
      final websocket = ref.read(websocketProvider);
      final positions = ref.read(portfolioProvider);

      _socketSubscription = websocket.socketDataStream.listen((socketData) {
        // Only process if this position's token is in the update
        if (!socketData.containsKey(widget.position.token)) return;

        final data = socketData[widget.position.token];
        if (data == null) return;

        // Check if LTP actually changed
        final lp = data['lp']?.toString();
        if (lp != null &&
            lp != "null" &&
            lp != "0" &&
            lp != "0.00" &&
            lp != _currentLp) {
          widget.position.lp = lp;
          _currentLp = lp;
          _needsUpdate = true;

          // Update PNL calculations if needed
          if (positions.isDay) {
            positions.positionCal(positions.isDay);
          }

          // Debounce multiple rapid updates
          if (mounted) {
            setState(() {
              _needsUpdate = false;
            });
          }
        }
      });
    });
  }

  // Get cached text style to avoid rebuilding styles
  TextStyle _getStyle(Color color, double size, int? fw, {String? key}) {
    final cacheKey = key ?? '${color.value}|$size|$fw';

    if (!_cachedStyles.containsKey(cacheKey)) {
      _cachedStyles[cacheKey] = TextWidget.textStyle(
        fontSize: size,
        color: color,
        theme: false,
        fw: fw,
      );
    }
    return _cachedStyles[cacheKey]!;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: widget.showLongPressOption
          ? () {
              if (widget.position.qty != "0") {
                Navigator.pushNamed(context, Routes.positionExit);
              }
            }
          : null,
      onTap: () async {
        // Prevent multiple navigation events on rapid taps
        if (_isNavigating) return;

        try {
          setState(() {
            _isNavigating = true;
          });

          await _handlePositionTap(context);
        } finally {
          // Reset navigation lock after some delay
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _isNavigating = false;
                });
              }
            });
          }
        }
      },
      child: _buildPositionCard(),
    );
  }

  Widget _buildPositionCard() {
    return Consumer(builder: (context, watch, _) {
      final positions = ref.watch(portfolioProvider);
      final theme = ref.read(themeProvider);

      // Calculate colors and values once
      final isZeroQty = widget.position.qty == "0";
      final netQtyZero = widget.position.netqty == "0";
      final bgColor = theme.isDarkMode
          ? isZeroQty
              ? colors.darkGrey
              : colors.colorBlack
          : Color(isZeroQty ? 0xffF1F3F8 : 0xffffffff);

      final containerColor = theme.isDarkMode
          ? isZeroQty
              ? colors.colorBlack
              : const Color(0xff666666).withOpacity(.2)
          : isZeroQty
              ? colors.colorWhite
              : const Color(0xffECEDEE);

      // final txtColor =
      //     theme.isDarkMode ? colors.colorWhite : const Color(0xff141414);

      // Get formatted quantity value
      final qty =
          "${((int.tryParse(widget.position.qty.toString()) ?? 0) / (widget.position.exch == 'MCX' ? (int.tryParse(widget.position.ls.toString()) ?? 1) : 1)).toInt()}";

      // Get PNL and determine its color
      final pnlValue = positions.isNetPnl
          ? "${widget.position.profitNloss ?? widget.position.rpnl}"
          : "${widget.position.mTm}";

      final pnlColor = _getPnlColor(
          positions.isNetPnl
              ? (widget.position.profitNloss ?? widget.position.rpnl)
              : widget.position.mTm,
          theme);

      // Get average price display value
      final avgPrice = positions.isDay
          ? "${widget.position.avgPrc}"
          : positions.isNetPnl
              ? "${widget.position.netupldprc}"
              : "${widget.position.netavgprc}";

      return Container(
        color: netQtyZero
            ? colors.colorBlack.withOpacity(0.05)
            : colors.textSecondaryDark,
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildHeaderRow(theme, containerColor),
              const SizedBox(height: 8),
              _buildQuantityRow(
                  qty, pnlValue, pnlColor, positions.isNetPnl, avgPrice, theme),
              const SizedBox(height: 8),
              _buildAveragePriceRow(theme, containerColor),
            ]),
      );
    });
  }

  Color _getPnlColor(String? value, ThemesProvider theme) {
    if (value == null) {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    }
    if (value.startsWith("-")) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    }
    if (value == "0.00") {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    }
    return theme.isDarkMode ? colors.profitDark : colors.profitLight;
  }

  Widget _buildHeaderRow(ThemesProvider theme, Color containerColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          TextWidget.subText(
              text: "${widget.position.symbol} ${widget.position.expDate} ",
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              textOverflow: TextOverflow.ellipsis,
              fw: 3),
          TextWidget.subText(
              text: "${widget.position.option} ",
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              textOverflow: TextOverflow.ellipsis,
              fw: 3),
        ]),
        Row(children: [
          TextWidget.paraText(
              text: "${widget.position.exch}",
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 3),
        ])
      ],
    );
  }

  Widget _buildQuantityRow(String qty, String pnlValue, Color pnlColor,
      bool isNetPnl, String avgPrice, ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left 50%: Qty label and value
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Qty ",
              style: _getStyle(
                  theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  12,
                  3,
                  key: 'qty-label'),
            ),
            Text(
              qty,
              style: _getStyle(
                  theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  12,
                  3,
                  key: 'qty-value'),
            ),

            const SizedBox(
              width: 5,
            ),
            // Right 50%: P&L value

            Text(
              "Avg  ",
              style: _getStyle(
                  theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  12,
                  3,
                  key: 'avg-label'),
            ),
            Text(
              avgPrice,
              style: _getStyle(
                  theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  12,
                  3,
                  key: 'avg-value'),
            ),
          ],
        ),
        RepaintBoundary(
          child: Text(
            pnlValue,
            style: _getStyle(pnlColor, 16, 0),
          ),
        ),
      ],
    );
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   children: [
    //     Expanded(
    //       child: Row(children: [
    //         Text(
    //           "Qty: ",
    //           style:
    //               _getStyle(const Color(0xff5E6B7D), 12, 0, key: 'qty-label'),
    //         ),
    //         Text(
    //           qty,
    //           style: _getStyle(txtColor, 14, 0, key: 'qty-value'),
    //         )
    //       ]),
    //     ),
    //     RepaintBoundary(
    //       child: Text(
    //         pnlValue,
    //         style: _getStyle(pnlColor, 15, 1),
    //       ),
    //     ),
    //   ],
    // );
  }

  Widget _buildAveragePriceRow(ThemesProvider theme, Color containerColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${widget.position.sPrdtAli}",
          overflow: TextOverflow.ellipsis,
          style: _getStyle(
            theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            12,
            3,
          ),
        ),

        // Wrap LTP in RepaintBoundary as it changes frequently
        RepaintBoundary(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "LTP  ",
                style: TextWidget.textStyle(
                  fontSize: 12,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  theme: theme.isDarkMode,
                  fw: 3,
                ),
              ),
              Text(
                "${widget.position.lp}",
                style: _getStyle(
                    theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    12,
                    3,
                    key: 'ltp-value'),
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handlePositionTap(BuildContext context) async {
    final marketWatch = ref.read(marketWatchProvider);

    // Fetch linked scrip data
    await marketWatch.fetchLinkeScrip(
        "${widget.position.token}", "${widget.position.exch}", context);

    // Fetch scrip quote
    await ref.read(marketWatchProvider).fetchScripQuote(
        "${widget.position.token}", "${widget.position.exch}", context);

    // Handle NSE/BSE specific data
    if (widget.position.exch == "NSE" || widget.position.exch == "BSE") {
      await marketWatch.fetchTechData(
          context: context,
          exch: "${widget.position.exch}",
          tradeSym: "${widget.position.tsym}",
          lastPrc: "${widget.position.lp}");
    }

    // Navigate to position detail
    if (mounted) {
      showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        isDismissible: true,
        enableDrag: false,
        useSafeArea: true,
        context: context,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: PositionDetailScreen(positionList: widget.position)),
      );
    }
  }
}
