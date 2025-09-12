import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/snack_bar.dart';

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
          leading: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                  ? colors.splashColorDark
                  : colors.splashColorLight,
              highlightColor: theme.isDarkMode
                  ? colors.highlightDark
                  : colors.highlightLight,
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
              child: Container(
                width: 44, // Increased touch area
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 18,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                ),
              ),
            ),
          ),
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
                    final chng =
                        socketDatas[position.token]['chng']?.toString();

                    if (lp != null &&
                        lp != "null" &&
                        lp != "0" &&
                        lp != "0.00") {
                      position.lp = lp;
                    }

                    if (pc != null && pc != "null") {
                      position.perChange = pc;
                    }

                    if (chng != null && chng != "null") {
                      position.chng = chng;
                    }

                    // Calculate profit/loss - use the same logic as position screen
                    // P&L is already calculated by the portfolio provider, no need to recalculate manually
                  }
                }
              }

              if (positions.openPosition == null ||
                  positions.openPosition!.isEmpty) {
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
              final exitablePositions =
                  positions.openPosition!.where((p) => p.qty != "0").toList();

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
                  final originalIndex =
                      positions.openPosition!.indexOf(position);

                  return InkWell(
                    onTap: () {
                      positions.selectExitPosition(originalIndex);
                    },
                    child: Container(
                      color: position.isExitSelection!
                          ? theme.isDarkMode
                              ? colors.textSecondaryDark.withOpacity(0.2)
                              : colors.textSecondaryLight.withOpacity(0.2)
                          : null,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget.subText(
                                        text:
                                            "${position.symbol?.replaceAll("-EQ", "")} ",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fw: 3,
                                        textOverflow: TextOverflow.ellipsis),
                                    TextWidget.subText(
                                        text: "${position.option} ",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fw: 3,
                                        textOverflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget.paraText(
                                        text: "${position.exch}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3,
                                        textOverflow: TextOverflow.ellipsis),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget.paraText(
                                        text: "Qty ",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3),
                                    TextWidget.paraText(
                                        text: "${((int.tryParse(position.qty.toString()) ?? 0) / (position.exch == 'MCX' ? (int.tryParse(position.ls.toString()) ?? 1) : 1)).toInt()}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3),
                                    const SizedBox(width: 4),
                                    TextWidget.paraText(
                                        text: "Avg ",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3),
                                    TextWidget.paraText(
                                        text: "${position.avgPrc}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3),
                                    // TextWidget.paraText(
                                    //     text: "  ${position.expDate} ",
                                    //     theme: false,
                                    //     color: theme.isDarkMode
                                    //         ? colors.colorWhite
                                    //         : colors.colorBlack,
                                    //     fw: 0,
                                    //     textOverflow: TextOverflow.ellipsis),
                                  ],
                                ),
                                positions.isNetPnl
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextWidget.titleText(
                                              text: positions.isNetPnl
                                                  ? "${position.profitNloss ?? position.rpnl}"
                                                  : "${position.mTm}",
                                              theme: false,
                                              color: _getPnlColor(
                                                  positions.isNetPnl
                                                      ? (position.profitNloss ?? position.rpnl)
                                                      : position.mTm,
                                                  theme),
                                              fw: 3),
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextWidget.titleText(
                                              text: "₹${position.mTm}",
                                              theme: false,
                                              color: position.mTm!
                                                      .startsWith("-")
                                                  ? theme.isDarkMode
                                                      ? colors.lossDark
                                                      : colors.lossLight
                                                  : position.mTm == "0.00"
                                                      ? theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight
                                                      : theme.isDarkMode
                                                          ? colors.profitDark
                                                          : colors.profitLight,
                                              fw: 3),
                                        ],
                                      ),
                                // TextWidget.paraText(
                                //     text: " (${position.perChange ?? 0.00}%)",
                                //     theme: false,
                                //     color: position.perChange == "0.00" ||
                                //             position.perChange == null
                                //         ? colors.ltpgrey
                                //         : position.perChange!.startsWith("-")
                                //             ? colors.darkred
                                //             : colors.ltpgreen,
                                //     fw: 0),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget.paraText(
                                        text: "${position.sPrdtAli}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextWidget.paraText(
                                        text: "LTP ",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textSecondaryDark
                                            : colors.textSecondaryLight,
                                        fw: 3),
                                    TextWidget.paraText(
                                        text: "${position.lp}",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.textPrimaryDark
                                            : colors.textPrimaryLight,
                                        fw: 3),
                                  ],
                                ),
                              ],
                            ),
                          ]),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  final position = exitablePositions[index];

                  

                  return Divider(
                      // color: !position.isExitSelection!
                      //     ? colors.dividerDark 
                      //     : colors.dividerLight ,

                          color:colors.dividerDark 
                           ,
                      height: 0);
                },
              );
            }),
        bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: const CircularNotchedRectangle(),
            child: SafeArea(
              child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                      color: positions.exitPositionQty == 0
                          ? colors.tertiary.withOpacity(.8)
                          : colors.tertiary,
                      borderRadius: BorderRadius.circular(5)),
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
                              showResponsiveError(context, 'Error: ${e.toString()}');
                            }
                          },
                    child: Center(
                      child: TextWidget.subText(
                          text: positions.exitPositionQty == 0
                              ? "Exit"
                              : "Exit (${positions.exitPositionQty})",
                          theme: false,
                          color: colors.colorWhite,
                          fw: 2),
                    ),
                  )),
            )),
      ),
    );
  }

  // Helper method to get P&L color (matching position screen logic)
  Color _getPnlColor(String? pnlValue, ThemesProvider theme) {
    if (pnlValue == null || pnlValue == "0.00") {
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }

    if (pnlValue.startsWith("-")) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    }

    return theme.isDarkMode ? colors.profitDark : colors.profitLight;
  }
}
