import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';

class ExitPositionScreen extends ConsumerWidget {
  final List<PositionBookModel> exitPositionList;
  const ExitPositionScreen({super.key, required this.exitPositionList});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final theme = context.read(themeProvider);
    final positions = watch(portfolioProvider);
    final socketDatas = watch(websocketProvider).socketDatas;
    return WillPopScope(
      onWillPop: () async {
        positions.selectExitAllPosition(false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
              onTap: () {
                positions.selectExitAllPosition(false);
                Navigator.pop(context);
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(assets.backArrow,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack))),
          title: Text(
            "Exit Position (${positions.openPosition!.length})",
            style: textStyles.appBarTitleTxt.copyWith(
                color:
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
          ),
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
                  child: Text(
                    positions.isExitAllPosition ? "Cancel" : "Select All",
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorLightBlue
                            : colors.colorBlue,
                        14,
                        FontWeight.w500),
                  ),
                )
              ],
            ),
          ],
        ),
        body: ListView.separated(
          itemCount: exitPositionList.length,
          itemBuilder: (BuildContext context, int index) {
            if (socketDatas.containsKey(exitPositionList[index].token)) {
              exitPositionList[index].lp =
                  "${socketDatas["${exitPositionList[index].token}"]['lp']}";

              exitPositionList[index].perChange =
                  "${socketDatas["${exitPositionList[index].token}"]['pc']}";
            }
            return exitPositionList[index].qty == "0"
                ? Container()
                : InkWell(
                    onTap: () {
                      positions.selectExitPosition(index);
                    },
                    child: Container(
                        color: theme.isDarkMode
                            ? exitPositionList[index].isExitSelection!
                                ? colors.darkGrey
                                : colors.colorBlack
                            : exitPositionList[index].isExitSelection!
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
                                      Text("${exitPositionList[index].symbol} ",
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripNameTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack)),
                                      Text("${exitPositionList[index].option} ",
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripNameTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack)),
                                    ],
                                  ),
                                  if (socketDatas.containsKey(
                                      exitPositionList[index].token)) ...[
                                    Row(
                                      children: [
                                        Text(" LTP: ",
                                            style: textStyle(
                                                const Color(0xff5E6B7D),
                                                13,
                                                FontWeight.w600)),
                                        Text("₹${exitPositionList[index].lp}",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                14,
                                                FontWeight.w500)),
                                      ],
                                    ),
                                  ]
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
                                                ? exitPositionList[index].qty ==
                                                        "0"
                                                    ? colors.colorBlack
                                                    : colors.darkGrey
                                                : exitPositionList[index].qty ==
                                                        "0"
                                                    ? colors.colorWhite
                                                    : const Color(0xffECEDEE)),
                                        child: Text(
                                            "${exitPositionList[index].exch}",
                                            overflow: TextOverflow.ellipsis,
                                            style: textStyle(
                                                const Color(0xff666666),
                                                10,
                                                FontWeight.w500)),
                                      ),
                                      Text(
                                          "  ${exitPositionList[index].expDate} ",
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyles.scripExchTxtStyle
                                              .copyWith(
                                                  color: theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack)),
                                    ],
                                  ),
                                  if (socketDatas.containsKey(
                                      exitPositionList[index].token)) ...[
                                    Text(
                                        " (${exitPositionList[index].perChange ?? 0.00}%)",
                                        style: textStyle(
                                            Color(exitPositionList[index]
                                                    .perChange!
                                                    .startsWith("-")
                                                ? 0XFFFF1717
                                                : exitPositionList[index]
                                                            .perChange ==
                                                        "0.00"
                                                    ? 0xff666666
                                                    : 0xff43A833),
                                            12,
                                            FontWeight.w500)),
                                  ]
                                ],
                              ),
                              Divider(
                                  color: theme.isDarkMode
                                      ? colors.darkGrey
                                      : Color(
                                          exitPositionList[index].netqty == "0"
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
                                      Text(
                                          "${exitPositionList[index].sPrdtAli}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              13,
                                              FontWeight.w600)),
                                    ],
                                  ),
                                  positions.isNetPnl
                                      ? Row(
                                          children: [
                                            Text("P&L: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    13,
                                                    FontWeight.w500)),
                                            Text(
                                                "₹${exitPositionList[index].profitNloss ?? exitPositionList[index].rpnl}",
                                                style: textStyle(
                                                    Color(exitPositionList[
                                                                    index]
                                                                .profitNloss !=
                                                            null
                                                        ? exitPositionList[
                                                                    index]
                                                                .profitNloss!
                                                                .startsWith("-")
                                                            ? 0XFFFF1717
                                                            : exitPositionList[
                                                                            index]
                                                                        .profitNloss ==
                                                                    "0.00"
                                                                ? 0xff999999
                                                                : 0xff43A833
                                                        : exitPositionList[
                                                                    index]
                                                                .rpnl!
                                                                .startsWith("-")
                                                            ? 0XFFFF1717
                                                            : exitPositionList[
                                                                            index]
                                                                        .rpnl ==
                                                                    "0.00"
                                                                ? 0xff999999
                                                                : 0xff43A833),
                                                    15,
                                                    FontWeight.w600)),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Text("MTM: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    13,
                                                    FontWeight.w500)),
                                            Text(
                                                "₹${exitPositionList[index].mTm}",
                                                style: textStyle(
                                                    Color(exitPositionList[
                                                                index]
                                                            .mTm!
                                                            .startsWith("-")
                                                        ? 0XFFFF1717
                                                        : exitPositionList[
                                                                        index]
                                                                    .mTm ==
                                                                "0.00"
                                                            ? 0xff999999
                                                            : 0xff43A833),
                                                    15,
                                                    FontWeight.w600)),
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
                                      Text("Qty: ",
                                          style: textStyle(
                                              const Color(0xff5E6B7D),
                                              14,
                                              FontWeight.w500)),
                                      Text("${exitPositionList[index].qty}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w500)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text("Avg: ",
                                          style: textStyle(
                                              const Color(0xff5E6B7D),
                                              14,
                                              FontWeight.w500)),
                                      Text("${exitPositionList[index].avgPrc}",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
                            ])),
                  );
          },
          separatorBuilder: (BuildContext context, int index) {
            return exitPositionList[index].qty == "0"
                ? Container()
                : Container(
                    color: theme.isDarkMode
                        ? !exitPositionList[index].isExitSelection!
                            ? colors.darkGrey
                            : colors.colorBlack
                        : !exitPositionList[index].isExitSelection!
                            ? const Color(0xffF1F3F8)
                            : colors.colorWhite,
                    height: 6);
          },
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
                          await positions.exitAllPosition(context, true);
                        },
                  child: Center(
                      child: Text(
                          positions.exitPositionQty == 0
                              ? "Exit"
                              : "Exit (${positions.exitPositionQty})",
                          style: textStyle(
                              const Color(0xffFFFFFF), 14, FontWeight.w600))),
                ))),
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
