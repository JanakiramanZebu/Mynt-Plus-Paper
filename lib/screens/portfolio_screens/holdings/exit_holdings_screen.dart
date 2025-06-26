import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/custom_exch_badge.dart';

class ExitHoldingsScreen extends ConsumerWidget {
  const ExitHoldingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final holdings = ref.watch(portfolioProvider);

    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // If system handled back, do nothing

        holdings.selectExitAllPosition(false);
        Navigator.of(context).pop(); // Proceed with back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: .2,
          centerTitle: false,
          leadingWidth: 41,
          titleSpacing: 6,
          leading: InkWell(
              onTap: () {
                holdings.selectExitAllHoldings(false);
                Navigator.pop(context);
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(assets.backArrow,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack))),
          title: TextWidget.titleText(
              text: "Exit Holdings", theme: theme.isDarkMode, fw: 1),
          actions: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    holdings.selectExitAllHoldings(
                        holdings.isExitAllHoldings ? false : true);
                  },
                  child: SvgPicture.asset(
                    theme.isDarkMode
                        ? holdings.isExitAllHoldings
                            ? assets.darkCheckedboxIcon
                            : assets.darkCheckboxIcon
                        : holdings.isExitAllHoldings
                            ? assets.ckeckedboxIcon
                            : assets.ckeckboxIcon,
                    width: 22,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextWidget.subText(
                      text:
                          holdings.isExitAllHoldings ? "Cancel" : "Select All",
                      theme: theme.isDarkMode,
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

              // Update holdings data with real-time values if available
              if (snapshot.hasData && holdings.sealableHoldings.isNotEmpty) {
                for (var index = 0;
                    index < holdings.sealableHoldings.length;
                    index++) {
                  final token =
                      holdings.sealableHoldings[index].exchTsym![0].token;
                  if (socketDatas.containsKey(token)) {
                    final lp = socketDatas[token]['lp']?.toString();
                    final pc = socketDatas[token]['pc']?.toString();
                    final c = socketDatas[token]['c']?.toString();

                    if (lp != null && lp != "null") {
                      holdings.sealableHoldings[index].exchTsym![0].lp = lp;
                    }

                    if (pc != null && pc != "null") {
                      holdings.sealableHoldings[index].exchTsym![0].perChange =
                          pc;
                    }

                    if (c != null && c != "null") {
                      holdings.sealableHoldings[index].exchTsym![0].close = c;
                    }
                  }
                }

                for (var index = 0;
                    index < holdings.nonSealableHoldings.length;
                    index++) {
                  final token =
                      holdings.nonSealableHoldings[index].exchTsym![0].token;
                  if (socketDatas.containsKey(token)) {
                    final lp = socketDatas[token]['lp']?.toString();
                    final pc = socketDatas[token]['pc']?.toString();
                    final c = socketDatas[token]['c']?.toString();

                    if (lp != null && lp != "null") {
                      holdings.nonSealableHoldings[index].exchTsym![0].lp = lp;
                    }

                    if (pc != null && pc != "null") {
                      holdings.nonSealableHoldings[index].exchTsym![0]
                          .perChange = pc;
                    }

                    if (c != null && c != "null") {
                      holdings.nonSealableHoldings[index].exchTsym![0].close =
                          c;
                    }
                  }
                }

                // Calculate values for each holding
                for (var index = 0;
                    index < holdings.sealableHoldings.length;
                    index++) {
                  if (holdings.sealableHoldings[index].exchTsym != null &&
                      holdings.sealableHoldings[index].exchTsym!.isNotEmpty) {
                    final exchTsym =
                        holdings.sealableHoldings[index].exchTsym![0];
                    final ltp = double.tryParse(exchTsym.lp ?? "0") ?? 0.0;
                    final qty =
                        holdings.sealableHoldings[index].currentQty ?? 0;
                    final avgPrice = double.tryParse(
                            holdings.sealableHoldings[index].upldprc ?? "0") ??
                        0.0;

                    if (ltp > 0 && qty > 0) {
                      holdings.sealableHoldings[index].currentValue =
                          (ltp * qty).toStringAsFixed(2);

                      if (avgPrice > 0) {
                        final pnl = (ltp - avgPrice) * qty;
                        exchTsym.profitNloss = pnl.toStringAsFixed(2);

                        if (avgPrice > 0) {
                          final pnlPerc = (pnl / (avgPrice * qty)) * 100;
                          exchTsym.pNlChng = pnlPerc.toStringAsFixed(2);
                        }
                      }
                    }
                  }
                }

                // Do the same for non-saleable holdings
                for (var index = 0;
                    index < holdings.nonSealableHoldings.length;
                    index++) {
                  if (holdings.nonSealableHoldings[index].exchTsym != null &&
                      holdings
                          .nonSealableHoldings[index].exchTsym!.isNotEmpty) {
                    final exchTsym =
                        holdings.nonSealableHoldings[index].exchTsym![0];
                    final ltp = double.tryParse(exchTsym.lp ?? "0") ?? 0.0;
                    final qty =
                        holdings.nonSealableHoldings[index].currentQty ?? 0;
                    final avgPrice = double.tryParse(
                            holdings.nonSealableHoldings[index].upldprc ??
                                "0") ??
                        0.0;

                    if (ltp > 0 && qty > 0) {
                      holdings.nonSealableHoldings[index].currentValue =
                          (ltp * qty).toStringAsFixed(2);

                      if (avgPrice > 0) {
                        final pnl = (ltp - avgPrice) * qty;
                        exchTsym.profitNloss = pnl.toStringAsFixed(2);

                        if (avgPrice > 0) {
                          final pnlPerc = (pnl / (avgPrice * qty)) * 100;
                          exchTsym.pNlChng = pnlPerc.toStringAsFixed(2);
                        }
                      }
                    }
                  }
                }
              }

              return ListView(
                children: [
                  if (holdings.sealableHoldings.isNotEmpty) ...[
                    Container(
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          border: holdings.sealableHoldings[0].isExitHoldings!
                              ? Border(
                                  bottom: BorderSide(
                                      color: colors.colorWhite, width: 6))
                              : null),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: TextWidget.titleText(
                          text:
                              "Sellable Holdings(${holdings.sealableHoldings.length})",
                          theme: theme.isDarkMode,
                          fw: 1),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: holdings.sealableHoldings.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              holdings.selectExitHoldings(index);
                            },
                            child: Container(
                              color: theme.isDarkMode
                                  ? holdings.sealableHoldings[index]
                                          .isExitHoldings!
                                      ? colors.darkGrey
                                      : colors.colorBlack
                                  : holdings.sealableHoldings[index]
                                          .isExitHoldings!
                                      ? const Color(0xffF1F3F8)
                                      : colors.colorWhite,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget.subText(
                                          text:
                                              "${holdings.sealableHoldings[index].exchTsym![0].tsym} ",
                                          theme: theme.isDarkMode,
                                          fw: 1,
                                          textOverflow: TextOverflow.ellipsis),
                                      Row(
                                        children: [
                                          TextWidget.paraText(
                                              text: " LTP: ",
                                              theme: theme.isDarkMode,
                                              color: const Color(0xff5E6B7D),
                                              fw: 1),
                                          TextWidget.subText(
                                              text:
                                                  "₹${holdings.sealableHoldings[index].exchTsym![0].lp}",
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomExchBadge(
                                          exch:
                                              "${holdings.sealableHoldings[index].exchTsym![0].exch}"),
                                      TextWidget.paraText(
                                          text:
                                              " (${holdings.sealableHoldings[index].exchTsym![0].perChange}%)",
                                          theme: theme.isDarkMode,
                                          color: holdings
                                                  .sealableHoldings[index]
                                                  .exchTsym![0]
                                                  .perChange!
                                                  .startsWith("-")
                                              ? colors.darkred
                                              : holdings
                                                          .sealableHoldings[
                                                              index]
                                                          .exchTsym![0]
                                                          .perChange ==
                                                      "0.00"
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen,
                                          fw: 0),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextWidget.subText(
                                              text: "Sellable: ",
                                              theme: theme.isDarkMode,
                                              color: const Color(0xff5E6B7D),
                                              fw: 0),
                                          TextWidget.subText(
                                              text:
                                                  "${holdings.sealableHoldings[index].saleableQty ?? 0} ",
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          TextWidget.subText(
                                              text: "/ Qty: ",
                                              theme: theme.isDarkMode,
                                              color: const Color(0xff5E6B7D),
                                              fw: 0),
                                          TextWidget.subText(
                                              text:
                                                  "${holdings.sealableHoldings[index].currentQty ?? 0} @ ₹${holdings.sealableHoldings[index].upldprc ?? holdings.sealableHoldings[index].exchTsym![0].close ?? 0.00}",
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          if (holdings.sealableHoldings[index]
                                                  .btstqty !=
                                              "0")
                                            TextWidget.paraText(
                                                text:
                                                    " T1: ${holdings.sealableHoldings[index].btstqty}",
                                                theme: theme.isDarkMode,
                                                color: const Color(0xff666666),
                                                fw: 0),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextWidget.subText(
                                              text:
                                                  "₹${holdings.sealableHoldings[index].exchTsym![0].profitNloss}",
                                              theme: false,
                                              color: holdings
                                                      .sealableHoldings[index]
                                                      .exchTsym![0]
                                                      .profitNloss!
                                                      .startsWith("-")
                                                  ? colors.darkred
                                                  : colors.ltpgreen,
                                              fw: 0),
                                          TextWidget.paraText(
                                              text:
                                                  " (${holdings.sealableHoldings[index].exchTsym![0].pNlChng == "NaN" ? 0.0 : holdings.sealableHoldings[index].exchTsym![0].pNlChng}%)",
                                              theme: false,
                                              color: holdings
                                                      .sealableHoldings[index]
                                                      .exchTsym![0]
                                                      .pNlChng!
                                                      .startsWith("-")
                                                  ? colors.darkred
                                                  : holdings
                                                              .sealableHoldings[
                                                                  index]
                                                              .exchTsym![0]
                                                              .pNlChng ==
                                                          "NaN"
                                                      ? colors.ltpgrey
                                                      : colors.ltpgreen,
                                              fw: 0),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                            color: theme.isDarkMode
                                ? !holdings
                                        .sealableHoldings[index].isExitHoldings!
                                    ? colors.darkGrey
                                    : colors.colorBlack
                                : !holdings
                                        .sealableHoldings[index].isExitHoldings!
                                    ? const Color(0xffF1F3F8)
                                    : colors.colorWhite,
                            height: 6);
                      },
                    ),
                  ],
                  if (holdings.nonSealableHoldings.isNotEmpty) ...[
                    Container(
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            border: holdings.isExitAllHoldings
                                ? Border(
                                    top: BorderSide(
                                        color: colors.colorWhite, width: 6))
                                : null),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: holdings.showEdis ? 6 : 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget.titleText(
                                text:
                                    "Non-Sellable Holdings(${holdings.nonSealableHoldings.length})",
                                theme: theme.isDarkMode,
                                fw: 1),
                            if (holdings.showEdis)
                              SizedBox(
                                  height: 27,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite,
                                        ),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32)))),
                                    onPressed: () async {
                                      await ref
                                          .read(fundProvider)
                                          .fetchHstoken(context);
                                      await ref
                                          .read(fundProvider)
                                          .eDis(context);
                                    },
                                    child: TextWidget.paraText(
                                        text: "E-DIS",
                                        theme: false,
                                        color: theme.isDarkMode
                                            ? colors.colorBlack
                                            : colors.colorWhite,
                                        fw: 1),
                                  )),
                          ],
                        )),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: holdings.nonSealableHoldings.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  isDismissible: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16))),
                                  context: context,
                                  builder: (context) => Container(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom,
                                      ),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              color: theme.isDarkMode
                                                  ? colors.colorBlack
                                                  : colors.colorWhite,
                                              boxShadow: const [
                                                BoxShadow(
                                                    color: Color(0xff999999),
                                                    blurRadius: 4.0,
                                                    offset: Offset(2.0, 0.0))
                                              ]),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const CustomDragHandler(),
                                                TextWidget.titleText(
                                                    text: 'Verify Holdings',
                                                    theme: theme.isDarkMode,
                                                    fw: 1,
                                                    textOverflow:
                                                        TextOverflow.ellipsis),
                                                Column(children: [
                                                  const SizedBox(height: 12),
                                                  TextWidget.paraText(
                                                      text: holdings
                                                                      .nonSealableHoldings[
                                                                          index]
                                                                      .brkcolqty ==
                                                                  null ||
                                                              holdings
                                                                      .nonSealableHoldings[
                                                                          index]
                                                                      .brkcolqty ==
                                                                  "0"
                                                          ? "You are unable to exit because there are no sellable quantity. Kindly do E-DIS."
                                                          : "You are unable to exit because the stock is pledged. Kindly unpledge and do E-DIS.",
                                                      theme: theme.isDarkMode,
                                                      fw: 0),
                                                  const SizedBox(height: 12)
                                                ]),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        if (holdings
                                                                    .nonSealableHoldings[
                                                                        index]
                                                                    .brkcolqty ==
                                                                null ||
                                                            holdings
                                                                    .nonSealableHoldings[
                                                                        index]
                                                                    .brkcolqty ==
                                                                "0") {
                                                          await ref
                                                              .read(
                                                                  fundProvider)
                                                              .fetchHstoken(
                                                                  context);

                                                          Navigator.pop(
                                                              context);
                                                          await ref
                                                              .read(
                                                                  fundProvider)
                                                              .eDis(context);
                                                        } else {
                                                          await ref
                                                              .read(
                                                                  fundProvider)
                                                              .fetchHstoken(
                                                                  context);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pushNamed(
                                                              context,
                                                              Routes
                                                                  .reportWebViewApp,
                                                              arguments:
                                                                  "pledge");
                                                        }
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                          elevation: 0,
                                                          backgroundColor: theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50))),
                                                      child: TextWidget.subText(
                                                          text: "Continue",
                                                          theme: false,
                                                          color: !theme
                                                                  .isDarkMode
                                                              ? colors
                                                                  .colorWhite
                                                              : colors
                                                                  .colorBlack,
                                                          fw: 0),
                                                    )),
                                                const SizedBox(height: 14)
                                              ]))));
                            },
                            child: Container(
                              color: theme.isDarkMode
                                  ? holdings.nonSealableHoldings[index]
                                          .isExitHoldings!
                                      ? colors.darkGrey
                                      : colors.colorBlack
                                  : holdings.nonSealableHoldings[index]
                                          .isExitHoldings!
                                      ? const Color(0xffF1F3F8)
                                      : colors.colorWhite,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextWidget.subText(
                                          text:
                                              "${holdings.nonSealableHoldings[index].exchTsym![0].tsym} ",
                                          theme: theme.isDarkMode,
                                          fw: 1,
                                          textOverflow: TextOverflow.ellipsis),
                                      Row(
                                        children: [
                                          TextWidget.paraText(
                                              text: " LTP: ",
                                              theme: false,
                                              color: const Color(0xff5E6B7D),
                                              fw: 1),
                                          TextWidget.subText(
                                              text:
                                                  "₹${holdings.nonSealableHoldings[index].exchTsym![0].lp}",
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomExchBadge(
                                          exch:
                                              "${holdings.nonSealableHoldings[index].exchTsym![0].exch}"),
                                      TextWidget.paraText(
                                          text:
                                              " (${holdings.nonSealableHoldings[index].exchTsym![0].perChange}%)",
                                          theme: false,
                                          color: holdings
                                                  .nonSealableHoldings[index]
                                                  .exchTsym![0]
                                                  .perChange!
                                                  .startsWith("-")
                                              ? colors.darkred
                                              : holdings
                                                          .nonSealableHoldings[
                                                              index]
                                                          .exchTsym![0]
                                                          .perChange ==
                                                      "0.00"
                                                  ? colors.ltpgrey
                                                  : colors.ltpgreen,
                                          fw: 0),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                  const SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextWidget.subText(
                                              text: "Qty: ",
                                              theme: false,
                                              color: const Color(0xff5E6B7D),
                                              fw: 0),
                                          TextWidget.subText(
                                              text:
                                                  "${holdings.nonSealableHoldings[index].currentQty ?? 0} @ ₹${holdings.nonSealableHoldings[index].upldprc ?? holdings.nonSealableHoldings[index].exchTsym![0].close ?? 0.00}",
                                              theme: theme.isDarkMode,
                                              fw: 0),
                                          if (holdings
                                                  .nonSealableHoldings[index]
                                                  .btstqty !=
                                              "0")
                                            TextWidget.paraText(
                                                text:
                                                    " T1: ${holdings.nonSealableHoldings[index].btstqty}",
                                                theme: false,
                                                color: const Color(0xff666666),
                                                fw: 0),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          TextWidget.subText(
                                              text:
                                                  "₹${holdings.nonSealableHoldings[index].exchTsym![0].profitNloss}",
                                              theme: false,
                                              color: holdings
                                                      .nonSealableHoldings[
                                                          index]
                                                      .exchTsym![0]
                                                      .profitNloss!
                                                      .startsWith("-")
                                                  ? colors.darkred
                                                  : colors.ltpgreen,
                                              fw: 0),
                                          TextWidget.paraText(
                                              text:
                                                  " (${holdings.nonSealableHoldings[index].exchTsym![0].pNlChng == "NaN" ? 0.0 : holdings.nonSealableHoldings[index].exchTsym![0].pNlChng}%)",
                                              theme: false,
                                              color: holdings
                                                      .nonSealableHoldings[
                                                          index]
                                                      .exchTsym![0]
                                                      .pNlChng!
                                                      .startsWith("-")
                                                  ? colors.darkred
                                                  : holdings
                                                              .nonSealableHoldings[
                                                                  index]
                                                              .exchTsym![0]
                                                              .pNlChng ==
                                                          "NaN"
                                                      ? colors.ltpgrey
                                                      : colors.ltpgreen,
                                              fw: 0),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                            color: theme.isDarkMode
                                ? !holdings.nonSealableHoldings[index]
                                        .isExitHoldings!
                                    ? colors.darkGrey
                                    : colors.colorBlack
                                : !holdings.nonSealableHoldings[index]
                                        .isExitHoldings!
                                    ? const Color(0xffF1F3F8)
                                    : colors.colorWhite,
                            height: 6);
                      },
                    )
                  ]
                ],
              );
            }),
        bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const CircularNotchedRectangle(),
            child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                    color: holdings.exitHoldingsQty == 0
                        ? const Color(0XFFD34645).withOpacity(.8)
                        : const Color(0XFFD34645),
                    borderRadius: BorderRadius.circular(32)),
                width: MediaQuery.of(context).size.width,
                child: InkWell(
                  onTap: holdings.exitHoldingsQty == 0
                      ? () {}
                      : () async {
                          await holdings.exitAllHoldings(context);
                        },
                  child: Center(
                    child: TextWidget.subText(
                        text: holdings.exitHoldingsQty == 0
                            ? "Exit"
                            : "Exit (${holdings.exitHoldingsQty})",
                        theme: false,
                        color: const Color(0xffFFFFFF),
                        fw: 1),
                  ),
                ))),
      ),
    );
  }
}
