import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:remove_emoji_input_formatter/remove_emoji_input_formatter.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_switch_btn.dart';
import '../../../sharedWidget/custom_text_btn.dart';
import '../../../sharedWidget/custom_text_form_field.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_data_found.dart';
import 'filter_scrip_bottom_sheet.dart';
import 'group/create_group.dart';
import 'group/position_group_symbol.dart';
import 'position_list_card.dart';

class PositionScreen extends StatefulWidget {
  final List<PositionBookModel> listofPosition;
  const PositionScreen({super.key, required this.listofPosition});

  @override
  State<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends State<PositionScreen> {
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
      final websocket = context.read(websocketProvider);
      final positionBook = context.read(portfolioProvider);
      
      _socketSubscription = websocket.socketDataStream.listen((socketDatas) {
        bool needsUpdate = false;
        
        for (var position in widget.listofPosition) {
                          if (socketDatas.containsKey(position.token)) {
                            final socketData = socketDatas[position.token];
                            
                            // Only update with non-zero values, otherwise keep existing values
                            final lp = socketData['lp']?.toString();
                            if (lp != null && lp != "null" && lp != "0" && lp != "0.0" && lp != "0.00") {
                              position.lp = lp;
              needsUpdate = true;
                            }
                            
                            final pc = socketData['pc']?.toString();
                            if (pc != null && pc != "null" && pc != "0" && pc != "0.0" && pc != "0.00") {
                              position.perChange = pc;
              needsUpdate = true;
                            }
                          }
                        }
                        
        if (needsUpdate) {
                        positionBook.positionCal(positionBook.isDay);
          if (mounted) setState(() {});
        }
      });
    });
  }
  
  // Cache SVG icons for better performance
  Widget _getCachedIcon(String iconPath, {Color? color, double? width}) {
    final key = "$iconPath${color?.value ?? ''}${width ?? ''}";
    if (!_cachedIcons.containsKey(key)) {
      _cachedIcons[key] = SvgPicture.asset(
        iconPath,
        width: width ?? 19,
        color: color ?? const Color(0xff666666),
      );
    }
    return _cachedIcons[key]!;
  }

  @override
  Widget build(BuildContext context) {
    // Only consume the necessary providers at the top level
    return Consumer(builder: (context, watch, _) {
      final positionBook = watch(portfolioProvider);
      final theme = context.read(themeProvider);
      
      if (positionBook.posloader) {
        return const Center(child: CircularProgressIndicator());
      }
      
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
            if (positionBook.postionBookModel!.isNotEmpty && widget.listofPosition.length > 1)
              _buildFilterSection(context, theme, positionBook),
            
            // Search section if enabled
            if (positionBook.showSearchPosition)
              _buildSearchSection(context, theme, positionBook),
            
            // Position list section
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await positionBook.fetchPositionBook(context, false);
                },
                child: _buildPositionList(context, theme, positionBook),
              ),
            ),
          ]
        ),
      );
    });
  }
  
  Widget _buildFilterSection(BuildContext context, ThemesProvider theme, PortfolioProvider positionBook) {
    return Container(
                  padding: const EdgeInsets.only(
                      left: 16, right: 4, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              width: 6))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
          if (widget.listofPosition.length > 1 && 
                          positionBook.posSelection == "All position") ...[
                        Row(
                          children: [
                            InkWell(
                                onTap: () async {
                                  // Add navigation lock to prevent multiple filter sheets
                                  if (positionBook.isFilterNavigating) return;
                                  
                                  try {
                                    positionBook.setFilterNavigating(true);
                                    
                                    showModalBottomSheet(
                                      useSafeArea: true,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(16))),
                                      context: context,
                                      builder: (context) => const PositionScripFilterBottomSheet(),
                                    ).then((_) {
                                      // Reset navigation lock after bottom sheet is closed
                                      positionBook.setFilterNavigating(false);
                                    });
                                  } catch (e) {
                                    positionBook.setFilterNavigating(false);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: _getCachedIcon(
                                    assets.filterLines,
                                    color: theme.isDarkMode
                                        ? const Color(0xffBDBDBD)
                                        : colors.colorGrey,
                                  ),
                                )
                            ),
                            InkWell(
                                onTap: () {
                                  // Prevent multiple taps on search button
                                  if (positionBook.isFilterNavigating) return;
                                  
                                  positionBook.showPositionSearch(true);
                                },
                                child: Padding(
                    padding: const EdgeInsets.only(right: 12, left: 10),
                    child: _getCachedIcon(
                      assets.searchIcon,
                                      width: 19,
                                      color: theme.isDarkMode
                                          ? const Color(0xffBDBDBD)
                        : colors.colorGrey,
                    ),
                  )
                ),
              ],
            )
          ] else if (positionBook.posSelection != "All position") ...[
                        CustomTextBtn(
                            label: 'Create Group',
                            onPress: () {
                              // Prevent multiple dialog opens
                              if (positionBook.isFilterNavigating) return;
                              
                              try {
                                positionBook.setFilterNavigating(true);
                                
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => const CreateGroupPos(),
                                ).then((_) {
                                  // Reset navigation lock after dialog is closed
                                  positionBook.setFilterNavigating(false);
                                });
                              } catch (e) {
                                positionBook.setFilterNavigating(false);
                              }
                            },
                            icon: assets.addCircleIcon)
                      ]
                    ],
                  ),
    );
  }
  
  Widget _buildSearchSection(BuildContext context, ThemesProvider theme, PortfolioProvider positionBook) {
    return Container(
                  height: 62,
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              width: 6))),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: positionBook.positionSearchCtrl,
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w600),
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                            RemoveEmojiInputFormatter(),
                FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
                          ],
                          decoration: InputDecoration(
                              fillColor: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              filled: true,
                              hintStyle: GoogleFonts.inter(
                  textStyle: textStyle(
                    const Color(0xff69758F),
                    15, 
                    FontWeight.w500)),
                              prefixIconColor: const Color(0xff586279),
                              prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _getCachedIcon(
                    assets.searchIcon,
                                    color: const Color(0xff586279),
                    width: 20,
                  ),
                              ),
                              suffixIcon: InkWell(
                  onTap: () {
                                  positionBook.clearPositionSearch();
                                },
                                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _getCachedIcon(
                      assets.removeIcon,
                      width: 20,
                    ),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)),
                              disabledBorder: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20)),
                              hintText: "Search Scrip Name",
                              contentPadding: const EdgeInsets.only(top: 20),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20))
              ),
              onChanged: (value) {
                            positionBook.positionSearch(value, context);
                          },
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            positionBook.showPositionSearch(false);
                          },
            child: Text(
              "Close",
                              style: textStyles.textBtn.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                  : colors.colorBlue)
            )
          )
        ],
      ),
    );
  }
  
  Widget _buildPositionList(BuildContext context, ThemesProvider theme, PortfolioProvider positionBook) {
    final itemsToDisplay = positionBook.positionSearchItem.isEmpty 
      ? widget.listofPosition 
      : positionBook.positionSearchItem;
    
    if (positionBook.posSelection == "Group by symbol") {
      return const PositionGroupSymbol();
    }
    
    if (itemsToDisplay.isEmpty) {
      return const Center(
        child: SizedBox(height: 500, child: NoDataFound()),
      );
    }
    
    return ListView.builder(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    shrinkWrap: false,
                                    itemBuilder: (context, idx) {
                                      final index = idx ~/ 2;

        // Return divider for odd indices
                                      if (idx.isOdd) {
                                        return Container(
                                            color: theme.isDarkMode
              ? itemsToDisplay[index].netqty == "0"
                                                    ? colors.colorBlack
                                                    : colors.darkGrey
              : itemsToDisplay[index].netqty == "0"
                                                    ? colors.colorWhite
                                                    : const Color(0xffF1F3F8),
                                            height: 6);
                                      }
                                      
        // Wrap each position item with RepaintBoundary to isolate updates
        return RepaintBoundary(
          child: _PositionItem(
            position: itemsToDisplay[index],
            isSearchItem: positionBook.positionSearchItem.isNotEmpty,
            showLongPressOption: positionBook.openPosition!.length > 1 && 
                                 itemsToDisplay[index].qty != "0",
          ),
        );
      },
      itemCount: itemsToDisplay.length * 2 - 1,
    );
  }
}

// Header section with P&L info
class _PositionHeaderSection extends StatelessWidget {
  final ThemesProvider theme;
  final PortfolioProvider positionBook;
  final List<PositionBookModel> listofPosition;
  
  const _PositionHeaderSection({
    required this.theme,
    required this.positionBook,
    required this.listofPosition,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.isDarkMode
        ? const Color(0xffB5C0CF).withOpacity(.15)
        : const Color(0xffF1F3F8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "P&L",
                    style: textStyle(
                      theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                      13,
                      FontWeight.w500
                    )
                  ),
                  const SizedBox(width: 6),
                  CustomSwitch(
                    onChanged: (bool value) {
                      positionBook.chngPositionPnl(!positionBook.isNetPnl);
                    },
                    color: !theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                    value: positionBook.isNetPnl
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "MTM",
                    style: textStyle(
                      theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                      13,
                      FontWeight.w500
                    )
                  ),
                ],
              ),
              _PnLDisplay(
                isNetPnl: positionBook.isNetPnl,
                isDay: positionBook.isDay,
                totUnRealMtm: positionBook.totUnRealMtm,
                totMtM: positionBook.totMtM,
                totBookedPnL: positionBook.totBookedPnL,
                totPnL: positionBook.totPnL,
              ),
            ],
          )
        ],
      )
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
  
  const _PnLDisplay({
    required this.isNetPnl,
    required this.isDay,
    required this.totUnRealMtm,
    required this.totMtM,
    required this.totBookedPnL,
    required this.totPnL,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          !isNetPnl ? "Net MTM" : "Net P&L",
          style: textStyle(
            const Color(0xff5E6B7D),
            12,
            FontWeight.w500
          )
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            !isNetPnl
              ? _buildValueText(
                  isDay ? totUnRealMtm : totMtM,
                  isDay
                    ? _getValueColor(totUnRealMtm)
                    : _getValueColor(totMtM)
                )
              : _buildValueText(
                  isDay ? totBookedPnL : totPnL,
                  isDay
                    ? _getValueColor(totBookedPnL)
                    : _getValueColor(totPnL)
                )
          ]
        )
      ],
    );
  }
  
  Widget _buildValueText(String value, Color color) {
    return Text(
      "₹$value",
      style: textStyle(color, 16, FontWeight.w500)
    );
  }
  
  Color _getValueColor(String value) {
    if (value.startsWith("-")) {
      return colors.darkred;
    } else if (value == "0.00") {
      return colors.ltpgrey;
                          } else {
      return colors.ltpgreen;
    }
  }
}

// Position item widget
class _PositionItem extends StatefulWidget {
  final PositionBookModel position;
  final bool isSearchItem;
  final bool showLongPressOption;
  
  const _PositionItem({
    required this.position,
    required this.isSearchItem,
    required this.showLongPressOption,
  });
  
  @override
  State<_PositionItem> createState() => _PositionItemState();
}

class _PositionItemState extends State<_PositionItem> {
  // Add navigation lock to prevent multiple taps
  bool _isNavigating = false;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: widget.showLongPressOption 
        ? () {
            Navigator.pushNamed(
              context,
              Routes.positionExit,
              arguments: context.read(portfolioProvider).postionBookModel
            );
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
      child: PositionListCard(positionList: widget.position),
    );
  }
  
  Future<void> _handlePositionTap(BuildContext context) async {
    final marketWatch = context.read(marketWatchProvider);
    
    // Fetch linked scrip data
    await marketWatch.fetchLinkeScrip(
      "${widget.position.token}",
      "${widget.position.exch}",
      context
    );

    // Fetch scrip quote
    await context.read(marketWatchProvider).fetchScripQuote(
      "${widget.position.token}",
      "${widget.position.exch}",
      context
    );

    // Handle NSE/BSE specific data
    if (widget.position.exch == "NSE" || widget.position.exch == "BSE") {
     

      await marketWatch.fetchTechData(
        context: context,
        exch: "${widget.position.exch}",
        tradeSym: "${widget.position.tsym}",
        lastPrc: "${widget.position.lp}"
      );
    }
    
    // Navigate to position detail
    if (mounted) {
      Navigator.pushNamed(context, Routes.positionDetail, arguments: widget.position);
    }
  }
}
