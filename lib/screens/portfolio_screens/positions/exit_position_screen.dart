import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';

class ExitPositionScreen extends ConsumerWidget {
  const ExitPositionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final positions = ref.watch(portfolioProvider);
    
    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        try {
          // Reset selection state first
          positions.selectExitAllPosition(false);
          
          // Only attempt navigation if the context is still valid
          if (context.mounted) {
            // Use maybePop which safely checks if navigation is possible
            Navigator.of(context).maybePop();
          }
        } catch (e) {
          // If we have any errors during navigation, log them
          debugPrint("Navigation error: $e");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
              onTap: () {
                try {
                  positions.selectExitAllPosition(false);
                  
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                  }
                } catch (e) {
                  debugPrint("Navigation error: $e");
                }
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(assets.backArrow,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack))),
          title: TextWidget.titleText(
              text:
            "Exit Position (${positions.openPosition?.where((p) => p.qty != "0").length ?? 0})",
              theme: false,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              fw: 1),
          actions: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    positions.selectExitAllPosition(
                        positions.isExitAllPosition ? false : true);
                  },
                  child: SvgPicture.asset(
                    theme.isDarkMode
                        ? positions.isExitAllPosition
                            ? assets.darkCheckedboxIcon
                            : assets.darkCheckboxIcon
                        : positions.isExitAllPosition
                            ? assets.ckeckedboxIcon
                            : assets.ckeckboxIcon,
                    width: 22,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextWidget.subText(
                      text:
                    positions.isExitAllPosition ? "Cancel" : "Select All",
                      theme: false,
                      color: theme.isDarkMode
                            ? colors.colorLightBlue
                            : colors.colorBlue,
                      fw: 0),
                )
              ],
            ),
          ],
        ),
        body: StreamBuilder<Map>(
          stream: ref.watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};
            
            // Update positions with real-time data if we have socket data
            if (snapshot.hasData && positions.openPosition != null) {
              for (var position in positions.openPosition!) {
                if (position.qty == "0") continue; // Skip closed positions
                
                if (socketDatas.containsKey(position.token)) {
                  final lp = socketDatas[position.token]['lp']?.toString();
                  final pc = socketDatas[position.token]['pc']?.toString();
                  final chng = socketDatas[position.token]['chng']?.toString();
                  
                  if (lp != null && lp != "null" && lp != "0" && lp != "0.00") {
                    position.lp = lp;
                  }
                  
                  if (pc != null && pc != "null") {
                    position.perChange = pc;
                  }
                  
                  if (chng != null && chng != "null") {
                    position.chng = chng;
                  }
                  
                  // Calculate profit/loss based on latest price
                  if (position.avgPrc != null && position.netqty != null) {
                    final avgPrice = double.tryParse(position.avgPrc ?? "0.0") ?? 0.0;
                    final qty = int.tryParse(position.netqty ?? "0") ?? 0;
                    final ltp = double.tryParse(position.lp ?? "0.0") ?? 0.0;
                    
                    if (avgPrice > 0 && qty != 0 && ltp > 0) {
                      final pnl = (ltp - avgPrice) * qty;
                      position.profitNloss = pnl.toStringAsFixed(2);
                      position.mTm = pnl.toStringAsFixed(2);
                    }
                  }
                }
              }
            }
            
            if (positions.openPosition == null || positions.openPosition!.isEmpty) {
              return Center(
                  child: TextWidget.titleText(
                      text: "No positions available to exit",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      fw: 0),
              );
            }
            
            // Filter out closed positions
            final exitablePositions = positions.openPosition!.where((p) => p.qty != "0").toList();
            
            if (exitablePositions.isEmpty) {
              return Center(
                  child: TextWidget.titleText(
                      text: "No open positions available to exit",
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                      fw: 0),
              );
            }
            
            return ListView.separated(
              itemCount: exitablePositions.length,
              itemBuilder: (BuildContext context, int index) {
                final position = exitablePositions[index];
                final originalIndex = positions.openPosition!.indexOf(position);
                
                return InkWell(
                        onTap: () {
                    positions.selectExitPosition(originalIndex);
                        },
                        child: Container(
                            color: theme.isDarkMode
                        ? position.isExitSelection!
                                    ? colors.darkGrey
                                    : colors.colorBlack
                        : position.isExitSelection!
                                    ? const Color(0xffF1F3F8)
                                    : colors.colorWhite,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                    TextWidget.subText(
                                        text: "${position.symbol} ",
                                        theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                            : colors.colorBlack,
                                        fw: 1,
                                        textOverflow: TextOverflow.ellipsis),
                                    TextWidget.subText(
                                        text: "${position.option} ",
                                        theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                            : colors.colorBlack,
                                        fw: 1,
                                        textOverflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                    TextWidget.paraText(
                                        text: " LTP: ",
                                        theme: false,
                                        color: const Color(0xff5E6B7D),
                                        fw: 1),
                                    TextWidget.subText(
                                        text: "₹${position.lp}",
                                        theme: false,
                                        color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                        fw: 0),
                                        ],
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 3),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                color: theme.isDarkMode
                                          ? position.qty ==
                                                            "0"
                                                        ? colors.colorBlack
                                                        : colors.darkGrey
                                          : position.qty ==
                                                            "0"
                                                        ? colors.colorWhite
                                                        : const Color(0xffECEDEE)),
                                      child: TextWidget.captionText(
                                          text: "${position.exch}",
                                          theme: false,
                                          color: const Color(0xff666666),
                                          fw: 0,
                                          textOverflow: TextOverflow.ellipsis),
                                          ),
                                    TextWidget.paraText(
                                        text: "  ${position.expDate} ",
                                        theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                            : colors.colorBlack,
                                        fw: 0,
                                        textOverflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                TextWidget.paraText(
                                    text: " (${position.perChange ?? 0.00}%)",
                                    theme: false,
                                    color: position.perChange == "0.00" ||
                                            position.perChange == null
                                        ? colors.ltpgrey
                                        : position.perChange!.startsWith("-")
                                                  ? colors.darkred
                                            : colors.ltpgreen,
                                    fw: 0),
                                    ],
                                  ),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkGrey
                                    : Color(position.netqty == "0"
                                                  ? 0xffffffff
                                                  : 0xffECEDEE),
                                      thickness: 1.2),
                                  const SizedBox(height: 2),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                    TextWidget.subText(
                                        text: "${position.sPrdtAli}",
                                        theme: false,
                                        color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                        fw: 1),
                                        ],
                                      ),
                                      positions.isNetPnl
                                          ? Row(
                                              children: [
                                          TextWidget.subText(
                                              text: "P&L: ",
                                              theme: false,
                                              color: const Color(0xff5E6B7D),
                                              fw: 0),
                                          TextWidget.titleText(
                                              text:
                                          "₹${position.profitNloss ?? position.rpnl}",
                                              theme: false,
                                              color: position.profitNloss !=
                                                                null
                                                  ? position.profitNloss!
                                                                    .startsWith("-")
                                                                ? colors.darkred
                                                      : position.profitNloss ==
                                                                        "0.00"
                                                                    ? colors.ltpgrey
                                                          : colors.ltpgreen
                                                  : position.rpnl!
                                                                    .startsWith("-")
                                                                ? colors.darkred
                                                      : position.rpnl == "0.00"
                                                                    ? colors.ltpgrey
                                                          : colors.ltpgreen,
                                              fw: 1),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                          TextWidget.subText(
                                              text: "MTM: ",
                                              theme: false,
                                              color: const Color(0xff5E6B7D),
                                              fw: 0),
                                          TextWidget.titleText(
                                              text: "₹${position.mTm}",
                                              theme: false,
                                              color:
                                                  position.mTm!.startsWith("-")
                                                            ? colors.darkred
                                                      : position.mTm == "0.00"
                                                                ? colors.ltpgrey
                                                                : colors.ltpgreen,
                                              fw: 1),
                                              ],
                                            ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                    TextWidget.subText(
                                        text: "Qty: ",
                                        theme: false,
                                        color: const Color(0xff5E6B7D),
                                        fw: 0),
                                    TextWidget.subText(
                                        text: "${position.netqty}",
                                        theme: false,
                                        color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                        fw: 0),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                    TextWidget.subText(
                                        text: "Avg: ",
                                        theme: false,
                                        color: const Color(0xff5E6B7D),
                                        fw: 0),
                                    TextWidget.subText(
                                        text: "${position.avgPrc}",
                                        theme: false,
                                        color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                        fw: 0),
                                        ],
                                      ),
                                    ],
                                  ),
                      ]
                    ),
                  ),
                      );
              },
              separatorBuilder: (BuildContext context, int index) {
                final position = exitablePositions[index];
                
                return Container(
                        color: theme.isDarkMode
                      ? !position.isExitSelection!
                                ? colors.darkGrey
                                : colors.colorBlack
                      : !position.isExitSelection!
                                ? const Color(0xffF1F3F8)
                                : colors.colorWhite,
                        height: 6);
              },
            );
          }
        ),
        bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const CircularNotchedRectangle(),
            child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                    color: positions.exitPositionQty == 0
                        ? const Color(0XFFD34645).withOpacity(.8)
                        : const Color(0XFFD34645),
                    borderRadius: BorderRadius.circular(32)),
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: positions.exitPositionQty == 0
                      ? () {}
                      : () async {
                          try {
                            // Execute the exit position logic
                            await positions.exitPosition(context, false);
                            
                            // Check if context is still valid and mounted before navigating
                            if (context.mounted) {
                              // Use Navigator.of(context).maybePop() which safely checks if navigation is possible
                              Navigator.of(context).maybePop();
                            }
                          } catch (e) {
                            // Handle any errors during the exit process
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        },
                  child: Center(
                    child: TextWidget.subText(
                        text: positions.exitPositionQty == 0
                              ? "Exit"
                              : "Exit (${positions.exitPositionQty})",
                        theme: false,
                        color: const Color(0xffFFFFFF),
                        fw: 1),
                  ),
                ))),
      ),
    );
  }
}
