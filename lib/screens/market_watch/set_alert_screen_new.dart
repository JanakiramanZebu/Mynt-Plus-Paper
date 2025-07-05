import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import 'set_alert_screen.dart';

class SetAlertScreen extends ConsumerWidget {
  final GetQuotes depthdata;
  final DepthInputArgs wlvalue;

  const SetAlertScreen(
      {super.key, required this.depthdata, required this.wlvalue});

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

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        elevation: 0.2,
        leadingWidth: 48,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.black.withOpacity(0.15),
              highlightColor: Colors.black.withOpacity(0.08),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 18,
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                ),
              ),
            ),
          ),
        ),
        shadowColor:
            theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
        title: StreamBuilder<Map>(
          stream: ref.watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};
      
            // Update depth data with WebSocket data if available
            if (socketDatas.containsKey(wlvalue.token)) {
              _processDepthData(depthdata, socketDatas[wlvalue.token]);
            }
      
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 8.0, 16, 8.0),// left, top, right, bottom
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextWidget.titleText(
                        text: wlvalue.symbol.toUpperCase(),
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                      ),
                      const SizedBox(width: 4),
                      TextWidget.titleText(
                        text: wlvalue.option,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        theme: theme.isDarkMode,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                       TextWidget.titleText(
                    text:
                        "${depthdata.lp != "null" ? depthdata.lp ?? depthdata.c ?? 0.00 : '0.00'}",
                    color: (depthdata.chng == "null" ||
                                depthdata.chng == null) ||
                            depthdata.chng == "0.00"
                        ? colors.textSecondaryLight
                        : depthdata.chng!.startsWith("-") ||
                                depthdata.pc!.startsWith("-")
                            ? colors.error
                            : colors.success,
                    theme: theme.isDarkMode,
                  ),
                  const SizedBox(height: 8),
                  TextWidget.paraText(
                    text:
                        "${(double.tryParse(depthdata.chng ?? '0.00') ?? 0.00).toStringAsFixed(2)} (${(double.tryParse(depthdata.pc ?? '0.00') ?? 0.00).toStringAsFixed(2)}%)",
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                  ),
                    ],
                  ),
                 
                 
                ],
              ),
            );
          },
        ),
      ),
      body: SetAlert(
        depthdata: depthdata,
        wlvalue: wlvalue,
      ),
    );
  }
}
