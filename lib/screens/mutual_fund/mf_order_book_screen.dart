import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_hold_new_screen.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/loader_ui.dart';
import 'order_single_page.dart';

class MfOrderBookScreen extends ConsumerStatefulWidget {
  const MfOrderBookScreen({super.key});
  @override
  ConsumerState<MfOrderBookScreen> createState() => _MfOrderBookScreen();
}

class _MfOrderBookScreen extends ConsumerState<MfOrderBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tablistitems = [
    {"title": "Holdings", "index": 0},
    {"title": "Orders", "index": 1}
  ];
  final inProgressStatuses = {
    "PAYMENT NOT INITIATED",
    "MODIFIED",
    "PAYMENT INITATED",
    "PAYMENT INIT",
    "PAYMENT COMPLETED",
    "CANCEL ERROR",
    "WAIT FOR ALLOTMENT",
    "MODIFY REJECTED",
    "PAYMENT REJECTED"
  };


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mfProvider).fetchMfOrderbook(context);
    });
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final theme = ref.watch(themeProvider);
      final mforderbook = ref.watch(mfProvider);
      return  Stack(
          children: [
            TransparentLoaderScreen(
              isLoading: mforderbook.bestmfloader == true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 35,
                      child: TabBar(
                        controller: _tabController,
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: theme.isDarkMode ? colors.searchBgDark : const Color(0xffF1F3F8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        unselectedLabelColor: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    labelStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        fw: 2,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight),
                    unselectedLabelStyle: TextWidget.textStyle(
                        fontSize: 14,
                        theme: false,
                        fw: 3,
                        color: colors.textSecondaryLight),
                        // labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        tabs: tablistitems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tabData = entry.value;
                          return Tab(
                            text: tabData['title'].toString(),
                          //   child: Builder(
                          //     builder: (context) {
                          //       final isSelected = _tabController.index == index;
                                
                          //       return Padding(
                          //         padding: const EdgeInsets.only(
                          //             left: 10, right: 10, top: 0, bottom: 0),
                          //         child: Row(
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           mainAxisSize: MainAxisSize.min,
                          //           children: [
                          //             TextWidget.paraText(
                          //                 text: ,
                          //                 theme: false,
                          //                 color: isSelected ? theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight : theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                          //                 fw: isSelected ? 2 : 3),
                          //           ],
                          //         ),
                          //       );
                          //     },
                          //   ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        const MfHoldNewScreen(),
                        _buildOrdersTab(mforderbook, theme, context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      // );
    });
  }

  Widget _buildOrdersTab(
      MFProvider mforderbook, ThemesProvider theme, BuildContext context) {
        if (mforderbook.mfOrderbookfilter == "All" &&
                  mforderbook.mflumpsumorderbook?.data != null &&
                  mforderbook.mflumpsumorderbook?.stat != "Not Ok"){
    return TransparentLoaderScreen(
      isLoading: mforderbook.mforderloader,
      child: RefreshIndicator(
        onRefresh: () async {
          await mforderbook.fetchMfOrderbook(context);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              
                _buildOrderList(mforderbook, theme, context)
               
            ],
          ),
        ),
      ),
    );
    }

   return Center(child: NoDataFound(
                  title: "No Orders Found",
                  subtitle: "There's nothing here yet. Buy some funds to see them here.",
                  primaryEnabled: false,
                  secondaryEnabled: false,
                ));
  }

  Widget _buildOrderList(
      MFProvider mforderbook, ThemesProvider theme, BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const ListDivider(),
      itemCount: mforderbook.mflumpsumorderbook?.data?.length ?? 0,
      itemBuilder: (context, index) {
        final orderData = mforderbook.mflumpsumorderbook?.data?[index];
        if (orderData == null) return const SizedBox();

        return InkWell(
            onTap: () async {
              mforderbook.loaderfun();
              await mforderbook.fetchorderdetails(orderData.orderId ?? ""
                  // orderData.buySell ?? "",
                  // orderData.ordertype ?? "",
                  // orderData.status ?? "",
                  // orderData.sipregnno ?? "",
                  // orderData.orderremarks ?? "",
                  );

              if (mforderbook.mforderdet?.stat == "Ok") {
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
          decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? colors.colorBlack
                            : colors.colorWhite,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),
                      ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
                    child: const mforderdetscreen()),
                );
                // Navigator.pushNamed(context, Routes.mforderdetscreen);
              } else {
                warningMessage(
                    context,
                    mforderbook.mforderdet?.emsg ??
                        'Error loading order details');
              }
            },
            child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8.0,
                  ),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.1,
                    ),
                    child: TextWidget.subText(
                        align: TextAlign.start,
                        text: orderData.name ?? "Unknown Fund",
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        theme: theme.isDarkMode,
                        fw: 0),
                  ),
                ),
                subtitle: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: orderData.buySell == "P"
                            ? theme.isDarkMode
                                ? colors.profitDark.withOpacity(0.1)
                                : colors.profitLight.withOpacity(0.1)
                            : theme.isDarkMode
                                ? colors.lossDark.withOpacity(0.1)
                                : colors.lossLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: TextWidget.paraText(
                        // align: TextAlign.start,
                        theme: theme.isDarkMode,
                        text: orderData.buySell ?? "-",
                        color: orderData.buySell == "P"
                            ? theme.isDarkMode
                                ? colors.profitDark
                                : colors.profitLight
                            : theme.isDarkMode
                                ? colors.lossDark
                                : colors.lossLight,
                        fw: 0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextWidget.paraText(
                        // align: TextAlign.start,
                        text:
                            "${orderData.orderType == 'NRM' ? 'One-Time' : 'SIP'}",
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                    const SizedBox(width: 8),

                    TextWidget.paraText(
                        // align: TextAlign.start,
                        text: orderData.datetime ?? "-",
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                    // Text(
                    //   orderData.dateTime ?? "-",
                    //   style: textStyle(
                    //       theme.isDarkMode
                    //           ? colors.colorWhite
                    //           : colors.colorBlack,
                    //       10,
                    //       FontWeight.w400),
                    // ),
                  ],
                ),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // SvgPicture.asset(
                    //   _getStatusIcon(orderData.status),
                    //   width: 20,
                    // ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: orderData.status == "ALLOCATED"
                            ? theme.isDarkMode
                                ? colors.profitDark.withOpacity(0.1)
                                : colors.profitLight.withOpacity(0.1)
                            : orderData.status == "REJECTED" ||
                                    orderData.status == "CANCELLED" ||
                                    orderData.status == "PAYMENT DECLINED"
                                ? theme.isDarkMode
                                    ? colors.lossDark.withOpacity(0.1)
                                    : colors.lossLight.withOpacity(0.1)
                                : orderData.status ==
                                        inProgressStatuses
                                            .contains(orderData.status)
                                    ? colors.pending.withOpacity(0.1)
                                    : colors.pending
                                        .withOpacity(0.1), // default fallback
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextWidget.paraText(
                          text: _getListStatusText(orderData.status),
                          theme: false,
                          color: orderData.status == "ALLOCATED"
                              ? theme.isDarkMode
                                  ? colors.profitDark
                                  : colors.profitLight
                              : orderData.status == "REJECTED" ||
                                      orderData.status == "CANCELLED" ||
                                      orderData.status == "PAYMENT DECLINED"
                                  ? theme.isDarkMode
                                      ? colors.lossDark
                                      : colors.lossLight
                                  : orderData.status ==
                                          inProgressStatuses
                                              .contains(orderData.status)
                                      ? colors.pending
                                      : colors.pending,
                                      fw: 0),
                    ),
                    // TextWidget.paraText(
                    //     // align: TextAlign.start,

                    //     color: theme.isDarkMode
                    //         ? colors.textPrimaryDark
                    //         : colors.textPrimaryLight,
                    //     textOverflow: TextOverflow.ellipsis,
                    //     theme: theme.isDarkMode,
                    //     fw: 3),

                    const SizedBox(height: 12),

                    TextWidget.paraText(
                        align: TextAlign.right,
                        text: _formatAmount(orderData.orderVal),
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 0),
                  ],
                )));
      },
    );
  }

  String _getStatusIcon(String? status) {
    if (status == "PLACED") return assets.completedIcon;
    if (status == "NOT PLACED") return assets.cancelledIcon;
    return assets.warningIcon;
  }

  String _getListStatusText(String? status) {
    if (status == "ALLOCATED") return 'ALLOCATED';
    if (status == "REJECTED") return 'REJECTED';
    if (status == "CANCELLED") return 'CANCELLED';
    if (status == "PAYMENT DECLINED") return 'PAYMENT DECLINED';
    if (inProgressStatuses.contains(status)) return 'IN PROGRESS';

    return status ?? 'Unknown';
  }

  String _formatAmount(String? amount) {
    if (amount == null || amount.isEmpty) return '0.00';
    final value = double.tryParse(amount) ?? 0.0;
    return value.toStringAsFixed(2);
  }


}





// Container(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.only(right: 1.0),
//                         child: SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.4,
//                           child: 
//                           TextWidget.subText(
//                                                     align: TextAlign.start,
//                                                     text: orderData.schemename ?? "Unknown Fund",
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textPrimaryDark:
//                                                          colors.textPrimaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                           
//                         ),
//                       ),
//                     ),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         SvgPicture.asset(
//                           _getStatusIcon(orderData.status),
//                           width: 20,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 4.0),
//                          child:   TextWidget.paraText(
//                                                     align: TextAlign.start,
//                                                     text: _getStatusText(orderData.status),
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textPrimaryDark:
//                                                          colors.textPrimaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                          
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: orderData.buySell == "P"
//                             ? const Color(0xFFE5F5EA)
//                             : const Color(0xFFFFC7C7),
//                         borderRadius: BorderRadius.circular(3),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 4,
//                         vertical: 2
//                       ),
//                       child: Text(
//                         orderData.buySell ?? "-",
//                         style: textStyle(
//                           orderData.buySell == "P"
//                               ? const Color(0xFF42A833)
//                               : const Color(0xFFF33E4B),
//                           10,
//                           FontWeight.w400,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     TextWidget.paraText(
//                                                     align: TextAlign.start,
//                                                     text: "${orderData.ordertype == 'NRM' ? 'One-Time' : 'SIP'}",
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textSecondaryDark:
//                                                           colors.textSecondaryLight 
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                     
//                     const SizedBox(width: 8),
//                     Text(
//                       orderData.dateTime ?? "-",
//                       style: textStyle(
//                         theme.isDarkMode
//                             ? colors.colorWhite
//                             : colors.colorBlack,
//                         10,
//                         FontWeight.w400
//                       ),
//                     ),
//                     const Spacer(),
//                     TextWidget.paraText(
//                                                     align: TextAlign.right,
//                                                     text:  _formatAmount(orderData.amount),
//                                                     color: theme.isDarkMode
//                                                         ?  colors.textSecondaryDark:
//                                                          colors.textSecondaryLight
//                                                              ,
//                                                     textOverflow:
//                                                         TextOverflow.ellipsis,
//                                                     theme: theme.isDarkMode,
//                                                     fw: 3),
                    
//                   ],
//                 ),
//               ],
//             ),
//           ),