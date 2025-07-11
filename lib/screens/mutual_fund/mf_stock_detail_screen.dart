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

  // final TaxSaving mfStockData;
  //  final mfData = mfProvider;
  const MFStockDetailScreen({super.key, required this.mfStockData});

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
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);
      final fund = ref.watch(fundProvider);
      final mfData = ref.watch(mfProvider);

      return Scaffold(
        backgroundColor: Colors.white,
        bottomSheet: _buildBottomActionButtons(context, theme, mfData),
        body: TransparentLoaderScreen(
          isLoading: mfData.singleloader ?? false,
          child: VerticalScrollableTabView(
            autoScrollController: autoScrollController,
            tabController: tabController,
            listItemData: tabList,
            slivers: [
              _buildAppBar(context, theme, mfData),
            ],
            eachItemChild: (tabName, int index) {
              switch (tabName) {
                case "Overview":
                  return MFOverview(mfStockData: widget.mfStockData);
                case "Performance":
                  return MFPerformance(mfStockData: widget.mfStockData);
                case "Scheme":
                  return MFSchemeInfo(mfStockData: widget.mfStockData);
                case "Allocation":
                  return MFAllocation(mfStockData: widget.mfStockData);
                case "Rollings":
                  return Container();
                default:
                  return MFComparison(mfStockData: widget.mfStockData);
              }
            }
          ),
        ),
      );
    });
  }

  Widget _buildBottomActionButtons(BuildContext context, dynamic theme, dynamic mfData) {
    return Container(
      color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      padding: const EdgeInsets.symmetric( vertical: 8 , horizontal: 14.0),
      child: Row(
        children: [
          Expanded(
            child: 
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10,  ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        )),
                    onPressed: () async {
                final isin = widget.mfStockData.iSIN;
                final schemeCode = widget.mfStockData.schemeCode;
                
                if (widget.mfStockData.sIPFLAG == "Y" && isin != null && schemeCode != null) {
                  await mfData.invertfun(isin, schemeCode);
                }
                Navigator.pushNamed(context, Routes.mforderScreen,
                    arguments: widget.mfStockData);
                mfData.orderchangetitle("One-time");
                mfData.orderpagetite("SDS");
                mfData.chngOrderType("One-time");
              },
                    child: TextWidget.subText(
                      text:  "One-time",
                      theme: false,
                      color: colors.colorWhite,
                      fw: 2,
                      align: TextAlign.center,
                    )),
              ))
            
            
            
             
          ),
          const SizedBox(width: 10),
          Expanded(
            child: 
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10,  ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        )),
                    onPressed: () async {
                final isin = widget.mfStockData.iSIN;
                final schemeCode = widget.mfStockData.schemeCode;
                
                if (widget.mfStockData.sIPFLAG == "Y" && isin != null && schemeCode != null) {
                  await mfData.invertfun(isin, schemeCode);
                }
                Navigator.pushNamed(context, Routes.mforderScreen,
                    arguments: widget.mfStockData);
                mfData.orderchangetitle("SIP");
                mfData.chngOrderType("SIP");
                mfData.orderpagetite("SDS");
              },
                    child: TextWidget.subText(
                      text:  "SIP",
                      theme: false,
                      color: colors.colorWhite,
                      fw: 2,
                      align: TextAlign.center,
                    )),
              ))
            
            
            
             
          ),
           
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, dynamic theme, dynamic mfData) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      leadingWidth: 41,
      centerTitle: false,
      titleSpacing: 2,
      toolbarHeight: 68,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      actions: [
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
                mfData.watchbatchval == true ? assets.bookmarkIcon : assets.bookmarkedIcon,
                fit: BoxFit.contain,
                color: mfData.watchbatchval == true ? colors.colorBlue : colors.colorGrey,
                height: 25,
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                color: theme.isDarkMode 
                  ? const Color.fromARGB(255, 0, 0, 0) 
                  : const Color.fromARGB(255, 250, 251, 255),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      _buildFundHeader(theme, mfData),
                      const SizedBox(height: 8),
                      _buildFundMetrics(theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundHeader(dynamic theme, dynamic mfData) {
    final amcCode = widget.mfStockData.aMCCode;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(
            "https://v3.mynt.in/mf/static/images/mf/${amcCode ?? 'default'}.png",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.titleText(
                                                    align: TextAlign.start,
                                                    text: _formatFundName(mfData),
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 1),
              
              const SizedBox(height: 8),
              SizedBox(
                height: 18,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [ 
                    TextWidget.paraText(
                                  fw: 3,
                                  text: widget.mfStockData.type ?? "Unknown",
                                  textOverflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  theme: false,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: TextWidget.paraText(
                                    fw: 3,
                                    text: widget.mfStockData.subtype ?? "Unknown",
                                    textOverflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                    theme: false,
                                  ),
                                  
                                  
                                ),
                    
                  ],
                ),
              ),
            ],
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

  Widget _buildFundMetrics(dynamic theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricColumn("AUM (CR)", _formatAum(widget.mfStockData.aUM), theme),
        _buildMetricColumn("NAV", _formatValue(widget.mfStockData.nETASSETVALUE), theme),
        _buildMetricColumn("MIN. INV", _formatValue(widget.mfStockData.minimumPurchaseAmount), theme),
        _buildMetricColumn("5YR CAGR", _formatYearData(widget.mfStockData.fIVEYEARDATA), theme),
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
                                                        ?  colors.textPrimaryDark
                                                             :  
                                                             
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
         
        const SizedBox(height: 6),
        TextWidget.paraText(
                                                    align: TextAlign.right,
                                                    text: value,
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark
                                                             :  
                                                             
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
         
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
