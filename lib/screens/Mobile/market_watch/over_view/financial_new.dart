import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'chart.dart';

class FinancialWidget extends ConsumerWidget {
  const FinancialWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provideData = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
// unique income chart

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.textSecondaryLight.withOpacity(0.1)),
                  color: colors.colorWhite,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.titleText(
                          text: "Income",
                          theme: theme.isDarkMode,
                          fw: 1,
                        ),
                        // Only show toggle buttons if there's data
                        provideData.fundamentalData!.stockFinancialsConsolidated!
                                    .incomeSheet!.isEmpty ||
                                provideData.fundamentalData!.stockFinancialsStandalone!
                                    .incomeSheet!.isEmpty
                            ? const SizedBox.shrink()
                            : Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: provideData.finType.map((filter) {
                                    final isSelected = provideData.selcteIncomeFinType == filter;
                                    return GestureDetector(
                                      onTap: () {
                                        provideData.chngIncomeFinType(filter);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colors.primaryLight
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: TextWidget.paraText(
                                          text: filter,
                                          theme: theme.isDarkMode,
                                          color: isSelected 
                                              ? colors.colorWhite 
                                              : theme.isDarkMode 
                                                  ? colors.textSecondaryDark 
                                                  : colors.textPrimaryLight,
                                          fw: isSelected ? 2 : 0,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ],
                    ),
                // const SizedBox(height: 16),
                    provideData.fundamentalData!.stockFinancialsConsolidated!
                                .incomeSheet!.isEmpty ||
                        provideData.fundamentalData!.stockFinancialsStandalone!
                            .incomeSheet!.isEmpty
                        ?  SizedBox(height: 250, child:  Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SvgPicture.asset(assets.noDatafound,
        // color:   Color(0xff777777)
        // ),
        // const SizedBox(height: 2),
        SizedBox(
          width: 250,
          child: TextWidget.subText(
              text: "Data not available",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
                  fw:0,
                  align: TextAlign.center,
              theme: theme.isDarkMode),
        )
      ]
    )))   
                        : const FIncomeChart(),
                const SizedBox(height: 16),
                  
                    // Only show data table if there's data
                    provideData.fundamentalData!.stockFinancialsConsolidated!
                                .incomeSheet!.isEmpty ||
                        provideData.fundamentalData!.stockFinancialsStandalone!
                            .incomeSheet!.isEmpty
                        ? const SizedBox.shrink()
                        : IncomeSheetData(
                            themes: theme,
                        incomSheet:
                            provideData.selcteIncomeFinType == "Consolidated"
                                ? provideData.fundamentalData!
                                    .stockFinancialsConsolidated!.incomeSheet!
                                : provideData.fundamentalData!
                                    .stockFinancialsStandalone!.incomeSheet!,
                            financialYear: provideData.selcteFinYear)
                  ],
                ),
              ),
          const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.textSecondaryLight.withOpacity(0.1)),
                  color: colors.colorWhite,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.titleText(
                          text: "Balance sheet",
                          theme: theme.isDarkMode,
                          fw: 1,
                        ),
                        // Only show toggle buttons if there's data
                        provideData.fundamentalData!.stockFinancialsConsolidated!
                                    .balanceSheet!.isEmpty ||
                                provideData.fundamentalData!.stockFinancialsStandalone!
                                    .balanceSheet!.isEmpty
                            ? const SizedBox.shrink()
                            : Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: provideData.finType.map((filter) {
                                    final isSelected = provideData.selcteBalanceSheetFinType == filter;
                                    return GestureDetector(
                                      onTap: () {
                                        provideData.chngBalanceSheetFinType(filter);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colors.primaryLight
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: TextWidget.paraText(
                                          text: filter,
                                          theme: theme.isDarkMode,
                                          color: isSelected 
                                              ? colors.colorWhite 
                                              : theme.isDarkMode 
                                                  ? colors.textSecondaryDark 
                                                  : colors.textPrimaryLight,
                                          fw: isSelected ? 2 : 0,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ],
                    ),
                // const SizedBox(height: 16),
                    provideData.fundamentalData!.stockFinancialsConsolidated!
                                .balanceSheet!.isEmpty ||
                        provideData.fundamentalData!.stockFinancialsStandalone!
                            .balanceSheet!.isEmpty
                        ?  SizedBox(height: 250, child:  Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SvgPicture.asset(assets.noDatafound,
        // color:   Color(0xff777777)
        // ),
        // const SizedBox(height: 2),
        SizedBox(
          width: 250,
          child: TextWidget.subText(
              text: "Data not available",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
                  fw:0,
                  align: TextAlign.center,
              theme: theme.isDarkMode),
        )
      ]
    )))
                        : const FBalSheetCahrt(),
                const SizedBox(height: 16),
                  
                    // Only show data table if there's data
                    provideData.fundamentalData!.stockFinancialsConsolidated!
                                .balanceSheet!.isEmpty ||
                        provideData.fundamentalData!.stockFinancialsStandalone!
                            .balanceSheet!.isEmpty
                        ? const SizedBox.shrink()
                        : BalanceSheetData(
                            balanceSheet:
                            provideData.selcteBalanceSheetFinType == "Consolidated"
                                    ? provideData.fundamentalData!
                                        .stockFinancialsConsolidated!.balanceSheet!
                                    : provideData.fundamentalData!
                                        .stockFinancialsStandalone!.balanceSheet!,
                            financialYear: provideData.selcteFinYear,
                            themes: theme)
                  ],
                ),
              ),
          const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.textSecondaryLight.withOpacity(0.1)),
                  color: colors.colorWhite,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.titleText(
                          text: "Cash flow",
                          theme: theme.isDarkMode,
                          fw: 1,
                        
                        ),
                        // Only show toggle buttons if there's data
                        provideData.fundamentalData!.stockFinancialsConsolidated!
                                    .cashflowSheet!.isEmpty ||
                                provideData.fundamentalData!.stockFinancialsStandalone!
                                    .cashflowSheet!.isEmpty
                            ? const SizedBox.shrink()
                            : Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.isDarkMode ? colors.darkGrey : const Color(0xffF1F3F8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: provideData.finType.map((filter) {
                                    final isSelected = provideData.selcteCashFlowFinType == filter;
                                    return GestureDetector(
                                      onTap: () {
                                        provideData.chngCashFlowFinType(filter);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? colors.primaryLight
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: TextWidget.paraText(
                                          text: filter,
                                          theme: theme.isDarkMode,
                                          color: isSelected 
                                              ? colors.colorWhite 
                                              : theme.isDarkMode 
                                                  ? colors.textSecondaryDark 
                                                  : colors.textPrimaryLight,
                                          fw: isSelected ? 2 : 0,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                      ],
                    ),
             
                // const SizedBox(height: 16),
                    provideData.fundamentalData!.stockFinancialsConsolidated!
                                .cashflowSheet!.isEmpty ||
                        provideData.fundamentalData!.stockFinancialsStandalone!
                            .cashflowSheet!.isEmpty
                        ?  SizedBox(height: 250, child:  Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // SvgPicture.asset(assets.noDatafound,
        // color:   Color(0xff777777)
        // ),
        // const SizedBox(height: 2),
        SizedBox(
          width: 250,
          child: TextWidget.subText(
              text: "Data not available",
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
                  fw:0,
                  align: TextAlign.center,
              theme: theme.isDarkMode),
        )
      ]
    )))
                        : FCashFlowChart(),
                    const SizedBox(height: 16),
                  
                    // Only show data table if there's data
                    provideData.fundamentalData!.stockFinancialsConsolidated!
                                .cashflowSheet!.isEmpty ||
                        provideData.fundamentalData!.stockFinancialsStandalone!
                            .cashflowSheet!.isEmpty
                        ? const SizedBox.shrink()
                        : CashFlowSheetData(
                            cashFlowSheet:
                            provideData.selcteCashFlowFinType == "Consolidated"
                                    ? provideData.fundamentalData!
                                        .stockFinancialsConsolidated!.cashflowSheet!
                                    : provideData.fundamentalData!
                                        .stockFinancialsStandalone!.cashflowSheet!,
                            financialYear: provideData.selcteFinYear,
                            themes: theme)
                  ],
                ),
              )
            ],
      ),
    ]);
  }
}

class BalanceSheetData extends StatelessWidget {
  final List<BalanceSheet> balanceSheet;
  final String financialYear;
  final ThemesProvider themes;
  const BalanceSheetData(
      {super.key, required this.balanceSheet, required this.financialYear, required this.themes});

  @override
  Widget build(BuildContext context) {
    // Filter and sort data by date
    final filteredData =
        balanceSheet.where((item) => item.convDate != null).toList();
    filteredData.sort((a, b) => a.convDate!.compareTo(b.convDate!));

    if (filteredData.isEmpty) {
      return const Center(child: NoDataFound());
    }

    // Get the last 5 years of data
    final recentData = filteredData.length > 5
        ? filteredData.sublist(filteredData.length - 5)
        : filteredData;

    return BalanceSheetTable(
      data: recentData,
      themes: themes,
    );
  }
}

class BalanceSheetTable extends StatelessWidget {
  final List<BalanceSheet> data;
  final ThemesProvider themes;

  const BalanceSheetTable({
    super.key,
    required this.data,
    required this.themes,
  });

  String _formatValue(String? value) {
    if (value == null || value.isEmpty) return "0";
    try {
      double numValue = double.parse(value);
      if (numValue >= 10000000) {
        // 1 crore
        return "${(numValue / 10000000).toStringAsFixed(2)}Cr";
      } else if (numValue >= 100000) {
        // 1 lakh
        return "${(numValue / 100000).toStringAsFixed(2)}L";
      } else {
        return numValue.round().toString();
      }
    } catch (e) {
      return value;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      // Assuming date is in format "2021-03-31" or similar
      final parts = date.split('-');
      if (parts.length >= 2) {
        final year = parts[0];
        // Extract last 2 digits of year for "Mar 21" format
        final shortYear = year.length > 2 ? year.substring(2) : year;
        return "Mar $shortYear";
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort data by date (oldest first - Mar 21, Mar 22, Mar 23)
    final sortedData = List<BalanceSheet>.from(data);
    sortedData.sort((a, b) {
      // Try to parse yearEndDate first, fallback to convDate if needed
      try {
        final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
        final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
        return dateA.compareTo(dateB); // Oldest first
      } catch (e) {
        // If parsing fails, use string comparison as fallback
        return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
      }
    });
    
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data rows with colored circles
          ..._buildMetricRows(sortedData),
          // Legend below table
          _buildLegend(),
        ],
      ),
    );
  }

  List<Widget> _buildMetricRows(List<BalanceSheet> sortedData) {
    final metrics = [
      {"name": "", "getValue": (item) => item.totalCurrentAssets, "color": const Color(0xFF00BCD4)}, // Bright Cyan
      {"name": "", "getValue": (item) => item.totalNonCurrentAssets, "color": const Color(0xFF3F51B5)}, // Indigo
      {"name": "", "getValue": (item) => item.totalCurrentLiabilities, "color": const Color(0xFFE91E63)}, // Bright Pink
    ];

    return metrics.map((metric) => Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Row(
        children: [
          Expanded(
            flex: 0,
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: metric["color"] as Color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          ...sortedData.map((item) => Expanded(
            child: TextWidget.custmText(
              text: _formatValue((metric["getValue"] as Function)(item)),
              fs: 12,
              theme: themes.isDarkMode,
              color: themes.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 0,
              align: TextAlign.right,
            ),
          )).toList(),
        ],
      ),
    )).toList();
  }

  Widget _buildLegend() {
    final legendItems = [
      {"name": "Current Assets", "color": const Color(0xFF00BCD4)}, // Bright Cyan
      {"name": "Non Current Assets", "color": const Color(0xFF3F51B5)}, // Indigo
      {"name": "Current Liabilities", "color": const Color(0xFFE91E63)}, // Bright Pink
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: legendItems.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item["color"] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            TextWidget.custmText(
              text: item["name"] as String,
              fs: 10,
              theme: themes.isDarkMode,
              color: themes.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        )).toList(),
      ),
    );
  }
}

class IncomeSheetData extends StatelessWidget {
  final List<IncomeSheet> incomSheet;
  final String financialYear;
  final ThemesProvider themes;
  const IncomeSheetData(
      {super.key,
      required this.incomSheet,
      required this.financialYear,
      required this.themes});

  @override
  Widget build(BuildContext context) {
    // Filter and sort data by date
    final filteredData =
        incomSheet.where((item) => item.convDate != null).toList();
    filteredData.sort((a, b) => a.convDate!.compareTo(b.convDate!));

    if (filteredData.isEmpty) {
      return const Center(child: NoDataFound());
    }

    // Get the last 5 years of data
    final recentData = filteredData.length > 5
        ? filteredData.sublist(filteredData.length - 5)
        : filteredData;

    return IncomeStatementTable(
      data: recentData,
      themes: themes,
    );
  }
}

class IncomeStatementTable extends StatelessWidget {
  final List<IncomeSheet> data;
  final ThemesProvider themes;

  const IncomeStatementTable({
    super.key,
    required this.data,
    required this.themes,
  });

  String _formatValue(String? value) {
    if (value == null || value.isEmpty) return "0";
    try {
      double numValue = double.parse(value);
      if (numValue >= 10000000) {
        // 1 crore
        return "${(numValue / 10000000).toStringAsFixed(2)}Cr";
      } else if (numValue >= 100000) {
        // 1 lakh
        return "${(numValue / 100000).toStringAsFixed(2)}L";
      } else {
        return numValue.round().toString();
      }
    } catch (e) {
      return value;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      // Assuming date is in format "2021-03-31" or similar
      final parts = date.split('-');
      if (parts.length >= 2) {
        final year = parts[0];
        // Extract last 2 digits of year for "Mar 21" format
        final shortYear = year.length > 2 ? year.substring(2) : year;
        return "Mar $shortYear";
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort data by date (oldest first - Mar 21, Mar 22, Mar 23)
    final sortedData = List<IncomeSheet>.from(data);
    sortedData.sort((a, b) {
      // Try to parse yearEndDate first, fallback to convDate if needed
      try {
        final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
        final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
        return dateA.compareTo(dateB); // Oldest first
      } catch (e) {
        // If parsing fails, use string comparison as fallback
        return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
      }
    });
    
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with years
          // Container(
          //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          //   child: Row(
          //     children: [
               
          //       // ...sortedData.map((item) => Expanded(
          //       //   child: Center(
          //       //     child: TextWidget.subText(
          //       //       // text: _formatDate(item.convDate),
          //       //       text:'',
          //       //       theme: themes.isDarkMode,
          //       //       color: themes.isDarkMode
          //       //           ? colors.textSecondaryDark
          //       //           : colors.textSecondaryLight,
          //       //       fw: 1,
          //       //     ),
          //       //   ),
          //       // )).toList(),
          //     ],
          //   ),
          // ),
          // Data rows with colored circles
          ..._buildMetricRows(sortedData),
          // Legend below table
          _buildLegend(),
        ],
      ),
    );
  }

  List<Widget> _buildMetricRows(List<IncomeSheet> sortedData) {
    final metrics = [
      {"name": "", "getValue": (item) => item.revenue, "color": const Color(0xFF2196F3)}, // Bright Blue
      {"name": "", "getValue": (item) => item.expenditure, "color": const Color(0xFFF44336)}, // Bright Red
      {"name": "", "getValue": (item) => item.operatingProfit, "color": const Color(0xFF4CAF50)}, // Bright Green
      {"name": "", "getValue": (item) => item.profitBeforeTax, "color": const Color(0xFF9C27B0)}, // Purple
      {"name": "", "getValue": (item) => item.tax, "color": const Color(0xFFFF9800)}, // Orange
      {"name": "", "getValue": (item) => item.profitAfterTax, "color": const Color(0xFFFFC107)}, // Amber
    ];

    return metrics.map((metric) => Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Row(
        children: [
          Expanded(
            flex: 0,
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: metric["color"] as Color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          ...sortedData.map((item) => Expanded(
            child: TextWidget.custmText(
              text: _formatValue((metric["getValue"] as Function)(item)),
              fs: 12,
              theme: themes.isDarkMode,
              color: colors.textPrimaryLight,
              fw: 0,
              align: TextAlign.right,
            ),
          )).toList(),
        ],
      ),
    )).toList();
  }

  Widget _buildLegend() {
    final legendItems = [
      {"name": "Revenue", "color": const Color(0xFF2196F3)}, // Bright Blue
      {"name": "Expenditure", "color": const Color(0xFFF44336)}, // Bright Red
      {"name": "Operating Profit", "color": const Color(0xFF4CAF50)}, // Bright Green
      {"name": "Profit Before Tax", "color": const Color(0xFF9C27B0)}, // Purple
      {"name": "Tax", "color": const Color(0xFFFF9800)}, // Orange
      {"name": "Profit After Tax", "color": const Color(0xFFFFC107)}, // Amber
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: legendItems.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item["color"] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            TextWidget.custmText(
              text: item["name"] as String,
              fs: 10,
              theme: themes.isDarkMode,
              color: themes.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        )).toList(),
      ),
    );
  }
}

class CashFlowSheetData extends StatelessWidget {
  final List<CashflowSheet> cashFlowSheet;
  final String financialYear;
  final ThemesProvider themes;
  const CashFlowSheetData(
      {super.key, required this.cashFlowSheet, required this.financialYear, required this.themes});

  @override
  Widget build(BuildContext context) {
    // Filter and sort data by date
    final filteredData =
        cashFlowSheet.where((item) => item.convDate != null).toList();
    filteredData.sort((a, b) => a.convDate!.compareTo(b.convDate!));

    if (filteredData.isEmpty) {
      return const Center(child: NoDataFound());
    }

    // Get the last 5 years of data
    final recentData = filteredData.length > 5
        ? filteredData.sublist(filteredData.length - 5)
        : filteredData;

    return CashFlowTable(
      data: recentData,
      themes: themes,
    );
  }
}

class CashFlowTable extends StatelessWidget {
  final List<CashflowSheet> data;
  final ThemesProvider themes;

  const CashFlowTable({
    super.key,
    required this.data,
    required this.themes,
  });

  String _formatValue(String? value) {
    if (value == null || value.isEmpty) return "0";
    try {
      double numValue = double.parse(value);
      if (numValue >= 10000000) {
        // 1 crore
        return "${(numValue / 10000000).toStringAsFixed(2)}Cr";
      } else if (numValue >= 100000) {
        // 1 lakh
        return "${(numValue / 100000).toStringAsFixed(2)}L";
      } else {
        return numValue.round().toString();
      }
    } catch (e) {
      return value;
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      // Assuming date is in format "2021-03-31" or similar
      final parts = date.split('-');
      if (parts.length >= 2) {
        final year = parts[0];
        // Extract last 2 digits of year for "Mar 21" format
        final shortYear = year.length > 2 ? year.substring(2) : year;
        return "Mar $shortYear";
      }
      return date;
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sort data by date (oldest first - Mar 21, Mar 22, Mar 23)
    final sortedData = List<CashflowSheet>.from(data);
    sortedData.sort((a, b) {
      // Try to parse yearEndDate first, fallback to convDate if needed
      try {
        final dateA = DateTime.parse(a.yearEndDate ?? a.convDate!);
        final dateB = DateTime.parse(b.yearEndDate ?? b.convDate!);
        return dateA.compareTo(dateB); // Oldest first
      } catch (e) {
        // If parsing fails, use string comparison as fallback
        return (a.yearEndDate ?? a.convDate!).compareTo(b.yearEndDate ?? b.convDate!);
      }
    });
    
    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Data rows with colored circles
          ..._buildMetricRows(sortedData),
          // Legend below table
          _buildLegend(),
        ],
      ),
    );
  }

  List<Widget> _buildMetricRows(List<CashflowSheet> sortedData) {
    final metrics = [
      {"name": "", "getValue": (item) => item.cashFromOperatingActivities, "color": const Color(0xFF03A9F4)}, // Bright Light Blue
      {"name": "", "getValue": (item) => item.cashFlowFromInvestingActivities, "color": const Color(0xFFFF6B35)}, // Bright Orange
      {"name": "", "getValue": (item) => item.cashFromFinancingActivities, "color": const Color(0xFFE91E63)}, // Bright Pink
    ];

    return metrics.map((metric) => Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Row(
        children: [
          Expanded(
            flex: 0,
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: metric["color"] as Color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          ...sortedData.map((item) => Expanded(
            child: TextWidget.custmText(
              text: _formatValue((metric["getValue"] as Function)(item)),
              fs: 12,
              theme: themes.isDarkMode,
              color: themes.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              fw: 0,
              align: TextAlign.right,
            ),
          )).toList(),
        ],
      ),
    )).toList();
  }

  Widget _buildLegend() {
    final legendItems = [
      {"name": "Cash From Operating Activities", "color": const Color(0xFF03A9F4)}, // Bright Light Blue
      {"name": "Cash Flow From Investing Activities", "color": const Color(0xFFFF6B35)}, // Bright Orange
      {"name": "Cash From Financing Activities", "color": const Color(0xFFE91E63)}, // Bright Pink
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 20,
        runSpacing: 12,
        children: legendItems.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: item["color"] as Color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            TextWidget.custmText(
              text: item["name"] as String,
              fs: 10,
              theme: themes.isDarkMode,
              color: themes.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        )).toList(),
      ),
    );
  }
}
