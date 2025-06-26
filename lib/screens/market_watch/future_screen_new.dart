import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import 'futures/future_screen.dart';

class FutureScreenNew extends ConsumerWidget {
  final GetQuotes depthdata;
  final DepthInputArgs wlvalue;
  
  const FutureScreenNew({
    super.key, 
    required this.depthdata, 
    required this.wlvalue
  });

  // Process depth data with socket updates
  void _processDepthData(GetQuotes depthData, Map<String, dynamic> socketData) {
    depthData.ap = "${socketData['ap']}";
    depthData.lp = "${socketData['lp']}";
    depthData.pc = "${socketData['pc']}";
    depthData.o = "${socketData['o']}";
    depthData.l = "${socketData['l']}";
    depthData.c = "${socketData['c']}";
    depthData.chng = "${socketData['chng']}";
    depthData.h = "${socketData['h']}";
    depthData.poi = "${socketData['poi']}";
    depthData.v = "${socketData['v']}";
    depthData.toi = "${socketData['toi']}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final scripInfo = ref.watch(marketWatchProvider);
    
    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        elevation: 0.2,
        leadingWidth: 48,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: Colors.black.withOpacity(0.15),
            highlightColor: Colors.black.withOpacity(0.08),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 18,
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ),
        ),
        shadowColor: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        title: StreamBuilder<Map>(
          stream: ref.watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};
            
            // Update depth data with WebSocket data if available
            if (socketDatas.containsKey(wlvalue.token)) {
              _processDepthData(depthdata, socketDatas[wlvalue.token]);
            }

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "${wlvalue.symbol.toUpperCase()}",
                        style: TextWidget.textStyle(
                          fontSize: 13,
                          color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                      ),
                       const SizedBox(
              width: 2,
                        ),
                      Text(
                        wlvalue.option,
                        style: TextWidget.textStyle(
                    fontSize: 13,
                    color: Color(0xff666666),
                    theme: theme.isDarkMode,
                    fw: 0),
                      ),
                      const Spacer(),
                     
              
                       TextWidget.subText(
                text:  "${depthdata.lp != "null" ? depthdata.lp ?? depthdata.c ?? '0.00' : '0.00'}", fw: 0, theme: theme.isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (wlvalue.expDate.isNotEmpty)
                        TextWidget.paraText(
                          text: wlvalue.expDate, 
                          fw: 00, 
                          theme: theme.isDarkMode
                        ),     
                      const Spacer(),
                      Text(
                        "${(double.tryParse(depthdata.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)}   ${(double.tryParse(depthdata.pc ?? '0.00') ?? 0.00).toStringAsFixed(2)}%",
                        style: 
                        TextWidget.textStyle(
                    fontSize: 12, // or keep 12 if you prefer
                    color: (depthdata.chng == "null" || depthdata.chng == null) || depthdata.chng == "0.00"
                              ? colors.ltpgrey
                              : depthdata.chng!.startsWith("-") || depthdata.pc!.startsWith("-")
                                  ? colors.darkred
                                  : colors.ltpgreen,
                    theme: theme.isDarkMode,
                    fw: 2, // fw = 0 → FontWeight.w500 as per your logic
                  )
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
            ),
      body: Column(
        children: [
          Container(
           
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xffe3f2fd),
              borderRadius: BorderRadius.circular(6)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  assets.dInfo,
                  color: colors.colorBlue
                ),
                Text(
                  " Long press to add ${scripInfo.wlName}'s Watchlist",
                  style: textStyle(
                    colors.colorBlue,
                    12,
                    FontWeight.w500
                  )
                )
              ]
            )
          ),
          const Expanded(child: FutureScreen()),
        ],
      ),
    );
  }
} 