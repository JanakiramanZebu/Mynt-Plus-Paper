import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import 'stock_row_data.dart';

class PriceComparision extends ConsumerWidget {
  const PriceComparision({super.key});

  // Helper function to remove exchange prefix from symbol and clean up suffixes
  String _cleanSymbol(String? symbol) {
    if (symbol == null) return 'N/A';
    String cleaned = symbol.contains(':') ? symbol.split(':')[1] : symbol;
    // Remove -EQ suffix if present
    return cleaned.replaceAll('-EQ', '');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peersData = ref.watch(marketWatchProvider);
    final theme = ref.watch(themeProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //      TextWidget.heroText(
            //     text: "Peers Comparison", theme: theme.isDarkMode, fw: 1),
            // const SizedBox(height: 5),
            // TextWidget.paraText(
            //     text: "Peers Comparison breakdown of Refineries information",
            //     theme: theme.isDarkMode,
            //     fw: 0),

            // Top Performers Card - moved above dropdown
            // _buildTopPerformersCard(peersData, theme),
            // const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.only(bottom: 6, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                      text: "Peers comparison",
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      theme: theme.isDarkMode,
                      fw: 1),
                   Material(
                     color: Colors.transparent,
                     child: InkWell(
                       onTap: () async {
                         await Future.delayed(const Duration(milliseconds: 150));
                         await peersData.cyclePeersType();
                       },
                       splashColor: theme.isDarkMode
                           ? colors.splashColorDark
                           : colors.splashColorLight,
                       highlightColor: theme.isDarkMode
                           ? colors.highlightDark
                           : colors.highlightLight,
                       borderRadius: BorderRadius.circular(8),
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Row(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             TextWidget.subText(
                               text: peersData.selctedPeers,
                               theme: theme.isDarkMode,
                               color: theme.isDarkMode
                                   ? colors.textSecondaryDark
                                   : colors.textSecondaryLight,
                               fw: 0,
                             ),
                             const SizedBox(width: 4),
                             Icon(
                               Icons.code,
                               size: 16,
                               color: theme.isDarkMode
                                   ? colors.textSecondaryDark
                                   : colors.textSecondaryLight,
                             ),
                           ],
                         ),
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),

     

      peersdata(
          peersData.fundamentalData!.peersComparison!.stock!, peersData, theme),
      // Divider(
      //     color:
      //         theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
      peersdata(
          peersData.fundamentalData!.peersComparison!.peers!, peersData, theme),
      const SizedBox(height: 12),
      // Divider(
      //     color:
      //         theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider),
      // const SizedBox(height: 8),
      // Text("Price Comparison",
      //     style: textStyle(
      //         theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
      //         20,
      //         FontWeight.w600)),
      // const SizedBox(height: 5),
      // Text(
      //     "Compare ${peersData.getQuotes!.tsym!.replaceAll("-EQ", "")} with other stocks",
      //     style: textStyle(const Color(0xff000000), 12, FontWeight.w500)),
      // const SizedBox(height: 14),
      // const PriceComChart(),
      // const SizedBox(height: 4),
      // Divider(color: theme.isDarkMode
      //             ?colors.darkColorDivider
      //             :colors.colorDivider),
      // const SizedBox(height: 4),
    ]);
  }

  ListView peersdata(
      List<Stock> list, MarketWatchProvider peersData, ThemesProvider themes) {
    // Sort stocks based on user preferences
    List<Stock> sortedList = List.from(list);
    _sortStocksByUserPreference(sortedList, peersData.selctedPeers);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: sortedList.length,
      
      itemBuilder: (BuildContext context, int index) {
        return StockRowTable(
            showIcon: false,
            title: sortedList[index].sYMBOL ?? 'N/A',
            metricType: peersData.selctedPeers,
            value: peersData.selctedPeers == "LTP"
                ? "${sortedList[index].ltp}"
                : peersData.selctedPeers == "Mkt Cap"
                    ? "${sortedList[index].marketCap}"
                    : peersData.selctedPeers == "PE Ratio"
                        ? "${sortedList[index].pe}"
                        : peersData.selctedPeers == "PB Ratio"
                            ? "${sortedList[index].priceBookValue}"
                            : peersData.selctedPeers == "ROCE"
                                ? "${sortedList[index].rocePercent}"
                                : peersData.selctedPeers == "Evebitda"
                                    ? "${sortedList[index].evEbitda}"
                                    : peersData.selctedPeers == "Debt to EQ"
                                        ? "${sortedList[index].debtToEquity}"
                                        : "${sortedList[index].dividendYieldPercent}");
      },
    );
  }

  // Top Performers Card
  Widget _buildTopPerformersCard(
      MarketWatchProvider peersData, ThemesProvider theme) {
    if (peersData.fundamentalData?.peersComparison?.peers == null) {
      return const SizedBox.shrink();
    }

    final peers = peersData.fundamentalData!.peersComparison!.peers!;
    final topPerformers = _calculateTopPerformers(peers);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // color: theme.isDarkMode
        //     ? colors.primaryDark.withOpacity(0.05)
        //     : colors.primaryLight.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.isDarkMode
              ? colors.primaryDark.withOpacity(0.7)
              : colors.primaryDark.withOpacity(0.7),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top performers grid
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Row(
                  children: [
                    // Lowest P/E
                    Expanded(
                      child: _buildPerformerCard(
                        "Lowest P/E",
                        topPerformers['lowestPE']?['symbol'] ?? 'N/A',
                        topPerformers['lowestPE']?['value'] ?? 'N/A',
                        Colors.green,
                        theme,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        width: 0.5,
                        height: 80,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.2)
                            : colors.textSecondaryLight.withOpacity(0.3),
                      ),
                    ),

                    // Highest ROCE
                    Expanded(
                      child: _buildPerformerCard(
                        "Highest ROCE",
                        topPerformers['highestROCE']?['symbol'] ?? 'N/A',
                        topPerformers['highestROCE']?['value'] ?? 'N/A',
                        Colors.blue,
                        theme,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Best Dividend Yield
                    Expanded(
                      child: _buildPerformerCard(
                        "Best Div Yield",
                        topPerformers['bestDividend']?['symbol'] ?? 'N/A',
                        topPerformers['bestDividend']?['value'] ?? 'N/A',
                        Colors.orange,
                        theme,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        width: 0.5,
                        height: 80,
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark.withOpacity(0.2)
                            : colors.textSecondaryLight.withOpacity(0.3),
                      ),
                    ),
                    // Largest Market Cap
                    Expanded(
                      child: _buildPerformerCard(
                        "Largest Mkt Cap",
                        topPerformers['largestMarketCap']?['symbol'] ?? 'N/A',
                        topPerformers['largestMarketCap']?['value'] ?? 'N/A',
                        Colors.purple,
                        theme,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ]),
    );
  }

  Widget _buildPerformerCard(String title, String symbol, String value,
      Color color, ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.subText(
          text: title,
          theme: theme.isDarkMode,
          fw: 1,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          align: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextWidget.heroText(
          text: value,
          theme: theme.isDarkMode,
          fw: 1,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          align: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextWidget.paraText(
          text: _cleanSymbol(symbol),
          theme: theme.isDarkMode,
          fw: 0,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          align: TextAlign.center,
        ),
      ],
    );
  }

  Map<String, Map<String, String>> _calculateTopPerformers(List<Stock> peers) {
    Map<String, Map<String, String>> result = {
      'lowestPE': {'symbol': 'N/A', 'value': 'N/A'},
      'highestROCE': {'symbol': 'N/A', 'value': 'N/A'},
      'bestDividend': {'symbol': 'N/A', 'value': 'N/A'},
      'largestMarketCap': {'symbol': 'N/A', 'value': 'N/A'},
    };

    if (peers.isEmpty) return result;

    // Find lowest P/E
    Stock? lowestPE;
    double minPE = double.infinity;
    for (var peer in peers) {
      double pe = double.tryParse(peer.pe?.replaceAll(',', '') ?? '0') ?? 0;
      if (pe > 0 && pe < minPE) {
        minPE = pe;
        lowestPE = peer;
      }
    }
    if (lowestPE != null) {
      result['lowestPE'] = {
        'symbol': _cleanSymbol(lowestPE.sYMBOL),
        'value': '${lowestPE.pe}',
      };
    }

    // Find highest ROCE
    Stock? highestROCE;
    double maxROCE = 0;
    for (var peer in peers) {
      double roce =
          double.tryParse(peer.rocePercent?.replaceAll(',', '') ?? '0') ?? 0;
      if (roce > maxROCE) {
        maxROCE = roce;
        highestROCE = peer;
      }
    }
    if (highestROCE != null) {
      result['highestROCE'] = {
        'symbol': _cleanSymbol(highestROCE.sYMBOL),
        'value': '${highestROCE.rocePercent}%',
      };
    }

    // Find best dividend yield
    Stock? bestDividend;
    double maxDividend = 0;
    for (var peer in peers) {
      double dividend = double.tryParse(
              peer.dividendYieldPercent?.replaceAll(',', '') ?? '0') ??
          0;
      if (dividend > maxDividend) {
        maxDividend = dividend;
        bestDividend = peer;
      }
    }
    if (bestDividend != null) {
      result['bestDividend'] = {
        'symbol': _cleanSymbol(bestDividend.sYMBOL),
        'value': '${bestDividend.dividendYieldPercent}%',
      };
    }

    // Find largest market cap
    Stock? largestMarketCap;
    double maxMarketCap = 0;
    for (var peer in peers) {
      double marketCap =
          double.tryParse(peer.marketCap?.replaceAll(',', '') ?? '0') ?? 0;
      if (marketCap > maxMarketCap) {
        maxMarketCap = marketCap;
        largestMarketCap = peer;
      }
    }
    if (largestMarketCap != null) {
      result['largestMarketCap'] = {
        'symbol': _cleanSymbol(largestMarketCap.sYMBOL),
        'value': _formatMarketCap(largestMarketCap.marketCap ?? '0'),
      };
    }

    return result;
  }

  String _formatMarketCap(String marketCap) {
    double value = double.tryParse(marketCap.replaceAll(',', '')) ?? 0;
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  // Sort stocks based on user preferences
  void _sortStocksByUserPreference(List<Stock> stocks, String selectedMetric) {
    stocks.sort((a, b) {
      double valueA = _getNumericValue(a, selectedMetric);
      double valueB = _getNumericValue(b, selectedMetric);

      // Define which metrics should be sorted ascending (lower is better)
      List<String> ascendingMetrics = ['PE Ratio', 'PB Ratio', 'Debt to EQ'];

      if (ascendingMetrics.contains(selectedMetric)) {
        // For PE, PB, Debt to EQ: Lower is better (ascending order)
        return valueA.compareTo(valueB);
      } else {
        // For LTP, Mkt Cap, ROCE, Evebitda, Div yield: Higher is better (descending order)
        return valueB.compareTo(valueA);
      }
    });
  }

  // Helper method to get numeric value for sorting
  double _getNumericValue(Stock stock, String metric) {
    String value = _getStockValue(stock, metric);
    return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
  }

  // Helper method to get stock value based on selected metric
  String _getStockValue(Stock stock, String selectedMetric) {
    switch (selectedMetric) {
      case "LTP":
        return "${stock.ltp}";
      case "Mkt Cap":
        return "${stock.marketCap}";
      case "PE Ratio":
        return "${stock.pe}";
      case "PB Ratio":
        return "${stock.priceBookValue}";
      case "ROCE":
        return "${stock.rocePercent}";
      case "Evebitda":
        return "${stock.evEbitda}";
      case "Debt to EQ":
        return "${stock.debtToEquity}";
      case "Div yield":
        return "${stock.dividendYieldPercent}";
      default:
        return "${stock.ltp}";
    }
  }
}
