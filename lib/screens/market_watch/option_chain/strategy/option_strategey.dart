import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/option_strategy.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';
import '../../tv_chart/webview_chart.dart';
import '../cur_strike_price.dart';
import '../opt_chain_call_list.dart';
import '../opt_chain_put_list.dart';
import '../strike_price_list_card.dart';
import 'stradegy_scrip_edit.dart';
import 'stratrgy_list_sheet.dart';

class OptionStrategey extends StatefulWidget {
  const OptionStrategey({super.key});

  @override
  State<OptionStrategey> createState() => _OptionStrategeyState();
}

class _OptionStrategeyState extends State<OptionStrategey> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final marketWatch = watch(marketWatchProvider);
      final optStrgy = watch(optStrategyProvider);
      final socketDatas = watch(websocketProvider).socketDatas;
      return Scaffold(
        appBar: AppBar(
            shadowColor: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            elevation: .3,
            actions: [
              Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                          dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: !theme.isDarkMode
                                      ? colors.colorWhite
                                      : const Color.fromARGB(255, 18, 18, 18))),
                          menuItemStyleData: MenuItemStyleData(
                              customHeights: optStrgy.getCustomItemsHeight()),
                          buttonStyleData: ButtonStyleData(
                              height: 40,
                              width: 150,
                              padding: const EdgeInsets.only(left: 12),
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(32)))),
                          isExpanded: true,
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w500),
                          hint: Text(optStrgy.selectedOptName,
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorBlack
                                      : colors.colorBlack,
                                  13,
                                  FontWeight.w500)),
                          items: optStrgy.addDividers(),
                          value: optStrgy.selectedOptName,
                          onChanged: (value) {
                            optStrgy.chngeOptionName("$value", context);
                          })))
            ]),
        body: Column(
          // shrinkWrap: true,
          // physics: optStrgy.selectBtn == "Option"
          //     ? const AlwaysScrollableScrollPhysics()
          //     : const NeverScrollableScrollPhysics(),
          children: [
            Container(
                padding: const EdgeInsets.only(left: 14, top: 8, bottom: 8),
                height: 52,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0),
                        top: BorderSide(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider,
                            width: 0))),
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: optStrgy.optBtns.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ElevatedButton(
                          onPressed: () async {
                            optStrgy
                                .chngBtn(optStrgy.optBtns[index]['btnName']);
                          },
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 0),
                              backgroundColor: theme.isDarkMode
                                  ? optStrgy.selectBtn ==
                                          optStrgy.optBtns[index]['btnName']
                                      ? colors.colorbluegrey
                                      : const Color(0xffB5C0CF).withOpacity(.15)
                                  : optStrgy.selectBtn ==
                                          optStrgy.optBtns[index]['btnName']
                                      ? const Color(0xff000000)
                                      : const Color(0xffF1F3F8),
                              shape: const StadiumBorder()),
                          child: Row(children: [
                            SvgPicture.asset(
                              "${optStrgy.optBtns[index]['imgPath']}",
                              color: theme.isDarkMode
                                  ? Color(optStrgy.selectBtn ==
                                          optStrgy.optBtns[index]['btnName']
                                      ? 0xff000000
                                      : 0xffffffff)
                                  : Color(optStrgy.selectBtn ==
                                          optStrgy.optBtns[index]['btnName']
                                      ? 0xffffffff
                                      : 0xff000000),
                            ),
                            const SizedBox(width: 8),
                            Text("${optStrgy.optBtns[index]['btnName']}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? Color(optStrgy.selectBtn ==
                                                optStrgy.optBtns[index]
                                                    ['btnName']
                                            ? 0xff000000
                                            : 0xffffffff)
                                        : Color(optStrgy.selectBtn ==
                                                optStrgy.optBtns[index]
                                                    ['btnName']
                                            ? 0xffffffff
                                            : 0xff000000),
                                    12.5,
                                    FontWeight.w500))
                          ]));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 10);
                    })),
            if (optStrgy.selectBtn == "Option") ...[
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 36,
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffFAFBFF),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("OI",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500)),
                        Text("  Call LTP   ",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500)),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(children: [
                              Text("${marketWatch.numStrike} ",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorLightBlue
                                          : colors.colorBlue,
                                      13,
                                      FontWeight.w500)),
                              Text("Strike",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorLightBlue
                                          : colors.colorBlue,
                                      13,
                                      FontWeight.w500)),
                              Icon(Icons.arrow_drop_down,
                                  color: theme.isDarkMode
                                      ? colors.colorLightBlue
                                      : colors.colorBlue,
                                  size: 20)
                            ])),
                        Text("  Put LTP   ",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500)),
                        Text("OI",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                13,
                                FontWeight.w500))
                      ])),
              Expanded(
                child: ListView(shrinkWrap: true, children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(children: <Widget>[
                        Flexible(
                            child: OptChainCallList(
                                callData: marketWatch.optChainCallUP,
                                isCallUp: true)),
                        SizedBox(
                            width: 100,
                            child: StrikePriceListCard(
                                strike: marketWatch.optChainCallUP,
                                isCallUp: true)),
                        Flexible(
                            child: OptChainPutList(
                                putData: marketWatch.optChainPutUp,
                                isPutUp: true))
                      ])),
                  CurStrkprice(token: optStrgy.selectedTK),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(children: [
                        Flexible(
                            child: OptChainCallList(
                                callData: marketWatch.optChainCallDown,
                                isCallUp: false)),
                        SizedBox(
                            width: 100,
                            child: StrikePriceListCard(
                                strike: marketWatch.optChainCallDown,
                                isCallUp: false)),
                        Flexible(
                            child: OptChainPutList(
                                putData: marketWatch.optChainPutDown,
                                isPutUp: false))
                      ]))
                ]),
              ),
            ] else ...[
              ChartScreenWebView(chartArgs: optStrgy.chartArgs!, cHeight: 1.9),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            useSafeArea: true,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(16))),
                            context: context,
                            builder: (context) {
                              return const StrategyListBottomSheet();
                            });
                      },
                      icon: SvgPicture.asset(assets.filterLines,
                          width: 19, color: colors.colorGrey))
                ],
              ),
              Expanded(
                  child: ListView.separated(
                shrinkWrap: true,
                itemCount: optStrgy.optStrgyStrike.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (BuildContext context, int index) {
                  if (socketDatas
                      .containsKey(optStrgy.optStrgyStrike[index].token)) {
                    optStrgy.optStrgyStrike[index].lp =
                        "${socketDatas["${optStrgy.optStrgyStrike[index].token}"]['lp']}";
                    optStrgy.optStrgyStrike[index].perChange =
                        "${socketDatas["${optStrgy.optStrgyStrike[index].token}"]['pc']}";
                  }

                  return InkWell(
                    onLongPress: () {

                       showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return OptionStrategyEdit(
                                                  scripData:  optStrgy.optStrgyStrike[index]);
                                            });
                    },
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Text(
                                      "${optStrgy.optStrgyStrike[index].symbol} ",
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                  Text(
                                      "${optStrgy.optStrgyStrike[index].option} ",
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                  Text("  Lot: ",
                                      style: textStyle(const Color(0xff5E6B7D),
                                          13, FontWeight.w600)),
                                  Text("${optStrgy.optStrgyStrike[index].ls}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          12,
                                          FontWeight.w500))
                                ]),
                                Row(children: [
                                  Text(" LTP: ",
                                      style: textStyle(const Color(0xff5E6B7D),
                                          13, FontWeight.w600)),
                                  Text("₹${optStrgy.optStrgyStrike[index].lp}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500))
                                ])
                              ]),
                          const SizedBox(height: 4),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          color: theme.isDarkMode
                                              ? const Color(0xff666666)
                                                  .withOpacity(.2)
                                              : const Color(0xffECEDEE)),
                                      child: Text(
                                          "${optStrgy.optStrgyStrike[index].exch}",
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : const Color(0xff666666),
                                              10,
                                              FontWeight.w500))),
                                  Text(
                                      "  ${optStrgy.optStrgyStrike[index].expDate}   ",
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyles.scripExchTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack)),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (optStrgy.optStrgyStrike[index]
                                                .transType ==
                                            "S") {
                                          optStrgy.optStrgyStrike[index]
                                              .transType = "B";
                                        } else {
                                          optStrgy.optStrgyStrike[index]
                                              .transType = "S";
                                        }
                                      });
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color: theme.isDarkMode
                                                ? optStrgy.optStrgyStrike[index]
                                                            .transType ==
                                                        "S"
                                                    ? colors.darkred
                                                        .withOpacity(.2)
                                                    : colors.ltpgreen
                                                        .withOpacity(.2)
                                                : Color(
                                                    optStrgy.optStrgyStrike[index].transType == "S"
                                                        ? 0xffFCF3F3
                                                        : 0xffECF8F1)),
                                        child: Text(
                                            "${optStrgy.optStrgyStrike[index].transType}",
                                            style: textStyle(
                                                optStrgy.optStrgyStrike[index]
                                                            .transType ==
                                                        "S"
                                                    ? colors.darkred
                                                    : colors.ltpgreen,
                                                12,
                                                FontWeight.w600))),
                                  ),
                                  Text("  MKT ",
                                      style: textStyle(const Color(0xff5E6B7D),
                                          13, FontWeight.w600)),
                                ]),
                                Text(
                                    " (${optStrgy.optStrgyStrike[index].perChange ?? 0.00}%)",
                                    style: textStyle(
                                        optStrgy.optStrgyStrike[index].perChange
                                                .toString()
                                                .startsWith("-")
                                            ? colors.darkred
                                            : optStrgy.optStrgyStrike[index]
                                                        .perChange ==
                                                    "0.00"
                                                ? colors.ltpgrey
                                                : colors.ltpgreen,
                                        12,
                                        FontWeight.w500))
                              ]),
                          Divider(
                              color: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffECEDEE),
                              thickness: 1.2),
                          const SizedBox(height: 2),
                        ]),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider();
                },
              )),
              const SizedBox(height: 20)
            ]
          ],
        ),
        bottomSheet: optStrgy.selectBtn == "Option"
            ? null
            : Container(
                margin: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: colors.ltpgreen,
                        shape: const StadiumBorder()),
                    onPressed: ()async {

              await     optStrgy .   optionStrategyOrderPlace(context);
                    },
                    child: Text("Place Order",
                        style: textStyle(
                            colors.colorWhite, 14, FontWeight.w600)))),
      );
    });
  }
}
