import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart'; 
import '../../../provider/market_watch_provider.dart';
import '../../../provider/option_strategy.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../tv_chart/webview_chart.dart';
import 'cur_strike_price.dart';
import 'opt_chain_call_list.dart';
import 'opt_chain_put_list.dart';
import 'strike_price_list_card.dart';

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
      return Scaffold(
        appBar: AppBar(
            shadowColor: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            elevation: .3,
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            padding: EdgeInsets.only(left: 12),
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
                        })),
              )
            ]),
        body: Column(
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
                            optStrgy.chngBtn(optStrgy.optBtns[index]['btnName']);

                           
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

                    if(optStrgy.selectBtn =="Option")...[
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
              child: ListView(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(children: <Widget>[
                        Flexible(
                          child: OptChainCallList(
                              callData: marketWatch.optChainCallUP,
                              isCallUp: true),
                        ),
                        SizedBox(
                          width: 100,
                          child: StrikePriceListCard(
                              strike: marketWatch.optChainCallUP,
                              isCallUp: true),
                        ),
                        Flexible(
                          child: OptChainPutList(
                              putData: marketWatch.optChainPutUp,
                              isPutUp: true),
                        )
                      ])),
                  CurStrkprice(token: optStrgy.selectedTK),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(children: [
                      Flexible(
                        child: OptChainCallList(
                            callData: marketWatch.optChainCallDown,
                            isCallUp: false),
                      ),
                      SizedBox(
                        width: 100,
                        child: StrikePriceListCard(
                            strike: marketWatch.optChainCallDown,
                            isCallUp: false),
                      ),
                      Flexible(
                        child: OptChainPutList(
                            putData: marketWatch.optChainPutDown,
                            isPutUp: false),
                      )
                    ]),
                  )
                ],
              ),
            ),
         ]else...[
                 ChartScreenWebView(chartArgs: optStrgy.chartArgs!)
         ] ],
        ),
      );
    });
  }
}
