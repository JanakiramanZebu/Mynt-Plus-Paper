import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_hold_new_screen.dart';
import 'package:mynt_plus/screens/mutual_fund/mf_sip_screen.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';

import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/list_divider.dart';
import '../../sharedWidget/loader_ui.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';
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
  int activeTab = 0;

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
      return Scaffold(
        body: Stack(
          children: [
            TransparentLoaderScreen(
              isLoading: mforderbook.bestmfloader == true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(bottom: 0, left: 0, top: 2),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          width: 0.4,
                        ),
                        bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                          width: 0.4,
                        ),
                      ),
                    ),
                    child: TabBar(
                      labelPadding: const EdgeInsets.only(right: 0, bottom: 0),
                      tabAlignment: TabAlignment.start,
                      indicatorColor: theme.isDarkMode
                          ? colors.secondaryDark
                          : colors.secondaryLight,
                      controller: _tabController,
                      isScrollable: true,
                      tabs: List.generate(
                        tablistitems.length,
                        (tab) => _buildTab(tab, theme),
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
        ),
      );
    });
  }

  Widget _buildOrdersTab(
      MFProvider mforderbook, ThemesProvider theme, BuildContext context) {
    return TransparentLoaderScreen(
      isLoading: mforderbook.mforderloader,
      child: RefreshIndicator(
        onRefresh: () async {
          await mforderbook.fetchMfOrderbook(context);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (mforderbook.mfOrderbookfilter == "All" &&
                  mforderbook.mflumpsumorderbook?.data != null &&
                  mforderbook.mflumpsumorderbook?.stat != "Not Ok")
                _buildOrderList(mforderbook, theme, context)
              else
                const Padding(
                  padding: EdgeInsets.only(top: 300),
                  child: Center(child: NoDataFound()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(
      MFProvider mforderbook, ThemesProvider theme, BuildContext context) {
    return ListView.separated(
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
                ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                    context,
                    mforderbook.mforderdet?.emsg ??
                        'Error loading order details'));
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
                        fw: 3),
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
                        fw: 3),
                    const SizedBox(width: 8),

                    TextWidget.paraText(
                        // align: TextAlign.start,
                        text: orderData.datetime ?? "-",
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 3),
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
                                      : colors.pending),
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
                        fw: 3),
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

  Widget _buildTab(int tab, ThemesProvider theme) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          activeTab = tab;
        });
        _tabController.animateTo(tab);
      },
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 50),
        overlayColor: Colors.transparent, // no splash
        splashFactory: NoSplash.splashFactory,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        // backgroundColor: theme.isDarkMode
        //     ? tab == activeTab
        //         ? colors.colorBlack
        //         : const Color.fromARGB(255, 0, 0, 0).withOpacity(.15)
        //     : tab == activeTab
        //         ? const Color.fromARGB(255, 255, 255, 255)
        //         : const Color.fromARGB(255, 255, 255, 255),

        backgroundColor:
            theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        shape: const StadiumBorder(),
      ),
      child: TextWidget.subText(
          align: TextAlign.right,
          text: tablistitems[tab]['title'].toString(),
          color: theme.isDarkMode
              ? tab == activeTab
                  ? colors.secondaryDark
                  : colors.textSecondaryDark
              : tab == activeTab
                  ? colors.secondaryLight
                  : colors.textSecondaryLight,
          textOverflow: TextOverflow.ellipsis,
          theme: theme.isDarkMode,
          fw: tab == activeTab ? 2 : 3),
    );
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