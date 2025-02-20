import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../models/mf_model/mutual_fundmodel.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/loader_ui.dart';
import 'widget/allocation.dart';
import 'widget/comparition.dart';
import 'widget/overview.dart';
import 'widget/performance.dart';
import 'widget/scheme.dart';

class MFStockDetailScreen extends StatefulWidget {
  final MutualFundList mfStockData;
  const MFStockDetailScreen({super.key, required this.mfStockData});

//    final MutualFundList mfStockData1;
//  MFStockDetailScreen({super.key, required this.mfStockData1});

  @override
  State<MFStockDetailScreen> createState() => _MFStockDetailScreenState();
}

class _MFStockDetailScreenState extends State<MFStockDetailScreen>
    with SingleTickerProviderStateMixin {
  List<String> tabList = [
    "Overview",
    "Performance",
    "Allocation",
    "Scheme",
    // "Rollings",
    // "Comparition"
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
      final fund = watch(fundProvider);
      final mfData = watch(mfProvider);

      return Scaffold(
        backgroundColor: Colors.white,
        bottomSheet: Container(
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: () { 
                    if (widget.mfStockData.sIPFLAG == "Y") {
                      mfData.invertfun("${widget.mfStockData.iSIN}",
                          "${widget.mfStockData.schemeCode}");
                    }

                    //  mfData.fetchTopSchemes();
                    Navigator.pushNamed(context, Routes.mforderScreen,
                        arguments: widget.mfStockData);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: colors.colorBlack,
                    shape: const StadiumBorder(),
                  ),
                  child: Text("Invest",
                      style: textStyle(
                          const Color(0xffffffff), 14, FontWeight.w600)),
                ),
              ),
              if (defaultTargetPlatform == TargetPlatform.iOS)
                const SizedBox(height: 18),
            ],
          ),
        ),
        body: TransparentLoaderScreen(
          isLoading: mfData.singleloader!,
          child: VerticalScrollableTabView(
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
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(110),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        color: const Color.fromARGB(255, 250, 251, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      "https://v3.mynt.in/mf/static/images/mf/${widget.mfStockData.aMCCode}.png",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${widget.mfStockData.fSchemeName}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            17,
                                            FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 18,
                                          child: ListView(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            children: [
                                              CustomExchBadge(
                                                exch: widget
                                                        .mfStockData.schemeName!
                                                        .contains("GROWTH")
                                                    ? "GROWTH"
                                                    : widget.mfStockData
                                                            .schemeName!
                                                            .contains(
                                                                "IDCW PAYOUT")
                                                        ? "IDCW PAYOUT"
                                                        : widget.mfStockData
                                                                .schemeName!
                                                                .contains(
                                                                    "IDCW REINVESTMENT")
                                                            ? "IDCW REINVESTMENT"
                                                            : widget.mfStockData
                                                                    .schemeName!
                                                                    .contains(
                                                                        "IDCW")
                                                                ? "IDCW"
                                                                : "NORMAL",
                                              ),
                                              const SizedBox(width: 5),
                                              CustomExchBadge(
                                                  exch:
                                                      "${widget.mfStockData.schemeType}"),
                                              const SizedBox(width: 5),
                                              CustomExchBadge(
                                                exch: widget.mfStockData
                                                    .sCHEMESUBCATEGORY!
                                                    .replaceAll("Fund", '')
                                                    .replaceAll("Hybrid", "")
                                                    .toUpperCase(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Padding(
                                  //   padding: const EdgeInsets.all(10.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 7),
                                      Text(
                                        "AUM (CR)",
                                        style: textStyle(
                                          const Color(0xff999999),
                                          12,
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        (double.parse(widget.mfStockData.aUM!
                                                        .isEmpty
                                                    ? "0.00"
                                                    : widget.mfStockData.aUM!) /
                                                10000000)
                                            .toStringAsFixed(2),
                                        style: textStyle(colors.colorBlack, 14,
                                            FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  // ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        "NAV",
                                        style: textStyle(
                                          const Color(0xff999999),
                                          12,
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        widget.mfStockData.nETASSETVALUE!
                                                .isEmpty
                                            ? "0.00"
                                            : widget.mfStockData.nETASSETVALUE!,
                                        style: textStyle(colors.colorBlack, 14,
                                            FontWeight.w600),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        "MIN. INV",
                                        style: textStyle(
                                          const Color(0xff999999),
                                          12,
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        widget.mfStockData
                                                .minimumPurchaseAmount!.isEmpty
                                            ? "0.00"
                                            : widget.mfStockData
                                                .minimumPurchaseAmount!,
                                        style: textStyle(colors.colorBlack, 14,
                                            FontWeight.w600),
                                      ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        "5YR CAGR",
                                        style: textStyle(
                                          const Color(0xff999999),
                                          12,
                                          FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        widget.mfStockData.fIVEYEARDATA
                                                    ?.isEmpty ??
                                                true
                                            ? "0.00"
                                            : "${widget.mfStockData.fIVEYEARDATA}%",
                                        style: textStyle(colors.colorBlack, 14,
                                            FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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
              }),
        ),
      );
    });
  }
}
