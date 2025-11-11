import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/no_internet_widget.dart';
import '../../../sharedWidget/snack_bar.dart';
import '../../../res/global_state_text.dart';

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
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            borderRadius: BorderRadius.circular(5),
            // border: Border.all(
            //   color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
            // ),
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
                    padding: const EdgeInsets.all(24),
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
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
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
                      style: TextWidget.textStyle(
                        fontSize: 16,
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                        fw: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode ? colors.primaryDark.withOpacity(0.7) : colors.primaryLight.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        exchange,
                        style: TextWidget.textStyle(
                          fontSize: 12,
                          theme: false,
                          color: colors.textPrimaryDark,
                          fw: 1,
                        ),
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
                      style: TextWidget.textStyle(
                        fontSize: 16,
                        theme: false,
                        color: (change == "null" || change == "0.00")
                            ? (theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight)
                            : (change.startsWith("-") == true || perChange.startsWith("-") == true)
                                ? (theme.isDarkMode
                                    ? colors.lossDark
                                    : colors.lossLight)
                                : (theme.isDarkMode
                                    ? colors.profitDark
                                    : colors.profitLight),
                        fw: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${(double.tryParse(change) ?? 0.00).toStringAsFixed(2)} ($perChange%)",
                      style: TextWidget.textStyle(
                        fontSize: 16,
                        theme: false,
                        color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                        fw: 1,
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
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSection(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
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
                style: TextWidget.textStyle(
                  fontSize: 12,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentLtp ?? widget.gttOrderBook.ltp ?? widget.gttOrderBook.prc ?? '0.00',
                style: TextWidget.textStyle(
                  fontSize: 16,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 2,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lot Size",
                style: TextWidget.textStyle(
                  fontSize: 12,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$lotSize",
                style: TextWidget.textStyle(
                  fontSize: 16,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                  fw: 2,
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
        TextWidget.subText(
          text: isOco ? "Target Trigger Price" : "Trigger Price",
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: CustomTextFormField(
            fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
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
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              if (value.isEmpty || inputPrice <= 0) {
                showResponsiveWarningMessage(
                  context,
                  "Trigger Price can not be ${inputPrice <= 0 ? 'zero' : 'empty'}",
                );
              }
            },
            hintText: "${widget.gttOrderBook.ltp}",
            hintStyle: TextWidget.textStyle(
              fontSize: 14,
              theme: theme.isDarkMode,
              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextWidget.textStyle(
              fontSize: 16,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
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
              TextWidget.subText(
                text: "Qty",
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 0,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                  hintText: orderInput.qtyCtrl.text,
                  hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  ),
                  inputFormate: [FilteringTextInputFormatter.digitsOnly],
                  style: TextWidget.textStyle(
                    fontSize: 16,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                  ),
                  textCtrl: orderInput.qtyCtrl,
                  textAlign: TextAlign.start,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                  TextWidget.subText(
                    text: "Price",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
                  ),
                  const SizedBox(width: 4),
                  TextWidget.subText(
                    text: "${orderInput.actPrcType}",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    if (value.isEmpty) {
                      showResponsiveWarningMessage(context, "Price can not be empty");
                    } else {
                      setState(() {
                        price = value;
                      });
                    }
                  },
                  hintText: "${widget.gttOrderBook.placeOrderParams!.prc}",
                  hintStyle: TextWidget.textStyle(
                    fontSize: 14,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  ),
                  style: TextWidget.textStyle(
                    fontSize: 16,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
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
        TextWidget.subText(
          text: isOco ? "Stoploss Trigger Price" : "Trigger Price",
          theme: theme.isDarkMode,
          color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
          fw: 0,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: CustomTextFormField(
            fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
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
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              if (value.isEmpty || inputPrice <= 0) {
                showResponsiveWarningMessage(
                  context,
                  "Trigger Price can not be ${inputPrice <= 0 ? 'zero' : 'empty'}",
                );
              }
            },
            hintText: "${widget.gttOrderBook.ltp}",
            hintStyle: textStyle(const Color(0xff666666), 15, FontWeight.w400),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              16,
              FontWeight.w600,
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
              TextWidget.subText(
                text: "Qty",
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                fw: 0,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                  hintText: orderInput.ocoQtyCtrl.text,
                  hintStyle: textStyle(const Color(0xff666666), 15, FontWeight.w400),
                  inputFormate: [FilteringTextInputFormatter.digitsOnly],
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600,
                  ),
                  textCtrl: orderInput.ocoQtyCtrl,
                  textAlign: TextAlign.start,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                  TextWidget.subText(
                    text: "Price",
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    fw: 0,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${orderInput.actOcoPrcType}",
                    style: textStyle(const Color(0xff777777), 14, FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: CustomTextFormField(
                  fillColor: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                  onChanged: (value) {},
                  hintText: "${widget.gttOrderBook.placeOrderParamsLeg2!.prc}",
                  hintStyle: textStyle(const Color(0xff666666), 15, FontWeight.w400),
                  style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    16,
                    FontWeight.w600,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
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
            backgroundColor: isBuy! ? colors.primary : colors.tertiary,
            minimumSize: const Size(double.infinity, 50),
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
              : TextWidget.subText(
                  text: "Modify",
                  theme: theme.isDarkMode,
                  color: colors.colorWhite,
                  fw: 2,
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
    await ref.read(orderProvider).modifyGTTOrder(input, context);
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
    await ref.read(orderProvider).modifyOCOOrder(input, context);
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      textStyle: TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize),
    );
  }
}
