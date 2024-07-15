
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../models/websockt_model/touchline_ack.dart';
// import '../../../provider/portfolio_provider.dart';
// import '../../../provider/websocket_provider.dart';

// class HoldingsListCard extends ConsumerWidget {
   
//   const HoldingsListCard(
//       {Key? key, })
//       : super(key: key);

 

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final portfolioProvide = watch(portfolioProvider);
//     return StreamBuilder(
//         stream: context
//             .read(websocketProvider)
//             .touchAcknowledgementStream
//             .stream
//             .where(
//               (event) =>
//                   event.tk ==
//                   (data.exchSeg1 == 'NSE' ? data.token1! : data.token2!),
//             ),
//         builder:
//             (_, AsyncSnapshot<TouchlineAckStream> snapshotAck) {
//           if (snapshotAck.data != null) {
//             data.ltp = snapshotAck.data!.lp == 'null'
//                 ? data.ltp
//                 : snapshotAck.data!.lp;
//             data.close = snapshotAck.data!.c == 'null'
//                 ? data.close
//                 : snapshotAck.data!.c;
//             data.percentageChange = snapshotAck.data!.pc == 'null'
//                 ? data.percentageChange
//                 : snapshotAck.data!.pc;
//           }
//           return StreamBuilder(
//               stream: context.read(websocketProvider).mwStream.stream.where(
//                     (event) =>
//                         event.tk ==
//                         (data.exchSeg1 == 'NSE' ? data.token1! : data.token2!),
//                   ),
//               builder: (_, AsyncSnapshot<UpdateStream> snapshot) {
//                 if (snapshot.data != null) {
//                   if (snapshot.data!.tk ==
//                       (data.exchSeg1 == 'NSE' ? data.token1! : data.token2!)) {
//                     if (snapshot.data!.lp != null &&
//                         (data.ltp != snapshot.data!.lp!)) {
//                       final double previousLtp = double.parse(data.ltp!);
//                       log("LTP :::: ${data.ltp}");
//                       log("LTP :::: 1 ${snapshot.data!.lp}");
//                       // portfolioProvide.setcurrentValue((double.parse(
//                       //           portfolioProvide.currentValue
//                       //               .replaceAll(",", ""),
//                       //         ) -
//                       //         (previousLtp * double.parse(data.sellableQty!)))
//                       //     .toStringAsFixed(2));
//                       data.ltp = snapshot.data!.lp == null ||
//                               snapshot.data!.lp! == 'null'
//                           ? data.ltp
//                           : snapshot.data!.lp!;
//                       data.percentageChange = snapshot.data!.pc == null ||
//                               snapshot.data!.pc! == 'null'
//                           ? data.percentageChange
//                           : snapshot.data!.pc!;
//                       // portfolioProvide.setcurrentValue((double.parse(
//                       //           portfolioProvide.currentValue
//                       //               .replaceAll(",", ""),
//                       //         ) +
//                       //         (double.parse(data.ltp!) *
//                       //             double.parse(data.sellableQty!)))
//                       //     .toStringAsFixed(2));
//                     }

//                     final String pnl =
//                         ((double.parse(data.ltp!) - double.parse(data.price!)) *
//                                 (data.sellableQty! == '0'
//                                     ? double.parse(data.btst!)
//                                     : double.parse(data.sellableQty!).ceil() +
//                                         double.parse(data.btst!).ceil()))
//                             .toStringAsFixed(2);
//                     final String todayPnlChange = ((double.parse(data.ltp!) -
//                                 double.parse(data.previousDayClose!)) *
//                             (data.sellableQty! == '0'
//                                 ? double.parse(data.btst!)
//                                 : double.parse(data.sellableQty!).ceil() +
//                                     double.parse(data.btst!).ceil()))
//                         .toStringAsFixed(2);
//                     final String percentageChange = (((double.parse(data.ltp!) -
//                                     double.parse(data.price!)) /
//                                 double.parse(data.price!)) *
//                             100)
//                         .toStringAsFixed(2);
//                     // if (investedData.pnl != pnl) {
//                     //   portfolioProvide.settotalPnl((double.parse(
//                     //               portfolioProvide.totalPnl
//                     //                   .replaceAll(",", "")) -
//                     //           double.parse(investedData.pnl!))
//                     //       .toStringAsFixed(2));

//                     //   portfolioProvide.setgetTodayPnl(
//                     //       portfolioProvide.getTodayPnl -
//                     //           double.parse(investedData.todayPnl ?? '0.00'));

//                     //   investedData.pnl = pnl;
//                     //   investedData.todayPnl = todayPnlChange;
//                     //   investedData.percentageChange = percentageChange;
//                     //   portfolioProvide.settotalPnl((double.parse(
//                     //               portfolioProvide.totalPnl
//                     //                   .replaceAll(",", "")) +
//                     //           double.parse(pnl))
//                     //       .toStringAsFixed(2));
//                     //   portfolioProvide.setgetTodayPnl(
//                     //       portfolioProvide.getTodayPnl +
//                     //           double.parse(investedData.todayPnl!));
//                     //   // ignore: unnecessary_parenthesis
//                     //   portfolioProvide.settotalPercentageChange(((double.parse(
//                     //                   portfolioProvide.currentValue
//                     //                       .toString()
//                     //                       .replaceAll(",", "")) -
//                     //               double.parse(portfolioProvide.totalInvested!
//                     //                   .replaceAll(",", ""))) /
//                     //           double.parse(portfolioProvide.totalInvested!
//                     //               .replaceAll(",", ""))) *
//                     //       100);

//                     //   portfolioProvide.setgetTodayTotalPercentageChange(
//                     //       ((double.parse(portfolioProvide.currentValue
//                     //                       .toString()
//                     //                       .replaceAll(",", "")) -
//                     //                   portfolioProvide
//                     //                       .getTotalPreviousDayPrice) /
//                     //               portfolioProvide.getTotalPreviousDayPrice) *
//                     //           100);
//                     //   log("Pc::::${portfolioProvide.getTodayTotalPercentageChange}");

//                     //   // log('portfolioProvide.getTodayPnl ${portfolioProvide.totalPercentageChange}');
//                     // }
//                   }
//                 }

//                 return Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: sizes.mediumPadding,
//                       vertical: sizes.regularPadding),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               text: "Qty. ",
//                               style: textStyles.kTextSubtitle2.copyWith(
//                                   color: context.read(themeProvider).isDarkMode
//                                       ? colors.kColorWhite60
//                                       : colors.kColorBlack60),
//                               children: <TextSpan>[
//                                 TextSpan(
//                                     text: '${data.sellableQty}',
//                                     style: textStyles.kTextSubtitle2.copyWith(
//                                         color: context
//                                                 .read(themeProvider)
//                                                 .isDarkMode
//                                             ? colors.kColorlightThemeBackground
//                                             : colors.kColorDarkThemeBackground,
//                                         letterSpacing: 0.3)),
//                                 // ignore: unrelated_type_equality_checks
//                                 // ignore: prefer_if_elements_to_conditional_expressions
//                                 data.btst != "0"
//                                     ? TextSpan(
//                                         text: ' (T1 : ${data.btst}) ',
//                                         style: textStyles.kTextSubtitle2
//                                             .copyWith(
//                                                 color: context
//                                                         .read(themeProvider)
//                                                         .isDarkMode
//                                                     ? colors.kColorWhite60
//                                                     : colors.kColorBlack60,
//                                                 letterSpacing: 0.3))
//                                     : const TextSpan(),
//                                 TextSpan(
//                                   text: ' | ',
//                                   style: textStyles.kTextSubtitle2.copyWith(
//                                     color:
//                                         context.read(themeProvider).isDarkMode
//                                             ? colors.kColorlightThemeBackground
//                                             : colors.kColorBlack,
//                                     letterSpacing: 0.3,
//                                   ),
//                                 ),
//                                 TextSpan(
//                                     text: 'Avg. ',
//                                     style: textStyles.kTextSubtitle2.copyWith(
//                                         color: context
//                                                 .read(themeProvider)
//                                                 .isDarkMode
//                                             ? colors.kColorWhite60
//                                             : colors.kColorBlack60)),
//                                 TextSpan(
//                                     text: formatCurrencyStandard(
//                                         value: getFormatedNumValue(
//                                             // ignore: unnecessary_string_interpolations
//                                             "${data.price}",
//                                             showSign: false,
//                                             afterPoint: 2)),
//                                     style: textStyles.kTextSubtitle2.copyWith(
//                                         color: context
//                                                 .read(themeProvider)
//                                                 .isDarkMode
//                                             ? colors.kColorlightThemeBackground
//                                             : colors.kColorBlack,
//                                         letterSpacing: 0.3)),
//                               ],
//                             ),
//                           ),
//                           Text(
//                             '${investedData.percentageChange!.toLowerCase() == 'infinity' ? '0.00' : investedData.percentageChange!} %',
//                             style: textStyles.kTextSubtitle2.copyWith(
//                               color: double.parse(
//                                 '${investedData.percentageChange}',
//                               ).isNegative
//                                   ? colors.kColorRedText
//                                   : colors.kColorGreenText,
//                               letterSpacing: 0.3,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Sizer.vertical10(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             // ignore: unnecessary_string_interpolations
//                             "${data.exchSeg1 == 'NSE' ? data.nsetsym : data.bsetsym}",
//                             style: textStyles.kTextTitle.copyWith(
//                                 color: context.read(themeProvider).isDarkMode
//                                     ? colors.kColorlightThemeBackground
//                                     : colors.kColorAccentBlack),
//                           ),
//                           Text(investedData.pnl.toString(),
//                               style: textStyles.kTextTitle.copyWith(
//                                   color: investedData.pnl
//                                               .toString()
//                                               .substring(0, 1) ==
//                                           '-'
//                                       ? colors.kColorRedText
//                                       : colors.kColorGreenText,
//                                   letterSpacing: 0.3)),
//                         ],
//                       ),
//                       Sizer.vertical10(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               text: "Invested ",
//                               style: textStyles.kTextSubtitle2.copyWith(
//                                   color: context.read(themeProvider).isDarkMode
//                                       ? colors.kColorWhite60
//                                       : colors.kColorBlack60),
//                               children: <TextSpan>[
//                                 TextSpan(
//                                     text: investedData.invest.toString(),
//                                     style: textStyles.kTextSubtitle2.copyWith(
//                                         color: context
//                                                 .read(themeProvider)
//                                                 .isDarkMode
//                                             ? colors.kColorlightThemeBackground
//                                             : colors.kColorBlack,
//                                         letterSpacing: 0.3)),
//                               ],
//                             ),
//                           ),
//                           RichText(
//                             text: TextSpan(
//                               text: "LTP",
//                               style: textStyles.kTextSubtitle2.copyWith(
//                                   color: context.read(themeProvider).isDarkMode
//                                       ? colors.kColorWhite60
//                                       : colors.kColorBlack60),
//                               children: <TextSpan>[
//                                 TextSpan(
//                                     text:
//                                         // ignore: unnecessary_string_interpolations
//                                         ' ${getFormatedNumValue("${data.ltp}", showSign: false, afterPoint: 2)} ',
//                                     style: textStyles.kTextSubtitle2.copyWith(
//                                         color: context
//                                                 .read(themeProvider)
//                                                 .isDarkMode
//                                             ? colors.kColorlightThemeBackground
//                                             : colors.kColorBlack,
//                                         letterSpacing: 0.3)),
//                                 TextSpan(
//                                     text:
//                                         '(${data.percentageChange!.toLowerCase() == 'infinity' || data.percentageChange!.toLowerCase() == 'nan' ? '0.00' : data.percentageChange!}%)',
//                                     style: textStyles.kTextSubtitle2.copyWith(
//                                         color: data.percentageChange!
//                                                 .startsWith('-')
//                                             ? colors.kColorRedText
//                                             : colors.kColorGreenText,
//                                         letterSpacing: 0.3)),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               });
//         });
//   }
// }