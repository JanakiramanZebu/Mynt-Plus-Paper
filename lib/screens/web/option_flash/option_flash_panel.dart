import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/option_flash_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/websocket_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/common_text_fields_web.dart';
import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
import 'package:mynt_plus/utils/responsive_snackbar.dart';
import 'dart:html' as html;
import '../market_watch/tv_chart/chart_iframe_guard.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Option Flash Panel - A draggable floating panel for quick options trading
class OptionFlashPanel extends ConsumerStatefulWidget {
  const OptionFlashPanel({super.key});

  @override
  ConsumerState<OptionFlashPanel> createState() => _OptionFlashPanelState();
}

class _OptionFlashPanelState extends ConsumerState<OptionFlashPanel> {
  // Dragging state
  bool _isDragging = false;
  Offset _initialPosition = Offset.zero;

  // Input controllers
  TextEditingController? _qtyController;
  TextEditingController? _priceController;

  // Track previous state for price sync
  String? _lastStrikeToken;
  String? _lastPriceType;

  // Symbol dropdown state
  final GlobalKey _symbolButtonKey = GlobalKey();
  OverlayEntry? _symbolOverlay;

  // Expiry dropdown state
  final GlobalKey _expiryButtonKey = GlobalKey();
  OverlayEntry? _expiryOverlay;

  // Strike dropdown state
  final GlobalKey _strikeButtonKey = GlobalKey();
  OverlayEntry? _strikeOverlay;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
    _priceController = TextEditingController();

    // Listen to WebSocket updates and initialize controller values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupWebSocketListener();
      _initializeControllerValues();
    });
  }

  /// Initialize text field values from provider on first load
  /// [force] - if true, overwrites existing values (used when panel reopens)
  void _initializeControllerValues({bool force = false}) {
    final optionFlash = ref.read(optionFlashProvider);

    // Set qty value
    if (_qtyController != null && (force || _qtyController!.text.isEmpty)) {
      _qtyController!.text = optionFlash.qtyLots.toString();
    }

    // Set price value (only if not market order)
    if (_priceController != null && (force || _priceController!.text.isEmpty)) {
      if (optionFlash.priceType == 'MKT') {
        _priceController!.text = '0';
      } else {
        _priceController!.text = optionFlash.price.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    ChartIframeGuard.release();
    _enableAllChartIframes();
    _removeSymbolOverlay();
    _removeExpiryOverlay();
    _removeStrikeOverlay();
    _qtyController?.dispose();
    _priceController?.dispose();
    super.dispose();
  }

  // Directly disable all chart iframes and reset cursor (like chart's onExit)
  void _disableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'none';
          // Reset cursor style to prevent cursor bleeding
          iframe.style.cursor = 'default';
        }
      }
      // Also reset cursor on document body to ensure it's reset globally
      html.document.body?.style.cursor = 'default';
    } catch (e) {
      debugPrint('Error disabling iframes: $e');
    }
  }

  void _enableAllChartIframes() {
    try {
      final iframes = html.document.querySelectorAll('iframe');
      for (var iframe in iframes) {
        if (iframe is html.IFrameElement && iframe.id.contains('chart-iframe')) {
          iframe.style.pointerEvents = 'auto';
          iframe.style.cursor = '';
        }
      }
      html.document.body?.style.cursor = '';
    } catch (e) {
      debugPrint('Error enabling iframes: $e');
    }
  }

  void _removeSymbolOverlay() {
    _symbolOverlay?.remove();
    _symbolOverlay = null;
  }

  void _removeExpiryOverlay() {
    _expiryOverlay?.remove();
    _expiryOverlay = null;
  }

  void _removeStrikeOverlay() {
    _strikeOverlay?.remove();
    _strikeOverlay = null;
  }

  void _setupWebSocketListener() {
    final websocketProv = ref.read(websocketProvider);
    websocketProv.socketDataStream.listen((data) {
      if (mounted) {
        final typedData = Map<String, dynamic>.from(data);
        ref.read(optionFlashProvider).updateFromWebSocket(typedData);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final optionFlash = ref.watch(optionFlashProvider);
    final theme = ref.watch(themeProvider);
    final isDark = theme.isDarkMode;

    if (!optionFlash.isVisible) {
      return const SizedBox.shrink();
    }

    // Listen for external state changes to update controllers
    ref.listen(optionFlashProvider, (previous, next) {
      // Re-initialize controller values when panel becomes visible
      if (previous?.isVisible == false && next.isVisible == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeControllerValues(force: true);
          // Reset tracking variables when panel reopens
          _lastStrikeToken = null;
          _lastPriceType = null;
        });
      }

      // Sync Qty (only if changed and mismatch)
      if (previous?.qtyLots != next.qtyLots) {
         if (_qtyController != null && _qtyController!.text != next.qtyLots.toString()) {
           // Check if the parsed text value is actually different to avoid formatting wars
           if (int.tryParse(_qtyController!.text) != next.qtyLots) {
             _qtyController!.text = next.qtyLots.toString();
             _qtyController!.selection = TextSelection.collapsed(offset: _qtyController!.text.length);
           }
         }
      }
      // Note: Price sync is handled in _buildPriceInput using state tracking
    });

    return Positioned(
      left: optionFlash.dialogPosition.dx,
      top: optionFlash.dialogPosition.dy,
      child: PointerInterceptor(
        child: MouseRegion(
          cursor: SystemMouseCursors.basic,
          onEnter: (_) {
            ChartIframeGuard.acquire();
            _disableAllChartIframes();
          },
          onHover: (_) {
            _disableAllChartIframes();
          },
          onExit: (_) {
            ChartIframeGuard.release();
            _enableAllChartIframes();
          },
          child: Listener(
            onPointerMove: (_) {
              _disableAllChartIframes();
            },
            child: GestureDetector(
              onTap: () {}, // Prevent tap from propagating to background
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  width: 840,
                  decoration: BoxDecoration(
                    color: isDark ? MyntColors.dialogDark : MyntColors.dialog,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDark ? MyntColors.dialogDark : MyntColors.dialog,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(context, optionFlash, isDark),
                          _buildControls(context, optionFlash, isDark),
                        ],
                      ),
                      if (optionFlash.isPanelLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(child: MyntLoader(size: MyntLoaderSize.small)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    final headerColor = optionFlash.isBuy
        ? ( resolveThemeColor(
          context,
          dark: MyntColors.primaryDark.withValues(alpha: 0.1),
          light: MyntColors.primary.withValues(alpha: 0.1),
        ))
        : ( resolveThemeColor(
          context,
          dark: MyntColors.errorDark.withValues(alpha: 0.2),
          light: MyntColors.tertiary.withValues(alpha: 0.2),
        ));

    return GestureDetector(
      onPanStart: (details) {
        _isDragging = true;
        _initialPosition = details.globalPosition - optionFlash.dialogPosition;
      },
      onPanUpdate: (details) {
        if (_isDragging) {
          final newPosition = details.globalPosition - _initialPosition;
          // Constrain to viewport
          final screenSize = MediaQuery.of(context).size;
          final constrainedX = newPosition.dx.clamp(0.0, screenSize.width - 920);
          final constrainedY = newPosition.dy.clamp(0.0, screenSize.height - 150);
          optionFlash.updateDialogPosition(Offset(constrainedX, constrainedY));
          setState(() {});
        }
      },
      onPanEnd: (_) {
        _isDragging = false;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: headerColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
          ),
        ),
        child: Row(
          children: [
            // Symbol selector
            _buildSymbolSelector(context, optionFlash, isDark),
            const SizedBox(width: 12),

            // Index price and change
            _buildIndexPrice(context, optionFlash, isDark),
            const SizedBox(width: 12),

            // Strike LTP info
            Expanded(
              child: _buildStrikeLTP(context, optionFlash, isDark),
            ),

            // P&L (fixed width to prevent dancing) - only show if positions exist
            if (optionFlash.hasSymbolPositions) ...[
              SizedBox(
                width: 140,
                child: _buildPnL(context, optionFlash, isDark),
              ),

              // Exit button with icon
              Tooltip(
                message: 'Exit All ${optionFlash.selectedSymbol?.display ?? ''} Positions',
                child: IconButton(
                  onPressed: () => optionFlash.exitAllPositions(context),
                  icon: Icon(
                    Icons.output,
                    size: 20,
                    color: isDark ? MyntColors.iconDark : MyntColors.icon,
                  ),
                ),
              ),
            ],

            // Refresh button
            Tooltip(
              message: 'Refresh',
              child: IconButton(
                onPressed: () => optionFlash.refreshData(context),
                icon: Icon(
                  Icons.refresh,
                  size: 20,
                  color: isDark ? MyntColors.iconDark : MyntColors.icon,
                ),
              ),
            ),

            // Close button
            Tooltip(
              message: 'Close',
              child: IconButton(
                onPressed: () => optionFlash.closePanel(),
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: isDark ? MyntColors.iconDark : MyntColors.icon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolSelector(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    return GestureDetector(
      key: _symbolButtonKey,
      onTap: () => _showSymbolOverlay(context, optionFlash, isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              optionFlash.selectedSymbol?.display ?? 'NIFTY',
              style: MyntWebTextStyles.body(
                context,
                darkColor: MyntColors.textWhite,
                lightColor: MyntColors.textBlack,
                fontWeight: MyntFonts.medium,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  void _showSymbolOverlay(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    if (optionFlash.symbolsList.isEmpty) return;

    // Toggle behavior - close if already open
    if (_symbolOverlay != null) {
      _removeSymbolOverlay();
      return;
    }

    // Get button position using GlobalKey
    final RenderBox? renderBox = _symbolButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate dropdown height (estimate: ~40px per item, max 300px)
    final dropdownHeight = (optionFlash.symbolsList.length * 40.0).clamp(0.0, 300.0);

    // Check if there's enough space below the button
    final spaceBelow = screenSize.height - (buttonPosition.dy + buttonSize.height + 4);
    final spaceAbove = buttonPosition.dy - 4;

    // Position above if not enough space below and more space above
    final showAbove = spaceBelow < dropdownHeight && spaceAbove > spaceBelow;

    _symbolOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeSymbolOverlay,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Dropdown menu positioned based on available space
            Positioned(
              left: buttonPosition.dx,
              top: showAbove ? null : buttonPosition.dy + buttonSize.height + 4,
              bottom: showAbove ? screenSize.height - buttonPosition.dy + 4 : null,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(6),
                color: isDark ? MyntColors.overlayBgDark : Colors.white,
                child: Container(
                  width: 140,
                  constraints: BoxConstraints(
                    maxHeight: (showAbove ? spaceAbove : spaceBelow).clamp(100.0, 300.0),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF444444) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: optionFlash.symbolsList.map((symbol) {
                          final isSelected = symbol == optionFlash.selectedSymbol;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _removeSymbolOverlay();
                                optionFlash.onSymbolChange(symbol, context);
                              },
                              splashColor: resolveThemeColor(
                                context,
                                dark: MyntColors.rippleDark,
                                light: MyntColors.rippleLight,
                              ),
                              highlightColor: resolveThemeColor(
                                context,
                                dark: MyntColors.highlightDark,
                                light: MyntColors.highlightLight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Text(
                                  symbol.display,
                                  style: MyntWebTextStyles.body(
                                    context,
                                    fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                                    color: isSelected
                                        ? resolveThemeColor(
                                            context,
                                            dark: MyntColors.primaryDark,
                                            light: MyntColors.primary,
                                          )
                                        : resolveThemeColor(
                                            context,
                                            dark: MyntColors.textPrimaryDark,
                                            light: MyntColors.textPrimary,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_symbolOverlay!);
  }

  Widget _buildIndexPrice(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    final isPositive = optionFlash.indexChange >= 0;
    final changeColor = isPositive ?  resolveThemeColor(
              context,
              dark: MyntColors.profitDark,
              light: MyntColors.profit,
            ) : resolveThemeColor(
              context,
              dark: MyntColors.lossDark,
              light: MyntColors.loss,
            );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            optionFlash.indexLTP,
            style: MyntWebTextStyles.body(
              context,
              color: changeColor,
              fontWeight: MyntFonts.medium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${optionFlash.indexChange.toStringAsFixed(2)} (${optionFlash.indexChangePer}%)',
            style: MyntWebTextStyles.para(
              context,
              fontWeight: MyntFonts.medium,
              color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrikeLTP(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    if (optionFlash.selectedStrike == null) {
      return Text(
        'Select a strike to view details',
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 13,
        ),
      );
    }

    final isPositive = optionFlash.strikeChange >= 0;
    final changeColor = isPositive ?  resolveThemeColor(
              context,
              dark: MyntColors.profitDark,
              light: MyntColors.profit,
            ) : resolveThemeColor(
              context,
              dark: MyntColors.lossDark,
              light: MyntColors.loss,
            );

    return Row(
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.start,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${optionFlash.selectedStrike!.strike.toStringAsFixed(0)} ${optionFlash.selectedStrike!.optionType} ',
          style: MyntWebTextStyles.body(
            context,
            darkColor: MyntColors.textPrimaryDark,
            lightColor: MyntColors.textPrimary,
            fontWeight: MyntFonts.medium,
          ),
        ),
        Row(
          children: [
            Text(
              '${optionFlash.strikeLTP}',
              style: MyntWebTextStyles.body(
                context,
                color : changeColor,
                fontWeight: MyntFonts.medium,
              ),
            ),
              const SizedBox(width: 8),
        Text(
          '${optionFlash.strikeChange.toStringAsFixed(2)} (${optionFlash.strikeChangePer}%)',
          style: MyntWebTextStyles.para(
            context,
            fontWeight: MyntFonts.medium,
            color:  resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
        ),
          ],
        ),
      
      ],
    );
  }

  Widget _buildPnL(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    final pnl = double.tryParse(optionFlash.indexPnL) ?? 0;
    final pnlColor = pnl >= 0 ?  resolveThemeColor(
              context,
              dark: MyntColors.profitDark,
              light: MyntColors.profit,
            ) : resolveThemeColor(
              context,
              dark: MyntColors.lossDark,
              light: MyntColors.loss,
            );

    // Build debug tooltip message
    final debugInfo = optionFlash.pnlDebugInfo.isNotEmpty
        ? optionFlash.pnlDebugInfo.join('\n')
        : 'No positions';

    return Tooltip(
      message: 'P&L Breakdown:\n$debugInfo',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'P&L ',
            style: MyntWebTextStyles.body(
              context,
           color :  resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
              fontWeight: MyntFonts.medium,
            ),
          ),
          Text(
            optionFlash.indexPnL,
            style: MyntWebTextStyles.body(
              context,
              color: pnlColor,
              fontWeight: MyntFonts.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Buy/Sell toggle
          _buildBuySellToggle(optionFlash, isDark),
          const SizedBox(width: 8),

          // Product type toggle (MIS/NRML)
          _buildProductToggle(optionFlash, isDark),
          const SizedBox(width: 8),

          // Expiry dropdown
          _buildExpiryDropdown(context, optionFlash, isDark),
          const SizedBox(width: 8),

          // Strike dropdown
          _buildStrikeDropdown(context, optionFlash, isDark),
          const SizedBox(width: 8),

          // Price type toggle (MKT/LMT)
          _buildPriceTypeToggle(optionFlash, isDark),
          const SizedBox(width: 8),

          // Quantity input
          _buildQtyInput(optionFlash, isDark),
          const SizedBox(width: 8),

          // Price input
          _buildPriceInput(optionFlash, isDark),
          const SizedBox(width: 8),

          // Submit button
          _buildSubmitButton(context, optionFlash),
        ],
      ),
    );
  }

  Widget _buildBuySellToggle(OptionFlashProvider optionFlash, bool isDark) {
    return Tooltip(
      message: optionFlash.isBuy ? 'Change to Sell' : 'Change to Buy',
      child: InkWell(
        onTap: () => optionFlash.toggleBuySell(),
      child: Container(
        width: 40,
        height: 35,
        decoration: BoxDecoration(
          // color: optionFlash.isBuy ? MyntColors.primary : MyntColors.tertiary,
          color: optionFlash.isBuy ? resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary) : resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.tertiary),
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Text(
          optionFlash.isBuy ? 'B' : 'S',
          style: MyntWebTextStyles.body(
            context,
            color: Colors.white, // Keep white for contrast on colored buttons
            fontWeight: MyntFonts.bold,
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildProductToggle(OptionFlashProvider optionFlash, bool isDark) {
    return Tooltip(
      message: optionFlash.productType == 'M' ? 'Change to MIS' : 'Change to NRML',
      child: InkWell(
        onTap: () => optionFlash.toggleProduct(),
        child: Container(
          width: 60,
          height: 35,
          decoration: BoxDecoration(
            color: resolveThemeColor(
              context,
              // dark: const Color(0xffB5C0CF).withValues(alpha: 0.15),
              dark: MyntColors.transparent,
              light: const Color(0xffF1F3F8),
            ),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: resolveThemeColor(
                context,
               dark:MyntColors.textSecondaryDark,
              light:MyntColors.primary,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            optionFlash.productType == 'M' ? 'NRML' : 'MIS',
            style: MyntWebTextStyles.body(
              context,
              color: optionFlash.productType == 'M'
                  ? resolveThemeColor(
                      context,
                      dark: MyntColors.textPrimaryDark,  // Lighter orange for dark mode
                      light: MyntColors.textPrimary,
                    )
                  : resolveThemeColor(
                      context,
                      dark: MyntColors.textPrimaryDark,  // Lighter blue for dark mode
                      light: MyntColors.textPrimary,

                    ),
              fontWeight: MyntFonts.medium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryDropdown(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    return GestureDetector(
      key: _expiryButtonKey,
      onTap: () => _showExpiryOverlay(context, optionFlash, isDark),
      child: Container(
        width: 140,
        height: 35,
        decoration: BoxDecoration(
          color: resolveThemeColor(
            context,
            // dark: const Color(0xffB5C0CF).withValues(alpha: 0.15),
            dark: MyntColors.transparent,
            light: const Color(0xffF1F3F8),
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: resolveThemeColor(
              context,
              // dark: WebColors.outlinedBorderDark,
              // light: WebColors.outlinedBorder,
              dark:MyntColors.textSecondaryDark,
              light:MyntColors.primary,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                optionFlash.selectedExpiry.isEmpty ? 'Select' : optionFlash.selectedExpiry,
                style: MyntWebTextStyles.bodySmall(
                  context,
                  darkColor: MyntColors.textWhite,
                  lightColor: MyntColors.textBlack,
                  fontWeight: MyntFonts.medium,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey : Colors.grey[700],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showExpiryOverlay(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    if (optionFlash.expiryList.isEmpty) return;

    // Toggle behavior - close if already open
    if (_expiryOverlay != null) {
      _removeExpiryOverlay();
      return;
    }

    // Get button position using GlobalKey
    final RenderBox? renderBox = _expiryButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate dropdown height (estimate: ~40px per item, max 300px)
    final dropdownHeight = (optionFlash.expiryList.length * 40.0).clamp(0.0, 300.0);

    // Check if there's enough space below the button
    final spaceBelow = screenSize.height - (buttonPosition.dy + buttonSize.height + 4);
    final spaceAbove = buttonPosition.dy - 4;

    // Position above if not enough space below and more space above
    final showAbove = spaceBelow < dropdownHeight && spaceAbove > spaceBelow;

    _expiryOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeExpiryOverlay,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Dropdown menu positioned based on available space
            Positioned(
              left: buttonPosition.dx,
              top: showAbove ? null : buttonPosition.dy + buttonSize.height + 4,
              bottom: showAbove ? screenSize.height - buttonPosition.dy + 4 : null,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(6),
                color: isDark ? MyntColors.overlayBgDark : Colors.white,
                child: Container(
                  width: 160,
                  constraints: BoxConstraints(
                    maxHeight: (showAbove ? spaceAbove : spaceBelow).clamp(100.0, 300.0),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF444444) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: optionFlash.expiryList.map((expiry) {
                          final isSelected = expiry == optionFlash.selectedExpiry;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _removeExpiryOverlay();
                                optionFlash.onExpiryChange(expiry, context);
                              },
                              splashColor: resolveThemeColor(
                                context,
                                dark: MyntColors.rippleDark,
                                light: MyntColors.rippleLight,
                              ),
                              highlightColor: resolveThemeColor(
                                context,
                                dark: MyntColors.highlightDark,
                                light: MyntColors.highlightLight,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                child: Text(
                                  expiry,
                                  style: MyntWebTextStyles.body(
                                    context,
                                    fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                                    color: isSelected
                                        ? resolveThemeColor(
                                            context,
                                            dark: MyntColors.primaryDark,
                                            light: MyntColors.primary,
                                          )
                                        : resolveThemeColor(
                                            context,
                                            dark: MyntColors.textPrimaryDark,
                                            light: MyntColors.textPrimary,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_expiryOverlay!);
  }

  Widget _buildStrikeDropdown(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    return GestureDetector(
      key: _strikeButtonKey,
      onTap: () => _showStrikeOverlay(context, optionFlash, isDark),
      child: Container(
        width: 195,
        height: 35,
        decoration: BoxDecoration(
          color: resolveThemeColor(
            context,
            dark: MyntColors.transparent,
            light: const Color(0xffF1F3F8),
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: resolveThemeColor(
              context,
            dark:MyntColors.textSecondaryDark,
              light:MyntColors.primary,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                optionFlash.selectedStrike != null
                    ? '${optionFlash.selectedStrike!.strike.toStringAsFixed(0)} ${optionFlash.selectedStrike!.optionType}'
                    : 'Select Strike',
                style: MyntWebTextStyles.bodySmall(
                  context,
                  darkColor: MyntColors.textWhite,
                  lightColor: MyntColors.textBlack,
                  fontWeight: MyntFonts.medium,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? Colors.grey : Colors.grey[700],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showStrikeOverlay(BuildContext context, OptionFlashProvider optionFlash, bool isDark) {
    if (optionFlash.formattedStrikes.isEmpty) return;

    // Toggle behavior - close if already open
    if (_strikeOverlay != null) {
      _removeStrikeOverlay();
      return;
    }

    // Get button position using GlobalKey
    final RenderBox? renderBox = _strikeButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate dropdown height (estimate: ~42px per item, max 350px)
    final dropdownHeight = (optionFlash.formattedStrikes.length * 42.0).clamp(0.0, 350.0);

    // Check if there's enough space below the button
    final spaceBelow = screenSize.height - (buttonPosition.dy + buttonSize.height + 4);
    final spaceAbove = buttonPosition.dy - 4;

    // Position above if not enough space below and more space above
    final showAbove = spaceBelow < dropdownHeight && spaceAbove > spaceBelow;

    _strikeOverlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Tap outside to close
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeStrikeOverlay,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Dropdown menu positioned based on available space
            Positioned(
              left: buttonPosition.dx,
              top: showAbove ? null : buttonPosition.dy + buttonSize.height + 4,
              bottom: showAbove ? screenSize.height - buttonPosition.dy + 4 : null,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(6),
                color: isDark ? MyntColors.overlayBgDark : Colors.white,
                child: Container(
                  width: 300,
                  constraints: BoxConstraints(
                    maxHeight: (showAbove ? spaceAbove : spaceBelow).clamp(100.0, 350.0),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF444444) : const Color(0xFFE0E0E0),
                    ),
                  ),
                  // Use Consumer to watch provider for live LTP updates
                  child: Consumer(
                    builder: (context, ref, _) {
                      final optionFlash = ref.watch(optionFlashProvider);
                      final formattedStrikes = optionFlash.formattedStrikes;

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(4),
                          itemCount: formattedStrikes.length,
                          itemBuilder: (context, index) {
                            final strike = formattedStrikes[index];
                            final isSelected = optionFlash.selectedStrike?.option.token == strike.option.token;
                            final isCall = strike.optionType == 'CE';

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  _removeStrikeOverlay();
                                  optionFlash.onStrikeChange(strike, context);
                                },
                                splashColor: resolveThemeColor(
                                  context,
                                  dark: MyntColors.rippleDark,
                                  light: MyntColors.rippleLight,
                                ),
                                highlightColor: resolveThemeColor(
                                  context,
                                  dark: MyntColors.highlightDark,
                                  light: MyntColors.highlightLight,
                                ),
                                child: Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      left: BorderSide(
                                        color: isCall ? MyntColors.profit :resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.tertiary),
                                        width: 4,
                                      ),
                                    ),
                                    color: isSelected
                                        ? resolveThemeColor(
                                            context,
                                            dark: MyntColors.primaryDark.withValues(alpha: 0.15),
                                            light: MyntColors.primary.withValues(alpha: 0.1),
                                          )
                                        : null,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      // Strike price
                                      SizedBox(
                                        width: 80,
                                        child: Text(
                                          strike.strike.toStringAsFixed(0),
                                          style: MyntWebTextStyles.body(
                                            context,
                                            fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                                            color: isSelected
                                                ? resolveThemeColor(
                                                    context,
                                                    dark: MyntColors.primaryDark,
                                                    light: MyntColors.primary,
                                                  )
                                                : resolveThemeColor(
                                                    context,
                                                    dark: MyntColors.textPrimaryDark,
                                                    light: MyntColors.textPrimary,
                                                  ),
                                          ),
                                        ),
                                      ),
                                      // CALL/PUT indicator
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isCall ? MyntColors.profit : resolveThemeColor(context, dark: MyntColors.errorDark, light: MyntColors.tertiary)).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isCall ? 'CE' : 'PE',
                                          style: MyntWebTextStyles.caption(
                                            context,
                                            color: isCall ? (isDarkMode(context) ? MyntColors.profitDark : MyntColors.profit) : (isDarkMode(context) ? MyntColors.lossDark : MyntColors.loss),
                                            fontWeight: MyntFonts.semiBold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Moneyness
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          strike.moneyness,
                                          style: MyntWebTextStyles.caption(
                                            context,
                                            color: resolveThemeColor(
                                              context,
                                              dark: MyntColors.textSecondaryDark,
                                              light: MyntColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // LTP
                                      Text(
                                        '₹${strike.ltp.toStringAsFixed(2)}',
                                        style: MyntWebTextStyles.body(
                                          context,
                                          fontWeight: MyntFonts.medium,
                                          color: resolveThemeColor(
                                            context,
                                            dark: MyntColors.textPrimaryDark,
                                            light: MyntColors.textPrimary,
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
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_strikeOverlay!);
  }

  Widget _buildPriceTypeToggle(OptionFlashProvider optionFlash, bool isDark) {
    return InkWell(
      onTap: () => optionFlash.togglePriceType(),
      child: Container(
        width: 60,
        height: 35,
        decoration: BoxDecoration(
          color: resolveThemeColor(
            context,
            dark: MyntColors.transparent,
            light: const Color(0xffF1F3F8),
          ),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: resolveThemeColor(
              context,
dark:MyntColors.textSecondaryDark,
              light:MyntColors.primary,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          optionFlash.priceType,
          style: MyntWebTextStyles.bodySmall(
            context,
            color: optionFlash.priceType == 'MKT'
                ? resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,  // Lighter purple for dark mode
                    light: MyntColors.textPrimary,
                  )
                : resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,  // Lighter teal for dark mode
                    light: MyntColors.textPrimary
                  ),
            fontWeight: MyntFonts.medium,
          ),
        ),
      ),
    );
  }

  Widget _buildQtyInput(OptionFlashProvider optionFlash, bool isDark) {
    final hasError = optionFlash.qtyError != null;

    return Tooltip(
      message: optionFlash.freezeQty > 0
          ? 'Freeze limit: ${optionFlash.freezeQty ~/ optionFlash.lotSize} lots (${optionFlash.freezeQty} qty)'
          : '',
      child: SizedBox(
        width: 75,
        child: MyntTextField(
          controller: (_qtyController ??= TextEditingController(text: optionFlash.qtyLots.toString())),
          height: 35,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          borderRadius: 5,
          borderColor: hasError ? MyntColors.loss : null,
          textStyle: MyntWebTextStyles.bodySmall(
            context,
            darkColor: hasError ? MyntColors.loss : MyntColors.textWhite,
            lightColor: hasError ? MyntColors.loss : MyntColors.textBlack,
            fontWeight: MyntFonts.medium,
          ),
          placeholder: optionFlash.qtyLots.toString(),
          placeholderStyle: MyntWebTextStyles.bodySmall(
            context,
            darkColor: const Color(0xFF999999),
            lightColor: Colors.grey[600],
          ),
          onChanged: (value) {
            final qty = int.tryParse(value);
            final previousError = optionFlash.qtyError;
            // Allow setting 0 or empty to trigger validation error
            optionFlash.setQtyLots(qty ?? 0);
            // Show toast if a new error occurred
            if (optionFlash.qtyError != null && optionFlash.qtyError != previousError) {
              ResponsiveSnackBar.showError(context, optionFlash.qtyError!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPriceInput(OptionFlashProvider optionFlash, bool isDark) {
    final isDisabled = optionFlash.priceType == 'MKT';
    final hasError = !isDisabled && optionFlash.priceError != null;

    // Build tooltip message with circuit info (only show circuit limits, not errors)
    String tooltipMessage = '';
    if (optionFlash.upperCircuit > 0 || optionFlash.lowerCircuit > 0) {
      tooltipMessage = 'Circuit: ₹${optionFlash.lowerCircuit.toStringAsFixed(2)} - ₹${optionFlash.upperCircuit.toStringAsFixed(2)}';
    }

    // Initialize controller if not already created
    _priceController ??= TextEditingController(text: isDisabled ? '0' : optionFlash.price.toStringAsFixed(2));

    // Get current strike token for change detection
    final currentStrikeToken = optionFlash.selectedStrike?.option.token;
    final currentPriceType = optionFlash.priceType;

    // Detect price type change (MKT <-> LMT)
    if (_lastPriceType != null && _lastPriceType != currentPriceType) {
      if (isDisabled) {
        // Switched to MKT - show '0'
        _priceController!.text = '0';
      } else {
        // Switched to LMT - show strike LTP
        _priceController!.text = optionFlash.price.toStringAsFixed(2);
      }
    }
    // Detect strike change or new strike selected - update price to strike's LTP (only in LMT mode)
    // This handles: symbol change (null -> new), expiry change (old -> new), manual strike selection
    else if (!isDisabled && currentStrikeToken != null && _lastStrikeToken != currentStrikeToken) {
      _priceController!.text = optionFlash.price.toStringAsFixed(2);
    }
    // When MKT mode (disabled), always show '0'
    else if (isDisabled && _priceController!.text != '0') {
      _priceController!.text = '0';
    }

    // Update tracking variables
    _lastStrikeToken = currentStrikeToken;
    _lastPriceType = currentPriceType;

    return Tooltip(
      message: tooltipMessage,
      child: SizedBox(
        width: 100,
        child: MyntTextField(
          controller: _priceController,
          enabled: !isDisabled,
          height: 35,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))],
          textAlign: TextAlign.center,
          borderRadius: 5,
          borderColor: hasError ? MyntColors.loss : null,
          textStyle: MyntWebTextStyles.bodySmall(
            context,
            darkColor: hasError ? MyntColors.loss : MyntColors.textWhite,
            lightColor: hasError ? MyntColors.loss : MyntColors.textBlack,
            fontWeight: MyntFonts.medium,
          ),
          placeholder: optionFlash.price.toStringAsFixed(2),
          placeholderStyle: MyntWebTextStyles.bodySmall(
            context,
            darkColor: const Color(0xFF999999),
            lightColor: Colors.grey[600],
          ),
          onChanged: (value) {
            final price = double.tryParse(value);
            final previousError = optionFlash.priceError;

            // Allow setting 0 or empty to trigger validation error for LMT
            optionFlash.setPrice(price ?? 0);
            // Show toast if a new error occurred
            if (optionFlash.priceError != null && optionFlash.priceError != previousError) {
              ResponsiveSnackBar.showError(context, optionFlash.priceError!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, OptionFlashProvider optionFlash) {
    final hasValidationErrors = !optionFlash.isQtyValid || !optionFlash.isPriceValid;
    final isDisabled = optionFlash.orderLoading || hasValidationErrors;

    return ElevatedButton(
        onPressed: isDisabled ? null : () => optionFlash.placeQuickOrder(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasValidationErrors
              ? (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF444444)
                  : Colors.grey[400])
              : resolveThemeColor(context, dark: MyntColors.secondary, light: MyntColors.primary),
          foregroundColor: Colors.white,
          fixedSize: const Size(80, 33),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 0,
        ),
        child: optionFlash.orderLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                'SUBMIT',
                style: MyntWebTextStyles.buttonMd(
                  context,
                  color: Colors.white,
                ),
              ),
    );
  }
}
