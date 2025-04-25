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
  late TabController _tabController1;
  final tablistitems = [
    {"title": "Holdings", "index": 0},
    {"title": "Orders", "index": 1}
  ];
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController1 = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, watch, child) {
      final theme = watch(themeProvider);
      final mforderbook = watch(mfProvider);
      return Scaffold(
        body: Stack(
          children: [
            TransparentLoaderScreen(
              isLoading: mforderbook.bestmfloader!,
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
                      indicatorColor: const Color.fromARGB(255, 0, 0, 0),
                      controller: _tabController1,
                      isScrollable: true,
                      tabs: List.generate(
                        tablistitems.length,
                        (tab) => tabConstruce(
                          tablistitems[tab]['title'].toString(),
                          theme,
                          tab,
                          () {},
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController1,
                      children: [
                        const MfHoldNewScreen(),
                        TransparentLoaderScreen(
                          isLoading: mforderbook.mforderloader,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                mforderbook.mfOrderbookfilter == "All"
                                    ? (mforderbook.mflumpsumorderbook == null || mforderbook.mflumpsumorderbook?.stat == "Not Ok")
                                        ? const Padding(
                                            padding: EdgeInsets.only(top: 280),
                                            child: Center(child: NoDataFound()),
                                          )
                                        : ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () async {
                                                  mforderbook.loaderfun();
                                                  await mforderbook.fetchorderdetails(
                                                    "${mforderbook.mflumpsumorderbook!.data![index].ordernumber}",
                                                    "${mforderbook.mflumpsumorderbook!.data![index].buysell}",
                                                    "${mforderbook.mflumpsumorderbook!.data![index].ordertype}",
                                                    "${mforderbook.mflumpsumorderbook!.data![index].orderstatus}",
                                                    "${mforderbook.mflumpsumorderbook!.data![index].sipregnno}",
                                                    "${mforderbook.mflumpsumorderbook!.data![index].orderremarks}",
                                                  );

                                                  if (mforderbook.mforderdet?.stat ==
                                                      "Ok") {
                                                    Navigator.pushNamed(
                                                        context,
                                                        Routes.mforderdetscreen);
                                                  } else {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(successMessage(
                                                            context,
                                                            "${mforderbook.mforderdet?.msg}"));
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(right: 1.0),
                                                              child: SizedBox(
                                                                 width: MediaQuery.of(context).size.width * 0.4,
                                                                child: Text(
                                                                  "${mforderbook.mflumpsumorderbook!.data![index].schemename}",
                                                                  maxLines: 2,
                                                                  style: textStyles
                                                                      .scripNameTxtStyle
                                                                      .copyWith(
                                                                    color: theme
                                                                            .isDarkMode
                                                                        ? colors
                                                                            .colorWhite
                                                                        : colors
                                                                            .colorBlack,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              SvgPicture.asset(
                                                                mforderbook
                                                                            .mflumpsumorderbook!
                                                                            .data![
                                                                                index]
                                                                            .orderstatus ==
                                                                        "VALID"
                                                                    ? assets
                                                                        .completedIcon
                                                                    : mforderbook
                                                                                .mflumpsumorderbook!
                                                                                .data![
                                                                                    index]
                                                                                .orderstatus ==
                                                                            "INVALID"
                                                                        ? assets
                                                                            .cancelledIcon
                                                                        : assets
                                                                            .warningIcon,
                                                                width: 20,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left: 4.0),
                                                                child: Text(
                                                                  mforderbook
                                                                              .mflumpsumorderbook!
                                                                              .data![
                                                                                  index]
                                                                              .orderstatus ==
                                                                          "VALID"
                                                                      ? 'Success'
                                                                      : mforderbook.mflumpsumorderbook!.data![index].orderstatus ==
                                                                              'PENDING'
                                                                          ? 'Pending' 
                                                                           : mforderbook.mflumpsumorderbook!.data![index].orderstatus ==
                                                                              'INVALID'
                                                                          ? 'Invalid'
                                                                          : mforderbook
                                                                              .mflumpsumorderbook!
                                                                              .data![index]
                                                                              .orderstatus!,
                                                                  style: textStyle(
                                                                      theme.isDarkMode
                                                                          ? colors
                                                                              .colorWhite
                                                                          : colors
                                                                              .colorBlack,
                                                                      14,
                                                                      FontWeight
                                                                          .w600),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: mforderbook
                                                                          .mflumpsumorderbook!
                                                                          .data![
                                                                              index]
                                                                          .buysell ==
                                                                      "P"
                                                                  ? const Color(
                                                                      0xFFE5F5EA)
                                                                  : const Color(
                                                                      0xFFFFC7C7),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(3),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4,
                                                                    vertical: 2),
                                                            child: Text(
                                                              "${mforderbook.mflumpsumorderbook!.data![index].buysell}",
                                                              style: textStyle(
                                                                mforderbook
                                                                            .mflumpsumorderbook!
                                                                            .data![
                                                                                index]
                                                                            .buysell ==
                                                                        "P"
                                                                    ? const Color(
                                                                        0xFF42A833)
                                                                    : const Color(
                                                                        0xFFF33E4B),
                                                                10,
                                                                FontWeight.w400,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          CustomExchBadge(
                                                            exch:
                                                                "${mforderbook.mflumpsumorderbook!.data![index].ordertype == "NRM" ? "One-Time" : "SIP"}",
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(
                                                            "${mforderbook.mflumpsumorderbook?.data?[index].dateTime}",
                                                            style: textStyle(
                                                                theme.isDarkMode
                                                                    ? colors
                                                                        .colorWhite
                                                                    : colors
                                                                        .colorBlack,
                                                                10,
                                                                FontWeight.w400),
                                                          ),
                                                          const Spacer(),
                                                          Text(
                                                            '${mforderbook.mflumpsumorderbook!.data![index].amount == "" || double.tryParse(mforderbook.mflumpsumorderbook!.data![index].amount.toString()) == null ? '0.00' : double.tryParse(mforderbook.mflumpsumorderbook!.data![index].amount.toString())!.toStringAsFixed(2)}',
                                                            style: textStyle(
                                                                colors.colorGrey,
                                                                12,
                                                                FontWeight.w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            separatorBuilder:
                                                (BuildContext context, int index) {
                                              return Container(
                                                color: theme.isDarkMode
                                                    ? colors.darkGrey
                                                    : const Color(0xffF1F3F8),
                                                height: 2,
                                              );
                                            },
                                          itemCount: mforderbook.mflumpsumorderbook?.data?.length ?? 0,

                                          )
                                    : const Padding(
                                        padding: EdgeInsets.only(top: 300),
                                        child: Center(child: NoDataFound()),
                                      ),
                              ],
                            ),
                          ),
                        ),
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

  Widget tabConstruce(
      String title, ThemesProvider theme, int tab, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          activeTab = tab;
        });
        _tabController1.animateTo(tab);
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: textStyle(
              theme.isDarkMode
                  ? Color(tab == activeTab ? 0xFFFFFFFF : 0xff5E6B7D)
                  : Color(tab == activeTab ? 0xff000000 : 0xff000000),
              15,
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}