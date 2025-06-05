import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../models/portfolio_model/holdings_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/alert_dialogue.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/scrip_info_btns.dart';

// Create a wrapper for ScripInfoBtns with navigation lock
class ScripInfoButtonsWithLock extends StatefulWidget {
  final String exch;
  final String token;
  final String insName;
  final String tsym;

  const ScripInfoButtonsWithLock({
    Key? key,
    required this.exch,
    required this.token,
    required this.insName,
    required this.tsym,
  }) : super(key: key);

  @override
  State<ScripInfoButtonsWithLock> createState() => _ScripInfoButtonsWithLockState();
}

class _ScripInfoButtonsWithLockState extends State<ScripInfoButtonsWithLock> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return ScripInfoBtns(
      exch: widget.exch,
      token: widget.token,
      insName: widget.insName,
      tsym: widget.tsym,
      navigationLock: (Function callback) async {
        if (_isNavigating) return;
        
        try {
          setState(() {
            _isNavigating = true;
          });
          
          await callback();
        } finally {
          // Reset the navigation lock after a delay
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
    );
  }
}

class HoldingDetailScreen extends ConsumerStatefulWidget {
  final ExchTsym exchTsym;
  final HoldingsModel holdingData;
  
  const HoldingDetailScreen({
    Key? key, 
    required this.exchTsym, 
    required this.holdingData
  }) : super(key: key);

  @override
  ConsumerState<HoldingDetailScreen> createState() => _HoldingDetailScreenState();
}

class _HoldingDetailScreenState extends ConsumerState<HoldingDetailScreen> with SingleTickerProviderStateMixin {
  StreamSubscription? _socketSubscription;
  late ExchTsym _exchTsym;
  late HoldingsModel _holdingData;
  
  // Track touch events to prevent multiple button presses
  bool _isProcessingBuy = false;
  bool _isProcessingSell = false;
  
  // Added for optimization
  bool _isInitialized = false;
  bool _isLoading = true;
  
  // Add animation controller for smooth transitions
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    // Make copies of the data to avoid modifying the original objects
    _exchTsym = _copyExchTsym(widget.exchTsym);
    _holdingData = widget.holdingData;
    
    // Set up animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Don't pre-load data here - moved to didChangeDependencies
    setState(() {
      _isLoading = true;
    });
  }
  
  bool _didInitDependencies = false;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only run this once
    if (!_didInitDependencies) {
      _didInitDependencies = true;
      
      // Use a microtask to ensure widget is fully mounted
      Future.microtask(() {
        if (mounted) {
          _preLoadData();
        }
      });
    }
  }
  
  // Pre-load data to avoid flickering
  Future<void> _preLoadData() async {
    if (!mounted) return;
    
    // Get the latest socket data for this token immediately
    final wsProvider = ProviderScope.containerOf(context).read(websocketProvider);
    final socketData = wsProvider.socketDatas[_exchTsym.token];
    
    if (socketData != null) {
      // Update with initial socket data
      final lp = socketData['lp']?.toString();
      final pc = socketData['pc']?.toString();
      final chng = socketData['chng']?.toString();
      final c = socketData['c']?.toString();
      
      if (lp != null && lp != "null") {
        _exchTsym.lp = lp;
      }
      
      if (pc != null && pc != "null") {
        _exchTsym.perChange = pc;
      }
      
      if (chng != null && chng != "null") {
        _exchTsym.change = chng;
      }
      
      if (c != null && c != "null") {
        _exchTsym.close = c;
      }
      
      _updateProfitLossValues();
    }
    
    // Set up socket subscription only after initial data is set
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _setupSocketSubscription();
        setState(() {
          _isLoading = false;
          _isInitialized = true;
        });
        _animationController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _socketSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }
  
  // Create a copy of the ExchTsym to avoid modifying the original
  ExchTsym _copyExchTsym(ExchTsym original) {
    final copy = ExchTsym();
    copy.token = original.token;
    copy.exch = original.exch;
    copy.tsym = original.tsym;
    copy.lp = original.lp;
    copy.perChange = original.perChange;
    copy.change = original.change;
    copy.close = original.close;
    copy.profitNloss = original.profitNloss;
    copy.pNlChng = original.pNlChng;
    copy.ls = original.ls;
    return copy;
  }
  
  // Set up the socket subscription
  void _setupSocketSubscription() {
    if (!mounted) return;
    
    try {
      final wsProvider = ProviderScope.containerOf(context).read(websocketProvider);
      
      _socketSubscription = wsProvider.socketDataStream.listen((socketData) {
        if (!mounted) return;
        
        final data = socketData[_exchTsym.token];
        if (data != null) {
          // Update with incremental socket data
          setState(() {
            final lp = data['lp']?.toString();
            final pc = data['pc']?.toString();
            final chng = data['chng']?.toString();
            
            if (_isValidValue(lp)) _exchTsym.lp = lp;
            if (_isValidValue(pc)) _exchTsym.perChange = pc;
            if (_isValidValue(chng)) _exchTsym.change = chng;
            
            _updateProfitLossValues();
          });
        }
      });
    } catch (e) {
      print("Error setting up socket subscription: $e");
    }
  }
  
  // Helper method to check if a value is valid
  bool _isValidValue(String? value) {
    return value != null && 
           value != "null" && 
           value != "0" && 
           value != "0.0" && 
           value != "0.00";
  }
  
  // Calculate profit and loss values
  void _updateProfitLossValues() {
    final ltp = double.tryParse(_exchTsym.lp ?? "0.0") ?? 0.0;
    final qty = _holdingData.currentQty ?? 0;
    final avgPrice = double.tryParse(_holdingData.upldprc ?? "0.0") ?? 0.0;
    
    if (ltp > 0 && qty > 0 && avgPrice > 0) {
      // Current value
      _holdingData.currentValue = (ltp * qty).toStringAsFixed(2);
      
      // Profit/Loss
      final pnl = (ltp - avgPrice) * qty;
      _exchTsym.profitNloss = pnl.toStringAsFixed(2);
      
      // P&L Percentage
      if (avgPrice > 0) {
        final pnlPerc = (pnl / (avgPrice * qty)) * 100;
        _exchTsym.pNlChng = pnlPerc.toStringAsFixed(2);
      }
    }
  }
  
  // Handle buy button click
  Future<void> _handleBuy() async {
    if (_isProcessingBuy) return;
    
    try {
      setState(() {
        _isProcessingBuy = true;
      });
      
      final wsProvider = ProviderScope.containerOf(context).read(websocketProvider);
      final mwProvider = ProviderScope.containerOf(context).read(marketWatchProvider);
      
      wsProvider.establishConnection(
        channelInput: "${_exchTsym.exch}|${_exchTsym.token}#",
        task: "t",
        context: context
      );
      
      await mwProvider.fetchScripInfo(
        "${_exchTsym.token}",
        '${_exchTsym.exch}',
        context,
        true
      );
      
      if (!mounted) return;
      
      final OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: '${_exchTsym.exch}',
        tSym: '${_exchTsym.tsym}',
        token: '',
        transType: true,
        prd: '${_holdingData.prd}',
        lotSize: '${_exchTsym.ls}',
        orderTpye: "${_holdingData.sPrdtAli}",
        isExit: false,
        ltp: '${_exchTsym.lp}',
        perChange: '${_exchTsym.perChange}',
        holdQty: '',
        isModify: false,
        raw: {}
      );
      
      Navigator.pushNamed(
        context,
        Routes.placeOrderScreen,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": mwProvider.scripInfoModel!,
          "isBskt": ""
        }
      ).then((_) {
        if (mounted) {
          setState(() {
            _isProcessingBuy = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingBuy = false;
        });
      }
    }
  }
  
  // Handle sell button click
  Future<void> _handleSell() async {
    if (_isProcessingSell) return;
    
    try {
      setState(() {
        _isProcessingSell = true;
      });
      
      if (_holdingData.saleableQty == 0) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialogue(
              scripName: "${_exchTsym.tsym}",
              exch: "${_exchTsym.exch}",
              content: 'You are unable to exit because there are no sellable quantity.',
            );
          }
        ).then((_) {
          if (mounted) {
            setState(() {
              _isProcessingSell = false;
            });
          }
        });
        return;
      }
      
      final wsProvider = ProviderScope.containerOf(context).read(websocketProvider);
      final mwProvider = ProviderScope.containerOf(context).read(marketWatchProvider);
      
      wsProvider.establishConnection(
        channelInput: "${_exchTsym.exch}|${_exchTsym.token}#",
        task: "t",
        context: context
      );
      
      await mwProvider.fetchScripInfo(
        "${_exchTsym.token}",
        '${_exchTsym.exch}',
        context,
        true
      );
      
      if (!mounted) return;
      
      final OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: '${_exchTsym.exch}',
        tSym: '${_exchTsym.tsym}',
        token: '',
        transType: false,
        lotSize: '${_exchTsym.ls}',
        isExit: true,
        ltp: '${_exchTsym.lp}',
        perChange: '${_exchTsym.perChange}',
        orderTpye: "${_holdingData.sPrdtAli}",
        holdQty: "${_holdingData.saleableQty ?? 0}",
        isModify: false,
        raw: {}
      );
      
      Navigator.pushNamed(
        context,
        Routes.placeOrderScreen,
        arguments: {
          "orderArg": orderArgs,
          "scripInfo": mwProvider.scripInfoModel!,
          "isBskt": ""
        }
      ).then((_) {
        if (mounted) {
          setState(() {
            _isProcessingSell = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessingSell = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    
    // Show loading state during initial load
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: .2,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          shadowColor: theme.isDarkMode
              ? colors.darkColorDivider
              : colors.colorDivider,
          title: Text("${_exchTsym.tsym}",
                  style: textStyles.appBarTitleTxt.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        elevation: .2,
        leadingWidth: 41,
        titleSpacing: 6,
        leading: const CustomBackBtn(),
        shadowColor: theme.isDarkMode
            ? colors.darkColorDivider
            : colors.colorDivider,
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${_exchTsym.tsym}",
                        style: textStyles.appBarTitleTxt.copyWith(
                            color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack)),
                    // Animate price changes
                    FadeTransition(
                      opacity: _animationController,
                      child: Text("₹${_exchTsym.lp}",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              16,
                              FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomExchBadge(exch: _exchTsym.exch!),
                      // Animate percentage changes
                      FadeTransition(
                        opacity: _animationController,
                        child: Text(
                            "${double.parse("${_exchTsym.change.toString() == "null" ? "0.00" : _exchTsym.change} ").toStringAsFixed(2)} (${_exchTsym.perChange.toString() == "null" ? "0.00" : _exchTsym.perChange}%)",
                            style: textStyle(
                                (_exchTsym.change == "null" ||
                                            _exchTsym.change == null) ||
                                        _exchTsym.change == "0.00"
                                    ? colors.ltpgrey
                                    : _exchTsym.change!.startsWith("-") ||
                                            _exchTsym.perChange!
                                                .startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                12,
                                FontWeight.w500)),
                      )
                    ])
              ]),
        )),
      body: ListView(children: [
        Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
                mainAxisAlignment: _holdingData.sPrdtAli != "null"
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  if (_holdingData.sPrdtAli != "null")
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: theme.isDarkMode
                                ? const Color(0xffB5C0CF).withOpacity(.15)
                                : const Color(0xffF1F3F8)),
                        child: Text("${_holdingData.sPrdtAli}",
                            overflow: TextOverflow.ellipsis,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500))),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("P&L",
                          style: textStyle(
                              const Color(0xff5E6B7D), 12, FontWeight.w500)),
                      const SizedBox(height: 4),
                      // Animate P&L changes
                      FadeTransition(
                        opacity: _animationController,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${_exchTsym.profitNloss}",
                                style: textStyle(
                                    _exchTsym.profitNloss!.startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                    16,
                                    FontWeight.w600)),
                            Text(" (${_exchTsym.pNlChng})%",
                                style: textStyle(
                                    _exchTsym.pNlChng!.startsWith("-")
                                        ? colors.darkred
                                        : colors.ltpgreen,
                                    14,
                                    FontWeight.w500)),
                          ],
                        ),
                      )
                    ],
                  ),
                ])),
        // Replace ScripInfoBtns with our wrapper that includes navigation lock
        ScripInfoButtonsWithLock(
            exch: '${_exchTsym.exch}',
            token: '${_exchTsym.token}',
            insName: '',
            tsym: '${_exchTsym.tsym}'),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text("Holding details",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          16,
                          FontWeight.w600)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sellable Qty",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              "${_holdingData.saleableQty ?? 0}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider)
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Avg.Price",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              "${_holdingData.upldprc ?? 0}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Non POA Qty",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              "${_holdingData.npoadqty ?? 0}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider)
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Invested",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              "${_holdingData.invested == "0.00" ? _exchTsym.close ?? 0.00 : _holdingData.invested ?? 0.00}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Divider(
                                color: theme.isDarkMode
                                    ? colors.darkColorDivider
                                    : colors.colorDivider)
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pledge Qty",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              "${_holdingData.brkcolqty ?? 0}",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Current Value",
                                style: textStyle(const Color(0xff666666), 12,
                                    FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(
                              (int.parse("${_holdingData.currentQty ?? 0}") *
                                      double.parse(
                                          _exchTsym.lp?.toString() ?? "0.0"))
                                  .toStringAsFixed(2),
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (_holdingData.btstqty != "0") ...[
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("T1 Qty",
                                  style: textStyle(const Color(0xff666666),
                                      12, FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text(
                                "${_holdingData.btstqty ?? 0}",
                                style: textStyle(const Color(0xff000000), 14,
                                    FontWeight.w500),
                              ),
                              const SizedBox(height: 2),
                              Divider(color: colors.colorDivider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ])),
      ]),
      bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: const CircularNotchedRectangle(),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(children: [
              Expanded(
                child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        color: _isProcessingBuy 
                            ? const Color(0xff43A833).withOpacity(0.7)
                            : const Color(0xff43A833),
                        borderRadius: BorderRadius.circular(32)),
                    width: MediaQuery.of(context).size.width,
                    child: InkWell(
                      onTap: _isProcessingBuy ? null : _handleBuy,
                      child: Center(
                          child: _isProcessingBuy
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  "Add More",
                                  style: textStyle(
                                      const Color(0xffFFFFFF), 14, FontWeight.w600)
                                )
                      ),
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                          color: _isProcessingSell || _holdingData.saleableQty == 0
                              ? colors.darkred.withOpacity(.8)
                              : colors.darkred,
                          borderRadius: BorderRadius.circular(32)),
                      width: MediaQuery.of(context).size.width,
                      child: InkWell(
                        onTap: _isProcessingSell ? null : _handleSell,
                        child: Center(
                            child: _isProcessingSell
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text(
                                    "Exit",
                                    style: textStyle(
                                        const Color(0xffFFFFFF), 14, FontWeight.w600)
                                  )
                        ),
                      )))
            ]),
          )),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
