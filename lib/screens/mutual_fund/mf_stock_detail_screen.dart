import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../models/mf_model/mutual_fundmodel.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import 'widget/allocation.dart';
import 'widget/comparition.dart';
import 'widget/overview.dart';
import 'widget/performance.dart';
import 'widget/scheme.dart';

class MFStockDetailScreen extends StatefulWidget {
  final MutualFundList mfStockData;
  const MFStockDetailScreen({super.key, required this.mfStockData});

  @override
  State<MFStockDetailScreen> createState() => _MFStockDetailScreenState();
}

class _MFStockDetailScreenState extends State<MFStockDetailScreen>
    with SingleTickerProviderStateMixin {
  List<String> tabList = [
    "Overview",
    "Performance",
    "Scheme",
    "Allocation",
    // "Rollings",
    "Comparition"
  ];

  late TabController tabController;
  late AutoScrollController autoScrollController;
  double scrollPosition = 0.00;
  @override
  void initState() {
    tabController = TabController(length: tabList.length, vsync: this);
    autoScrollController = AutoScrollController();
    autoScrollController.addListener(() {
      scrollPosition = autoScrollController.offset;
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    autoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);

      final mfData = watch(mfProvider);
      return Scaffold(
          backgroundColor: Colors.white,
          body: VerticalScrollableTabView(
              autoScrollController: autoScrollController,
              tabController: tabController,
              listItemData: tabList,
              slivers: [
                SliverAppBar(
                    pinned: true,
                    elevation: .2,
                    leadingWidth: 41,
                    centerTitle: false,
                    titleSpacing: 2,
                    leading: const CustomBackBtn(),
                    shadowColor: const Color(0xffECEFF3),
                    title: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              backgroundImage: NetworkImage(
                                  "https://v3.mynt.in/mf/static/images/mf/${widget.mfStockData.aMCCode}.png")),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("${widget.mfStockData.fSchemeName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        16,
                                        FontWeight.w500)),
                                const SizedBox(height: 5),
                                SizedBox(
                                  height: 18,
                                  child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      CustomExchBadge(
                                          exch: widget.mfStockData.schemeName!
                                                  .contains("GROWTH")
                                              ? "GROWTH"
                                              : widget.mfStockData.schemeName!
                                                      .contains("IDCW PAYOUT")
                                                  ? "IDCW PAYOUT"
                                                  : widget.mfStockData.schemeName!
                                                          .contains(
                                                              "IDCW REINVESTMENT")
                                                      ? "IDCW REINVESTMENT"
                                                      : widget.mfStockData
                                                              .schemeName!
                                                              .contains("IDCW")
                                                          ? "IDCW"
                                                          : "NORMAL"),
                                      CustomExchBadge(
                                          exch: "${widget.mfStockData.schemeType}"),
                                      CustomExchBadge(
                                          exch: widget
                                              .mfStockData.sCHEMESUBCATEGORY!
                                              .replaceAll("Fund", '')
                                              .replaceAll("Hybrid", "")
                                              .toUpperCase()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    backgroundColor: Colors.white,
                    bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(90),
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("AUM (cr): ",
                                        style: textStyle(
                                            const Color(0xff999999),
                                            12,
                                            FontWeight.w500)),
                                    const SizedBox(height: 3),
                                    Text(
                                        (double.parse(widget.mfStockData.aUM!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : widget.mfStockData.aUM!) /
                                                10000000)
                                            .toStringAsFixed(2),
                                        style: textStyle(colors.colorBlack, 12,
                                            FontWeight.w500)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Min. Inv",
                                        style: textStyle(
                                            const Color(0xff999999),
                                            12,
                                            FontWeight.w500)),
                                    const SizedBox(height: 3),
                                    Text(
                                        widget.mfStockData
                                                .minimumPurchaseAmount!.isEmpty
                                            ? "0.00"
                                            : widget.mfStockData
                                                .minimumPurchaseAmount!,
                                        style: textStyle(colors.colorBlack, 12,
                                            FontWeight.w500)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xffEEF0F2),
                                          width: 1.5)),
                                  child: Row(
                                    children: [
                                      SvgPicture.asset(
                                          int.parse(mfData.factSheetDataModel!
                                                          .data!.risk ??
                                                      "0") >
                                                  3
                                              ? assets.highRisk
                                              : assets.lowRisk,
                                          height: 22,
                                          width: 22),
                                      const SizedBox(width: 12),
                                      Column(
                                        children: [
                                          Text("RISK METER",
                                              style: textStyle(
                                                  const Color(0xff999999),
                                                  12,
                                                  FontWeight.w500)),
                                          const SizedBox(height: 2),
                                          Text(
                                              mfData.factSheetDataModel!.data!
                                                          .risk ==
                                                      "1"
                                                  ? "Low"
                                                  : mfData.factSheetDataModel!
                                                              .data!.risk ==
                                                          "2"
                                                      ? "Moderately Low"
                                                      : mfData.factSheetDataModel!
                                                                  .data!.risk ==
                                                              "3"
                                                          ? "Moderate"
                                                          : mfData.factSheetDataModel!
                                                                      .data!.risk ==
                                                                  "4"
                                                              ? "Moderately High"
                                                              : mfData
                                                                          .factSheetDataModel!
                                                                          .data!
                                                                          .risk ==
                                                                      "5"
                                                                  ? "High"
                                                                  : "Very High",
                                              style: textStyle(
                                                  colors.colorBlack,
                                                  12,
                                                  FontWeight.w500)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TabBar(
                              isScrollable: true,
                              controller: tabController,
                              indicatorPadding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicatorColor: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue,
                              unselectedLabelColor: const Color(0XFF777777),
                              unselectedLabelStyle: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.28)),
                              labelColor: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue,
                              labelStyle: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              tabs: tabList.map((e) {
                                return Tab(text: e);
                              }).toList(),
                              onTap: (index) {
                                VerticalScrollableTabBarStatus.setIndex(index);
                              })
                        ])))
              ],
              eachItemChild: (aaa, int index) {
                return aaa == "Overview"
                    ? MFOverview(mfStockData: widget.mfStockData)
                    : aaa == "Performance"
                        ? MFPerformance(mfStockData: widget.mfStockData)
                        : aaa == "Scheme"
                            ? MFSchemeInfo(mfStockData: widget.mfStockData)
                            : aaa == "Allocation"
                                ? MFAllocation(mfStockData: widget.mfStockData)
                                : aaa == "Rollings"
                                    ? Container()
                                    : MFComparison(
                                        mfStockData: widget.mfStockData);
              }));
    });
  }
}
