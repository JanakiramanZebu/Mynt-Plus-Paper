import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../provider/thems.dart';
import '../../../provider/websocket_provider.dart';
import '../../../res/res.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/order_provider.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

class ExitOrderScreen extends ConsumerWidget {
  final List<OrderBookModel> exitOrdersList;
  const ExitOrderScreen({super.key, required this.exitOrdersList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    final Orders = ref.watch(orderProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        final socketDatas = snapshot.data ?? {};
        
        // Create a local copy of the list to avoid modifying the original data
        List<OrderBookModel> displayOrdersList = List.from(exitOrdersList);
        
        // Update with real-time data
        for (var order in displayOrdersList) {
          if (socketDatas.containsKey(order.token)) {
            final socketData = socketDatas[order.token];
            
            // Only update with valid values
            final lp = socketData['lp']?.toString();
            if (lp != null && lp != "null" && lp != "0") {
              order.ltp = lp;
            }
            
            final pc = socketData['pc']?.toString();
            if (pc != null && pc != "null") {
              order.perChange = pc;
            }
          }
        }
        
        return PopScope(
          canPop: true, // Allows back navigation
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return; // If system handled back, do nothing
    
            Orders.selectExitAllOrders(false);
          },
    
          child: Scaffold(
            appBar: AppBar(
              elevation: .2,
              centerTitle: false,
              leadingWidth: 41,
              titleSpacing: 6,
              leading: InkWell(
                  onTap: () {
                    Orders.selectExitAllOrders(false);
                    Navigator.pop(context);
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: SvgPicture.asset(assets.backArrow,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack))),
              title: Text(
                "Cancel Orders (${Orders.openOrder!.length})",
                style: textStyles.appBarTitleTxt.copyWith(
                    color:
                        theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
              ),
              actions: [
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Orders.selectExitAllOrders(
                            Orders.isExitAllOrder ? false : true);
                      },
                      child: SvgPicture.asset(
                        theme.isDarkMode
                            ? Orders.isExitAllOrder
                                ? assets.darkCheckedboxIcon
                                : assets.darkCheckboxIcon
                            : Orders.isExitAllOrder
                                ? assets.ckeckedboxIcon
                                : assets.ckeckboxIcon,
                        width: 22,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        Orders.isExitAllOrder ? "Cancel" : "Select All",
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
            body: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: false,
              itemBuilder: (context, index) {
                final itemIndex = index ~/ 2;
                
                if (index.isOdd) {
                  return Container(
                      color: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffF1F3F8),
                      height: 6);
                }
    
                return InkWell(
                    onTap: () async {
                      Orders.selectExitOrder(itemIndex);
                    },
                    child: displayOrdersList[itemIndex].status != null
                        ? Container(
                            color: theme.isDarkMode
                                ? displayOrdersList[itemIndex].isExitSelection ?? false
                                    ? colors.darkGrey
                                    : colors.colorBlack
                                : displayOrdersList[itemIndex].isExitSelection ?? false
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
                                        Row(children: [
                                          Text(
                                              "${displayOrdersList[itemIndex].symbol} ",
                                              overflow: TextOverflow.ellipsis,
                                              style: textStyles.scripNameTxtStyle
                                                  .copyWith(
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack)),
                                          Text(
                                              "${displayOrdersList[itemIndex].option} ",
                                              overflow: TextOverflow.ellipsis,
                                              style: textStyles.scripNameTxtStyle
                                                  .copyWith(
                                                      color: theme.isDarkMode
                                                          ? colors.colorWhite
                                                          : colors.colorBlack)),
                                        ]),
                                        Row(
                                          children: [
                                            Text(" LTP: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    13,
                                                    FontWeight.w600)),
                                            Text(
                                                "₹${displayOrdersList[itemIndex].ltp ?? displayOrdersList[itemIndex].close ?? 0.00}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500)),
                                          ],
                                        ),
                                      ]),
                                  const SizedBox(height: 4),
                                  Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CustomExchBadge(
                                                exch:
                                                    "${displayOrdersList[itemIndex].exch}"),
                                            Text(
                                                " ${displayOrdersList[itemIndex].expDate} ",
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyles.scripExchTxtStyle
                                                    .copyWith(
                                                        color: theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors.colorBlack)),
                                            Container(
                                                margin:
                                                    const EdgeInsets.only(left: 7),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                    color: theme.isDarkMode
                                                        ? const Color(0xff666666)
                                                            .withOpacity(.2)
                                                        : const Color(0xff999999)
                                                            .withOpacity(.2)),
                                                child: Text(
                                                    "${displayOrdersList[itemIndex].sPrdtAli}",
                                                    style: textStyle(
                                                        const Color(0xff666666),
                                                        11,
                                                        FontWeight.w600))),
                                            Container(
                                                margin:
                                                    const EdgeInsets.only(left: 7),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                    color: theme.isDarkMode
                                                        ? const Color(0xff666666)
                                                            .withOpacity(.2)
                                                        : const Color(0xff999999)
                                                            .withOpacity(.2)),
                                                child: Text(
                                                    "${displayOrdersList[itemIndex].prctyp}",
                                                    style: textStyle(
                                                        const Color(0xff666666),
                                                        11,
                                                        FontWeight.w600)))
                                          ],
                                        ),
                                        Text(
                                            " (${displayOrdersList[itemIndex].perChange ?? 0.00}%)",
                                            style: textStyle(
                                                displayOrdersList[itemIndex]
                                                        .perChange!
                                                        .startsWith("-")
                                                    ? colors.darkred
                                                    : displayOrdersList[itemIndex]
                                                                .perChange ==
                                                            "0.00"
                                                        ? colors.ltpgrey
                                                        : colors.ltpgreen,
                                                12,
                                                FontWeight.w500)),
                                      ]),
                                  const SizedBox(height: 4),
                                  Divider(
                                      color: theme.isDarkMode
                                          ? colors.darkColorDivider
                                          : colors.colorDivider),
                                  const SizedBox(height: 2),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: theme.isDarkMode
                                                      ? displayOrdersList[itemIndex]
                                                                  .trantype ==
                                                              "S"
                                                          ? colors.darkred
                                                              .withOpacity(.2)
                                                          : colors.ltpgreen
                                                              .withOpacity(.2)
                                                  : Color(
                                                      displayOrdersList[itemIndex].trantype == "S"
                                                          ? 0xffFCF3F3
                                                          : 0xffECF8F1)),
                                              child: Text(
                                                  displayOrdersList[itemIndex].trantype == "S"
                                                      ? "SELL"
                                                      : "BUY",
                                                  style: textStyle(
                                                      displayOrdersList[itemIndex].trantype == "S"
                                                          ? colors.darkred
                                                          : colors.ltpgreen,
                                                      12,
                                                      FontWeight.w600))),
                                          const SizedBox(width: 8),
                                          Text(
                                              formatDateTime(
                                                      value:
                                                          displayOrdersList[itemIndex]
                                                              .norentm!)
                                                  .substring(13, 21),
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  12,
                                                  FontWeight.w500))
                                        ]),
                                        Row(children: [
                                          Text("Qty: ",
                                              style: textStyle(
                                                  const Color(0xff5E6B7D),
                                                  14,
                                                  FontWeight.w500)),
                                          Text(
                                              "${displayOrdersList[itemIndex].status == "COMPLETE" ? displayOrdersList[itemIndex].rqty ?? 0 : displayOrdersList[itemIndex].dscqty ?? 0}/${displayOrdersList[itemIndex].qty ?? 0}",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  14,
                                                  FontWeight.w500))
                                        ])
                                      ]),
                                  const SizedBox(height: 10),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(children: [
                                          SvgPicture.asset(displayOrdersList[itemIndex]
                                                      .status ==
                                                  "COMPLETE"
                                              ? assets.completedIcon
                                              : displayOrdersList[itemIndex].status ==
                                                          "CANCELED" ||
                                                      displayOrdersList[itemIndex]
                                                              .status ==
                                                          "REJECTED"
                                                  ? assets.cancelledIcon
                                                  : assets.warningIcon),
                                          Text(
                                              " ${displayOrdersList[itemIndex].status![0].toUpperCase()}${displayOrdersList[itemIndex].status!.toLowerCase().replaceAll("_", " ").substring(1)}  ",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  13,
                                                  FontWeight.w500)),
                                        ]),
                                        Row(children: [
                                          Text("Prc: ",
                                              style: textStyle(
                                                  const Color(0xff5E6B7D),
                                                  14,
                                                  FontWeight.w500)),
                                          Text(
                                              "${displayOrdersList[itemIndex].avgprc ?? displayOrdersList[itemIndex].prc ?? 0.00}",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  14,
                                                  FontWeight.w500)),
                                          if (displayOrdersList[itemIndex].prctyp ==
                                                  "SL-LMT" ||
                                              displayOrdersList[itemIndex].prctyp ==
                                                  "SL-MKT") ...[
                                            const SizedBox(child: Text(' / ')),
                                            Text("TP: ",
                                                style: textStyle(
                                                    const Color(0xff5E6B7D),
                                                    14,
                                                    FontWeight.w500)),
                                            Text(
                                                "${displayOrdersList[itemIndex].trgprc ?? 0.00}",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w500))
                                          ]
                                        ])
                                      ])
                                ]))
                        : Container());
              },
              itemCount: displayOrdersList.length * 2 - 1,
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
                        color: Orders.exitOrderQty == 0
                            ? const Color(0XFFD34645).withOpacity(.8)
                            : const Color(0XFFD34645),
                        borderRadius: BorderRadius.circular(32)),
                    width: MediaQuery.of(context).size.width,
                    child: InkWell(
                      onTap: Orders.exitOrderQty == 0
                          ? () {}
                          : () async {
                              await Orders.exitOrders(context);
                            },
                      child: Center(
                          child: Text(
                              Orders.exitOrderQty == 0
                                  ? "Cancel"
                                  : "Cancel (${Orders.exitOrderQty})",
                              style: textStyle(
                                  const Color(0xffFFFFFF), 14, FontWeight.w600))),
                    ))),
          ),
        );
      },
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
