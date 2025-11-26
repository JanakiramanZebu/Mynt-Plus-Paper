import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/models/mf_model/mf_bestnewapi_list_model.dart';
import 'package:mynt_plus/sharedWidget/custom_back_btn.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import '../../models/mf_model/mutual_fundmodel.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_drag_handler.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/loader_ui.dart';
import '../../sharedWidget/splash_loader.dart';
import 'widget/allocation.dart';
import 'widget/comparition.dart';
import 'widget/overview.dart';
import 'widget/performance.dart';
import 'widget/scheme.dart';

class MFStockDetailScreen extends StatefulWidget {
  final MutualFundList mfStockData;
  final bool fromSearch;

  // final TaxSaving mfStockData;
  //  final mfData = mfProvider;
  const MFStockDetailScreen({super.key, required this.mfStockData, this.fromSearch = false});

//    final MutualFundList mfStockData1;
//  MFStockDetailScreen({super.key, required this.mfStockData1});

  @override
  State<MFStockDetailScreen> createState() => _MFStockDetailScreenState();
}

class _MFStockDetailScreenState extends State<MFStockDetailScreen>
    with SingleTickerProviderStateMixin {
  final List<String> tabList = [
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 400) {
          Navigator.of(context).pop();
        }
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.05,
        maxChildSize: 0.99,
        builder: (context, scrollController) {
          return Consumer(builder: (context, WidgetRef ref, _) {
            final theme = ref.watch(themeProvider);
            final fund = ref.watch(fundProvider);
            final mfData = ref.watch(mfProvider);

            return SafeArea(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Container(
                  decoration: BoxDecoration(
                    color:
                        theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: theme.isDarkMode ? Border(
                      top: BorderSide(
                        color: colors.textSecondaryDark.withOpacity(0.5),
                      ),
                      left: BorderSide(
                        color: colors.textSecondaryDark.withOpacity(0.5),
                      ),
                      right: BorderSide(
                        color: colors.textSecondaryDark.withOpacity(0.5),
                      ),
                    ) : null,
                  ),
                  child: Stack(
                    children: [
                      Column(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const CustomDragHandler(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorWhite,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            children: [
                                              _buildFundHeader(theme, mfData),
                                              const SizedBox(height: 16),
                                              _buildBottomActionButtons(
                                                  context, theme, mfData),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Tab Content - Scrollable
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: ClampingScrollPhysics(),
                                  controller: scrollController,
                                  child: Column(
                                    children: [
                                      MFOverview(mfStockData: widget.mfStockData),
                                      MFPerformance(
                                          mfStockData: widget.mfStockData),
                                      MFAllocation(
                                          mfStockData: widget.mfStockData),
                                      MFSchemeInfo(
                                          mfStockData: widget.mfStockData),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                      // Black overlay with Mynt logo loader
                      if (mfData.singleloader == true)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: CircularLoaderImage(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildBottomActionButtons(
      BuildContext context, dynamic theme, dynamic mfData) {
    return Row(
      children: [
        Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: mfData.singleloader == true 
                              ? (theme.isDarkMode 
                                  ? colors.primaryDark.withOpacity(0.5)
                                  : colors.primaryLight.withOpacity(0.5))
                              : (theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          )),
                      onPressed: mfData.singleloader == true ? null : () async {
                        final isin = widget.mfStockData.iSIN;
                        final schemeCode = widget.mfStockData.schemeCode;

                        if (widget.mfStockData.sIPFLAG == "Y" &&
                            isin != null &&
                            schemeCode != null) {
                          await mfData.invertfun(isin, schemeCode, context);
                          String amt =
                              widget.mfStockData.minimumPurchaseAmount ?? "0";
                          mfData.invAmt.text = amt.split('.').first;
                        }
                        Navigator.pushNamed(context, Routes.mforderScreen,
                            arguments: widget.mfStockData);
                        mfData.orderchangetitle("One-time");
                        mfData.orderpagetite("SDS");
                        mfData.chngOrderType("One-time");
                      },
                      child: TextWidget.subText(
                        text: "One-time",
                        theme: false,
                        color: colors.colorWhite,
                        fw: 2,
                        align: TextAlign.center,
                      )),
                ))),
        const SizedBox(width: 10),
        Expanded(
            child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 45,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          backgroundColor: mfData.singleloader == true 
                              ? (theme.isDarkMode 
                                  ? colors.primaryDark.withOpacity(0.5)
                                  : colors.primaryLight.withOpacity(0.5))
                              : (theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          )),
                      onPressed: mfData.singleloader == true ? null : () async {
                        final isin = widget.mfStockData.iSIN;
                        final schemeCode = widget.mfStockData.schemeCode;

                        if (widget.mfStockData.sIPFLAG == "Y" &&
                            isin != null &&
                            schemeCode != null) {
                          await mfData.invertfun(isin, schemeCode, context);
                          String amt =
                              widget.mfStockData.minimumPurchaseAmount ?? "0";
                          mfData.installmentAmt.text = amt.split('.').first;
                        }
                        Navigator.pushNamed(context, Routes.mforderScreen,
                            arguments: widget.mfStockData);
                        mfData.orderchangetitle("SIP");
                        mfData.chngOrderType("SIP");
                        mfData.orderpagetite("SDS");
                      },
                      child: TextWidget.subText(
                        text: "SIP",
                        theme: false,
                        color: colors.colorWhite,
                        fw: 2,
                        align: TextAlign.center,
                      )),
                ))),
      ],
    );
  }

  Widget _buildFundHeader(dynamic theme, dynamic mfData) {
    final amcCode = widget.mfStockData.aMCCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                "https://v3.mynt.in/mfapi/static/images/mf/${mfData.factSheetDataModel?.data?.amccode ?? 'default'}.png",
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: TextWidget.titleText(
                      align: TextAlign.start,
                      text: _formatFundName(mfData),
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      textOverflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      theme: theme.isDarkMode,
                      fw: 1),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 18,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      TextWidget.paraText(
                        fw: 0,
                        text: widget.mfStockData.type ?? "Unknown",
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        theme: false,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 5),
                      //   child: TextWidget.paraText(
                      //     fw: 3,
                      //     text: widget.mfStockData.subtype ?? "Unknown",
                      //     textOverflow: TextOverflow.ellipsis,
                      //     maxLines: 1,
                      //     color: theme.isDarkMode
                      //         ? colors.textSecondaryDark
                      //         : colors.textSecondaryLight,
                      //     theme: false,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        if(!widget.fromSearch)
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            height: 30,
            width: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minHeight: 25,
                minWidth: 25,
              ),
              icon: SvgPicture.asset(
                mfData.watchbatchval == true
                    ? assets.bookmarkIcon
                    : assets.bookmarkedIcon,
                fit: BoxFit.contain,
                color: mfData.watchbatchval == true
                    ? colors.colorBlue
                    : colors.colorGrey,
                height: 20,
              ),
              onPressed: () async {
                final isin = widget.mfStockData.iSIN;
                if (isin != null) {
                  await mfData.fetchMFWatchlist(
                    isin,
                    mfData.watchbatchval == true ? "delete" : "add",
                    context,
                    false,
                    "watch",
                  );
                  mfData.fetchmatchisan(isin);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatFundName(dynamic mfData) {
    if (mfData.factSheetDataModel?.data?.name != null) {
      return mfData.factSheetDataModel!.data!.name!
          .replaceAll(RegExp(r'(Reg \(G\)|\(G\))$'), ' ');
    }
    return widget.mfStockData.schemeName ?? 'Unknown Fund';
  }

  Widget _buildFundMetrics(dynamic theme, MFProvider mfdatapro) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // _buildMetricColumn(
        //     "AUM (CR)", _formatAum(widget.mfStockData.aUM), theme),
        _buildMetricColumn(
            "NAV",
            _formatValue(mfdatapro.factSheetDataModel?.data?.currentNAV),
            theme),
        // _buildMetricColumn("MIN. INV",
        //     _formatValue(widget.mfStockData.minimumPurchaseAmount), theme),
        // _buildMetricColumn("5YR CAGR",
        //     _formatYearData(widget.mfStockData.fIVEYEARDATA), theme),
      ],
    );
  }

  Widget _buildMetricColumn(String title, String value, dynamic theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 7),
        TextWidget.subText(
            align: TextAlign.right,
            text: title,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
        const SizedBox(height: 6),
        TextWidget.paraText(
            align: TextAlign.right,
            text: value,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textPrimaryLight,
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            fw: 0),
      ],
    );
  }

  String _formatAum(String? aum) {
    if (aum == null || aum.isEmpty) return "0.00";
    try {
      return double.parse(aum).toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  String _formatValue(String? value) {
    return value?.isEmpty ?? true ? "0.00" : value!;
  }

  String _formatYearData(String? yearData) {
    if (yearData == null || yearData.isEmpty) return "0.00";
    return "$yearData%";
  }
}
