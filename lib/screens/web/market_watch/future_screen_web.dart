// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:data_table_2/data_table_2.dart';

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
  // PERFORMANCE FIX: Use ValueNotifier for hover instead of setState
  // setState causes full widget rebuild, ValueNotifier only rebuilds hover-dependent parts
  final ValueNotifier<String?> _hoveredToken = ValueNotifier<String?>(null);
  bool _isNavigating = false;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _hoveredToken.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

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

    // PERFORMANCE FIX: Use ref.read() for stream - watching causes double rebuild
    return StreamBuilder<Map>(
      stream: ref.read(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};

        return LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available height for the table
            final screenHeight = MediaQuery.of(context).size.height;
            const padding = 32.0; // Top and bottom padding
            final maxHeight = screenHeight * 0.75;
            final calculatedHeight = (screenHeight - padding > maxHeight
                ? maxHeight
                : (screenHeight - padding > 400 ? screenHeight - padding : 400.0));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: calculatedHeight.toDouble(),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.isDarkMode
                        ? WebDarkColors.divider
                        : WebColors.divider,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  color: theme.isDarkMode
                      ? WebDarkColors.background
                      : Colors.white,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    scrollbarTheme: ScrollbarThemeData(
                      thumbVisibility: WidgetStateProperty.all(true),
                      trackVisibility: WidgetStateProperty.all(true),
                      thickness: WidgetStateProperty.all(6.0),
                      crossAxisMargin: 0.0,
                      mainAxisMargin: 0.0,
                      radius: const Radius.circular(3),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        return theme.isDarkMode 
                            ? WebDarkColors.textSecondary.withOpacity(0.3)
                            : WebColors.textSecondary.withOpacity(0.3);
                      }),
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        return theme.isDarkMode 
                            ? WebDarkColors.divider.withOpacity(0.1)
                            : WebColors.divider.withOpacity(0.1);
                      }),
                      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                      minThumbLength: 48.0,
                    ),
                  ),
                  child: DataTable2(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    minWidth: 800,
                    fixedLeftColumns: 1, // Fix the first column (Symbol)
                    fixedColumnsColor: theme.isDarkMode 
                        ? WebDarkColors.backgroundSecondary.withOpacity(0.8)
                        : WebColors.backgroundSecondary.withOpacity(0.8),
                    showBottomBorder: true,
                    horizontalScrollController: _horizontalScrollController,
                    scrollController: _verticalScrollController,
                    showCheckboxColumn: false,
                    headingRowColor: WidgetStateProperty.all(
                      theme.isDarkMode
                          ? WebDarkColors.primary
                          : WebColors.primary.withOpacity(0.05),
                    ),
                    headingTextStyle: WebTextStyles.tableHeader(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                    ),
                    dataTextStyle: WebTextStyles.custom(
                      fontSize: 13,
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? WebDarkColors.textPrimary
                          : WebColors.textPrimary,
                      fontWeight: WebFonts.medium,
                    ),
                    border: TableBorder(
                      top: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                        width: 1,
                      ),
                      bottom: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                        width: 1,
                      ),
                      horizontalInside: BorderSide(
                        color: theme.isDarkMode
                            ? WebDarkColors.divider
                            : WebColors.divider,
                        width: 1,
                      ),
                    ),
                    columns: [
                      DataColumn2(
                        label: Text(
                          'Symbol',
                          style: WebTextStyles.tableHeader(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                        ),
                        size: ColumnSize.L,
                        fixedWidth: 300.0,
                      ),
                      DataColumn2(
                        label: Text(
                          'LTP',
                          style: WebTextStyles.tableHeader(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                        ),
                        size: ColumnSize.S,
                      ),
                      DataColumn2(
                        label: Text(
                          '%Change',
                          style: WebTextStyles.tableHeader(
                            isDarkTheme: theme.isDarkMode,
                            color: theme.isDarkMode
                                ? WebDarkColors.textPrimary
                                : WebColors.textPrimary,
                          ),
                        ),
                        size: ColumnSize.S,
                      ),
                    ],
                    rows: future.fut!.asMap().entries.map((entry) {
                  final index = entry.key;
                  final displayData = entry.value;
                  // Update with socket data if available
                  var updatedData = displayData;
                  final tokenKey = displayData.token?.toString();

                  if (tokenKey != null && socketDatas.containsKey(tokenKey)) {
                    final socketData = socketDatas[tokenKey];

                    // Try multiple possible keys for LTP
                    final lp = socketData['lp']?.toString() ??
                        socketData['ltp']?.toString() ??
                        socketData['last_price']?.toString();
                    if (lp != null &&
                        lp != "null" &&
                        lp != "0" &&
                        lp != "0.00" &&
                        lp.isNotEmpty) {
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
                      try {
                        updatedData.change = chng;
                      } catch (e) {
                        // Property might be read-only, ignore
                      }
                    }

                    // Try multiple possible keys for percentage change
                    final pc = socketData['pc']?.toString() ??
                        socketData['per_change']?.toString() ??
                        socketData['percentage_change']?.toString() ??
                        socketData['pchange']?.toString();
                    if (pc != null && pc != "null" && pc.isNotEmpty) {
                      try {
                        updatedData.perChange = pc;
                      } catch (e) {
                        // Property might be read-only, ignore
                      }
                    }
                  }

                      final token = updatedData.token?.toString() ?? '';
                      final uniqueId = '$token$index';

                      return DataRow2(
                        onTap: () {
                          // Row tap handler if needed
                        },
                        color: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.hovered) || _hoveredToken.value == uniqueId) {
                            return theme.isDarkMode
                                ? WebDarkColors.primary.withOpacity(0.06)
                                : WebColors.primary.withOpacity(0.10);
                          }
                          return Colors.transparent;
                        }),
                        cells: [
                          // Symbol cell with hover actions
                          DataCell(
                            MouseRegion(
                              onEnter: (_) => _hoveredToken.value = uniqueId,
                              onExit: (_) => _hoveredToken.value = null,
                              child: SizedBox.expand(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                  child: _buildSymbolCellContent(updatedData, theme, future, uniqueId),
                                ),
                              ),
                            ),
                          ),
                          // LTP cell
                          DataCell(
                            MouseRegion(
                              onEnter: (_) => _hoveredToken.value = uniqueId,
                              onExit: (_) => _hoveredToken.value = null,
                              child: SizedBox.expand(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                  child: Text(
                                    updatedData.ltp != null &&
                                            updatedData.ltp != "null"
                                        ? "${updatedData.ltp}"
                                        : updatedData.close != null &&
                                                updatedData.close != "null"
                                            ? "${updatedData.close}"
                                            : '0.00',
                                    style: WebTextStyles.custom(
                                      fontSize: 13,
                                      isDarkTheme: theme.isDarkMode,
                                      color: _getPriceColor(updatedData, theme),
                                      fontWeight: WebFonts.medium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Change cell
                          DataCell(
                            MouseRegion(
                              onEnter: (_) => _hoveredToken.value = uniqueId,
                              onExit: (_) => _hoveredToken.value = null,
                              child: SizedBox.expand(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                                  child: Text(
                                    "${(_getChangeValue(updatedData))} "
                                    "(${_getPerChangeValue(updatedData)}%)",
                                    style: WebTextStyles.custom(
                                      fontSize: 13,
                                      isDarkTheme: theme.isDarkMode,
                                      color: _getChangeColor(updatedData, theme),
                                      fontWeight: WebFonts.medium,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSymbolCellContent(
      dynamic displayData, ThemesProvider theme, MarketWatchProvider future, String uniqueId) {
    final displayText = displayData.tsym?.toString() ?? '';

    // PERFORMANCE FIX: Use ValueListenableBuilder to only rebuild hover-dependent parts
    return ValueListenableBuilder<String?>(
      valueListenable: _hoveredToken,
      builder: (context, hoveredToken, _) {
        final isHovered = hoveredToken == uniqueId;
        return Row(
          children: [
            Expanded(
              flex: isHovered ? 1 : 2,
              child: Tooltip(
                message: displayText,
                child: Text(
                  displayText,
                  style: WebTextStyles.custom(
                    fontSize: 13,
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? WebDarkColors.textPrimary
                        : WebColors.textPrimary,
                    fontWeight: WebFonts.medium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Action buttons fade in on hover
            IgnorePointer(
              ignoring: !isHovered,
              child: AnimatedOpacity(
                opacity: isHovered ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: _buildActionButtons(
                  context,
                  displayData,
                  future,
                  theme,
                  isHovered,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    dynamic displayData,
    MarketWatchProvider future,
    ThemesProvider theme,
    bool isHovered,
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
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
          onPressed: () async {
            try {
              await _placeOrderInput(context, displayData, true, future);
            } catch (e) {
              print('Buy button error: $e');
            }
          },
          theme: theme,
        ),
        const SizedBox(width: 6),
        // Sell Button
        _buildHoverButton(
          label: 'S',
          color: Colors.white,
          backgroundColor:
              theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary,
          onPressed: () async {
            try {
              await _placeOrderInput(context, displayData, false, future);
            } catch (e) {
              print('Sell button error: $e');
            }
          },
          theme: theme,
        ),
        const SizedBox(width: 6),
        // Chart Button
        _buildHoverButton(
          icon: Icons.bar_chart,
          color: Colors.black,
          backgroundColor: Colors.white,
          borderRadius: 5.0,
          onPressed: () {
            // Navigate to chart screen - same logic as watchlist_card_web
            Navigator.pop(context);
            ref
                .read(marketWatchProvider)
                .calldepthApis(context, displayData, "");
          },
          theme: theme,
        ),
        const SizedBox(width: 6),
        // Save Button (Add to watchlist)
        _buildHoverButton(
          svgIcon: isInWatchlist ? assets.bookmarkIcon : assets.bookmarkedIcon,
          color: isInWatchlist
              ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
              : (theme.isDarkMode
                  ? WebDarkColors.textSecondary
                  : WebColors.textSecondary),
          backgroundColor: Colors.white,
          borderRadius: 5.0,
          onPressed: () async {
            final bool add = !isInWatchlist;
            final success = await future.addDelMarketScrip(
              future.wlName,
              key,
              context,
              add,
              true,
              false,
              false, // Set isOptionStike to false to prevent provider's Fluttertoast
            );
            if (success && mounted) {
              // Show toast message (provider only shows Fluttertoast for add case)
              if (add) {
                ResponsiveSnackBar.showSuccess(
                    context, 'Added to ${future.wlName}');
              } else {
                ResponsiveSnackBar.showInfo(
                    context, 'Removed from ${future.wlName}');
              }
              // Force rebuild to refresh icon state
              setState(() {});
            }
          },
          theme: theme,
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
    double? borderRadius,
    required VoidCallback? onPressed,
    required ThemesProvider theme,
  }) {
    final isLongLabel = label != null && label.length > 1;
    final borderRadiusValue = borderRadius ?? 5.0;
    return SizedBox(
      width: isLongLabel ? null : 25,
      height: 25,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadiusValue),
          splashColor: color.withOpacity(0.15),
          highlightColor: color.withOpacity(0.08),
          onTap: onPressed,
          child: Container(
            padding:
                isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 1.3,
                    )
                  : null,
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
                          size: 16,
                          color: color,
                          weight: 400,
                        )
                      : Text(
                          label ?? "",
                          style: WebTextStyles.buttonXs(
                            isDarkTheme: theme.isDarkMode,
                            color: color,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }

  String _getChangeValue(dynamic displayData) {
    final change = displayData.change?.toString();
    if (change != null && change != "null" && change.isNotEmpty) {
      return (double.tryParse(change)?.toStringAsFixed(2) ?? "0.00");
    }
    return "0.00";
  }

  String _getPerChangeValue(dynamic displayData) {
    final perChange = displayData.perChange?.toString();
    if (perChange != null && perChange != "null" && perChange.isNotEmpty) {
      return (double.tryParse(perChange)?.toStringAsFixed(2) ?? "0.00");
    }
    return "0.00";
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
