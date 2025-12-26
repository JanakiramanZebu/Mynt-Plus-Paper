import 'dart:async';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../models/marketwatch_model/get_quotes.dart';
import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../models/order_book_model/order_book_model.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/order_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';
import '../../../../sharedWidget/list_divider.dart';
import '../../../../utils/responsive_navigation.dart';
import '../../../../sharedWidget/snack_bar.dart';
import '../../../../utils/responsive_snackbar.dart';

class OptChainCallList extends StatelessWidget {
  final List<OptionValues>? callData;
  final bool isCallUp;
  final SwipeActionController? swipe;
  final bool showPriceView;
  final bool isBasketMode;

  const OptChainCallList({
    super.key,
    this.callData,
    this.swipe,
    required this.isCallUp,
    required this.showPriceView,
    required this.isBasketMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      reverse: isCallUp,
      itemCount: callData?.length ?? 0,
      separatorBuilder: (context, index) => const ListDivider(),
      itemBuilder: (context, index) {
        final option = callData![index];
        return _OptionChainCallRow(
          key: ValueKey('call-${option.token}'),
          option: option,
          swipe: swipe,
          index: index,
          showPriceView: showPriceView,
          isBasketMode: isBasketMode,
        );
      },
    );
  }
}

class _OptionChainCallRow extends StatefulWidget {
  final OptionValues option;
  final SwipeActionController? swipe;
  final int index;
  final bool showPriceView;
  final bool isBasketMode;

  const _OptionChainCallRow({
    super.key,
    required this.option,
    this.swipe,
    required this.index,
    required this.showPriceView,
    required this.isBasketMode,
  });

  @override
  _OptionChainCallRowState createState() => _OptionChainCallRowState();
}

class _OptionChainCallRowState extends State<_OptionChainCallRow> {
  // Cache the data locally to avoid rebuilds when parent rebuilds
  late String _lp;
  late String _perChange;
  late String _oiLack;
  late String _oiPerChng;
  late double _currentOI;
  bool _isHovered = false;
  bool _isInWatchlist = false;
  StreamSubscription? _subscription;

  // Static variable to track global maximum OI across all CALL options
  static double _globalMaxOI = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize with option model data first (context not available for websocket yet)
    _lp = widget.option.lp ?? widget.option.close ?? "0.00";
    _perChange = widget.option.perChange ?? "0.00";
    _oiLack = widget.option.oiLack ?? "0.00";
    _oiPerChng = widget.option.oiPerChng ?? "0.00";
    
    // Initialize current OI from option model
    _currentOI = double.tryParse(widget.option.oi ?? "0") ?? 
                 double.tryParse(widget.option.oiLack ?? "0") ?? 0.0;
    
    // Convert OI lack back to full OI if needed
    if (_currentOI < 1000 && _currentOI > 0) {
      _currentOI = _currentOI * 100000;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if current option is in watchlist
    _checkIfInWatchlist();

    // Now context is available - check for existing websocket data and update if needed
    try {
      final provider = ProviderScope.containerOf(context).read(websocketProvider);
      final socketData = provider.socketDatas;
      final existingData = socketData[widget.option.token];
      
      if (existingData != null) {
        // Update with websocket data if available
        final newLp = existingData['lp']?.toString();
        final newPc = existingData['pc']?.toString();
        final newOI = double.tryParse("${existingData['oi']}") ?? 0.0;
        
        if (newLp != null && newLp != "null") _lp = newLp;
        if (newPc != null && newPc != "null") _perChange = newPc;
        if (newOI >= 0) {
          _currentOI = newOI;
          _oiLack = (_currentOI / 100000).toStringAsFixed(2);
          
          // Calculate OI percentage change
          final poi = double.tryParse("${existingData['poi'] ?? 0.00}") ?? 0.0;
          if (poi > 0) {
            _oiPerChng = (((_currentOI - poi) / poi) * 100).toStringAsFixed(2);
          } else if (_currentOI > 0) {
            _oiPerChng = "100.00";
          } else {
            _oiPerChng = "0.00";
          }
        }

        // Update global max OI if current OI is greater
        if (_currentOI > _globalMaxOI) {
          _globalMaxOI = _currentOI;
        }

        // if (kDebugMode) {
        //   print("=== CALL WEBSOCKET SYNC ===");
        //   print("Token: ${widget.option.token}");
        //   print("Updated from WebSocket - LTP: $_lp, PC: $_perChange, OI: $_currentOI");
        //   print("LTP: $_lp, PC: $_perChange, OI: $_currentOI, OI Per Chng: $_oiPerChng, poi: ${existingData['poi']}, oi: ${existingData['oi']}");
        //   print("===========================");
        // }
        
        // Update UI with websocket data
        setState(() {});
      }
    } catch (e) {
      // If provider access fails, just use option model data
      // if (kDebugMode) {
      //   print("=== CALL INIT FALLBACK ===");
      //   print("Token: ${widget.option.token}");
      //   print("Using Option Model - LTP: $_lp, PC: $_perChange, OI: $_currentOI");

        
      //   print("==========================");
      // }
    }

    // Always re-setup the listener to ensure fresh data flow
    _setupSocketListener();
  }


  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _setupSocketListener() {
    // Cancel existing subscription first
    _subscription?.cancel();
    
    // Get the stream of data
    final provider = ProviderScope.containerOf(context).read(websocketProvider);

    // Always subscribe to changes for THIS token
    _subscription = provider.socketDataStream.listen((socketData) {
      if (!mounted) return;

      // Only process if this token's data exists
      if (socketData.containsKey(widget.option.token)) {
        final data = socketData[widget.option.token];
        if (data == null) return;

        // Always update values when websocket data comes in (remove restrictive checks)
        bool needsUpdate = false;

        final newLp = data['lp']?.toString();
        if (newLp != null && newLp != "null" && newLp != _lp) {
          _lp = newLp;
          needsUpdate = true;
        }

        final newPc = data['pc']?.toString();
        if (newPc != null && newPc != "null" && newPc != _perChange) {
          _perChange = newPc;
          needsUpdate = true;
        }

        // Calculate OI values only if needed
        final oi = double.tryParse("${data['oi']}");
        if (oi != null && oi >= 0) { // Allow 0 values
          // Update current OI value
          if (oi != _currentOI) {
            _currentOI = oi;
            needsUpdate = true;
            
            // Update GLOBAL max OI if current OI is greater
            if (_currentOI > _globalMaxOI) {
              _globalMaxOI = _currentOI;
            }
          }
          
          final newOiLack = (oi / 100000).toStringAsFixed(2);
          if (newOiLack != _oiLack) {
            _oiLack = newOiLack;
            needsUpdate = true;
          }

          final poi = double.tryParse("${data['poi'] ?? 0.00}") ?? 0.0;
          String newOiPerChng = "0.00";
          // print("poi: $poi");
          // print("oi: $oi");
          // Safe calculation to avoid division by zero
          if (poi > 0) {
          
            newOiPerChng = (((oi - poi) / poi) * 100).toStringAsFixed(2);
          } else if (oi > 0) {
            // If previous OI was 0 but current OI exists, show as 100% increase
            newOiPerChng = "100.00";
          }
          
          if (newOiPerChng != _oiPerChng && newOiPerChng != "NaN") {
            _oiPerChng = newOiPerChng;
            needsUpdate = true;
          }
        }

        // Always rebuild if we have any data update
        if (needsUpdate) {
          // if (kDebugMode) {
            // print("=== CALL DATA UPDATE ===");
            // print("Token: ${widget.option.token}");
            // print("LTP: $_lp, PC: $_perChange, OI: $_currentOI, OI Per Chng: $_oiPerChng, poi: $data['poi'], oi: $data['oi']");
            // print("========================");
          // }
          setState(() {});
          
          // Also check basket state periodically
              }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scripData =
        ProviderScope.containerOf(context).read(marketWatchProvider);
    final theme = ProviderScope.containerOf(context).read(themeProvider);
    
    // Check watchlist status on every build to react to changes
    final scripToken = "${widget.option.exch}|${widget.option.token}";
    final isCurrentlyInWatchlist = scripData.scrips.any((scrip) => 
      "${scrip['exch']}|${scrip['token']}" == scripToken
    );
    if (_isInWatchlist != isCurrentlyInWatchlist) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInWatchlist = isCurrentlyInWatchlist;
          });
        }
      });
    }

    return RepaintBoundary(
      child: SwipeActionCell(
        isDraggable: widget.option.tsym!.contains("|||") ? false : true,
        fullSwipeFactor: 0.7,
        controller: widget.swipe,
        index: widget.index,
        key: ValueKey(widget.option.token),
        leadingActions: [
          SwipeAction(
            performsFirstActionWithFullSwipe: true,
            title: "SELL",
            color: Color(theme.isDarkMode ? 0xfffbbbb6 : 0xfffee8e7),
            style: _getActionStyle(colors.darkred),
            onTap: (handler) async {
              await placeOrderInput(scripData, context, widget.option, false);
              handler(false);
            },
          ),
        ],
        trailingActions: [
          SwipeAction(
            performsFirstActionWithFullSwipe: true,
            title: "BUY",
            color: Color(theme.isDarkMode ? 0xffcaedc4 : 0xffedf9eb),
            style: _getActionStyle(colors.ltpgreen),
            onTap: (handler) async {
              await placeOrderInput(scripData, context, widget.option, true);
              handler(false);
            },
          ),
        ],
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          // Long press disabled - using hover icon for add to watchlist instead
          // onLongPress: () => {
          //   widget.option.tsym!.contains("|||")
          //       ? _symbolenotFound(context)
          //       : _handleLongPress(context, widget.option)
          // },
          onTap: () => {
            widget.option.tsym!.contains("|||")
                ? _symbolenotFound(context)
                : widget.isBasketMode 
                  ? _handleBasketModeTap(context, widget.option)
                  : _handleTap(context, widget.option)
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: _isHovered
                ? (theme.isDarkMode
                    ? WebDarkColors.primary
                    : WebColors.primary)
                    .withOpacity(0.15)
                : Colors.transparent,
            child: _buildCompleteDataRow(theme, scripData),
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteDataRow(ThemesProvider theme, MarketWatchProvider scripData) {
    final changeColor = _perChange.startsWith("-")
        ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss)
        : (_perChange == "0.00" || _perChange == "0.0"
            ? (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary)
            : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit));

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // CALLS column order: OI(ch), OI, CH, LTP (reversed from PUTS)
        Row(
                children: [
                  // OI column - shows OI(ch), OI
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${_oiPerChng == "NaN" ? "0.00" : _oiPerChng}%",
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: (_oiPerChng.startsWith("-"))
                                      ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss)
                                      : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _oiLack,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price column - shows CH, LTP
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "$_perChange%",
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: changeColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _lp,
                                style: WebTextStyles.tableDataCompact(
                                  isDarkTheme: theme.isDarkMode,
                                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 2),
                        // // Green bar for call OI
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: Container(
                        //     height: 2,
                        //     width: MediaQuery.of(context).size.width * 0.12 * 
                        //         (_currentOI > 0 && _globalMaxOI > 0 
                        //             ? (_currentOI / _globalMaxOI).clamp(0.0, 1.0) 
                        //             : 0.0),
                        //     decoration: BoxDecoration(
                        //       color: theme.isDarkMode ? WebDarkColors.profit : WebColors.profit,
                        //       borderRadius: BorderRadius.circular(1),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
        // Buttons positioned on top - aligned to right edge of CALLS column
        if (_isHovered)
          Positioned(
            top: 0,
            right: 8,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHoverButton(
                    label: 'B',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                    onPressed: () async {
                      await placeOrderInput(scripData, context, widget.option, true);
                    },
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildHoverButton(
                    label: 'S',
                    color: Colors.white,
                    backgroundColor: theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary,
                    onPressed: () async {
                      await placeOrderInput(scripData, context, widget.option, false);
                    },
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildHoverButton(
                    icon: Icons.bar_chart,
                    color: Colors.black,
                    backgroundColor: Colors.white,
                    borderRadius: 5.0,
                    onPressed: () async {
                      await _handleChartTap(context, widget.option);
                    },
                    theme: theme,
                  ),
                  const SizedBox(width: 6),
                  _buildHoverButton(
                    svgIcon: _isInWatchlist ? assets.bookmarkIcon : assets.bookmarkedIcon,
                    color: _isInWatchlist 
                        ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                        : (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary),
                    backgroundColor: Colors.white,
                    borderRadius: 5.0,
                    onPressed: () async {
                      await _handleSaveToWatchlist(context, widget.option);
                    },
                    theme: theme,
                  ),
                ],
              ),
          ),
      ],
    );
  }

  Widget _buildDataCell(String value, ThemesProvider theme, {bool isPrimary = false, Color? color}) {
    final displayValue = value == "0.00" || value == "0" ? "0.00" : value;
    final textColor = color ?? (isPrimary 
        ? (theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary)
        : (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary));

    return Text(
      displayValue,
      style: isPrimary 
          ? WebTextStyles.tableDataCompact(
              isDarkTheme: theme.isDarkMode,
              color: textColor,
            )
          : WebTextStyles.tableDataCompact(
              isDarkTheme: theme.isDarkMode,
              color: textColor,
            ),
      textAlign: TextAlign.start,
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
            padding: isLongLabel ? const EdgeInsets.symmetric(horizontal: 8) : null,
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

  Future<void> _handleChartTap(BuildContext context, OptionValues option) async {
    final scripData = ProviderScope.containerOf(context).read(marketWatchProvider);
    
    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch.toString(),
        token: quots.token.toString(),
        tsym: quots.tsym.toString(),
        instname: quots.instname.toString(),
        symbol: quots.symbol.toString(),
        expDate: quots.expDate.toString(),
        option: quots.option.toString(),
      );
      scripData.scripdepthsize(false);
      await scripData.calldepthApis(context, depthArgs, "");
    }
  }

  void _checkIfInWatchlist() {
    try {
      final scripData = ProviderScope.containerOf(context).read(marketWatchProvider);
      final scrips = scripData.scrips;
      
      // Check if this option's token exists in the current watchlist
      final scripToken = "${widget.option.exch}|${widget.option.token}";
      _isInWatchlist = scrips.any((scrip) => 
        "${scrip['exch']}|${scrip['token']}" == scripToken
      );
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _isInWatchlist = false;
    }
  }

  Future<void> _handleSaveToWatchlist(BuildContext context, OptionValues option) async {
    final provider = ProviderScope.containerOf(context);
    final scripData = provider.read(marketWatchProvider);

    if (scripData.isPreDefWLs == "Yes") {
      showResponsiveWarningMessage(context, "This is a pre-defined watchlist that cannot be edited!");
      return;
    }

    final scripToken = "${option.exch}|${option.token}";
    final isCurrentlyInWatchlist = scripData.scrips.any((scrip) => 
      "${scrip['exch']}|${scrip['token']}" == scripToken
    );

    if (isCurrentlyInWatchlist) {
      // Delete from watchlist
      final success = await scripData.addDelMarketScrip(
        scripData.wlName,
        scripToken,
        context,
        false, // delete
        true,
        false,
        false, // Set isOptionStike to false to prevent provider's Fluttertoast
      );
      if (success && mounted) {
        ResponsiveSnackBar.showInfo(context, 'Removed from ${scripData.wlName}');
        setState(() {});
      }
    } else {
      // Add to watchlist
      provider.read(websocketProvider).establishConnection(
        channelInput: scripToken,
        task: "t",
        context: context,
      );
      
      final success = await scripData.addDelMarketScrip(
        scripData.wlName,
        scripToken,
        context,
        true, // add
        true,
        false,
        false, // Set isOptionStike to false to prevent provider's Fluttertoast
      );
      if (success && mounted) {
        ResponsiveSnackBar.showSuccess(context, 'Added to ${scripData.wlName}');
        setState(() {});
      }
    }
    
    // Update watchlist status after a brief delay to allow for API response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _checkIfInWatchlist();
      }
    });
  }

Widget _buildOIData(ThemesProvider theme) {
  // Calculate line width percentage based on current OI relative to GLOBAL max OI
  double lineWidthPercentage = 0.0;
  
  if (_currentOI > 0 && _globalMaxOI > 0) {
    // Calculate line width percentage based on current OI relative to GLOBAL max OI
    lineWidthPercentage = (_currentOI / _globalMaxOI).clamp(0.0, 1.0);
  }

  return Container(
    height: 55,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _oiLack,
          style: _getTextStyle(
              theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary, _oiPerChng, theme),
        ),
        const SizedBox(height: 3),
        Text(
          "(${_oiPerChng == "NaN" ? "0.00" : _oiPerChng}%)",
          style: _getPercentageStyle(_oiPerChng, theme),
        ),
        const SizedBox(height: 2),
        // Dynamic width line based on OI
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 1.5,
            width: MediaQuery.of(context).size.width * 0.25 * lineWidthPercentage,
            decoration: BoxDecoration(
              color: _oiPerChng.startsWith("-") 
                  ? (theme.isDarkMode ? WebDarkColors.error : WebColors.error)
                  : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    ),
  );
}


Widget _buildPriceData(ThemesProvider theme) {
  // Calculate line width percentage based on current OI relative to GLOBAL max OI
  double lineWidthPercentage = 0.0;
  
  if (_currentOI > 0 && _globalMaxOI > 0) {
    // Calculate line width percentage based on current OI relative to GLOBAL max OI
    lineWidthPercentage = (_currentOI / _globalMaxOI).clamp(0.0, 1.0);
  }

  return Container(
    height: 55,
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _lp,
          style: _getTextStyle(
              theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary, _perChange, theme),
        ),
        const SizedBox(height: 3),
        
        Text(
          "($_perChange%)",
          style: _getPercentageStyle(_perChange, theme),
        ),
        
        const SizedBox(height: 2),
        // Dynamic width line based on OI
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 1.5,
            width: MediaQuery.of(context).size.width * 0.25 * lineWidthPercentage,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? WebDarkColors.profit : WebColors.profit,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    ),
  );
}

  void _symbolenotFound(BuildContext context) {
    showResponsiveWarningMessage(context, "Scrip Not founded");
  }

  void _handleLongPress(BuildContext context, OptionValues option) {
    final provider = ProviderScope.containerOf(context);
    final scripData = provider.read(marketWatchProvider);

    if (scripData.isPreDefWLs == "Yes") {
      Fluttertoast.showToast(
        msg: "This is a pre-defined watchlist that cannot be Added!",
        timeInSecForIosWeb: 2,
        backgroundColor: colors.colorBlack,
        textColor: colors.colorWhite,
        fontSize: 14.0,
      );
    } else {
      provider.read(websocketProvider).establishConnection(
            channelInput: "${option.exch}|${option.token}",
            task: "t",
            context: context,
          );
      scripData.addDelMarketScrip(
        scripData.wlName,
        "${option.exch}|${option.token}",
        context,
        true,
        true,
        false,
        true,
      );
    }
  }

  Future<void> _handleTap(BuildContext context, OptionValues option) async {
    final provider = ProviderScope.containerOf(context);
    final scripData = provider.read(marketWatchProvider);

    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;
    DepthInputArgs depthArgs = DepthInputArgs(
      exch: quots!.exch.toString(),
      token: quots.token.toString(),
      tsym: quots.tsym.toString(),
      instname: quots.instname.toString(),
      symbol: quots.symbol.toString(),
      expDate: quots.expDate.toString(),
      option: quots.option.toString(),
    );
    // Navigator.pop(context);
    await scripData.calldepthApis(context, depthArgs, "");
  }

  Future<void> _handleBasketModeTap(BuildContext context, OptionValues option) async {
    final provider = ProviderScope.containerOf(context);
    final scripData = provider.read(marketWatchProvider);
    final orderProv = provider.read(orderProvider);

    // Check if a basket is selected
    if (orderProv.selectedBsktName.isEmpty) {
      showResponsiveErrorMessage(context, "Please select a basket");
      return;
    }

    // Preserve current symbol context before basket operations
    scripData.preserveContextForBasket();

    await scripData.fetchScripQuoteIndex(
      "${option.token}",
      "${option.exch}",
      context,
    );
    final quots = scripData.getQuotes;
    
    if (quots != null) {
      DepthInputArgs depthArgs = DepthInputArgs(
        exch: quots.exch.toString(),
        token: quots.token.toString(),
        tsym: quots.tsym.toString(),
        instname: quots.instname.toString(),
        symbol: quots.symbol.toString(),
        expDate: quots.expDate.toString(),
        option: quots.option.toString(),
      );
      
      await scripData.calldepthApis(context, depthArgs, "BasketMode");

      // Restore original symbol context after basket operations
      scripData.restoreContextFromBasket();
    }
  }

  static final Map<Color, TextStyle> _actionStyleCache = {};

  static TextStyle _getActionStyle(Color color) {
    return _actionStyleCache.putIfAbsent(
      color,
      () => WebTextStyles.head(
        isDarkTheme: false,
        color: color,
        fontWeight: WebFonts.regular,
      ),
    );
  }

  static TextStyle _getTextStyle(Color color, String perChange, ThemesProvider theme) {
    Color textColor = theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
    if (perChange != "0.00" && perChange.isNotEmpty) {
      textColor = perChange.startsWith("-") 
          ? (theme.isDarkMode ? WebDarkColors.loss : WebColors.loss) 
          : (theme.isDarkMode ? WebDarkColors.profit : WebColors.profit);
    }
    return WebTextStyles.sub(
      isDarkTheme: theme.isDarkMode,
      color: textColor,
    );
  }

  static TextStyle _getPercentageStyle(String? value, ThemesProvider theme) {
        Color color = theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
        // if (value != null && value != "0.00") {
        //   color = value.startsWith("-") ? colors.darkred : colors.ltpgreen;
        // } 
        return WebTextStyles.para(
            isDarkTheme: theme.isDarkMode, 
            color: color,
        );
  }
}

Future<void> placeOrderInput(
  MarketWatchProvider scripInfo,
  BuildContext context,
  OptionValues depthData,
  bool transType,
) async {
  // Obtain a WidgetRef from the context
  final container = ProviderScope.containerOf(context);

  await container.read(marketWatchProvider).fetchScripInfo(
        depthData.token.toString(),
        depthData.exch.toString(),
        context,
        true,
      );
  
  // **FIX: Use lot size from scripInfoModel if option data doesn't have it**
  final lotSize = depthData.ls?.isNotEmpty == true 
      ? depthData.ls 
      : container.read(marketWatchProvider).scripInfoModel?.ls.toString();
  
  OrderScreenArgs orderArgs = OrderScreenArgs(
    exchange: depthData.exch.toString(),
    tSym: depthData.tsym.toString(),
    isExit: false,
    token: depthData.token.toString(),
    transType: transType,
    lotSize: lotSize,
    ltp: "${depthData.lp ?? depthData.close ?? 0.00}",
    perChange: depthData.perChange ?? "0.00",
    orderTpye: '',
    holdQty: '',
    isModify: false,
    raw: {},
  );
  ResponsiveNavigation.toPlaceOrderScreen(
    context: context,
    arguments: {
      "orderArg": orderArgs,
      "scripInfo": container.read(marketWatchProvider).scripInfoModel!,
      "isBskt": "",
    },
  );
}
