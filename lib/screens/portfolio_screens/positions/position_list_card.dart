import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';

class PositionListCard extends ConsumerStatefulWidget {
  final PositionBookModel positionList;

  const PositionListCard({super.key, required this.positionList});

  @override
  ConsumerState<PositionListCard> createState() => _PositionListCardState();
}

class _PositionListCardState extends ConsumerState<PositionListCard> {
  StreamSubscription? _socketSubscription;
  late String _currentLp;
  bool _needsUpdate = false;
  
  // Cache text styles to avoid rebuilds
  final Map<String, TextStyle> _cachedStyles = {};
  
  @override
  void initState() {
    super.initState();
    _currentLp = widget.positionList.lp ?? '0.00';
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
        if (!socketData.containsKey(widget.positionList.token)) return;
        
        final data = socketData[widget.positionList.token];
        if (data == null) return;
        
        // Check if LTP actually changed
        final lp = data['lp']?.toString();
        if (lp != null && lp != "null" && lp != "0" && lp != "0.00" && lp != _currentLp) {
          widget.positionList.lp = lp;
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
  TextStyle _getStyle(Color color, double size, FontWeight weight, {String? key}) {
    final cacheKey = key ?? '${color.value}|$size|${weight.index}';
    if (!_cachedStyles.containsKey(cacheKey)) {
      _cachedStyles[cacheKey] = textStyle(color, size, weight);
    }
    return _cachedStyles[cacheKey]!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, _) {
      final positions = ref.watch(portfolioProvider);
      final theme = ref.read(themeProvider);
      
      // Calculate colors and values once
      final isZeroQty = widget.positionList.qty == "0";
      final netQtyZero = widget.positionList.netqty == "0";
      final bgColor = theme.isDarkMode
          ? isZeroQty ? colors.darkGrey : colors.colorBlack
          : Color(isZeroQty ? 0xffF1F3F8 : 0xffffffff);
      
      final ContainerColor = theme.isDarkMode
          ? isZeroQty ? colors.colorBlack : const Color(0xff666666).withOpacity(.2)
          : isZeroQty ? colors.colorWhite : const Color(0xffECEDEE);
      
      final dividerColor = theme.isDarkMode
          ? colors.darkGrey
          : Color(netQtyZero ? 0xffffffff : 0xffECEDEE);
      
      final txtColor = theme.isDarkMode
          ? colors.colorWhite
          : colors.colorBlack;
      
      // Get formatted quantity value
      final qty = "${((int.tryParse(widget.positionList.qty.toString()) ?? 0) / 
          (widget.positionList.exch == 'MCX' ? 
           (int.tryParse(widget.positionList.ls.toString()) ?? 1) : 1)).toInt()}";
      
      // Get PNL and determine its color
      final pnlValue = positions.isNetPnl
          ? "₹${widget.positionList.profitNloss ?? widget.positionList.rpnl}"
          : "₹${widget.positionList.mTm}";
          
      final pnlColor = _getPnlColor(positions.isNetPnl 
          ? (widget.positionList.profitNloss ?? widget.positionList.rpnl)
          : widget.positionList.mTm);
      
      // Get average price display value
      final avgPrice = positions.isDay
          ? "${widget.positionList.avgPrc}"
          : positions.isNetPnl
              ? "${widget.positionList.netupldprc}"
              : "${widget.positionList.netavgprc}";
      
      return Container(
        color: bgColor,
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildHeaderRow(theme, txtColor, ContainerColor),
              const SizedBox(height: 4),
              Divider(color: dividerColor, thickness: 1.2),
              const SizedBox(height: 2),
              _buildQuantityRow(txtColor, qty, pnlValue, pnlColor),
              const SizedBox(height: 10),
              _buildAveragePriceRow(txtColor, avgPrice),
            ]),
      );
    });
  }
  
  Color _getPnlColor(String? value) {
    if (value == null) return colors.ltpgrey;
    if (value.startsWith("-")) return colors.darkred;
    if (value == "0.00") return colors.ltpgrey;
    return colors.ltpgreen;
  }
  
  Widget _buildHeaderRow(ThemesProvider theme, Color txtColor, Color containerColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Row(children: [
          Text(
            "${widget.positionList.symbol} ${widget.positionList.expDate} ",
            overflow: TextOverflow.ellipsis,
            style: textStyles.scripNameTxtStyle.copyWith(color: txtColor),
          ),
          Text(
            "${widget.positionList.option} ",
            overflow: TextOverflow.ellipsis,
            style: textStyles.scripNameTxtStyle.copyWith(color: txtColor),
          ),
        ]),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: containerColor,
            ),
            child: Text(
              "${widget.positionList.exch}",
              overflow: TextOverflow.ellipsis,
              style: _getStyle(
                theme.isDarkMode ? colors.colorWhite : const Color(0xff666666),
                10,
                FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: containerColor,
            ),
            child: Text(
              "${widget.positionList.sPrdtAli}",
              overflow: TextOverflow.ellipsis,
              style: _getStyle(
                theme.isDarkMode ? colors.colorWhite : const Color(0xff666666),
                10,
                FontWeight.w500,
              ),
            ),
          ),
        ])
      ],
    );
  }
  
  Widget _buildQuantityRow(Color txtColor, String qty, String pnlValue, Color pnlColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Row(children: [
          Text(
            "Qty: ",
            style: _getStyle(const Color(0xff5E6B7D), 14, FontWeight.w500, key: 'qty-label'),
          ),
          Text(
            qty,
            style: _getStyle(txtColor, 14, FontWeight.w500, key: 'qty-value'),
          )
        ]),
        // Wrap the PNL in RepaintBoundary as it changes frequently
        RepaintBoundary(
          child: Text(
            pnlValue,
            style: _getStyle(pnlColor, 15, FontWeight.w600),
          ),
        )
      ],
    );
  }
  
  Widget _buildAveragePriceRow(Color txtColor, String avgPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Row(children: [
          Text(
            "Avg: ",
            style: _getStyle(const Color(0xff5E6B7D), 14, FontWeight.w500, key: 'avg-label'),
          ),
          Text(
            avgPrice,
            style: _getStyle(txtColor, 14, FontWeight.w500, key: 'avg-value'),
          )
        ]),
        // Wrap LTP in RepaintBoundary as it changes frequently
        RepaintBoundary(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: [
              Text(
                " LTP: ",
                style: _getStyle(const Color(0xff5E6B7D), 13, FontWeight.w600, key: 'ltp-label'),
              ),
              Text(
                "₹${widget.positionList.lp}",
                style: _getStyle(txtColor, 14, FontWeight.w500, key: 'ltp-value'),
              )
            ],
          ),
        ),
      ],
    );
  }
}

// Position item widget
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
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: widget.showLongPressOption 
        ? () {
            Navigator.pushNamed(
              context,
              Routes.positionExit
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
    final marketWatch = ref.read(marketWatchProvider);
    
    // Fetch linked scrip data
    await marketWatch.fetchLinkeScrip(
      "${widget.position.token}",
      "${widget.position.exch}",
      context
    );

    // Fetch scrip quote
    await ref.read(marketWatchProvider).fetchScripQuote(
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
