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
import '../../sharedWidget/loader_ui.dart';
import '../portfolio_screens/mfHoldings/mf_holding_screen.dart';

class MfOrderBookScreen extends StatefulWidget {
  const MfOrderBookScreen({super.key});
  @override
  State<MfOrderBookScreen> createState() => _MfOrderBookScreen();
}

class _MfOrderBookScreen extends State<MfOrderBookScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tablistitems = [
    {"title": "Holdings", "index": 0},
    {"title": "Orders", "index": 1}
  ];
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
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
            Column(
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
                            ? colors.primaryDark
                            : colors.primaryLight, 
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
          ],
        ),
      );
    });
  }

  Widget _buildOrdersTab(MFProvider mforderbook, ThemesProvider theme, BuildContext context) {
    return TransparentLoaderScreen(
      isLoading: mforderbook.mforderloader,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (mforderbook.mfOrderbookfilter == "All" && mforderbook.mflumpsumorderbook != null && mforderbook.mflumpsumorderbook?.stat != "Not Ok")
              _buildOrderList(mforderbook, theme, context)
            else
              const Padding(
                padding: EdgeInsets.only(top: 300),
                child: Center(child: NoDataFound()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(MFProvider mforderbook, ThemesProvider theme, BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mforderbook.mflumpsumorderbook?.data?.length ?? 0,
      itemBuilder: (context, index) {
        final orderData = mforderbook.mflumpsumorderbook?.data?[index];
        if (orderData == null) return const SizedBox();
        
        return InkWell(
          onTap: () async {
            mforderbook.loaderfun();
            await mforderbook.fetchorderdetails(
              orderData.ordernumber ?? "",
              orderData.buysell ?? "",
              orderData.ordertype ?? "",
              orderData.orderstatus ?? "",
              orderData.sipregnno ?? "",
              orderData.orderremarks ?? "",
            );

            if (mforderbook.mforderdet?.stat == "Ok") {
              Navigator.pushNamed(context, Routes.mforderdetscreen);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                successMessage(context, "${mforderbook.mforderdet?.msg ?? 'Error loading order details'}")
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 1.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: 
                          TextWidget.subText(
                                                    align: TextAlign.start,
                                                    text: orderData.schemename ?? "Unknown Fund",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                           
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          _getStatusIcon(orderData.orderstatus),
                          width: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                         child:   TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text: _getStatusText(orderData.orderstatus),
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                          
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: orderData.buysell == "P"
                            ? const Color(0xFFE5F5EA)
                            : const Color(0xFFFFC7C7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2
                      ),
                      child: Text(
                        orderData.buysell ?? "-",
                        style: textStyle(
                          orderData.buysell == "P"
                              ? const Color(0xFF42A833)
                              : const Color(0xFFF33E4B),
                          10,
                          FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text: "${orderData.ordertype == 'NRM' ? 'One-Time' : 'SIP'}",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark:
                                                          colors.textSecondaryLight 
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                     
                    const SizedBox(width: 8),
                    Text(
                      orderData.dateTime ?? "-",
                      style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        10,
                        FontWeight.w400
                      ),
                    ),
                    const Spacer(),
                    TextWidget.paraText(
                                                    align: TextAlign.right,
                                                    text:  _formatAmount(orderData.amount),
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark:
                                                         colors.textSecondaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                    
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          color: theme.isDarkMode
              ? colors.darkGrey
              : const Color(0xffF1F3F8),
          height: 2,
        );
      },
    );
  }

  String _getStatusIcon(String? status) {
    if (status == "VALID") return assets.completedIcon;
    if (status == "INVALID") return assets.cancelledIcon;
    return assets.warningIcon;
  }

  String _getStatusText(String? status) {
    if (status == "VALID") return 'Success';
    if (status == 'PENDING') return 'Pending';
    if (status == 'INVALID') return 'Invalid';
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
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        backgroundColor: theme.isDarkMode
            ? tab == activeTab
                ? colors.colorBlack
                : const Color.fromARGB(255, 0, 0, 0).withOpacity(.15)
            : tab == activeTab
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color.fromARGB(255, 255, 255, 255),
        shape: const StadiumBorder(),
      ),
      child: 
      TextWidget.subText(
                                                    align: TextAlign.right,
                                                    text:  tablistitems[tab]['title'].toString(),
       
                                                    color:theme.isDarkMode
              ? tab == activeTab  
              ? colors.primaryDark : colors.textSecondaryDark
              : tab == activeTab
                ? colors.primaryLight
                : colors.textSecondaryLight,
              
                                                             
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: tab == activeTab ? 1 : 3),
      
      
    );
  }
}