import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../models/marketwatch_model/market_watch_scrip_model.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/no_data_found.dart';
import 'over_view/funtamental_data_widget.dart';
import 'over_view/financial.dart';
import 'over_view/price_comparision.dart';
import 'over_view/stocks_holdings_widget.dart';
import 'over_view/stock_events.dart';
import 'over_view/mf_holding.dart';
import 'over_view/chart.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class FundamentalDetailScreen extends ConsumerStatefulWidget {
  final DepthInputArgs wlValue;
  final GetQuotes depthData;

  const FundamentalDetailScreen({
    super.key,
    required this.wlValue,
    required this.depthData,
  });

  @override
  ConsumerState<FundamentalDetailScreen> createState() => _FundamentalDetailScreenState();
}

class _FundamentalDetailScreenState extends ConsumerState<FundamentalDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final double tabWidth = 85.0;
  
  final List<Map<String, String>> _tabs = [
    {'title': 'Ratios', 'subtitle': 'Fundamental ratios'},
    {'title': 'Financial', 'subtitle': 'Financial data'},
    {'title': 'Peers', 'subtitle': 'Peer comparison'},
    {'title': 'Holdings', 'subtitle': 'Shareholdings'},
    {'title': 'Events', 'subtitle': 'Stock events'},
    {'title': 'Overview', 'subtitle': 'Stock overview'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final marketWatch = ref.watch(marketWatchProvider);

      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          elevation: 1,
          leadingWidth: 48,
          titleSpacing: 0,
          leading: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              customBorder: const CircleBorder(),
              splashColor: Colors.grey.withOpacity(0.4),
              highlightColor: Colors.grey.withOpacity(0.2),
              onTap: () {
                Navigator.pop(context);
              },
              child:
                 Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 18,
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack,
                ),
              ),
            ),
          ),
          shadowColor: theme.isDarkMode
              ? colors.darkColorDivider
              : colors.colorDivider,
          title: TextWidget.titleText(
              text: "${widget.wlValue.symbol.toUpperCase()}  Fundamental",
              color: Color(theme.isDarkMode ? 0xffffffff : 0xff000000),
              theme: theme.isDarkMode,
              fw: 1),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: theme.isDarkMode ? Colors.black : Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 42,
                    child: _buildFundamentalTabs(theme),
                  ),
                  Container(
                    height: 1,
                    color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildRatiosTab(marketWatch, theme),
                  _buildFinancialTab(marketWatch, theme),
                  _buildPeersTab(marketWatch, theme),
                  _buildHoldingsTab(marketWatch, theme),
                  _buildEventsTab(marketWatch, theme),
                  _buildOverviewTab(marketWatch, theme),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFundamentalTabs(ThemesProvider theme) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      physics: const BouncingScrollPhysics(),
      labelColor: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
      unselectedLabelColor: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
      indicatorColor: colors.colorBlue,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextWidget.textStyle(
        fontSize: 12,
        theme: theme.isDarkMode,
        fw: 1,
      ),
      unselectedLabelStyle: TextWidget.textStyle(
        fontSize: 12,
        theme: theme.isDarkMode,
        fw: 0,
      ),
      tabs: _tabs.map((tab) => Tab(
        child: Container(
          width: tabWidth - 18,
          alignment: Alignment.center,
          child: Text(
            tab['title']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildRatiosTab(MarketWatchProvider marketWatch, ThemesProvider theme) {
    if (marketWatch.fundamentalData?.fundamental?.isEmpty ?? true) {
      return const Center(child: NoDataFound());
    }
    
    final funData = marketWatch.fundamentalData!.fundamental![0];
    final symbolName = marketWatch.getQuotes?.tsym?.replaceAll("-EQ", "") ?? "";
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.heroText(
            text: "Fundamental Ratios",
            theme: theme.isDarkMode,
            fw: 1,
          ),
          const SizedBox(height: 5),
          TextWidget.paraText(
            text: "Fundamental breakdown of $symbolName information",
            theme: theme.isDarkMode,
            fw: 0,
          ),
          const SizedBox(height: 16),
          _buildRatiosSection(funData, theme),
        ],
      ),
    );
  }

  Widget _buildFinancialTab(MarketWatchProvider marketWatch, ThemesProvider theme) {
    if (marketWatch.fundamentalData?.msg == "no data found") {
      return const Center(child: NoDataFound());
    }
    
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: FinancialWidget(),
    );
  }

  Widget _buildPeersTab(MarketWatchProvider marketWatch, ThemesProvider theme) {
    if (marketWatch.fundamentalData?.msg == "no data found") {
      return const Center(child: NoDataFound());
    }
    
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: PriceComparision(),
    );
  }

  Widget _buildHoldingsTab(MarketWatchProvider marketWatch, ThemesProvider theme) {
    if (marketWatch.fundamentalData?.msg == "no data found" || 
        marketWatch.fundamentalData?.shareholdings == null) {
      return const Center(child: NoDataFound());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildHoldingsContent(marketWatch, theme),
    );
  }

  Widget _buildHoldingsContent(MarketWatchProvider marketWatch, ThemesProvider theme) {
    final stockHold = marketWatch.fundamentalData?.shareholdings ?? [];
    final shareHoldings = marketWatch;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.heroText(
          text: "Holdings",
          theme: theme.isDarkMode,
          fw: 1,
        ),
        const SizedBox(height: 16),
        
                 // Date selection
         Container(
           height: 36,
           child: stockHold.isEmpty
               ? Center(
                   child: TextWidget.subText(
                     text: "No Holdings",
                     theme: theme.isDarkMode,
                     fw: 0,
                   ),
                 )
               : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: shareHoldings.mfHoldingDate.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? shareHoldings.selectedMfHolddate == shareHoldings.mfHoldingDate[index]
                                ? const Color(0xffB0BEC5)
                                : const Color(0xffB5C0CF).withOpacity(.15)
                            : shareHoldings.selectedMfHolddate == shareHoldings.mfHoldingDate[index]
                                ? const Color(0xff000000)
                                : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(98),
                      ),
                      child: InkWell(
                        onTap: () async {
                          shareHoldings.chngMfHoldDate(shareHoldings.mfHoldingDate[index], index);
                        },
                        child: TextWidget.paraText(
                          text: shareHoldings.mfHoldingDate[index],
                          color: theme.isDarkMode
                              ? shareHoldings.selectedMfHolddate == shareHoldings.mfHoldingDate[index]
                                  ? const Color(0xff000000)
                                  : const Color(0xffffffff)
                              : shareHoldings.selectedMfHolddate == shareHoldings.mfHoldingDate[index]
                                  ? const Color(0xffffffff)
                                  : const Color(0xff000000),
                          theme: theme.isDarkMode,
                          fw: 0,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 10);
                  },
                ),
        ),
        const SizedBox(height: 16),
        
        // Holdings table header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xff999999), width: .5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: "Investors",
                color: const Color(0xff666666),
                theme: theme.isDarkMode,
                fw: 0,
              ),
              TextWidget.subText(
                text: "Holding %",
                color: const Color(0xff666666),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ],
          ),
        ),
        
                 // Holdings data
         if (stockHold.isNotEmpty && shareHoldings.selectedMfHoldindex < stockHold.length) ...[
           _buildHoldingItem("Promoter Holding", "${stockHold[shareHoldings.selectedMfHoldindex].promoters ?? 'N/A'}", const Color(0xff2e8564), theme),
           Divider(thickness: 0, color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 0),
           _buildHoldingItem("Foreign Institution", "${stockHold[shareHoldings.selectedMfHoldindex].fiiFpi ?? 'N/A'}", const Color(0xff7cd36f), theme),
           Divider(thickness: 0, color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 0),
           _buildHoldingItem("Other Domestic Institution", "${stockHold[shareHoldings.selectedMfHoldindex].dii ?? 'N/A'}", const Color(0xfff7cd6c), theme),
           Divider(thickness: 0, color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 0),
           _buildHoldingItem("Retail and Others", "${stockHold[shareHoldings.selectedMfHoldindex].retailAndOthers ?? 'N/A'}", const Color(0XFFfbebc4), theme),
           Divider(thickness: 0, color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider, height: 0),
         ],
        
        const SizedBox(height: 16),
        
        // Chart section
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 36,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    style: TextWidget.textStyle(fontSize: 12, theme: theme.isDarkMode, fw: 0),
                    hint: TextWidget.paraText(
                      text: shareHoldings.selctedShareHold,
                      color: theme.isDarkMode ? colors.colorBlack : colors.colorBlack,
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                    items: shareHoldings.addDividersAfterExpDates(shareHoldings.shareHoldType),
                    value: shareHoldings.selctedShareHold,
                    onChanged: (value) async {
                      shareHoldings.chngshareHold("$value");
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const ShareHoldChart(),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        Divider(color: colors.colorDivider),
        const SizedBox(height: 4),
        
        // Mutual Fund Holdings
        const MutualFundholdings(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildHoldingItem(String name, String value, Color color, ThemesProvider theme) {
    return ListTile(
      minLeadingWidth: 10,
      leading: Container(
        height: 17,
        width: 18,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      dense: true,
      title: TextWidget.subText(
        text: name,
        theme: theme.isDarkMode,
        fw: 0,
      ),
      trailing: TextWidget.subText(
        text: value,
        theme: theme.isDarkMode,
        fw: 1,
      ),
    );
  }

  Widget _buildEventsTab(MarketWatchProvider marketWatch, ThemesProvider theme) {
    if (marketWatch.fundamentalData?.msg == "no data found") {
      return const Center(child: NoDataFound());
    }
    
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: StockEvents(),
    );
  }

  Widget _buildOverviewTab(MarketWatchProvider marketWatch, ThemesProvider theme) {
    if (marketWatch.fundamentalData?.stockDescription?.isEmpty ?? true) {
      return const Center(child: NoDataFound());
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget.heroText(
            text: "Stock Overview",
            theme: theme.isDarkMode,
            fw: 1,
          ),
          const SizedBox(height: 16),
          TextWidget.paraText(
            text: marketWatch.fundamentalData?.stockDescription ?? "",
            theme: theme.isDarkMode,
            fw: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildRatiosSection(dynamic funData, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowOfInfoData(
          "PE RATIO",
          "${funData.pe}",
          "SECTOR PE",
          "${funData.sectorPe}",
          "EVEBITDA",
          "${funData.evEbitda}",
          theme,
        ),
        const SizedBox(height: 14),
        _rowOfInfoData(
          "PB RATIO",
          "${funData.priceBookValue}",
          "EPS",
          "${funData.eps}",
          "DIVIDEND YIELD",
          "${funData.dividendYieldPercent}",
          theme,
        ),
        const SizedBox(height: 14),
        _rowOfInfoData(
          "ROCE",
          "${funData.rocePercent}",
          "ROE",
          "${funData.roePercent}",
          "DEBT TO EQUITY",
          "${funData.debtToEquity}",
          theme,
        ),
        const SizedBox(height: 14),
        _rowOfInfoData(
          "PRICE TO SALE",
          "${funData.salesToWorkingCapital}",
          "BOOK VALUE",
          "${funData.bookValue}",
          "FACE VALUE",
          "${funData.fv}",
          theme,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Row _rowOfInfoData(String title1, String value1, String title2, String value2,
      String title3, String value3, ThemesProvider theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.captionText(
                text: title1,
                color: const Color(0xff666666),
                theme: theme.isDarkMode,
                fw: 0,
              ),
              const SizedBox(height: 4),
              TextWidget.subText(
                text: value1,
                theme: theme.isDarkMode,
                fw: 1,
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.captionText(
                text: title2,
                color: const Color(0xff666666),
                theme: theme.isDarkMode,
                fw: 0,
              ),
              const SizedBox(height: 4),
              TextWidget.subText(
                text: value2,
                theme: theme.isDarkMode,
                fw: 1,
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.captionText(
                text: title3,
                color: const Color(0xff666666),
                theme: theme.isDarkMode,
                fw: 0,
              ),
              const SizedBox(height: 4),
              TextWidget.subText(
                text: value3,
                theme: theme.isDarkMode,
                fw: 1,
              ),
              const SizedBox(height: 2),
              Divider(
                color: theme.isDarkMode
                    ? colors.darkColorDivider
                    : colors.colorDivider,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 