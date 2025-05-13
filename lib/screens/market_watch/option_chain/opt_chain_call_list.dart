// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/marketwatch_model/get_quotes.dart';
import '../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../models/order_book_model/order_book_model.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/list_divider.dart';

class OptChainCallList extends ConsumerWidget {
  final List<OptionValues>? callData;
  final bool isCallUp;
  final SwipeActionController? swipe;
  
  const OptChainCallList({
    super.key,
    this.callData,
    this.swipe,
    required this.isCallUp,
  });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final scripData = watch(marketWatchProvider);
    final theme = watch(themeProvider);

    return StreamBuilder<Map>(
      stream: watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final socketDatas = snapshot.data!;
        
        // Preprocess data
        final List<OptionValues> processedData = callData!.map((option) {
          if (socketDatas.containsKey(option.token)) {
            final socketData = socketDatas[option.token];
            option.lp = "${socketData['lp']}";
            option.perChange = "${socketData['pc']}";
            
            final oi = double.parse("${socketData['oi']}");
            option.oiLack = (oi / 100000).toStringAsFixed(2);
            
            final poi = double.parse("${socketData['poi'] ?? 0.00}");
            option.oiPerChng = ((poi / oi) * 100).toStringAsFixed(2);
          }
          return option;
        }).toList();

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          reverse: isCallUp,
          itemCount: processedData.length,
          separatorBuilder: (context, index) => const ListDivider(),
          itemBuilder: (BuildContext context, int index) {
            final option = processedData[index];
            
            return SwipeActionCell(
              isDraggable: true,
              fullSwipeFactor: 0.7,
              controller: swipe,
              index: index,
              key: ValueKey(option.token),
              leadingActions: [
                SwipeAction(
                  performsFirstActionWithFullSwipe: true,
                  title: "SELL",
                  color: Color(theme.isDarkMode ? 0xfffbbbb6 : 0xfffee8e7),
                  style: _getActionStyle(colors.darkred),
                  onTap: (handler) async {
                    await placeOrderInput(scripData, context, option, false);
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
                    await placeOrderInput(scripData, context, option, true);
                    handler(false);
                  },
                ),
              ],
              child: InkWell(
                onLongPress: () => _handleLongPress(context, watch, scripData, option),
                onTap: () => _handleTap(context, watch, scripData, option),
                child: Container(
                  height: 58,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildOIData(theme, option),
                      Expanded(
                        child: _buildPriceData(theme, option),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }

  static final Map<Color, TextStyle> _actionStyleCache = {};
  
  static TextStyle _getActionStyle(Color color) {
    return _actionStyleCache.putIfAbsent(
      color,
      () => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ).copyWith(color: color),
    );
  }

  Widget _buildOIData(ThemesProvider theme, OptionValues option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${option.oiLack ?? 0.00}",
          style: _getTextStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
        ),
        const SizedBox(height: 3),
        Text(
          "(${option.oiPerChng == "NaN" ? "0.00" : option.oiPerChng ?? 0.00}%)",
          style: _getPercentageStyle(option.oiPerChng),
        ),
      ],
    );
  }

  Widget _buildPriceData(ThemesProvider theme, OptionValues option) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${option.lp ?? option.close ?? 0.00}",
          style: _getTextStyle(theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
        ),
        const SizedBox(height: 3),
        Text(
          "(${option.perChange ?? 0.00}%)",
          style: _getPercentageStyle(option.perChange),
        ),
      ],
    );
  }

  static final Map<Color, TextStyle> _textStyleCache = {};
  
  static TextStyle _getTextStyle(Color color) {
    return _textStyleCache.putIfAbsent(
      color,
      () => const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ).copyWith(color: color),
    );
  }

  static final Map<String, TextStyle> _percentageStyleCache = {};
  
  static TextStyle _getPercentageStyle(String? value) {
    final key = value ?? "0.00";
    return _percentageStyleCache.putIfAbsent(
      key,
      () {
        Color color = colors.ltpgrey;
        if (value != null && value != "0.00") {
          color = value.startsWith("-") ? colors.darkred : colors.ltpgreen;
        }
        return const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ).copyWith(color: color);
      },
    );
  }

  Future<void> _handleLongPress(
    BuildContext context,
    ScopedReader watch,
    MarketWatchProvider scripData,
    OptionValues option,
  ) async {
    if (scripData.isPreDefWLs == "Yes") {
      Fluttertoast.showToast(
        msg: "This is a pre-defined watchlist that cannot be Added!",
        timeInSecForIosWeb: 2,
        backgroundColor: colors.colorBlack,
        textColor: colors.colorWhite,
        fontSize: 14.0,
      );
    } else {
      await watch(websocketProvider).establishConnection(
        channelInput: "${option.exch}|${option.token}",
        task: "t",
        context: context,
      );
      await scripData.addDelMarketScrip(
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

  Future<void> _handleTap(
    BuildContext context,
    ScopedReader watch,
    MarketWatchProvider scripData,
    OptionValues option,
  ) async {
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
    Navigator.pop(context);
    await scripData.calldepthApis(context, depthArgs, "");
  }

  Future<void> placeOrderInput(
    MarketWatchProvider scripInfo,
    BuildContext context,
    OptionValues depthData,
    bool transType,
  ) async {
    await context.read(marketWatchProvider).fetchScripInfo(
          depthData.token.toString(),
          depthData.exch.toString(),
          context,
          true,
        );
    OrderScreenArgs orderArgs = OrderScreenArgs(
      exchange: depthData.exch.toString(),
      tSym: depthData.tsym.toString(),
      isExit: false,
      token: depthData.token.toString(),
      transType: transType,
      lotSize: depthData.ls,
      ltp: "${depthData.lp ?? depthData.close ?? 0.00}",
      perChange: depthData.perChange ?? "0.00",
      orderTpye: '',
      holdQty: '',
      isModify: false,
      raw: {},
    );
    Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": context.read(marketWatchProvider).scripInfoModel!,
      "isBskt": "",
    });
  }
}
