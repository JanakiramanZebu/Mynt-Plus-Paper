// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../res/res.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../../../utils/responsive_snackbar.dart';

class FutureScreenWeb extends ConsumerStatefulWidget {
  const FutureScreenWeb({super.key});

  @override
  ConsumerState<FutureScreenWeb> createState() => _FutureScreenWebState();
}

class _FutureScreenWebState extends ConsumerState<FutureScreenWeb> {
  String? _hoveredToken;
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final future = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);

    if (future.fut == null || future.fut!.isEmpty) {
      return Center(
        child: Text(
          "No futures data available",
          style: WebTextStyles.sub(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode
                ? WebDarkColors.textSecondary
                : WebColors.textSecondary,
          ),
        ),
      );
    }

    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
     

        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0, bottom: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.isDarkMode
                    ? WebDarkColors.divider.withOpacity(0.6)
                    : WebColors.divider.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Table Header
                _buildTableHeader(theme),
                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.isDarkMode
                      ? WebDarkColors.divider.withOpacity(0.6)
                      : WebColors.divider.withOpacity(0.6),
                ),
                // Table Body - No Expanded, just content-sized
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      future.fut!.length,
                      (int index) {
                        return _buildTableRow(
                          context,
                          future.fut![index],
                          socketDatas,
                          theme,
                          future,
                          index,
                          future.fut!.length,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
     decoration: BoxDecoration(
  color: WebColors.textSecondary.withOpacity(0.1),
  // borderRadius: const BorderRadius.only(
  //   topLeft: Radius.circular(8),
  //   topRight: Radius.circular(8),
  //   // bottomRight: Radius.circular(8),
  // ),
),

      child: Row(
        children: [
          // Symbol Column (30%)
          Expanded(
            flex: 3,
            child: Text(
              "SYMBOL",
              style: WebTextStyles.para(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textSecondary
                    : WebColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Exchange/Expiry Column
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     "Exchange/Expiry",
          //     style: WebTextStyles.sub(
          //       isDarkTheme: theme.isDarkMode,
          //       color: theme.isDarkMode
          //           ? WebDarkColors.textPrimary
          //           : WebColors.textPrimary,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          // LTP & Change Column
          Expanded(
            flex: 3,
            child: Text(
              "LTP",
              textAlign: TextAlign.start,
              style: WebTextStyles.para(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textSecondary
                    : WebColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Actions Column
          // const SizedBox(width: 120), // Fixed width for actions
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    dynamic displayData,
    Map socketDatas,
    ThemesProvider theme,
    MarketWatchProvider future,
    int index,
    int totalRows,
  ) {
    // Update with socket data if available
    var updatedData = displayData;
    final tokenKey = displayData.token?.toString();
    
    if (tokenKey != null && socketDatas.containsKey(tokenKey)) {
      final socketData = socketDatas[tokenKey];
      
      // Try multiple possible keys for LTP
      final lp = socketData['lp']?.toString() ?? 
                 socketData['ltp']?.toString() ?? 
                 socketData['last_price']?.toString();
      if (lp != null && lp != "null" && lp != "0" && lp != "0.00" && lp.isNotEmpty) {
        try {
          final ltpValue = double.parse(lp);
          if (ltpValue > 0) {
            updatedData.ltp = lp;
          }
        } catch (e) {
          // Keep original value if parsing fails
        }
      }

      // Try multiple possible keys for change
      final chng = socketData['chng']?.toString() ?? 
                   socketData['change']?.toString() ?? 
                   socketData['net_change']?.toString();
      if (chng != null && chng != "null" && chng.isNotEmpty) {
        updatedData.change = chng;
      }

      // Try multiple possible keys for percentage change
      final pc = socketData['pc']?.toString() ?? 
                 socketData['per_change']?.toString() ?? 
                 socketData['percentage_change']?.toString() ??
                 socketData['pchange']?.toString();
      if (pc != null && pc != "null" && pc.isNotEmpty) {
        updatedData.perChange = pc;
      }
    }

    final isHovered = _hoveredToken == updatedData.token;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredToken = updatedData.token),
      onExit: (_) => setState(() => _hoveredToken = null),
      child: Material(
        color: isHovered
            ?  WebColors.backgroundSecondary.withOpacity(0.01)
            : Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.zero,
          splashColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.15)
              : Colors.black.withOpacity(0.15),
          highlightColor: theme.isDarkMode
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
          onTap: () async {
            if (_isNavigating) return;

            try {
              setState(() => _isNavigating = true);

              // Add delay for visual feedback
              await Future.delayed(const Duration(milliseconds: 150));

              Navigator.pop(context);
              await ref
                  .watch(marketWatchProvider)
                  .calldepthApis(context, updatedData, "");
            } finally {
              if (mounted) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() => _isNavigating = false);
                  }
                });
              }
            }
          },
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        // Symbol Column
                        Expanded(
                          flex: 3,
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${updatedData.tsym}",
                                style: WebTextStyles.custom(
                                  fontSize: 13,
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode
                                      ? WebDarkColors.textPrimary
                                      : WebColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // if (updatedData.option != null &&
                              //     updatedData.option!.isNotEmpty)
                              //   Padding(
                              //     padding: const EdgeInsets.only(left: 4),
                              //     child: Text(
                              //       "${updatedData.option}",
                              //       style: WebTextStyles.custom(
                              //         fontSize: 13,
                              //         isDarkTheme: theme.isDarkMode,
                              //         color: theme.isDarkMode
                              //             ? WebDarkColors.textPrimary
                              //             : WebColors.textPrimary,
                              //         fontWeight: FontWeight.w700,
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Exchange/Expiry Column
                    // Expanded(
                    //   flex: 2,
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Text(
                    //             '${updatedData.exch}',
                    //             style: WebTextStyles.caption(
                    //               isDarkTheme: theme.isDarkMode,
                    //               color: theme.isDarkMode
                    //                   ? WebDarkColors.textSecondary
                    //                   : WebColors.textSecondary,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //             maxLines: 1,
                    //             overflow: TextOverflow.ellipsis,
                    //           ),
                    //           // if (updatedData.expDate != null &&
                    //           //     updatedData.expDate!.isNotEmpty)
                    //           //   Padding(
                    //           //     padding: const EdgeInsets.only(left: 8),
                    //           //     child: Text(
                    //           //       " ${updatedData.expDate}",
                    //           //       style: WebTextStyles.custom(
                    //           //         fontSize: 10,
                    //           //         isDarkTheme: theme.isDarkMode,
                    //           //         color: theme.isDarkMode
                    //           //             ? WebDarkColors.textSecondary
                    //           //             : WebColors.textSecondary,
                    //           //         fontWeight: FontWeight.w600,
                    //           //       ),
                    //           //       maxLines: 1,
                    //           //       overflow: TextOverflow.ellipsis,
                    //           //     ),
                    //           //   ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // LTP & Change Column
                    Expanded(
                      flex: 3,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            updatedData.ltp != null && updatedData.ltp != "null" 
                                ? "${updatedData.ltp}" 
                                : updatedData.close != null && updatedData.close != "null" 
                                    ? "${updatedData.close}" 
                                    : '0.00',
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: _getPriceColor(updatedData, theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(updatedData.change != null && updatedData.change != "null" && updatedData.change.isNotEmpty) ? (double.tryParse(updatedData.change)?.toStringAsFixed(2) ?? "0.00") : "0.00"} "
                            "(${(updatedData.perChange != null && updatedData.perChange != "null" && updatedData.perChange.isNotEmpty) ? (double.tryParse(updatedData.perChange)?.toStringAsFixed(2) ?? "0.00") : "0.00"}%)",
                            style: WebTextStyles.custom(
                              fontSize: 13,
                              isDarkTheme: theme.isDarkMode,
                              color: _getChangeColor(updatedData, theme),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Overlay Action Buttons - Centered
              Positioned.fill(
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: isHovered ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !isHovered,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        // Remove border radius on hover overlay container
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.zero,
                        ),
                        child: _buildActionButtons(
                          context,
                          updatedData,
                          future,
                          theme,
                          isHovered,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
              // Bottom border for each table row (except last row)
              if (index < totalRows - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.isDarkMode
                      ? WebDarkColors.divider.withOpacity(0.6)
                      : WebColors.divider.withOpacity(0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    dynamic displayData,
    MarketWatchProvider future,
    ThemesProvider theme,
    bool isCentered,
  ) {
    // Determine if scrip already exists in current watchlist
    final String key = "${displayData.exch}|${displayData.token}";
    final bool isInWatchlist = ref
        .read(marketWatchProvider)
        .scrips
        .any((e) => "${e['exch']}|${e['token']}" == key);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Buy Button
        _buildHoverButton(
          label: 'B',
          color: Colors.white,
          backgroundColor: theme.isDarkMode 
              ? WebDarkColors.primary
              : WebColors.primary,
          onPressed: () async {
            try {
              await _placeOrderInput(context, displayData, true, future);
            } catch (e) {
              print('Buy button error: $e');
            }
          },
        ),
        const SizedBox(width: 6),
        // Sell Button
        _buildHoverButton(
          label: 'S',
          color: Colors.white,
          backgroundColor: theme.isDarkMode
              ? WebDarkColors.tertiary
              : WebColors.tertiary,
          onPressed: () async {
            try {
              await _placeOrderInput(context, displayData, false, future);
            } catch (e) {
              print('Sell button error: $e');
            }
          },
        ),
        const SizedBox(width: 6),
        // Chart Button
        _buildHoverButton(
          icon: Icons.bar_chart,
          color: Colors.white,
          backgroundColor: theme.isDarkMode
              ? WebDarkColors.textSecondary
              : WebColors.textSecondary,
          onPressed: () {
            // Navigate to chart screen - same logic as watchlist_card_web
            Navigator.pop(context);
            ref.read(marketWatchProvider).calldepthApis(context, displayData, "");
          },
        ),
        const SizedBox(width: 6),
        // Save Button (Add to watchlist)
        _buildHoverButton(
          svgIcon: isInWatchlist ? assets.bookmarkIcon : assets.bookmarkedIcon,
          color: isInWatchlist 
              ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
              : (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary),
          backgroundColor: Colors.transparent,
          borderColor: isInWatchlist 
              ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
              : (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary),
          onPressed: () async {
            final bool add = !isInWatchlist;
            final success = await future.addDelMarketScrip(
              future.wlName,
              key,
              context,
              add,
              true,
              false,
              true,
            );
            if (success && mounted) {
              // Web toast using ResponsiveSnackBar
              if (add) {
                ResponsiveSnackBar.showSuccess(context, 'Added to ${future.wlName}');
              } else {
                ResponsiveSnackBar.showInfo(context, 'Removed from ${future.wlName}');
              }
              // Force rebuild to refresh icon state
              setState(() {});
            }
          },
        ),
      ],
    );
  }

  Widget _buildHoverButton({
    String? label,
    IconData? icon,
    String? svgIcon,
    required Color color,
    Color? backgroundColor,
    Color? borderColor,
    required VoidCallback? onPressed,
  }) {
    final theme = ref.read(themeProvider);
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: svgIcon != null
                  ? SvgPicture.asset(
                      svgIcon,
                      height: 16,
                      width: 16,
                      color: color,
                    )
                  : icon != null
                      ? Icon(
                          icon,
                          size: 14,
                          color: color,
                        )
                      : Text(
                          label ?? "",
                          style: WebTextStyles.custom(
                            fontSize: 11,
                            isDarkTheme: theme.isDarkMode,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriceColor(dynamic displayData, ThemesProvider theme) {
    final change = displayData.change?.toString() ?? "0.00";
    final perChange = displayData.perChange?.toString() ?? "0.00";

    if (change.startsWith("-") || perChange.startsWith('-')) {
      return theme.isDarkMode ? WebDarkColors.loss : WebColors.loss;
    } else if (change == "null" ||
        perChange == "null" ||
        change == "0.00" ||
        perChange == "0.00") {
      return theme.isDarkMode
          ? WebDarkColors.textPrimary
          : WebColors.textPrimary;
    } else {
      return theme.isDarkMode ? WebDarkColors.profit : WebColors.profit;
    }
  }

  Color _getChangeColor(dynamic displayData, ThemesProvider theme) {
    final change = displayData.change?.toString() ?? "0.00";
    final perChange = displayData.perChange?.toString() ?? "0.00";

    if (change.startsWith("-") || perChange.startsWith('-')) {
      return theme.isDarkMode ? WebDarkColors.loss : WebColors.loss;
    } else if (change == "null" ||
        perChange == "null" ||
        change == "0.00" ||
        perChange == "0.00") {
      return theme.isDarkMode
          ? WebDarkColors.textSecondary
          : WebColors.textSecondary;
    } else {
      return theme.isDarkMode ? WebDarkColors.profit : WebColors.profit;
    }
  }

  // Helper method to safely parse numeric values
  String _safeParseNumeric(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;

    String stringValue = value.toString().trim();

    // Handle common invalid values
    if (stringValue.isEmpty ||
        stringValue == 'null' ||
        stringValue == '0.0' ||
        stringValue == '0' ||
        stringValue == 'NaN' ||
        stringValue == 'Infinity') {
      return defaultValue;
    }

    // Try to parse as double first, then int
    try {
      double.parse(stringValue);
      return stringValue;
    } catch (e) {
      try {
        int.parse(stringValue);
        return stringValue;
      } catch (e) {
        return defaultValue;
      }
    }
  }

  // Helper method to safely parse lot size
  String _safeParseLotSize(
      dynamic scripInfoLs, dynamic depthDataLs, String defaultValue) {
    // Try scripInfo first
    String scripInfoValue = _safeParseNumeric(scripInfoLs, "");
    if (scripInfoValue.isNotEmpty && scripInfoValue != defaultValue) {
      return scripInfoValue;
    }

    // Try depthData
    String depthDataValue = _safeParseNumeric(depthDataLs, "");
    if (depthDataValue.isNotEmpty && depthDataValue != defaultValue) {
      return depthDataValue;
    }

    return defaultValue;
  }

  Future<void> _placeOrderInput(BuildContext ctx, dynamic displayData,
      bool transType, MarketWatchProvider future) async {
    try {
      // Prevent multiple simultaneous calls
      if (_isNavigating) return;

      setState(() {
        _isNavigating = true;
      });

      // Fetch scrip info first, exactly like reference implementation
      await ref.read(marketWatchProvider).fetchScripInfo(
          displayData.token?.toString() ?? "",
          displayData.exch?.toString() ?? "",
          context,
          true);

      // Ensure scripInfo is loaded before proceeding
      final scripInfo = ref.read(marketWatchProvider).scripInfoModel;
      if (scripInfo == null) {
        throw Exception('Failed to load scrip information');
      }

      // Get depth data
      final depthData = ref.read(marketWatchProvider).getQuotes ?? GetQuotes();

      // Use exact lot size logic from reference implementation
      final lotSize = _safeParseLotSize(depthData.ls, scripInfo.ls, "1");

      // Use safe parsing for price values
      final safeLtp = _safeParseNumeric(
          displayData.ltp ?? displayData.close ?? depthData.lp, "0.00");
      final safePerChange =
          _safeParseNumeric(displayData.perChange ?? depthData.pc, "0.00");

      OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: displayData.exch?.toString() ?? "",
        tSym: displayData.tsym?.toString() ?? "",
        isExit: false,
        token: displayData.token?.toString() ?? "",
        transType: transType,
        lotSize: lotSize,
        ltp: safeLtp,
        perChange: safePerChange,
        orderTpye: '',
        holdQty: '',
        isModify: false,
        raw: {},
      );

      // Add small delay to ensure state is properly set
      await Future.delayed(const Duration(milliseconds: 150));

      ResponsiveNavigation.toPlaceOrderScreen(
        context: context,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": scripInfo,
          "isBskt": ""
        },
      );
    } catch (e) {
      print('Place order error: $e');
      print('Display data: ${displayData.toJson()}');
      // Show error to user
      if (mounted) {
        ResponsiveSnackBar.showError(
          context,
          'Error placing order: ${e.toString()}',
        );
      }
    } finally {
      // Reset navigation state after a delay
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
  }
}
