import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../models/marketwatch_model/scrip_info.dart';
import '../../../models/order_book_model/gtt_order_book.dart';
import '../../../models/order_book_model/place_gtt_order.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/network_state_provider.dart';
import '../../../provider/order_input_provider.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/no_internet_widget.dart';
import '../../../sharedWidget/snack_bar.dart';

// InheritedWidget to pass close callback to child widgets
class _ModifyGttDialogCloseNotifier extends InheritedWidget {
  final VoidCallback onClose;

  const _ModifyGttDialogCloseNotifier({
    required this.onClose,
    required super.child,
  });

  static _ModifyGttDialogCloseNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ModifyGttDialogCloseNotifier>();
  }

  @override
  bool updateShouldNotify(_ModifyGttDialogCloseNotifier oldWidget) {
    return onClose != oldWidget.onClose;
  }
}

// InheritedWidget to pass drag callbacks to child widgets
class _ModifyGttDialogDragNotifier extends InheritedWidget {
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final bool isDragging;

  const _ModifyGttDialogDragNotifier({
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.isDragging,
    required super.child,
  });

  static _ModifyGttDialogDragNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ModifyGttDialogDragNotifier>();
  }

  @override
  bool updateShouldNotify(_ModifyGttDialogDragNotifier oldWidget) {
    return onPanStart != oldWidget.onPanStart ||
        onPanUpdate != oldWidget.onPanUpdate ||
        onPanEnd != oldWidget.onPanEnd ||
        isDragging != oldWidget.isDragging;
  }
}

class ModifyGttWeb extends ConsumerStatefulWidget {
  final GttOrderBookModel gttOrderBook;
  final ScripInfoModel scripInfo;
  
  const ModifyGttWeb({
    super.key,
    required this.scripInfo,
    required this.gttOrderBook,
  });

  @override
  ConsumerState<ModifyGttWeb> createState() => _ModifyGttWebState();

  /// Static method to show ModifyGttWeb as a draggable dialog
  static void showDraggable({
    required BuildContext context,
    required GttOrderBookModel gttOrderBook,
    required ScripInfoModel scripInfo,
    Offset? initialPosition,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry overlayEntry;
    
    final position = initialPosition ?? Offset(
      MediaQuery.of(context).size.width * 0.1,
      MediaQuery.of(context).size.height * 0.05,
    );
    
    overlayEntry = OverlayEntry(
      maintainState: false,
      builder: (context) => _DraggableModifyGttDialog(
        gttOrderBook: gttOrderBook,
        scripInfo: scripInfo,
        initialPosition: position,
        onPositionChanged: (newPosition) {
          // Position can be saved if needed
        },
        onClose: () {
          // Remove overlay immediately for quick response
          if (overlayEntry.mounted) {
            overlayEntry.remove();
          }
        },
      ),
    );
    
    overlay.insert(overlayEntry);
  }
}

class _ModifyGttWebState extends ConsumerState<ModifyGttWeb> {
  bool? isBuy;
  bool isOco = false;
  bool isGtt = true;
  String product = "I";
  int lotSize = 0;
  int multiplayer = 0;
  String price = "0.00";
  bool _GTTPriceTypeIsMarket = false;
  bool _GTTOCOPriceTypeIsMarket = false;
  
  // For real-time LTP updates
  String? currentLtp;
  String? currentChange;
  String? currentPerChange;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordInputProvider).getModifyData(widget.gttOrderBook);
    });

    setState(() {
      isOco = widget.gttOrderBook.placeOrderParamsLeg2 != null;
      lotSize = int.parse("${widget.scripInfo.ls ?? 0}");
      isBuy = widget.gttOrderBook.trantype == "B";

      multiplayer = int.parse((widget.gttOrderBook.exch == "MCX"
              ? widget.scripInfo.prcqqty
              : widget.gttOrderBook.ls)
          .toString());

      product = "I";
      
      // Initialize LTP from order book
      currentLtp = widget.gttOrderBook.ltp ?? widget.gttOrderBook.prc ?? "0.00";
      currentChange = widget.gttOrderBook.change ?? "0.00";
      currentPerChange = widget.gttOrderBook.perChange ?? "0.00";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final internet = ref.watch(networkStateProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        // Get updated LTP, change, and perChange from websocket if available
        String? updatedLtp = currentLtp;
        String? updatedChange = currentChange;
        String? updatedPerChange = currentPerChange;
        
        if (widget.gttOrderBook.token != null && socketDatas.containsKey(widget.gttOrderBook.token)) {
          final socketData = socketDatas[widget.gttOrderBook.token];
          if (socketData != null) {
            final lp = socketData['lp']?.toString();
            final pc = socketData['pc']?.toString();
            final chng = socketData['chng']?.toString();
            
            if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
              updatedLtp = lp;
            }
            
            if (pc != null && pc != "null" && pc != "0" && pc != "0.00") {
              updatedPerChange = pc;
            }
            
            if (chng != null && chng != "null") {
              updatedChange = chng;
            }
          }
        }
        
        // Update state variables if changed
        if (updatedLtp != currentLtp || updatedChange != currentChange || updatedPerChange != currentPerChange) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                currentLtp = updatedLtp;
                currentChange = updatedChange;
                currentPerChange = updatedPerChange;
              });
            }
          });
        }
        
        return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        ref.read(ordInputProvider).clearTextField();
        await ref
            .read(marketWatchProvider)
            .requestMWScrip(context: context, isSubscribe: true);
      },
      child: Container(
        width: 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(theme),
            
            // Content
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Symbol and Exchange Info
                      // _buildSymbolSection(theme),
                      // const SizedBox(height: 24),
                      
                      // Trigger Price Section
                      _buildTriggerPriceSection(theme),
                      const SizedBox(height: 24),
                      
                      // Qty and Price Section
                      _buildQtyPriceSection(theme),
                      const SizedBox(height: 24),
                      
                      // OCO Section (if applicable)
                      if (isOco) ...[
                        _buildOcoTriggerSection(theme),
                        const SizedBox(height: 24),
                        _buildOcoQtyPriceSection(theme),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer with Modify Button
            if (internet.connectionStatus == ConnectivityResult.none)
              const NoInternetWidget()
            else
              _buildFooter(theme),
          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    final symbol = widget.gttOrderBook.symbol?.replaceAll("-EQ", "").toUpperCase() ?? widget.scripInfo.symbol ?? '';
    final expDate = widget.gttOrderBook.expDate ?? widget.scripInfo.expDate ?? '';
    final option = widget.gttOrderBook.option ?? widget.scripInfo.option ?? '';
    final exchange = widget.gttOrderBook.exch ?? widget.scripInfo.exch ?? '';
    
    final ltp = currentLtp ?? widget.gttOrderBook.ltp ?? widget.gttOrderBook.prc ?? '0.00';
    final change = currentChange ?? widget.gttOrderBook.change ?? '0.00';
    final perChange = currentPerChange ?? widget.gttOrderBook.perChange ?? '0.00';
    
    // Get drag notifier for header dragging
    final dragNotifier = _ModifyGttDialogDragNotifier.of(context);
    
    Widget headerContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Symbol and Exchange
                Row(
                  children: [
                    Text(
                      "$symbol $expDate $option ",
                      style: WebTextStyles.symbolList(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exchange,
                      style: WebTextStyles.exchText(
                          isDarkTheme: theme.isDarkMode,
                          color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Price and Change
                Row(
                  children: [
                    Text(
                      ltp,
                      style: WebTextStyles.priceWatch(
                        isDarkTheme: theme.isDarkMode,
                        color: (change == "null" || change == "0.00")
                            ? (theme.isDarkMode
                                ? WebDarkColors.textSecondary
                                : WebColors.textSecondary)
                            : (change.startsWith("-") == true || perChange.startsWith("-") == true)
                                ? (theme.isDarkMode
                                    ? WebDarkColors.loss
                                    : WebColors.loss)
                                : (theme.isDarkMode
                                    ? WebDarkColors.profit
                                    : WebColors.profit),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${(double.tryParse(change) ?? 0.00).toStringAsFixed(2)} ($perChange%)",
                      style: WebTextStyles.pricePercent(
                        isDarkTheme: theme.isDarkMode,
                        color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
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
                ref.read(ordInputProvider).clearTextField();
                // Try to use draggable dialog close callback, fallback to Navigator.pop
                final closeNotifier = _ModifyGttDialogCloseNotifier.of(context);
                if (closeNotifier != null) {
                  closeNotifier.onClose();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
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
    );
    
    // Wrap with drag functionality if drag notifier is available
    if (dragNotifier != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          onPanStart: dragNotifier.onPanStart,
          onPanUpdate: dragNotifier.onPanUpdate,
          onPanEnd: dragNotifier.onPanEnd,
          child: headerContent,
        ),
      );
    }
    
    return headerContent;
  }

  Widget _buildSymbolSection(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LTP",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentLtp ?? widget.gttOrderBook.ltp ?? widget.gttOrderBook.prc ?? '0.00',
                style: WebTextStyles.title(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  fontWeight: WebFonts.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lot Size",
                style: WebTextStyles.para(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$lotSize",
                style: WebTextStyles.title(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  fontWeight: WebFonts.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerPriceSection(ThemesProvider theme) {
    final orderInput = ref.watch(ordInputProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOco ? "Target Trigger Price" : "Trigger Price",
          style: WebTextStyles.formLabel(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: CustomTextFormField(
            fillColor: theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary,
            onChanged: (value) {
              double inputPrice = double.tryParse(value) ?? 0;

              if (value.isNotEmpty && inputPrice > 0) {
                final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                if (!regex.hasMatch(value)) {
                  orderInput.val1Ctrl.text = value.substring(0, value.length - 1);
                  orderInput.val1Ctrl.selection = TextSelection.collapsed(
                    offset: orderInput.val1Ctrl.text.length,
                  );
                }
              }
              if (value.isEmpty || inputPrice <= 0) {
                showResponsiveWarningMessage(
                  context,
                  "Trigger Price can not be ${inputPrice <= 0 ? 'zero' : 'empty'}",
                );
              }
            },
            hintText: "${widget.gttOrderBook.ltp}",
            hintStyle: WebTextStyles.helperText(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: WebTextStyles.formInput(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
            textCtrl: orderInput.val1Ctrl,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildQtyPriceSection(ThemesProvider theme) {
    final orderInput = ref.watch(ordInputProvider);
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Qty",
                style: WebTextStyles.formLabel(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary,
                  hintText: orderInput.qtyCtrl.text,
                  hintStyle: WebTextStyles.helperText(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                  ),
                  inputFormate: [FilteringTextInputFormatter.digitsOnly],
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                  textCtrl: orderInput.qtyCtrl,
                  textAlign: TextAlign.start,
                  onChanged: (value) {
                    if (value.isEmpty || value == "0") {
                      showResponsiveWarningMessage(
                        context,
                        "Quantity can not be ${value == "0" ? 'zero' : 'empty'}",
                      );
                    } else {
                      String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (newValue != value) {
                        orderInput.qtyCtrl.text = newValue;
                        orderInput.qtyCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Price",
                    style: WebTextStyles.formLabel(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${orderInput.actPrcType}",
                    style: WebTextStyles.formLabel(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      showResponsiveWarningMessage(context, "Price can not be empty");
                    } else {
                      setState(() {
                        price = value;
                      });
                    }
                  },
                  hintText: "${widget.gttOrderBook.placeOrderParams!.prc}",
                  hintStyle: WebTextStyles.helperText(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                  ),
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                  isReadable: orderInput.actPrcType == "Limit" ||
                      orderInput.actPrcType == "SL Limit"
                      ? false
                      : true,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _GTTPriceTypeIsMarket = !_GTTPriceTypeIsMarket;
                        orderInput.chngGTTPriceType(
                          _GTTPriceTypeIsMarket ? "Market" : "Limit",
                        );
                        if (orderInput.actPrcType == "Market" ||
                            orderInput.actPrcType == "SL MKT") {
                          orderInput.priceCtrl.text = "Market";
                        } else {
                          orderInput.priceCtrl.text = "${widget.gttOrderBook.ltp}";
                        }
                      });
                    },
                    child: SvgPicture.asset(
                      assets.switchIcon,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  textCtrl: orderInput.priceCtrl,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOcoTriggerSection(ThemesProvider theme) {
    final orderInput = ref.watch(ordInputProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isOco ? "Stoploss Trigger Price" : "Trigger Price",
          style: WebTextStyles.formLabel(
            isDarkTheme: theme.isDarkMode,
            color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: CustomTextFormField(
            fillColor: theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary,
            onChanged: (value) {
              double inputPrice = double.tryParse(value) ?? 0;

              if (value.isNotEmpty && inputPrice > 0) {
                final regex = RegExp(r'^(\d+)?(\.\d{0,2})?$');
                if (!regex.hasMatch(value)) {
                  orderInput.val2Ctrl.text = value.substring(0, value.length - 1);
                  orderInput.val2Ctrl.selection = TextSelection.collapsed(
                    offset: orderInput.val2Ctrl.text.length,
                  );
                }
              }
              if (value.isEmpty || inputPrice <= 0) {
                showResponsiveWarningMessage(
                  context,
                  "Trigger Price can not be ${inputPrice <= 0 ? 'zero' : 'empty'}",
                );
              }
            },
            hintText: "${widget.gttOrderBook.ltp}",
            hintStyle: WebTextStyles.helperText(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: WebTextStyles.formInput(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
            textCtrl: orderInput.val2Ctrl,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildOcoQtyPriceSection(ThemesProvider theme) {
    final orderInput = ref.watch(ordInputProvider);
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Qty",
                style: WebTextStyles.formLabel(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary,
                  hintText: orderInput.ocoQtyCtrl.text,
                  hintStyle: WebTextStyles.helperText(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                  ),
                  inputFormate: [FilteringTextInputFormatter.digitsOnly],
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                  textCtrl: orderInput.ocoQtyCtrl,
                  textAlign: TextAlign.start,
                  onChanged: (value) {
                    if (value.isEmpty || value == "0") {
                      showResponsiveWarningMessage(
                        context,
                        "Quantity can not be ${value == "0" ? 'zero' : 'empty'}",
                      );
                    } else {
                      String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (newValue != value) {
                        orderInput.ocoQtyCtrl.text = newValue;
                        orderInput.ocoQtyCtrl.selection = TextSelection.fromPosition(
                          TextPosition(offset: newValue.length),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Price",
                    style: WebTextStyles.formLabel(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${orderInput.actOcoPrcType}",
                    style: WebTextStyles.sub(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode ? WebDarkColors.icon : WebColors.icon,
                      fontWeight: WebFonts.semiBold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? WebDarkColors.backgroundTertiary : WebColors.backgroundTertiary,
                  onChanged: (value) {},
                  hintText: "${widget.gttOrderBook.placeOrderParamsLeg2!.prc}",
                  hintStyle: WebTextStyles.helperText(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
                  ),
                  style: WebTextStyles.formInput(
                    isDarkTheme: theme.isDarkMode,
                    color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
                  ),
                  isReadable: orderInput.actOcoPrcType == "Limit" ||
                      orderInput.actOcoPrcType == "SL Limit"
                      ? false
                      : true,
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _GTTOCOPriceTypeIsMarket = !_GTTOCOPriceTypeIsMarket;
                        orderInput.chngOCOPriceType(
                          _GTTOCOPriceTypeIsMarket ? "Market" : "Limit",
                        );
                        if (orderInput.actOcoPrcType == "Market" ||
                            orderInput.actOcoPrcType == "SL MKT") {
                          orderInput.ocoPriceCtrl.text = "Market";
                        } else {
                          orderInput.ocoPriceCtrl.text = "${widget.gttOrderBook.ltp}";
                        }
                      });
                    },
                    child: SvgPicture.asset(
                      assets.switchIcon,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  textCtrl: orderInput.ocoPriceCtrl,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemesProvider theme) {
    final orderInput = ref.watch(ordInputProvider);
    final internet = ref.watch(networkStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: internet.connectionStatus == ConnectivityResult.none ||
              ref.read(orderProvider).loading
              ? null
              : () async {
                  if (orderInput.disableGTTCond) {
                    if ((orderInput.val1Ctrl.text.isNotEmpty &&
                            orderInput.val2Ctrl.text.isNotEmpty &&
                            orderInput.priceCtrl.text.isNotEmpty &&
                            orderInput.ocoPriceCtrl.text.isNotEmpty &&
                            orderInput.ocoQtyCtrl.text.isNotEmpty) &&
                        orderInput.qtyCtrl.text.isNotEmpty) {
                      double ltp = double.parse(widget.gttOrderBook.ltp ?? "0.00");
                      double val1 = double.parse(orderInput.val1Ctrl.text);
                      double val2 = double.parse(orderInput.val2Ctrl.text);

                      if (val1 > ltp && val2 < ltp) {
                        prepareToModifyOCOOrder(orderInput);
                      } else {
                        showResponsiveWarningMessage(
                          context,
                          val1 <= ltp
                              ? "Target Trigger Price can not be Less than LTP"
                              : val2 >= ltp
                                  ? "Stoploss Trigger Price can not be Greater than LTP"
                                  : "Trigger Price can not be equal to LTP",
                        );
                      }
                    } else {
                      showResponsiveWarningMessage(context, "Enter all Input fields");
                    }
                  } else {
                    if ((orderInput.val1Ctrl.text.isNotEmpty &&
                            orderInput.priceCtrl.text.isNotEmpty) &&
                        orderInput.qtyCtrl.text.isNotEmpty) {
                      double ltp = double.parse(widget.gttOrderBook.ltp ?? "0.00");
                      double val1 = double.parse(orderInput.val1Ctrl.text);

                      if (val1 > ltp) {
                        prepareToModifyGttOrder(orderInput);
                      } else {
                        showResponsiveWarningMessage(
                          context,
                          "Trigger Price can not be equal to LTP",
                        );
                      }
                    } else {
                      showResponsiveWarningMessage(context, "Enter all Input fields");
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            backgroundColor: isBuy! 
                ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
                : (theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary),
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: ref.read(orderProvider).loading
              ? const SizedBox(
                  width: 18,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xff666666),
                  ),
                )
              : Text(
                  "Modify",
                  style: WebTextStyles.buttonMd(
                    isDarkTheme: theme.isDarkMode,
                    color: WebColors.background,
                    fontWeight: WebFonts.bold,
                  ),
                ),
        ),
      ),
    );
  }

  prepareToModifyGttOrder(OrderInputProvider orderInput) async {
    PlaceGTTOrderInput input = PlaceGTTOrderInput(
      exch: '${widget.gttOrderBook.exch}',
      qty: orderInput.qtyCtrl.text,
      tsym: '${widget.gttOrderBook.tsym}',
      validity: "GTT",
      prc: orderInput.priceCtrl.text,
      prd: orderInput.orderType,
      trantype: isBuy! ? 'B' : "S",
      ret: 'DAY',
      ait: orderInput.ait,
      d: orderInput.val1Ctrl.text,
      prctyp: orderInput.prcType,
      remarks: orderInput.reMarksCtrl.text,
      trgprc: orderInput.actPrcType == "SL Limit" || orderInput.actPrcType == "SL MKT"
          ? orderInput.trgPrcCtrl.text
          : "",
      alid: '${widget.gttOrderBook.alId}',
    );
    
    // Get the result before calling modify
    final orderProv = ref.read(orderProvider);
    
    // Close the draggable dialog callback (get it before the async call)
    final closeNotifier = _ModifyGttDialogCloseNotifier.of(context);
    
    await orderProv.modifyGTTOrder(input, context);
    
    // Check if modification was successful by checking the model
    final modifyResult = orderProv.modifyGttOrderModel;
    final wasSuccessful = modifyResult?.stat == "OI replaced";
    
    // Close the draggable dialog immediately if modification was successful
    // Close right away to prevent user from seeing cleared fields
    if (wasSuccessful && closeNotifier != null && mounted) {
      // Close immediately - don't wait
      closeNotifier.onClose();
    }
  }

  prepareToModifyOCOOrder(OrderInputProvider orderInput) async {
    PlaceOcoOrderInput input = PlaceOcoOrderInput(
      exch: '${widget.gttOrderBook.exch}',
      tsym: '${widget.gttOrderBook.tsym}',
      validity: "GTT",
      trantype: isBuy! ? 'B' : "S",
      ret: 'DAY',
      remarks: orderInput.reMarksCtrl.text,
      qty1: orderInput.qtyCtrl.text,
      trgprc1: orderInput.actOcoPrcType == "SL Limit" || orderInput.actOcoPrcType == "SL MKT"
          ? orderInput.trgPrcCtrl.text
          : "",
      prc1: orderInput.priceCtrl.text,
      prd1: orderInput.orderType,
      d1: orderInput.val1Ctrl.text,
      prctyp1: orderInput.prcType,
      d2: orderInput.val2Ctrl.text,
      prctyp2: orderInput.ocoPrcType,
      prc2: orderInput.ocoPriceCtrl.text,
      prd2: orderInput.ocoOrderType,
      qty2: orderInput.ocoQtyCtrl.text,
      trgprc2: orderInput.actOcoPrcType == "SL Limit" || orderInput.actOcoPrcType == "SL MKT"
          ? orderInput.ocoTrgPrcCtrl.text
          : "",
      alid: '${widget.gttOrderBook.alId}',
    );
    
    // Get the result before calling modify
    final orderProv = ref.read(orderProvider);
    
    // Close the draggable dialog callback (get it before the async call)
    final closeNotifier = _ModifyGttDialogCloseNotifier.of(context);
    
    await orderProv.modifyOCOOrder(input, context);
    
    // Check if modification was successful by checking the model
    final modifyResult = orderProv.modifyGttOrderModel;
    final wasSuccessful = modifyResult?.stat == "OI replaced";
    
    // Close the draggable dialog immediately if modification was successful
    // Close right away to prevent user from seeing cleared fields
    if (wasSuccessful && closeNotifier != null && mounted) {
      // Close immediately - don't wait
      closeNotifier.onClose();
    }
  }

}

// Draggable Modify GTT Dialog Widget
class _DraggableModifyGttDialog extends ConsumerStatefulWidget {
  final GttOrderBookModel gttOrderBook;
  final ScripInfoModel scripInfo;
  final Offset initialPosition;
  final Function(Offset) onPositionChanged;
  final VoidCallback onClose;

  const _DraggableModifyGttDialog({
    required this.gttOrderBook,
    required this.scripInfo,
    required this.initialPosition,
    required this.onPositionChanged,
    required this.onClose,
  });

  @override
  ConsumerState<_DraggableModifyGttDialog> createState() => _DraggableModifyGttDialogState();
}

class _DraggableModifyGttDialogState extends ConsumerState<_DraggableModifyGttDialog> {
  late Offset _position;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final screenSize = MediaQuery.of(context).size;

    // Constrain position to screen bounds
    final dialogWidth = 400.0;
    final dialogHeight = screenSize.height * 0.5;
    final constrainedPosition = Offset(
      _position.dx.clamp(0, screenSize.width - dialogWidth),
      _position.dy.clamp(0, screenSize.height - dialogHeight),
    );

    return Stack(
      children: [
        // Actual dialog
        Positioned(
          left: constrainedPosition.dx,
          top: constrainedPosition.dy,
          child: GestureDetector(
            onTap: () {}, // Prevent tap from propagating to background
            child: Material(
              elevation: _isDragging ? 16 : 8,
              borderRadius: BorderRadius.circular(5),
              color: theme.isDarkMode ? WebDarkColors.background : WebColors.background,
              child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
                  ),
                ),
                child: _ModifyGttDialogCloseNotifier(
                  onClose: widget.onClose,
                  child: _ModifyGttDialogDragNotifier(
                    onPanStart: (details) {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _position = Offset(
                          _position.dx + details.delta.dx,
                          _position.dy + details.delta.dy,
                        );
                      });
                      widget.onPositionChanged(_position);
                    },
                    onPanEnd: (details) {
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    isDragging: _isDragging,
                    child: ModifyGttWeb(
                      gttOrderBook: widget.gttOrderBook,
                      scripInfo: widget.scripInfo,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
