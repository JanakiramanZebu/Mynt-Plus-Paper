import 'dart:async';

import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:percent_indicator/percent_indicator.dart'; 
import '../../../provider/websocket_provider.dart'; 
import '../../locator/constant.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/market_watch_provider.dart'; 
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';  
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/no_data_found.dart';
import 'futures/future_screen.dart';
import 'option_chain/cur_strike_price.dart';
import 'option_chain/opt_chain_call_list.dart';
import 'option_chain/opt_chain_put_list.dart';
import 'option_chain/strike_price_list_card.dart';
 
import 'over_view/funtamental_data_widget.dart';
import 'scrip_detail_dialogue.dart';
import 'set_alert_screen.dart';
import 'tv_chart/webview_chart.dart';

class ScripDepthInfo extends StatefulWidget {
  final DepthInputArgs wlValue;

  const ScripDepthInfo({super.key, required this.wlValue});

  @override
  State<ScripDepthInfo> createState() => _ScripDepthInfoState();
}

class _ScripDepthInfoState extends State<ScripDepthInfo> {
  double initSize = 0.88;
  ChartArgs? chartArgs;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    setState(() {
      initSize = (widget.wlValue.instname != "UNDIND" &&
              widget.wlValue.instname != "COM")
          ? 0.88
          : 0.38;
      chartArgs = ChartArgs(
          exch: widget.wlValue.exch,
          tsym: widget.wlValue.tsym,
          token: widget.wlValue.token);

    //   if ((widget.wlValue.exch == "NSE" || widget.wlValue.exch == "BSE") &&
    //       (widget.wlValue.instname != "UNDIND")) {
       
    // // context.read(marketWatchProvider).fetchFundamentalData(
    // //         tradeSym:
    // //             "${context.read(marketWatchProvider).getQuotes!.exch}:${context.read(marketWatchProvider).getQuotes!.tsym}");
      
      
    //   }
    });

    super.initState();
  }


// getFundamental()async{
//  await  context.read(marketWatchProvider).fetchFundamentalData(
//             tradeSym:
//                 "${context.read(marketWatchProvider).getQuotes!.exch}:${context.read(marketWatchProvider).getQuotes!.tsym}");
//  if ( context.read(marketWatchProvider).fundamentalData!.emsg != "error in data fetch") {
//         if ( context.read(marketWatchProvider).fundamentalData!.msg != "no data found") {

//            context
//                                       .read(marketWatchProvider)
//                                       .depthBtns
//                                       .add({
//                                     "btnName": "Fundamental",
//                                     "imgPath": assets.dInfo,
//                                     "key": context
//                                         .read(showcaseProvide)
//                                         .fundamentalcase,
//                                     "case":
//                                         "Click here to view fundamental data."
//                                   });
//         }}
 
 

// }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      ConstantName.charttimer =
          Timer.periodic(const Duration(milliseconds: 0), (timer) {});
      ConstantName.charttimer!.cancel();
      await context
          .read(marketWatchProvider)
          .requestWSOptChain(context: context, isSubscribe: false);
      await context.read(websocketProvider).establishConnection(
          channelInput: "${widget.wlValue.exch}|${widget.wlValue.token}",
          task: "ud",
          context: context);
if (context
          .read(marketWatchProvider).actDeptBtn ==
                                                    "Chart") {
      ConstantName.webViewController.evaluateJavascript(
                                source:
                                    'window.localStorage.removeItem("tick_tick")');
}
        

      return true;
    }, child: Consumer(builder: (context, ScopedReader watch, _) {
      final depthData = watch(marketWatchProvider).getQuotes!;
      final scripInfo = watch(marketWatchProvider);
      final socketDatas = watch(websocketProvider).socketDatas;
      final theme = context.read(themeProvider);
      if (socketDatas.containsKey(depthData.token)) {
        depthData.lp = "${socketDatas["${depthData.token}"]['lp']}";
        depthData.pc = "${socketDatas["${depthData.token}"]['pc']}";
        depthData.o = "${socketDatas["${depthData.token}"]['o']}";
        depthData.l = "${socketDatas["${depthData.token}"]['l']}";
        depthData.c = "${socketDatas["${depthData.token}"]['c']}";
        depthData.chng = "${socketDatas["${depthData.token}"]['chng']}";

        depthData.h = "${socketDatas["${depthData.token}"]['h']}";
        depthData.poi = "${socketDatas["${depthData.token}"]['poi']}";
        depthData.v = "${socketDatas["${depthData.token}"]['v']}";
        depthData.toi = "${socketDatas["${depthData.token}"]['toi']}";

        depthData.sp1 = "${socketDatas["${depthData.token}"]['sp1']}";
        depthData.sp2 = "${socketDatas["${depthData.token}"]['sp2']}";
        depthData.sp3 = "${socketDatas["${depthData.token}"]['sp3']}";
        depthData.sp4 = "${socketDatas["${depthData.token}"]['sp4']}";
        depthData.sp5 = "${socketDatas["${depthData.token}"]['sp5']}";
        depthData.bp1 = "${socketDatas["${depthData.token}"]['bp1']}";
        depthData.bp2 = "${socketDatas["${depthData.token}"]['bp2']}";
        depthData.bp3 = "${socketDatas["${depthData.token}"]['bp3']}";
        depthData.bp4 = "${socketDatas["${depthData.token}"]['bp4']}";
        depthData.bp5 = "${socketDatas["${depthData.token}"]['bp5']}";

        depthData.sq1 = "${socketDatas["${depthData.token}"]['sq1']}";
        depthData.sq2 = "${socketDatas["${depthData.token}"]['sq2']}";
        depthData.sq3 = "${socketDatas["${depthData.token}"]['sq3']}";
        depthData.sq4 = "${socketDatas["${depthData.token}"]['sq4']}";
        depthData.sq5 = "${socketDatas["${depthData.token}"]['sq5']}";
        depthData.bq1 = "${socketDatas["${depthData.token}"]['bq1']}";
        depthData.bq2 = "${socketDatas["${depthData.token}"]['bq2']}";
        depthData.bq3 = "${socketDatas["${depthData.token}"]['bq3']}";
        depthData.bq4 = "${socketDatas["${depthData.token}"]['bq4']}";
        depthData.bq5 = "${socketDatas["${depthData.token}"]['bq5']}";
        depthData.tbq = "${socketDatas["${depthData.token}"]['tbq']}";

        depthData.wk52H = "${socketDatas["${depthData.token}"]['52h']}";
        depthData.wk52L = "${socketDatas["${depthData.token}"]['52l']}";
        depthData.lc = "${socketDatas["${depthData.token}"]['lc']}";
        depthData.uc = "${socketDatas["${depthData.token}"]['uc']}";
        depthData.ltq = "${socketDatas["${depthData.token}"]['ltq']}";
        depthData.ltt = "${socketDatas["${depthData.token}"]['ltt']}";
        depthData.ft = "${socketDatas["${depthData.token}"]['ft']}";

        if (scripInfo.actDeptBtn == "Overview") {
          if ((depthData.exch == "NSE" || depthData.exch == "BSE") &&
              (depthData.instname != "UNDIND")) {
            scripInfo.techDataCalc("${depthData.lp}");
          }
          if (widget.wlValue.instname != "UNDIND" &&
              widget.wlValue.instname != "COM") {
            scripInfo.scripQtyCal();
          }
        }
      }

      return DraggableScrollableSheet(
          initialChildSize: initSize,
          minChildSize: (widget.wlValue.instname != "UNDIND" &&
                  widget.wlValue.instname != "COM")
              ? 0.4
              : 0.22,
          maxChildSize: .99,
          expand: false,
          builder: (BuildContext ctx, ScrollController scrollController) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0xff999999),
                        blurRadius: 4.0,
                        offset: Offset(2.0, 0.0))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        controller: scrollController,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const CustomDragHandler(),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                    "${widget.wlValue.symbol.toUpperCase()} ",
                                                    style: textStyle(
                                                        !theme.isDarkMode
                                                            ? colors.colorBlack
                                                            : colors.colorWhite,
                                                        16,
                                                        FontWeight.w600)),
                                                Text(widget.wlValue.option,
                                                    style: textStyle(
                                                        !theme.isDarkMode
                                                            ? colors.colorBlack
                                                            : colors.colorWhite,
                                                        16,
                                                        FontWeight.w600)),
                                                InkWell(
                                                    onTap: () async {
                                                      await scripInfo
                                                          .fetchScripInfo(
                                                              depthData.token!,
                                                              depthData.exch!,
                                                              ctx);
                                                      if (scripInfo
                                                              .scripInfoModel!
                                                              .stat ==
                                                          "Ok") {
                                                          showModalBottomSheet(
                                                            backgroundColor:
                                                                Color(
                                                                    0xff000000),
                                                            isScrollControlled:
                                                                true,
                                                            useSafeArea: true,
                                                            isDismissible: true,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.vertical(
                                                                        top: Radius.circular(
                                                                            16))),
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return const ScripDetailDialogue();
                                                            });
                                                      }
                                                    },
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8,
                                                                right: 8,
                                                                bottom: 4,
                                                                top: 4),
                                                        child: SvgPicture.asset(
                                                            assets.dInfo,
                                                            width: 18,
                                                            height: 15,
                                                            color: const Color(
                                                                0xff666666))))


                                                                
                                              ]),
                                          Text(
                                              "₹${depthData.lp ?? depthData.c ?? 0.00}",
                                              style: textStyle(
                                                  !theme.isDarkMode
                                                      ? colors.colorBlack
                                                      : colors.colorWhite,
                                                  16,
                                                  FontWeight.w600)),
                                        ])),
                                const SizedBox(height: 5),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(children: [
                                            CustomExchBadge(
                                                exch: widget.wlValue.exch),
                                            Text("  ${widget.wlValue.expDate}",
                                                style: textStyle(
                                             !theme.isDarkMode
                                                      ? colors.colorBlack
                                                      : colors.colorWhite,
                                                    12,
                                                    FontWeight.w600)),
                                          ]),
                                          Text(
                                              " ${double.parse("${depthData.chng ?? 0.00} ").toStringAsFixed(2)} (${depthData.pc ?? 0.00}%)",
                                              style: textStyle(
                                                  (depthData.chng ==
                                                                  "null" ||
                                                              depthData.chng ==
                                                                  null) ||
                                                          depthData.chng ==
                                                              "0.00"
                                                      ? colors.ltpgrey
                                                      : depthData.chng!
                                                                  .startsWith(
                                                                      "-") ||
                                                              depthData.pc!
                                                                  .startsWith(
                                                                      "-")
                                                          ? colors.darkred
                                                          : colors.ltpgreen,
                                                  12,
                                                  FontWeight.w500))
                                        ])),
                                const SizedBox(height: 8),
                                Container(
                                    padding: const EdgeInsets.only(
                                        left: 14, top: 8, bottom: 8),
                                    height: 52,
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider,width: 0),
                                            top: BorderSide(
                                                color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider,width: 0))),
                                    child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: scripInfo.depthBtns.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ElevatedButton(
                                              onPressed: () async {
                                                // if (scripInfo.depthBtns[index]
                                                //         ['btnName'] ==
                                                //     "Create GTT") {
                                                //   await scripInfo
                                                //       .fetchScripInfo(
                                                //           widget.wlValue.token,
                                                //           widget.wlValue.exch,
                                                //           ctx);
                                                //   Navigator.pop(ctx);
                                                //   OrderScreenArgs orderArgs =
                                                //       OrderScreenArgs(
                                                //           exchange: widget
                                                //               .wlValue.exch,
                                                //           tSym: widget
                                                //               .wlValue.tsym,
                                                //           isExit: false,
                                                //           token: widget
                                                //               .wlValue.token,
                                                //           transType: true,
                                                //           // change: depthData.chng,
                                                //           // close: depthData.c,
                                                //           lotSize: depthData.ls,
                                                //           ltp: depthData.lp ??
                                                //               "0.00",
                                                //           perChange:
                                                //               depthData.pc ??
                                                //                   "0.00",
                                                //           orderTpye: '',
                                                //           holdQty: '',
                                                //           isModify: false);
                                                //   Navigator.pushNamed(ctx,
                                                //       Routes.gttOrderScreen,
                                                //       arguments: {
                                                //         "orderArg": orderArgs,
                                                //         "scripInfo": ctx
                                                //             .read(
                                                //                 marketWatchProvider)
                                                //             .scripInfoModel!
                                                //       });
                                                // }
                                                if (scripInfo.depthBtns[index]
                                                        ['btnName'] ==
                                                    "Option") {
                                                  if (depthData.exch == "NFO" ||
                                                      (depthData.exch ==
                                                              "MCX" &&
                                                          depthData.instname ==
                                                              "OPTFUT")) {
                                                    await scripInfo.fetchStikePrc(
                                                        "${depthData.undTk}",
                                                        "${depthData.undExch}",
                                                        context);
                                                  }

                                                  await context
                                                      .read(websocketProvider)
                                                      .establishConnection(
                                                          channelInput: (depthData
                                                                          .exch ==
                                                                      "NFO" ||
                                                                  (depthData.exch ==
                                                                          "MCX" &&
                                                                      depthData
                                                                              .instname ==
                                                                          "OPTFUT"))
                                                              ? '${depthData.undExch}|${depthData.undTk!}'
                                                              : '${depthData.exch}|${depthData.token!}',
                                                          task: "t",
                                                          context: context);

                                                  await scripInfo
                                                      .fetchOPtionChain(
                                                          context: context,
                                                          exchange: scripInfo
                                                              .optionExch!,
                                                          numofStrike: scripInfo
                                                              .numStrike,
                                                          strPrc: scripInfo
                                                              .optionStrPrc,
                                                          tradeSym: scripInfo
                                                              .selectedTradeSym!);
                                                } else if (scripInfo
                                                            .depthBtns[index]
                                                        ['btnName'] ==
                                                    "Future") {
                                                  await scripInfo.requestWSFut(
                                                      context: context,
                                                      isSubscribe: true);
                                                }

                                                setState(() {
                                                  initSize = .99;

                                                  scripInfo.chngDephBtn(
                                                      scripInfo.depthBtns[index]
                                                          ['btnName']);
                                                });
                                                if (scripInfo.actDeptBtn ==
                                                    "Overview") {
                                                  await watch(websocketProvider)
                                                      .establishConnection(
                                                          channelInput:
                                                              "${depthData.exch}|${depthData.token}",
                                                          task: "d",
                                                          context: context);
                                                }

                                                if (scripInfo.actDeptBtn ==
                                                    "Fundamental") {
                                                  scripInfo.chngshareHold(
                                                      "Promoter Holding");
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 0),
                                                  backgroundColor: theme
                                                          .isDarkMode
                                                      ? scripInfo.actDeptBtn ==
                                                              scripInfo.depthBtns[
                                                                      index]
                                                                  ['btnName']
                                                          ? colors.colorbluegrey
                                                          : const Color(
                                                                  0xffB5C0CF)
                                                              .withOpacity(.15)
                                                      : scripInfo.actDeptBtn ==
                                                              scripInfo.depthBtns[
                                                                      index]
                                                                  ['btnName']
                                                          ? const Color(
                                                              0xff000000)
                                                          : const Color(
                                                              0xffF1F3F8),
                                                  shape: const StadiumBorder()),
                                              child: Row(children: [
                                                SvgPicture.asset(
                                                  "${scripInfo.depthBtns[index]['imgPath']}",
                                                  color: theme.isDarkMode
                                                      ? Color(scripInfo
                                                                  .actDeptBtn ==
                                                              scripInfo.depthBtns[
                                                                      index]
                                                                  ['btnName']
                                                          ? 0xff000000
                                                          : 0xffffffff)
                                                      : Color(scripInfo
                                                                  .actDeptBtn ==
                                                              scripInfo.depthBtns[
                                                                      index]
                                                                  ['btnName']
                                                          ? 0xffffffff
                                                          : 0xff000000),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                    "${scripInfo.depthBtns[index]['btnName']}",
                                                    style: textStyle(
                                                        theme.isDarkMode
                                                            ? Color(scripInfo
                                                                        .actDeptBtn ==
                                                                    scripInfo.depthBtns[
                                                                            index]
                                                                        [
                                                                        'btnName']
                                                                ? 0xff000000
                                                                : 0xffffffff)
                                                            : Color(scripInfo
                                                                        .actDeptBtn ==
                                                                    scripInfo.depthBtns[
                                                                            index]
                                                                        [
                                                                        'btnName']
                                                                ? 0xffffffff
                                                                : 0xff000000),
                                                        12.5,
                                                        FontWeight.w500))
                                              ]));
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return const SizedBox(width: 10);
                                        })),
                                if (scripInfo.actDeptBtn == "Option") ...[
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          right: 3,
                                          left: 16,
                                          top: 10,
                                          bottom: 8),
                                      child: SizedBox(
                                          height: 32,
                                          child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              controller: _controller,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14),
                                                  decoration: BoxDecoration(
                                                      color: theme.isDarkMode
                                                          ? scripInfo.selectedExpDate! ==
                                                                  scripInfo
                                                                          .sortDate[
                                                                      index]
                                                              ? const Color(
                                                                  0xffF1F3F8)
                                                              : const Color(
                                                                      0xffB5C0CF)
                                                                  .withOpacity(
                                                                      .15)
                                                          : scripInfo.selectedExpDate! ==
                                                                  scripInfo
                                                                          .sortDate[
                                                                      index]
                                                              ? const Color(
                                                                  0xff000000)
                                                              : const Color(
                                                                  0xffF1F3F8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              98)),
                                                  child: InkWell(
                                                      onTap: () async {
                                                        if (scripInfo.sortDate
                                                                .length <=
                                                            12) {
                                                          _controller.animateTo(
                                                              scripInfo.sortDate
                                                                          .length <=
                                                                      4
                                                                  ? index * 40
                                                                  : index * 100,
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                              curve: Curves
                                                                  .fastOutSlowIn);
                                                        } else {
                                                          _controller.animateTo(
                                                              index * 112,
                                                              duration:
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                              curve: Curves
                                                                  .fastOutSlowIn);
                                                        }

                                                        for (var i = 0;
                                                            i <
                                                                scripInfo
                                                                    .optExp!
                                                                    .length;
                                                            i++) {
                                                          if (scripInfo
                                                                      .sortDate[
                                                                  index] ==
                                                              scripInfo
                                                                  .optExp![i]
                                                                  .exd) {
                                                            scripInfo.selecTradSym(
                                                                "${scripInfo.optExp![i].tsym}");
                                                            scripInfo.optExch(
                                                                "${scripInfo.optExp![i].exch}");
                                                          }
                                                        }
                                                        scripInfo.selecexpDate(
                                                            scripInfo.sortDate[
                                                                index]);

                                                        await context
                                                            .read(
                                                                marketWatchProvider)
                                                            .fetchOPtionChain(
                                                                context:
                                                                    context,
                                                                exchange: scripInfo
                                                                    .optionExch!,
                                                                numofStrike:
                                                                    scripInfo
                                                                        .numStrike,
                                                                strPrc: scripInfo
                                                                    .optionStrPrc,
                                                                tradeSym: scripInfo
                                                                    .selectedTradeSym!);
                                                      },
                                                      child: Text(
                                                          scripInfo
                                                              .sortDate[index]
                                                              .replaceAll(
                                                                  "-", " "),
                                                          style: textStyle(
                                                              theme.isDarkMode
                                                                  ? Color(scripInfo
                                                                              .selectedExpDate! ==
                                                                          scripInfo.sortDate[
                                                                              index]
                                                                      ? 0xff000000
                                                                      : 0xffffffff)
                                                                  : Color(scripInfo
                                                                              .selectedExpDate! ==
                                                                          scripInfo
                                                                              .sortDate[index]
                                                                      ? 0xffffffff
                                                                      : 0xff000000),
                                                              12.5,
                                                              FontWeight.w500))),
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, index) {
                                                return const SizedBox(width: 8);
                                              },
                                              shrinkWrap: true,
                                              itemCount:
                                                  scripInfo.sortDate.length))),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      height: 36,
                                      color: theme.isDarkMode
                                          ? const Color(0xffB5C0CF)
                                              .withOpacity(.15)
                                          : const Color(0xffFAFBFF),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text("OI",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    13,
                                                    FontWeight.w500)),
                                            Text("    Call LTP ",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    13,
                                                    FontWeight.w500)),
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                child: InkWell(
                                                    onTap: () {
                                                      showModalBottomSheet(
                                                          useSafeArea: true,
                                                          isScrollControlled:
                                                              true,
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                      top: Radius.circular(
                                                                          16))),
                                                          context: context,
                                                          builder: (context) =>
                                                              Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(16),
                                                                      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                            color: Color(
                                                                                0xff999999),
                                                                            blurRadius:
                                                                                4.0,
                                                                            offset:
                                                                                Offset(2.0, 0.0))
                                                                      ]),
                                                                  padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16.0),
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment.start,
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        const CustomDragHandler(),
                                                                        Text(
                                                                            "Select Number of Strike",
                                                                            style:
                                                                                textStyles.appBarTitleTxt.copyWith(color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack)),
                                                                        const SizedBox(
                                                                            height:
                                                                                6),
                                                                        Flexible(
                                                                            child: ListView.separated(
                                                                                physics: const ClampingScrollPhysics(),
                                                                                itemBuilder: (context, index) {
                                                                                  return ListTile(
                                                                                      onTap: () async {
                                                                                        scripInfo.selecNumStrike(scripInfo.numStrikes[index]);
                                                                                        await context.read(marketWatchProvider).fetchOPtionChain(context: context, exchange: scripInfo.optionExch!, numofStrike: scripInfo.numStrikes[index], strPrc: scripInfo.optionStrPrc, tradeSym: scripInfo.selectedTradeSym!);
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                                                                      dense: true,
                                                                                      title: Text(scripInfo.numStrikes[index] == "50" ? "All" : scripInfo.numStrikes[index], style: textStyle( scripInfo.numStrike == scripInfo.numStrikes[index] && theme.isDarkMode?colors.colorLightBlue:scripInfo.numStrike == scripInfo.numStrikes[index] ?colors.colorBlue:colors.colorGrey, 14,  scripInfo.numStrike == scripInfo.numStrikes[index]?FontWeight.w600:FontWeight.w500)
                                                                                       ),
                                                                                      trailing: SvgPicture.asset(
                                                                                        
                                                                                      theme.isDarkMode?  scripInfo.numStrike == scripInfo.numStrikes[index] ? assets.darkActProductIcon : assets.darkProductIcon:  
                                                                                        scripInfo.numStrike == scripInfo.numStrikes[index] ? assets.actProductIcon : assets.productIcon));
                                                                                },
                                                                                separatorBuilder: (context, index) {
                                                                                  return const ListDivider();
                                                                                },
                                                                                shrinkWrap: true,
                                                                                itemCount: scripInfo.numStrikes.length))
                                                                      ])));
                                                    },
                                                    child: Row(children: [
                                                      Text(
                                                          "${scripInfo.numStrike == "50" ? "All" : scripInfo.numStrike} ",
                                                          style: textStyle(
                                                             theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
                                                              13,
                                                              FontWeight.w500)),
                                                      Text("Strike",
                                                          style: textStyle(theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
                                                              13,
                                                              FontWeight.w500)),
 Icon(
                                                          Icons.arrow_drop_down,
                                                          color:
                                                              theme.isDarkMode?colors.colorLightBlue:colors.colorBlue,
                                                          size: 20)
                                                    ]))),
                                            Text("  Put LTP    ",
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
                                          ]))
                                ]
                              ])
                        ]),
                    Expanded(
                        child: ListView(
                            physics: scripInfo.actDeptBtn == "Chart"
                                ? const NeverScrollableScrollPhysics()
                                : const AlwaysScrollableScrollPhysics(),
                            controller: scrollController,
                            children: [
                          if (scripInfo.actDeptBtn == "Overview") ...[
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      rowOfInfoData(
                                          "Open",
                                          "${depthData.o ?? 0.00}",
                                          "Close",
                                          "${depthData.c ?? 0.00}",
                                          theme),
                                      const SizedBox(height: 4),
                                      Text("Low - High",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              12,
                                              FontWeight.w500)),
                                      const SizedBox(height: 4),
                                      lowHighBar(
                                          "${depthData.l ?? 0.00}",
                                          "${depthData.h ?? 0.00}",
                                          "${depthData.lp ?? depthData.c ?? 0.00}",
                                          theme),
                                      const SizedBox(height: 2),
                                      Divider(color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider),
                                      if (depthData.wk52L != null &&
                                          depthData.wk52H != null) ...[
                                        const SizedBox(height: 6),
                                        Text("52 Week Low - 52 Week High",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                12,
                                                FontWeight.w500)),
                                        const SizedBox(height: 4),
                                        lowHighBar(
                                            "${depthData.wk52L ?? 0.00}",
                                            "${depthData.wk52H ?? 0.00}",
                                            "${depthData.lp ?? depthData.c ?? 0.00}",
                                            theme),
                                        Divider(color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider),
                                        const SizedBox(height: 6)
                                      ],
                                      if (widget.wlValue.instname != "UNDIND" &&
                                          widget.wlValue.instname != "COM") ...[
                                        Text("Market Depth",
                                            style: textStyle(
                                                theme.isDarkMode
                                                    ? colors.colorWhite
                                                    : colors.colorBlack,
                                                14,
                                                FontWeight.w600)),
                                        const SizedBox(height: 6),
                                        Row(children: [
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Qty",
                                                          style: textStyle(
                                                              const Color(
                                                                  0XFF506D84),
                                                              13,
                                                              FontWeight.w600)),
                                                      Text("Bid",
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff43A833),
                                                              13,
                                                              FontWeight.w600))
                                                    ]),
                                                const SizedBox(height: 7),
                                                depthPercentageBuy(
                                                    "${depthData.bq1 ?? 0}",
                                                    "${depthData.bp1 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageBuy(
                                                    "${depthData.bq2 ?? 0}",
                                                    "${depthData.bp2 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageBuy(
                                                    "${depthData.bq3 ?? 0}",
                                                    "${depthData.bp3 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageBuy(
                                                    "${depthData.bq4 ?? 0}",
                                                    "${depthData.bp4 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageBuy(
                                                    "${depthData.bq5 ?? 0}",
                                                    "${depthData.bp5 ?? 0.00}",
                                                    scripInfo,
                                                    theme)
                                              ])),
                                          const SizedBox(width: 20),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Ask",
                                                          style: textStyle(
                                                              colors.darkred,
                                                              13,
                                                              FontWeight.w600)),
                                                      Text("Qty",
                                                          style: textStyle(
                                                              const Color(
                                                                  0XFF506D84),
                                                              13,
                                                              FontWeight.w600))
                                                    ]),
                                                const SizedBox(height: 7),
                                                depthPercentageSell(
                                                    "${depthData.sq1 ?? 0}",
                                                    "${depthData.sp1 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageSell(
                                                    "${depthData.sq2 ?? 0}",
                                                    "${depthData.sp2 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageSell(
                                                    "${depthData.sq3 ?? 0}",
                                                    "${depthData.sp3 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageSell(
                                                    "${depthData.sq4 ?? 0}",
                                                    "${depthData.sp4 ?? 0.00}",
                                                    scripInfo,
                                                    theme),
                                                const SizedBox(height: 6),
                                                depthPercentageSell(
                                                    "${depthData.sq5 ?? 0}",
                                                    "${depthData.sp5 ?? 0.00}",
                                                    scripInfo,
                                                    theme)
                                              ]))
                                        ]),
                                        const SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("${depthData.tbq ?? 0}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      15,
                                                      FontWeight.w600)),
                                              Text("${depthData.tsq ?? 0}",
                                                  style: textStyle(
                                                      theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack,
                                                      15,
                                                      FontWeight.w600))
                                            ]),
                                        const SizedBox(height: 6),
                                        LinearPercentIndicator(
                                            leading: Text(
                                                "${scripInfo.totBuyQtyPer.toStringAsFixed(2)}%",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500)),
                                            trailing: Text(
                                                "${scripInfo.totSellQtyPer.toStringAsFixed(2)}%",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500)),
                                            lineHeight: 12.0,
                                            barRadius: const Radius.circular(4),
                                            backgroundColor:
                                                (scripInfo.totBuyQtyPer.toStringAsFixed(2) ==
                                                            "0.00" &&
                                                        scripInfo.totSellQtyPer.toStringAsFixed(2) ==
                                                            "0.00")
                                                    ? const Color(0xffECEDEE)
                                                    : const Color(0XFFD34645),
                                                       
                                            percent: scripInfo.totBuyQtyPerChng,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14),
                                            progressColor: const Color(0xff43A833)
                                               ),
                                        const SizedBox(height: 5),
                                        Divider(color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider)
                                      ],
                                      const SizedBox(height: 4),
                                      if ((widget.wlValue.instname !=
                                              "UNDIND" &&
                                          widget.wlValue.instname !=
                                              "COM")) ...[
                                        rowOfInfoData(
                                            "Avg Price",
                                            "${depthData.ap ?? 0.00}",
                                            "Volume",
                                            "${depthData.v ?? 0.00}",
                                            theme),
                                        const SizedBox(height: 4),
                                        rowOfInfoData(
                                            "Lower Circuit",
                                            "${depthData.lc ?? 0.00}",
                                            "Upper Circuit",
                                            "${depthData.uc ?? 0.00}",
                                            theme),
                                        const SizedBox(height: 4),
                                        rowOfInfoData(
                                            "Last Trade Qty",
                                            "${depthData.ltq ?? 0}",
                                            "Last Trade Time",
                                            depthData.ltt ?? "--",
                                            theme),
                                        const SizedBox(height: 4),
                                        if (depthData.seg != "EQT") ...[
                                          rowOfInfoData(
                                              "Open Intrest",
                                              "${depthData.oi ?? 0.00}",
                                              "Change in OI",
                                              "${depthData.poi ?? 0.00}",
                                              theme),
                                          const SizedBox(height: 4),
                                        ],
                                        if (    scripInfo.returnsGridview.isNotEmpty) ...[
                                          Text("Returns",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  14,
                                                  FontWeight.w600)),
                                          const SizedBox(height: 8),
                                          GridView.count(
                                              crossAxisCount: 3,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              crossAxisSpacing: 12,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 1.8,
                                              children: List.generate(
                                                  scripInfo.returnsGridview
                                                      .length, (index) {
                                                return Container(
                                                    width: 120,
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            vertical: 7,
                                                            horizontal: 8),
                                                    decoration: BoxDecoration(
                                                        color: const Color(0xffB5C0CF)
                                                            .withOpacity(.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)
                                                        ),
                                                    child: Column(children: [
                                                      Text(
                                                          "${scripInfo.returnsGridview[index]['percent']}%",
                                                          style: textStyle(
                                                              Color(scripInfo
                                                                      .returnsGridview[
                                                                          index]
                                                                          [
                                                                          'percent']
                                                                      .toString()
                                                                      .startsWith(
                                                                          "-")
                                                                  ? 0xffF44336
                                                                  : 0xff43A833),
                                                              18,
                                                              FontWeight.w500)),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                          "${scripInfo.returnsGridview[index]['duration']}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: textStyle(
                                                              const Color(
                                                                  0xff666666),
                                                              12,
                                                              FontWeight.w500))
                                                    ]));
                                              }))
                                        ]
                                      ]
                                    ]))
                          ] else if (scripInfo.actDeptBtn == "Fundamental") ...[
                            if (context
                                    .read(marketWatchProvider)
                                    .fundamentalData!
                                    .msg
                                    .toString() !=
                                "no data found") ...[
                              const SizedBox(height: 10),
                          
                               const FundamentalDataWidget(),
                            ]else...[NoDataFound()]
                          ] else if (scripInfo.actDeptBtn == "Chart") ...[
                            ChartScreenWebView(chartArgs: chartArgs!)
                          ] else if (scripInfo.actDeptBtn == "Option") ...[
                            if (scripInfo.isLoad)
                              const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xff0037B7)))
                            else
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Row(children: <Widget>[
                                    Flexible(
                                      child: OptChainCallList(
                                          callData: scripInfo.optChainCallUP,
                                          isCallUp: true),
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: StrikePriceListCard(
                                          strike: scripInfo.optChainCallUP,
                                          isCallUp: true),
                                    ),
                                    Flexible(
                                      child: OptChainPutList(
                                          putData: scripInfo.optChainPutUp,
                                          isPutUp: true),
                                    )
                                  ])),
                            CurStrkprice(
                                token: depthData.undTk ?? depthData.token!),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(children: [
                                Flexible(
                                  child: OptChainCallList(
                                      callData: scripInfo.optChainCallDown,
                                      isCallUp: false),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: StrikePriceListCard(
                                      strike: scripInfo.optChainCallDown,
                                      isCallUp: false),
                                ),
                                Flexible(
                                  child: OptChainPutList(
                                      putData: scripInfo.optChainPutDown,
                                      isPutUp: false),
                                )
                              ]),
                            )
                          ] else if (scripInfo.actDeptBtn == "Future") ...[
                            const FutureScreen()
                          ] else if (scripInfo.actDeptBtn == "Set Alert") ...[
                            SetAlert(
                                depthdata: depthData, wlvalue: widget.wlValue)
                          ]
                        ])),
                    if (widget.wlValue.instname != "UNDIND" &&
                        widget.wlValue.instname != "COM")
                      scripInfo.actDeptBtn == "Set Alert"
                          ? Container()
                          : Container(
                              decoration:   BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider))),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: InkWell(
                                      onTap: () async {
                                        if (depthData.ordMsg == null) {
                                          await placeOrderInput(
                                              scripInfo, ctx, depthData, true);
                                        } else {
                                          exchAlert( 
                                              ctx, depthData, scripInfo, true,theme);
                                        }
                                      },
                                      child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              color: const Color(0xff43A833),
                                              borderRadius:
                                                  BorderRadius.circular(108)),
                                          child: Center(
                                              child: Text("BUY",
                                                  style: textStyle(
                                                      const Color(0XFFFFFFFF),
                                                      16,
                                                      FontWeight.w600)))),
                                    )),
                                    const SizedBox(width: 18),
                                    Expanded(
                                        child: InkWell(
                                            onTap: () async {
                                              if (depthData.ordMsg == null) {
                                                await placeOrderInput(scripInfo,
                                                    ctx, depthData, false);
                                              } else {
                                                exchAlert(ctx, depthData,
                                                    scripInfo, false,theme);
                                              }
                                            },
                                            child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    color:
                                                        colors.darkred,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            108)),
                                                child: Center(
                                                    child: Text("SELL",
                                                        style: textStyle(
                                                            const Color(
                                                                0XFFFFFFFF),
                                                            16,
                                                            FontWeight
                                                                .w600))))))
                                  ])),
                    const SizedBox(height: 18)
                  ]),
            );
          });
    }));
  }

  Future<dynamic> exchAlert(BuildContext ctx, GetQuotes depthData,
      MarketWatchProvider scripInfo, bool transType, ThemesProvider theme) {
    return showDialog(
        context: ctx,
        builder: (BuildContext context) {
          return AlertDialog(   backgroundColor:theme.isDarkMode? const Color.fromARGB(255, 18, 18, 18):colors.colorWhite,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16))),
            scrollable: true,
            actionsPadding:
                const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 3),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            titlePadding: const EdgeInsets.only(left: 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Alert!',
                    style: textStyle( !theme.isDarkMode? colors.colorBlack:colors.colorWhite, 16, FontWeight.w600)),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close_rounded))
              ],
            ),
            content: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(children: [
                  Divider(color: colors.colorDivider, height: 0),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text("${depthData.tsym} ",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: textStyles.appBarTitleTxt.copyWith(color: !theme.isDarkMode? colors.colorBlack:colors.colorWhite)),
                     CustomExchBadge(exch: "${depthData.exch}")
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: Text("${depthData.ordMsg}",
                            style: textStyle(
                                !theme.isDarkMode? colors.colorBlack:colors.colorWhite, 14, FontWeight.w500)))
                  ]),
                  const SizedBox(height: 10),
                ])),
            actions: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await placeOrderInput(
                          scripInfo, ctx, depthData, transType);
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: !theme.isDarkMode? colors.colorBlack:colors.colorbluegrey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50))),
                    child: Text("Proceed",
                        style: textStyle(
                         theme.isDarkMode? colors.colorBlack:colors.colorWhite, 14, FontWeight.w500))),
              ),
            ],
          );
        });
  }

  Future<void> placeOrderInput(MarketWatchProvider scripInfo, BuildContext ctx,
      GetQuotes depthData, bool transType) async {
    await scripInfo.fetchScripInfo(
        widget.wlValue.token, widget.wlValue.exch, ctx);
    Navigator.pop(ctx);
    OrderScreenArgs orderArgs = OrderScreenArgs(
        exchange: widget.wlValue.exch,
        tSym: widget.wlValue.tsym,
        isExit: false,
        token: widget.wlValue.token,
        transType: transType,
        // change: depthData.chng,
        // close: depthData.c,
        lotSize: depthData.ls,
        ltp: depthData.lp ?? "0.00",
        perChange: depthData.pc ?? "0.00",
        orderTpye: '',
        holdQty: '',
        isModify: false);
    Navigator.pushNamed(ctx, Routes.placeOrderScreen, arguments: {
      "orderArg": orderArgs,
      "scripInfo": ctx.read(marketWatchProvider).scripInfoModel!
    });
  }

 Row lowHighBar(String low, String high, String value, ThemesProvider theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(
          "${double.parse(low) <= double.parse(value) ? double.parse(low) : double.parse(value)}",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500)),
      SizedBox(
        width: MediaQuery.of(context).size.width / 1.8,
        child: FlutterSlider(
          handlerHeight: 20,
          handlerWidth: 12,
          handler: FlutterSliderHandler(
              child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: theme.isDarkMode
                              ? Color(0xffB0BEC5)
                              : Color(0xff000000)),
                      child: const Center(
                          child: Text(
                        ' ',
                        style: TextStyle(color: Colors.transparent),
                      ))))),
          tooltip: FlutterSliderTooltip(
            disabled: true,
          ),
          trackBar: FlutterSliderTrackBar(
            inactiveDisabledTrackBarColor: Color(0xff666666).withOpacity(.2),
            activeDisabledTrackBarColor: theme.isDarkMode
                ? Color.fromARGB(255, 36, 35, 35).withOpacity(.2)
                : Color.fromARGB(255, 247, 246, 246).withOpacity(.2),
            activeTrackBarHeight: 4,
            inactiveTrackBarHeight: 4,
          ),
          min: double.parse(low) <= double.parse(value)
              ? double.parse(low)
              : double.parse(value),
          max: double.parse(high) >= double.parse(value)
              ? double.parse(high)
              : double.parse(value),
          values: [double.parse(value)],
          onDragging: (handlerIndex, lowerValue, upperValue) {},
          jump: false,
          disabled: true,
        ),
      ),
      Text(
          "${double.parse(high) >= double.parse(value) ? double.parse(high) : double.parse(value)}",
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500))
    ]);
  }

  Row rowOfInfoData(String title1, String value1, String title2, String value2,
      ThemesProvider theme) {
    return Row(children: [
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title1,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value1,
            style: textStyle(
                theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                14,
                FontWeight.w500)),
        const SizedBox(height: 2),
        Divider(color:theme.isDarkMode?colors.darkColorDivider: colors.colorDivider)
      ])),
      const SizedBox(width: 24),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title2,
            style: textStyle(const Color(0xff666666), 12, FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value2,
          style: textStyle(
              theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              14,
              FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Divider(color: theme.isDarkMode?colors.darkColorDivider: colors.colorDivider)
      ]))
    ]);
  }

  Stack depthPercentageSell(
      sellQty, sellPrc, MarketWatchProvider scripInfo, ThemesProvider theme) {
    String val = (((int.parse("$sellQty") / scripInfo.maxSellQty) * 100) / 100)
        .toStringAsFixed(2);
    double barPercentage = double.parse(val);

    return Stack(children: [
      Transform.flip(
          flipX: true,
          child: LinearPercentIndicator(
              lineHeight: 20.0,
              backgroundColor:
                  !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              percent: barPercentage.isNaN
                  ? 0.00
                  : barPercentage >= 1
                      ? 1
                      : barPercentage,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              progressColor: colors.darkred.withOpacity(.2))),
      Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                qtyDepthTexts(sellPrc, theme),
                qtyDepthTexts(sellQty, theme)
              ]))
    ]);
  }

  Stack depthPercentageBuy(
      buyQty, buyPrc, MarketWatchProvider scripInfo, ThemesProvider theme) {
    String val = (((int.parse("$buyQty") / scripInfo.maxBuyQty) * 100) / 100)
        .toStringAsFixed(2);
    double barPercentage = double.parse(val);
    return Stack(children: [
      LinearPercentIndicator(
          lineHeight: 20.0,
          backgroundColor:
              !theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          percent: barPercentage.isNaN
              ? 0.00
              : barPercentage >= 1
                  ? 1
                  : barPercentage,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          progressColor: colors.ltpgreen.withOpacity(.2)),
      Padding(
          padding: const EdgeInsets.only(top: 1.5),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                qtyDepthTexts(buyQty, theme),
                qtyDepthTexts(buyPrc, theme)
              ]))
    ]);
  }

  Text qtyDepthTexts(String? text, ThemesProvider theme) {
    return Text(" ${text ?? 0} ",
        style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            13,
            FontWeight.w500));
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
