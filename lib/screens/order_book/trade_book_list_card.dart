// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import '../../models/order_book_model/trade_book_model.dart';
// import '../../provider/order_provider.dart';
// import '../../provider/thems.dart';
// import '../../res/res.dart';
// import '../../sharedWidget/custom_exch_badge.dart';
// import '../../sharedWidget/functions.dart';

// class TradeBookList extends ConsumerWidget {
//   final List<TradeBookModel>? orderBookList;
//   const TradeBookList({
//     super.key,
//     this.orderBookList,
//   });

//   @override
//   Widget build(BuildContext context, ScopedReader watch) {
//     final theme = context.read(themeProvider);
//     final order = watch(orderProvider);
//     return Container(
//         padding: const EdgeInsets.all(16),
//         child: 
//           Expanded(
//             child: ListView.separated(
//                 primary: true,
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(children: [
//                                 Text("${orderBookList![index].symbol} ",
//                                     overflow: TextOverflow.ellipsis,
//                                     style: textStyles.scripNameTxtStyle.copyWith(
//                                         color: theme.isDarkMode
//                                             ? colors.colorWhite
//                                             : colors.colorBlack)),
//                                 Text("${orderBookList![index].option} ",
//                                     overflow: TextOverflow.ellipsis,
//                                     style: textStyles.scripNameTxtStyle.copyWith(
//                                         color: theme.isDarkMode
//                                             ? colors.colorWhite
//                                             : colors.colorBlack))
//                               ]),
//                               SvgPicture.asset(assets.rightArrowIcon)
//                             ]),
//                         const SizedBox(height: 4),
//                         Row(children: [
//                           CustomExchBadge(exch: "${orderBookList![index].exch}"),
//                           Text(" ${orderBookList![index].expDate} ",
//                               overflow: TextOverflow.ellipsis,
//                               style: textStyles.scripExchTxtStyle.copyWith(
//                                   color: theme.isDarkMode
//                                       ? colors.colorWhite
//                                       : colors.colorBlack))
//                         ]),
//                         const SizedBox(height: 3),
//                         Divider(
//                             color: theme.isDarkMode
//                                 ? colors.darkColorDivider
//                                 : colors.colorDivider),
//                         const SizedBox(height: 3),
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(children: [
//                                 Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 2),
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         color: theme.isDarkMode
//                                             ? Color(orderBookList![index].trantype == "S"
//                                                     ? 0XFFf44336
//                                                     : 0xff43A833)
//                                                 .withOpacity(.2)
//                                             : Color(
//                                                 orderBookList![index].trantype == "S"
//                                                     ? 0xffFCF3F3
//                                                     : 0xffECF8F1)),
//                                     child: Text(orderBookList![index].trantype == "S" ? "SELL" : "BUY",
//                                         style: textStyle(
//                                             orderBookList![index].trantype == "S"
//                                                 ? colors.darkred
//                                                 : colors.ltpgreen,
//                                             12,
//                                             FontWeight.w600))),
//                                 Container(
//                                   margin: const EdgeInsets.only(left: 7),
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 7, vertical: 2),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.circular(4),
//                                       color: theme.isDarkMode
//                                           ? const Color(0xff666666)
//                                               .withOpacity(.2)
//                                           : const Color(0xff999999)
//                                               .withOpacity(.2)),
//                                   child: Text("${orderBookList![index].sPrdtAli}",
//                                       style: textStyle(const Color(0xff666666),
//                                           12, FontWeight.w600)),
//                                 ),
//                                 Container(
//                                     margin: const EdgeInsets.only(left: 7),
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 7, vertical: 2),
//                                     decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(4),
//                                         color: theme.isDarkMode
//                                             ? const Color(0xff666666)
//                                                 .withOpacity(.2)
//                                             : const Color(0xff999999)
//                                                 .withOpacity(.2)),
//                                     child: Text("${orderBookList![index].prctyp}",
//                                         style: textStyle(const Color(0xff666666),
//                                             12, FontWeight.w600)))
//                               ]),
//                               Row(children: [
//                                 Text("Prc: ",
//                                     style: textStyle(const Color(0xff5E6B7D), 14,
//                                         FontWeight.w500)),
//                                 Text("₹${orderBookList![index].prc ?? 0.00}",
//                                     style: textStyle(
//                                         theme.isDarkMode
//                                             ? colors.colorWhite
//                                             : colors.colorBlack,
//                                         14,
//                                         FontWeight.w500))
//                               ])
//                             ]),
//                         const SizedBox(height: 8),
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(children: [
//                                 Text("Fill Qty: ",
//                                     style: textStyle(const Color(0xff5E6B7D), 14,
//                                         FontWeight.w500)),
//                                 Text("${orderBookList![index].flqty ?? 0}",
//                                     style: textStyle(
//                                         theme.isDarkMode
//                                             ? colors.colorWhite
//                                             : colors.colorBlack,
//                                         14,
//                                         FontWeight.w500))
//                               ]),
//                               Row(children: [
//                                 Text("Avg.Price: ",
//                                     style: textStyle(const Color(0xff5E6B7D), 14,
//                                         FontWeight.w500)),
//                                 Text("${orderBookList![index].avgprc ?? 0.00}",
//                                     style: textStyle(
//                                         theme.isDarkMode
//                                             ? colors.colorWhite
//                                             : colors.colorBlack,
//                                         14,
//                                         FontWeight.w500))
//                               ])
//                             ]),
//                         const SizedBox(height: 8),
//                         Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(children: [
//                                 Text("Fill Id: ",
//                                     style: textStyle(const Color(0xff5E6B7D), 14,
//                                         FontWeight.w500)),
//                                 Text("${orderBookList![index].flid ?? 0}",
//                                     style: textStyle(
//                                         theme.isDarkMode
//                                             ? colors.colorWhite
//                                             : colors.colorBlack,
//                                         14,
//                                         FontWeight.w500))
//                               ]),
//                               Text(
//                                   formatDateTime(
//                                       value: orderBookList![index].norentm!),
//                                   style: textStyle(const Color(0xff666666), 12,
//                                       FontWeight.w500))
//                             ])
//                       ]);
                
//                 },
//                 separatorBuilder: (context, index) {
//                   return Divider();
//                 },
//                 itemCount: orderBookList!.length),
//           ));
    
//   }
// }
