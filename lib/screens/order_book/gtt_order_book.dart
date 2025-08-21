import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/order_book_model/gtt_order_book.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/order_provider.dart';
import '../../provider/shocase_provider.dart';
import '../../provider/thems.dart';
import '../../provider/websocket_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/custom_text_form_field.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/no_data_found.dart';
import '../../utils/no_emoji_inputformatter.dart';
import 'filter_gtt_bottom_sheet.dart';
import 'gtt_order_detail.dart';

class GttOrderBook extends ConsumerWidget {
  final List<GttOrderBookModel> gttOrderBook;
  const GttOrderBook({super.key, required this.gttOrderBook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider);
    final theme = ref.read(themeProvider);

    return Column(children: [
      // if (gttOrderBook.length > 1)
      //   order.showGttOrderSearch
      //       ? Container(
      //           padding:
      //               const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(5),
      //           ),
      //           child: SizedBox(
      //             height: 40,
      //             child: TextFormField(
      //                 autofocus: true,
      //                 controller: order.orderGttSearchCtrl,
      //                 style: TextWidget.textStyle(
      //                     fontSize: 14, theme: theme.isDarkMode, fw: 1),
      //                 keyboardType: TextInputType.text,
      //                 textCapitalization: TextCapitalization.characters,
      //                 inputFormatters: [
      //                   UpperCaseTextFormatter(),
      //                   NoEmojiInputFormatter(),
      //                   FilteringTextInputFormatter.deny(
      //                       RegExp('[π£•₹€℅™∆√¶/.,]'))
      //                 ],
      //                 decoration: InputDecoration(
      //                     hintText: "Search",
      //                     hintStyle: TextWidget.textStyle(
      //                         fontSize: 14,
      //                         theme: theme.isDarkMode,
      //                         fw: 0,
      //                         color: colors.textSecondaryLight),
      //                     fillColor: colors.searchBg,
      //                     filled: true,
      //                     prefixIcon: Padding(
      //                       padding: const EdgeInsets.all(8.0),
      //                       child: SvgPicture.asset(assets.searchIcon,
      //                           color: colors.textPrimaryLight,
      //                           fit: BoxFit.scaleDown,
      //                           width: 20),
      //                     ),
      //                     suffixIcon: Material(
      //                       color: Colors.transparent,
      //                       shape: const CircleBorder(),
      //                       clipBehavior: Clip.hardEdge,
      //                       child: InkWell(
      //                         customBorder: const CircleBorder(),
      //                         splashColor: theme.isDarkMode
      //                             ? colors.splashColorDark
      //                             : colors.splashColorLight,
      //                         highlightColor: theme.isDarkMode
      //                             ? colors.highlightDark
      //                             : colors.highlightLight,
      //                         onTap: () async {
      //                           Future.delayed(
      //                               const Duration(milliseconds: 150), () {
      //                             order.clearGttOrderSearch();
      //                             if (order.orderGttSearchCtrl.text.isEmpty) {
      //                               order.showGTTOrderSearch(false);
      //                             }
      //                             // Clear cached widgets when search is cleared
      //                             order.clearGttOrderSearch();
      //                           });
      //                         },
      //                         child: SvgPicture.asset(assets.removeIcon,
      //                             fit: BoxFit.scaleDown, width: 20),
      //                       ),
      //                     ),
      //                     enabledBorder: OutlineInputBorder(
      //                         borderSide: BorderSide.none,
      //                         borderRadius: BorderRadius.circular(20)),
      //                     disabledBorder: InputBorder.none,
      //                     focusedBorder: OutlineInputBorder(
      //                         borderSide: BorderSide.none,
      //                         borderRadius: BorderRadius.circular(20)),
      //                     contentPadding: const EdgeInsets.symmetric(
      //                         horizontal: 5, vertical: 5),
      //                     border: OutlineInputBorder(
      //                         borderSide: BorderSide.none,
      //                         borderRadius: BorderRadius.circular(20))),
      //                 onChanged: (value) {
      //                   // Enable search mode when user starts typing
      //                   if (value.isNotEmpty) {
      //                     order.showGTTOrderSearch(true);
      //                   } else {
      //                     // Disable search mode when field is empty
      //                     order.showGTTOrderSearch(false);
      //                   }

      //                   // Perform the search
      //                   order.orderGttSearch(value, context);

      //                   // Clear cached widgets to force rebuild with new data
      //                   // setState(() {
      //                   //   _cachedSummarySection = null;
      //                   //   _cachedActionButtons = null;
      //                   //   _cachedEmptyState = null;
      //                   //   _cachedActionButtonsKey = null;
      //                   //   _cachedSummaryKey = null;
      //                   // });
      //                 }),
      //           ),
      //         )
      //       : Padding(
      //           padding: const EdgeInsets.only(
      //               left: 16, right: 16, top: 5, bottom: 8),
      //           child: Column(
      //             children: [
      //               SizedBox(
      //                 height: 40,
      //                 child: Container(
      //                   padding: const EdgeInsets.symmetric(horizontal: 5),
      //                   decoration: BoxDecoration(
      //                     color: colors.searchBg,
      //                     borderRadius: BorderRadius.circular(5),
      //                   ),
      //                   child: Row(
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Padding(
      //                         padding: const EdgeInsets.only(right: 10),
      //                         child: Row(
      //                           children: [
      //                             Material(
      //                               color: Colors.transparent,
      //                               shape: const CircleBorder(),
      //                               clipBehavior: Clip.hardEdge,
      //                               child: InkWell(
      //                                 customBorder: const CircleBorder(),
      //                                 splashColor: theme.isDarkMode
      //                                     ? colors.splashColorDark
      //                                     : colors.splashColorLight,
      //                                 highlightColor: theme.isDarkMode
      //                                     ? colors.highlightDark
      //                                     : colors.highlightLight,
      //                                 onTap: () {
      //                                   Future.delayed(
      //                                       const Duration(milliseconds: 150),
      //                                       () async {
      //                                     order.showGTTOrderSearch(true);
      //                                   });
      //                                 },
      //                                 child: Padding(
      //                                   padding: const EdgeInsets.all(8.0),
      //                                   child: SvgPicture.asset(
      //                                     assets.searchIcon,
      //                                     color: colors.textPrimaryLight,
      //                                     width: 20,
      //                                     fit: BoxFit.scaleDown,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                             Material(
      //                               color: Colors.transparent,
      //                               shape: const CircleBorder(),
      //                               clipBehavior: Clip.hardEdge,
      //                               child: InkWell(
      //                                 customBorder: const CircleBorder(),
      //                                 splashColor: theme.isDarkMode
      //                                     ? colors.splashColorDark
      //                                     : colors.splashColorLight,
      //                                 highlightColor: theme.isDarkMode
      //                                     ? colors.highlightDark
      //                                     : colors.highlightLight,
      //                                 onTap: () async {
      //                                   Future.delayed(
      //                                       const Duration(milliseconds: 150),
      //                                       () async {
      //                                     await showModalBottomSheet(
      //                                         useSafeArea: true,
      //                                         isScrollControlled: true,
      //                                         shape:
      //                                             const RoundedRectangleBorder(
      //                                                 borderRadius:
      //                                                     BorderRadius.vertical(
      //                                                         top: Radius
      //                                                             .circular(
      //                                                                 16))),
      //                                         context: context,
      //                                         builder: (context) {
      //                                           return const OrderbooGTTkFilterBottomSheet();
      //                                         });
      //                                   });
      //                                 },
      //                                 child: Padding(
      //                                   padding: const EdgeInsets.all(8.0),
      //                                   child: SvgPicture.asset(
      //                                     assets.filterLinesDark,
      //                                     width: 18,
      //                                     color: colors.textPrimaryLight,
      //                                     fit: BoxFit.scaleDown,
      //                                   ),
      //                                 ),
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ),
      //             ],
      //           )),
      // Container(
      //     decoration: BoxDecoration(
      //         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      //         border: Border(
      //             bottom: BorderSide(
      //                 color: theme.isDarkMode
      //                     ? colors.darkGrey
      //                     : const Color(0xffF1F3F8),
      //                 width: 6))),
      //     child: Padding(
      //         padding:
      //             const EdgeInsets.only(left: 16, right: 2, top: 8, bottom: 8),
      //         child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      //           Row(children: [
      //             InkWell(
      //                 onTap: () async {
      //                   FocusScope.of(context).unfocus();
      //                   showModalBottomSheet(
      //                       useSafeArea: true,
      //                       isScrollControlled: true,
      //                       shape: const RoundedRectangleBorder(
      //                           borderRadius: BorderRadius.vertical(
      //                               top: Radius.circular(16))),
      //                       context: context,
      //                       builder: (context) {
      //                         return const OrderbooGTTkFilterBottomSheet();
      //                       });
      //                 },
      //                 child: Padding(
      //                     padding: const EdgeInsets.only(right: 12),
      //                     child: SvgPicture.asset(assets.filterLines,
      //                         color: const Color(0xff333333)))),
      //             InkWell(
      //                 onTap: () {
      //                   order.showGTTOrderSearch(true);
      //                 },
      //                 child: Padding(
      //                     padding: const EdgeInsets.only(right: 12, left: 10),
      //                     child: SvgPicture.asset(assets.searchIcon,
      //                         width: 19, color: const Color(0xff333333))))
      //           ])
      //         ]))),
      // if ()
      //   Container(
      //     height: 62,
      //     padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      //     decoration: BoxDecoration(
      //         border: Border(
      //             bottom: BorderSide(
      //                 color: theme.isDarkMode
      //                     ? colors.darkGrey
      //                     : const Color(0xffF1F3F8),
      //                 width: 6))),
      //     child: Row(
      //       children: [
      //         Expanded(
      //           child: TextFormField(
      //             textCapitalization: TextCapitalization.characters,
      //             inputFormatters: [UpperCaseTextFormatter()],
      //             controller: order.orderGttSearchCtrl,
      //             style: TextWidget.textStyle(
      //                 color: const Color(0xff000000),
      //                 fontSize: 16,
      //                 fw: 1,
      //                 theme: false),
      //             decoration: InputDecoration(
      //                 fillColor: const Color(0xffF1F3F8),
      //                 filled: true,
      //                 hintStyle: TextWidget.textStyle(
      //                     color: const Color(0xff69758F),
      //                     fontSize: 14,
      //                     fw: 0,
      //                     theme: false),
      //                 prefixIconColor: const Color(0xff586279),
      //                 prefixIcon: Padding(
      //                   padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //                   child: SvgPicture.asset(assets.searchIcon,
      //                       color: const Color(0xff586279),
      //                       fit: BoxFit.contain,
      //                       width: 20),
      //                 ),
      //                 suffixIcon: InkWell(
      //                   onTap: () async {
      //                     order.clearGttOrderSearch();
      //                   },
      //                   child: Padding(
      //                     padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //                     child: SvgPicture.asset(assets.removeIcon,
      //                         fit: BoxFit.scaleDown, width: 20),
      //                   ),
      //                 ),
      //                 enabledBorder: OutlineInputBorder(
      //                     borderSide: BorderSide.none,
      //                     borderRadius: BorderRadius.circular(20)),
      //                 disabledBorder: InputBorder.none,
      //                 focusedBorder: OutlineInputBorder(
      //                     borderSide: BorderSide.none,
      //                     borderRadius: BorderRadius.circular(20)),
      //                 hintText: "Search Scrip Name",
      //                 contentPadding: const EdgeInsets.only(top: 20),
      //                 border: OutlineInputBorder(
      //                     borderSide: BorderSide.none,
      //                     borderRadius: BorderRadius.circular(20))),
      //             onChanged: (value) async {
      //               order.orderGttSearch(value, context);
      //             },
      //           ),
      //         ),
      //         TextButton(
      //             onPressed: () {
      //               order.showGTTOrderSearch(false);
      //               order.clearGttOrderSearch();
      //             },
      //             child: TextWidget.subText(
      //                 text: "Close",
      //                 theme: false,
      //                 color: colors.colorBlue,
      //                 fw: 0))
      //       ],
      //     ),
      //   ),
      Expanded(
        child: StreamBuilder<Map>(
          stream: ref.watch(websocketProvider).socketDataStream,
          builder: (context, snapshot) {
            final socketDatas = snapshot.data ?? {};

            // ⚡ CRITICAL FIX: Initialize with existing socket data on first load
            if (snapshot.data == null) {
              // On first load, get existing socket data
              final wsProvider = ref.watch(websocketProvider);
              final existingSocketData = wsProvider.socketDatas;

              if (existingSocketData.isNotEmpty) {
                print("=== GTT INITIAL SOCKET DATA LOAD ===");
                for (var order in gttOrderBook) {
                  if (existingSocketData.containsKey(order.token)) {
                    final socketData = existingSocketData[order.token];
                    final lp = socketData['ltp']?.toString() ??
                        socketData['lp']?.toString();
                    final pc = socketData['pc']?.toString();

                    if (lp != null && lp != "null" && lp.isNotEmpty) {
                      order.ltp = lp;
                      print("  ✅ Initial LTP set for ${order.token}: $lp");
                    }

                    if (pc != null && pc != "null" && pc.isNotEmpty) {
                      order.perChange = pc;
                      print("  ✅ Initial PC set for ${order.token}: $pc");
                    }
                  }
                }
                print("===================================");
              }
            }

            // Update order book data with real-time values
            if (snapshot.hasData) {
              // Debug: Print socket data updates for GTT orders
              print("=== GTT ORDER SOCKET UPDATE DEBUG ===");
              print("Socket data keys: ${socketDatas.length}");

              bool dataUpdated = false;

              for (var order in gttOrderBook) {
                if (socketDatas.containsKey(order.token)) {
                  final socketData = socketDatas[order.token];
                  final lp = socketData['ltp']?.toString() ??
                      socketData['lp']?.toString();
                  final pc = socketData['pc']?.toString();
                  final chng = socketData['chng']?.toString();

                  // Debug: Print update info
                  print(
                      "Token ${order.token}: Socket LTP=$lp, PC=$pc, Current LTP=${order.ltp}");

                  // ⚡ FIX: Accept ALL valid values including "0" and "0.00"
                  if (lp != null &&
                      lp != "null" &&
                      lp.isNotEmpty &&
                      lp != order.ltp) {
                    order.ltp = lp;
                    dataUpdated = true;
                    print("  ✅ LTP updated to: $lp");
                  }

                  if (pc != null &&
                      pc != "null" &&
                      pc.isNotEmpty &&
                      pc != order.perChange) {
                    order.perChange = pc;
                    dataUpdated = true;
                    print("  ✅ PC updated to: $pc");
                  }

                  if (chng != null &&
                      chng != "null" &&
                      chng.isNotEmpty &&
                      chng != order.change) {
                    order.change = chng;
                    dataUpdated = true;
                  }
                }
              }

              if (order.gttOrderBookSearch!.isNotEmpty) {
                for (var searchOrder in order.gttOrderBookSearch!) {
                  if (socketDatas.containsKey(searchOrder.token)) {
                    final socketData = socketDatas[searchOrder.token];
                    final lp = socketData['ltp']?.toString() ??
                        socketData['lp']?.toString();
                    final pc = socketData['pc']?.toString();
                    final chng = socketData['chng']?.toString();

                    // ⚡ FIX: Accept ALL valid values including "0" and "0.00"
                    if (lp != null &&
                        lp != "null" &&
                        lp.isNotEmpty &&
                        lp != searchOrder.ltp) {
                      searchOrder.ltp = lp;
                      dataUpdated = true;
                    }

                    if (pc != null &&
                        pc != "null" &&
                        pc.isNotEmpty &&
                        pc != searchOrder.perChange) {
                      searchOrder.perChange = pc;
                      dataUpdated = true;
                    }

                    if (chng != null &&
                        chng != "null" &&
                        chng.isNotEmpty &&
                        chng != searchOrder.change) {
                      searchOrder.change = chng;
                      dataUpdated = true;
                    }
                  }
                }
              }

              if (dataUpdated) {
                print("🔄 GTT Order data updated, triggering rebuild");
              }
              print("=====================================");
            }

            return ListView(
              children: [
                if (order.gttOrderBookSearch!.isEmpty)
                  gttOrderBook.isNotEmpty
                      ? ListView.separated(
                          primary: true,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () async {
                                  await ref
                                      .read(marketWatchProvider)
                                      .fetchLinkeScrip(
                                          "${gttOrderBook[index].token}",
                                          "${gttOrderBook[index].exch}",
                                          context);

                                  await ref
                                      .watch(marketWatchProvider)
                                      .fetchScripQuote(
                                          "${gttOrderBook[index].token}",
                                          "${gttOrderBook[index].exch}",
                                          context);

                                  if ((gttOrderBook[index].exch == "NSE" ||
                                      gttOrderBook[index].exch == "BSE")) {
                                    await ref
                                        .read(marketWatchProvider)
                                        .fetchTechData(
                                            context: context,
                                            exch: "${gttOrderBook[index].exch}",
                                            tradeSym:
                                                "${gttOrderBook[index].tsym}",
                                            lastPrc:
                                                "${gttOrderBook[index].prc}");
                                  }
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    isDismissible: true,
                                    enableDrag: false,
                                    useSafeArea: true,
                                    context: context,
                                    builder: (context) => Container(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                        ),
                                        child: GttOrderDetail(
                                            gttOrderBook: gttOrderBook[index])),
                                  );
                                  // Navigator.pushNamed(
                                  //     context, Routes.gttOrderDetail,
                                  //     arguments: gttOrderBook[index]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                TextWidget.subText(
                                                    text:
                                                        "${gttOrderBook[index].symbol?.replaceAll("-EQ", "")} ",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 0,
                                                    textOverflow:
                                                        TextOverflow.ellipsis),
                                                TextWidget.subText(
                                                    text:
                                                        "${gttOrderBook[index].option} ",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors.textPrimaryDark
                                                        : colors
                                                            .textPrimaryLight,
                                                    fw: 0,
                                                    textOverflow:
                                                        TextOverflow.ellipsis),
                                              ]),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      color: gttOrderBook[index]
                                                                  .gttOrderCurrentStatus
                                                                  ?.toUpperCase() ==
                                                              "CANCELLED"
                                                          ? theme.isDarkMode
                                                              ? colors.lossDark
                                                                  .withOpacity(
                                                                      0.1)
                                                              : colors.lossLight
                                                                  .withOpacity(
                                                                      0.1)
                                                          : gttOrderBook[index]
                                                                      .gttOrderCurrentStatus
                                                                      ?.toUpperCase() ==
                                                                  "PENDING"
                                                              ? colors.pending
                                                                  .withOpacity(
                                                                      0.1)
                                                              : gttOrderBook[index]
                                                                          .gttOrderCurrentStatus
                                                                          ?.toUpperCase() ==
                                                                      "COMPLETED"
                                                                  ? theme
                                                                          .isDarkMode
                                                                      ? colors.profitDark.withOpacity(
                                                                          0.1)
                                                                      : colors
                                                                          .profitLight
                                                                          .withOpacity(
                                                                              0.1)
                                                                  : colors
                                                                      .textSecondaryLight
                                                                      .withOpacity(0.1),
                                                      // border: Border.all(
                                                      //     color: gttOrderBook[
                                                      //                     index]
                                                      //                 .gttOrderCurrentStatus
                                                      //                 ?.toUpperCase() ==
                                                      //             "CANCELLED"
                                                      //         ? theme.isDarkMode
                                                      //             ? colors
                                                      //                 .lossDark
                                                      //             : colors
                                                      //                 .lossLight
                                                      //         : gttOrderBook[index]
                                                      //                     .gttOrderCurrentStatus
                                                      //                     ?.toUpperCase() ==
                                                      //                 "PENDING"
                                                      //             ? colors
                                                      //                 .pending
                                                      //             : gttOrderBook[index]
                                                      //                         .gttOrderCurrentStatus
                                                      //                         ?.toUpperCase() ==
                                                      //                     "COMPLETED"
                                                      //                 ? theme
                                                      //                         .isDarkMode
                                                      //                     ? colors
                                                      //                         .profitDark
                                                      //                     : colors
                                                      //                         .profitLight
                                                      //                 : colors
                                                      //                     .textSecondaryLight),
                                                    ),
                                                    child: TextWidget.paraText(
                                                        text: gttOrderBook[
                                                                    index]
                                                                .gttOrderCurrentStatus
                                                                ?.toUpperCase() ??
                                                            '',
                                                        theme: false,
                                                        color: gttOrderBook[
                                                                        index]
                                                                    .gttOrderCurrentStatus
                                                                    ?.toUpperCase() ==
                                                                "CANCELLED"
                                                            ? theme.isDarkMode
                                                                ? colors
                                                                    .lossDark
                                                                : colors
                                                                    .lossLight
                                                            : gttOrderBook[index]
                                                                        .gttOrderCurrentStatus
                                                                        ?.toUpperCase() ==
                                                                    "PENDING"
                                                                ? colors.pending
                                                                : gttOrderBook[index]
                                                                            .gttOrderCurrentStatus
                                                                            ?.toUpperCase() ==
                                                                        "COMPLETED"
                                                                    ? theme
                                                                            .isDarkMode
                                                                        ? colors
                                                                            .profitDark
                                                                        : colors
                                                                            .profitLight
                                                                    : colors
                                                                        .textSecondaryLight,
                                                        fw: 0),
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                              )
                                            ]),
                                        const SizedBox(height: 6),
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  TextWidget.paraText(
                                                      text:
                                                          "${gttOrderBook[index].exch}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      fw: 0),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  // TextWidget.paraText(
                                                  //     text:
                                                  //         " ${gttOrderBook[index].expDate} ",
                                                  //     theme: false,
                                                  //     color: theme.isDarkMode
                                                  //         ? colors
                                                  //             .textSecondaryDark
                                                  //         : colors
                                                  //             .textSecondaryLight,
                                                  //     fw: 3,
                                                  //     textOverflow: TextOverflow
                                                  //         .ellipsis),
                                                  // const SizedBox(width: 4),
                                                  TextWidget.paraText(
                                                      text: "LTP ",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      fw: 0),
                                                  TextWidget.paraText(
                                                      text:
                                                          "${gttOrderBook[index].ltp ?? gttOrderBook[index].close ?? 0.00}",
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      fw: 0),
                                                  TextWidget.paraText(
                                                      text:
                                                          " (${gttOrderBook[index].perChange ?? 0.00}%)",
                                                      theme: false,
                                                      color: gttOrderBook[index]
                                                              .perChange!
                                                              .startsWith("-")
                                                          ? theme.isDarkMode
                                                              ? colors.lossDark
                                                              : colors.lossLight
                                                          : gttOrderBook[index]
                                                                      .perChange ==
                                                                  "0.00"
                                                              ? theme.isDarkMode
                                                                  ? colors
                                                                      .textSecondaryDark
                                                                  : colors
                                                                      .textSecondaryLight
                                                              : theme.isDarkMode
                                                                  ? colors
                                                                      .profitDark
                                                                  : colors
                                                                      .profitLight,
                                                      fw: 0),
                                                ],
                                              ),
                                            ]),
                                        const SizedBox(height: 8),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(children: [
                                                TextWidget.paraText(
                                                    text: gttOrderBook[index]
                                                                .trantype ==
                                                            "S"
                                                        ? "SELL"
                                                        : "BUY",
                                                    theme: false,
                                                    color: gttOrderBook[index]
                                                                .trantype ==
                                                            "S"
                                                        ? theme.isDarkMode
                                                            ? colors.lossDark
                                                            : colors.lossLight
                                                        : theme.isDarkMode
                                                            ? colors.profitDark
                                                            : colors
                                                                .profitLight,
                                                    fw: 0),
                                                const SizedBox(width: 4),
                                                TextWidget.paraText(
                                                    text:
                                                        "${gttOrderBook[index].placeOrderParams!.sPrdtAli}",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 0),
                                              ]),
                                              Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    TextWidget.paraText(
                                                        text: "Qty ",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 0),
                                                    TextWidget.paraText(
                                                        text:
                                                            "${gttOrderBook[index].placeOrderParams?.qty ?? ''} ${gttOrderBook[index].placeOrderParamsLeg2?.qty != null ? ' / ${gttOrderBook[index].placeOrderParamsLeg2?.qty}' : ''}",
                                                        theme: false,
                                                        color: theme.isDarkMode
                                                            ? colors
                                                                .textSecondaryDark
                                                            : colors
                                                                .textSecondaryLight,
                                                        fw: 0),
                                                  ])
                                            ]),
                                        const SizedBox(height: 10),
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  // Text(
                                                  //     "${gttOrderBook[index].aiT!.replaceAll("_B_O", "").replaceAll("_A_O", "").replaceAll("_", " ")} ",
                                                  //     style: textStyle(
                                                  //         theme.isDarkMode
                                                  //             ? colors.colorWhite
                                                  //             : colors.colorBlack,
                                                  //         14,
                                                  //         FontWeight.w500)),
                                                  TextWidget.paraText(
                                                      text: formatDateTime(
                                                          value: gttOrderBook[
                                                                  index]
                                                              .norentm!),
                                                      theme: false,
                                                      color: theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight,
                                                      fw: 0),
                                                ],
                                              ),
                                              Row(children: [
                                                // TextWidget.paraText(
                                                //     text: "Price ",
                                                //     theme: false,
                                                //     color: theme.isDarkMode
                                                //         ? colors
                                                //             .textSecondaryDark
                                                //         : colors
                                                //             .textSecondaryLight,
                                                //     fw: 3),
                                                TextWidget.paraText(
                                                    text:
                                                        "${gttOrderBook[index].placeOrderParams?.prctyp == "MKT" ? "MKT" : gttOrderBook[index].placeOrderParams?.prc ?? ''} ${gttOrderBook[index].placeOrderParamsLeg2?.prc != null ? ' / ${gttOrderBook[index].placeOrderParamsLeg2?.prctyp == "MKT" ? "MKT" : gttOrderBook[index].placeOrderParamsLeg2?.prc}' : ''}",
                                                    theme: false,
                                                    color: theme.isDarkMode
                                                        ? colors
                                                            .textSecondaryDark
                                                        : colors
                                                            .textSecondaryLight,
                                                    fw: 0),
                                              ])
                                            ]),
                                        const SizedBox(height: 8),
                                      ]),
                                )

                                // GTTOrderBookList( gttOrderBook: gttOrderBook[index])

                                );
                          },
                          itemCount: gttOrderBook.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Divider(
                                color: theme.isDarkMode
                                    ? colors.dividerDark
                                    : colors.dividerLight,
                                thickness: 0);
                          },
                        )
                      : const SizedBox(height: 500, child: NoDataFound()),
                if (order.gttOrderBookSearch!.isNotEmpty)
                  ListView.separated(
                    primary: true,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () async {
                            await ref.read(marketWatchProvider).fetchLinkeScrip(
                                "${order.gttOrderBookSearch![index].token}",
                                "${order.gttOrderBookSearch![index].exch}",
                                context);

                            await ref
                                .watch(marketWatchProvider)
                                .fetchScripQuote(
                                    "${order.gttOrderBookSearch![index].token}",
                                    "${order.gttOrderBookSearch![index].exch}",
                                    context);

                            if ((order.gttOrderBookSearch![index].exch ==
                                    "NSE" ||
                                order.gttOrderBookSearch![index].exch ==
                                    "BSE")) {
                              await ref.read(marketWatchProvider).fetchTechData(
                                  context: context,
                                  exch:
                                      "${order.gttOrderBookSearch![index].exch}",
                                  tradeSym:
                                      "${order.gttOrderBookSearch![index].tsym}",
                                  lastPrc:
                                      "${order.gttOrderBookSearch![index].prc}");
                            }

                            Navigator.pushNamed(context, Routes.gttOrderDetail,
                                arguments: order.gttOrderBookSearch![index]);
                          },
                          child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            TextWidget.subText(
                                                text:
                                                    "${order.gttOrderBookSearch![index].symbol?.replaceAll("-EQ", "")} ",
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 0,
                                                textOverflow:
                                                    TextOverflow.ellipsis),
                                            TextWidget.subText(
                                                text:
                                                    "${order.gttOrderBookSearch![index].option} ",
                                                theme: theme.isDarkMode,
                                                color: theme.isDarkMode
                                                    ? colors.textPrimaryDark
                                                    : colors.textPrimaryLight,
                                                fw: 0,
                                                textOverflow:
                                                    TextOverflow.ellipsis),
                                          ]),
                                          Row(
                                            children: [
                                              TextWidget.paraText(
                                                  text: " LTP ",
                                                  theme: false,
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                                  fw: 3),
                                              if (socketDatas.containsKey(order
                                                  .gttOrderBookSearch![index]
                                                  .token)) ...[
                                                TextWidget.paraText(
                                                    text:
                                                        "${order.gttOrderBookSearch![index].ltp ?? order.gttOrderBookSearch![index].close ?? 0.00}",
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                              ]
                                              // SvgPicture.asset(assets.rightArrowIcon),
                                            ],
                                          )
                                        ]),
                                    const SizedBox(height: 8),
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CustomExchBadge(
                                                  exch:
                                                      "${order.gttOrderBookSearch![index].exch}"),
                                              TextWidget.paraText(
                                                  text:
                                                      " ${order.gttOrderBookSearch![index].expDate} ",
                                                  theme: theme.isDarkMode,
                                                  fw: 3,
                                                  textOverflow:
                                                      TextOverflow.ellipsis),
                                            ],
                                          ),
                                          TextWidget.paraText(
                                              text:
                                                  " (${order.gttOrderBookSearch![index].perChange ?? 0.00}%)",
                                              theme: false,
                                              color: order
                                                      .gttOrderBookSearch![
                                                          index]
                                                      .perChange!
                                                      .startsWith("-")
                                                  ? theme.isDarkMode
                                                      ? colors.lossDark
                                                      : colors.lossLight
                                                  : order
                                                              .gttOrderBookSearch![
                                                                  index]
                                                              .perChange ==
                                                          "0.00"
                                                      ? theme.isDarkMode
                                                          ? colors
                                                              .textSecondaryDark
                                                          : colors
                                                              .textSecondaryLight
                                                      : theme.isDarkMode
                                                          ? colors.profitDark
                                                          : colors.profitLight,
                                              fw: 3),
                                        ]),
                                    const SizedBox(height: 8),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            TextWidget.paraText(
                                                text: gttOrderBook[index]
                                                            .trantype ==
                                                        "S"
                                                    ? "SELL"
                                                    : "BUY",
                                                theme: false,
                                                color: order
                                                            .gttOrderBookSearch![
                                                                index]
                                                            .trantype ==
                                                        "S"
                                                    ? theme.isDarkMode
                                                        ? colors.lossDark
                                                        : colors.lossLight
                                                    : theme.isDarkMode
                                                        ? colors.profitDark
                                                        : colors.profitLight,
                                                fw: 3),
                                            TextWidget.paraText(
                                                text:
                                                    "${order.gttOrderBookSearch![index].placeOrderParams!.sPrdtAli}",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3)
                                          ]),
                                          Row(children: [
                                            TextWidget.paraText(
                                                text: "Qty: ",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3),
                                            TextWidget.paraText(
                                                text:
                                                    "${order.gttOrderBookSearch![index].placeOrderParams?.qty ?? ''} ${order.gttOrderBookSearch![index].placeOrderParamsLeg2?.qty != null ? ' / ${order.gttOrderBookSearch![index].placeOrderParamsLeg2?.qty}' : ''}",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3),
                                          ])
                                        ]),
                                    const SizedBox(height: 8),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              //   Text(
                                              //       "${order.gttOrderBookSearch![index].aiT!.replaceAll("_B_O", "").replaceAll("_A_O", "").replaceAll("_", " ")} ",
                                              //       style: textStyle(
                                              //           theme.isDarkMode
                                              //               ? colors.colorWhite
                                              //               : colors.colorBlack,
                                              //           14,
                                              //           FontWeight.w500)),
                                              TextWidget.paraText(
                                                  text: formatDateTime(
                                                      value: gttOrderBook[index]
                                                          .norentm!),
                                                  theme: false,
                                                  color: theme.isDarkMode
                                                      ? colors.textSecondaryDark
                                                      : colors
                                                          .textSecondaryLight,
                                                  fw: 3),
                                            ],
                                          ),
                                          Row(children: [
                                            TextWidget.paraText(
                                                text: "Price ",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3),
                                            TextWidget.paraText(
                                                text:
                                                    "${order.gttOrderBookSearch![index].placeOrderParams?.prctyp == "MKT" ? "MKT" : order.gttOrderBookSearch![index].placeOrderParams?.prc ?? ''} ${order.gttOrderBookSearch![index].placeOrderParamsLeg2?.prc != null ? ' / ${order.gttOrderBookSearch![index].placeOrderParamsLeg2?.prctyp == "MKT" ? "MKT" : order.gttOrderBookSearch![index].placeOrderParamsLeg2?.prc}' : ''}",
                                                theme: false,
                                                color: theme.isDarkMode
                                                    ? colors.textSecondaryDark
                                                    : colors.textSecondaryLight,
                                                fw: 3),
                                          ])
                                        ])
                                  ]))

                          // GTTOrderBookList( gttOrderBook: gttOrderBook[index])

                          );
                    },
                    itemCount: order.gttOrderBookSearch!.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                          color: theme.isDarkMode
                              ? colors.dividerDark
                              : colors.dividerLight,
                          height: 1);
                    },
                  ),
              ],
            );
          },
        ),
      )
    ]);
  }
}
