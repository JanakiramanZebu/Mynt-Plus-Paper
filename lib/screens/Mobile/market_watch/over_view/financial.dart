import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/scrip_overview/stock_data.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/stocks_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'chart.dart';
import 'stock_row_data.dart';

class FinancialWidget extends ConsumerWidget {
  const FinancialWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finData = ref.watch(stocksProvide);
    final provideData = ref.watch(marketWatchProvider);
    final theme = ref.read(themeProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
     
           TextWidget.heroText(
                      text:"Financial" ,                     
                      theme: theme.isDarkMode,
                      fw: 1),

      const SizedBox(height: 5),
     

               TextWidget.paraText(
                      text:"Fundamental breakdown of ${ref.watch(marketWatchProvider).getQuotes!.tsym!.replaceAll("-EQ", "")} information" ,                  
                      theme: theme.isDarkMode,
                      fw: 0),
      const SizedBox(height: 16),
      SizedBox(
          height: 36,
          child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: finData.finacialType.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                        color: theme.isDarkMode
                            ? finData.selctedFinType ==
                                    finData.finacialType[index]
                                ? const Color(0xffB0BEC5)
                                : const Color(0xffB5C0CF).withOpacity(.15)
                            : finData.selctedFinType ==
                                    finData.finacialType[index]
                                ? const Color(0xff000000)
                                : const Color(0xffF1F3F8),
                        borderRadius: BorderRadius.circular(98)),
                    child: InkWell(
                        onTap: () async {
                          finData
                              .chngfinancilaType(finData.finacialType[index]);
                        },
                        child:
                                    
                                    
                                     TextWidget.subText(
                      text: finData.finacialType[index],
                      color:  theme.isDarkMode
                                    ? finData.selctedFinType ==
                                            finData.finacialType[index]
                                        ? colors.colorBlack
                                        : colors.colorWhite
                                    : finData.selctedFinType ==
                                            finData.finacialType[index]
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                      theme: theme.isDarkMode,
                      fw: finData.selctedFinType ==
                                        finData.finacialType[index]
                                    ? 0
                                    : 00),
                                    
                                    ));
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(width: 10);
              })),
      const SizedBox(height: 16),
      if (finData.selctedFinType == "Income") ...[
        provideData.fundamentalData!.stockFinancialsConsolidated!.incomeSheet!
                    .isEmpty ||
                provideData.fundamentalData!.stockFinancialsStandalone!
                    .incomeSheet!.isEmpty
            ? const Center(child: NoDataFound())
            : const FIncomeChart()
      ] else if (finData.selctedFinType == "Balance sheet") ...[
        const FBalSheetCahrt()
      ] else ...[
        const FCashFlowChart()
      ],
      const SizedBox(height: 2),
      Divider(color: colors.colorDivider),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [             
                       TextWidget.titleText(
                      text:"${finData.selctedFinType} statement" ,                     
                      theme: theme.isDarkMode,
                      fw: 1),
              const SizedBox(height: 3),            
                       TextWidget.paraText(
                      text: "All figures in Cr",
                      color: const Color(0xff666666),
                      theme: theme.isDarkMode,
                      fw: 0),
            ],
          ),
          DropdownButtonHideUnderline(
              child: DropdownButton2(
            dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: !theme.isDarkMode
                        ? colors.colorWhite
                        : const Color.fromARGB(255, 18, 18, 18))),
            menuItemStyleData: MenuItemStyleData(
                customHeights:
                    provideData.getCustomItemsHeight(provideData.finType)),
            buttonStyleData: ButtonStyleData(
                height: 40,
                width: 138,
                decoration: BoxDecoration(
                    color: theme.isDarkMode
                        ? const Color(0xffB5C0CF).withOpacity(.15)
                        : const Color(0xffF1F3F8),
                    // border: Border.all(color: Colors.grey),
                    borderRadius: const BorderRadius.all(Radius.circular(32)))),
            // buttonDecoration: const BoxDecoration(
            //     color: Color(0xffF1F3F8),
            //     // border: Border.all(color: Colors.grey),
            //     borderRadius: BorderRadius.all(Radius.circular(32))),
            // buttonSplashColor: Colors.transparent,
            isExpanded: true,
            style:

                 TextWidget.textStyle(
                 fontSize: 12 , theme: theme.isDarkMode , fw: 0 ),	
            hint: 
                     TextWidget.paraText(
                      text:provideData.selcteFinType ,
                      color:   theme.isDarkMode ? colors.colorBlack : colors.colorBlack,
                      theme: theme.isDarkMode,
                      fw: 0),
            items: provideData.addDividersAfterStock(provideData.finType),
            // customItemsHeights: provideData
            //     .getStochCustomItemsHeight(provideData.finType),
            value: provideData.selcteFinType,
            onChanged: (value) async {
              provideData.chngFinType("$value");
            },
            // buttonHeight: 40,
            // buttonWidth: 138
          ))
        ],
      ),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: const BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Color(0xff999999), width: .5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                 TextWidget.subText(
                      text: "Financial Years",
                      color: const Color(0xff666666),
                      theme: theme.isDarkMode,
                      fw: 0),
            DropdownButtonHideUnderline(
                child: DropdownButton2(
              dropdownStyleData: DropdownStyleData(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: !theme.isDarkMode
                          ? colors.colorWhite
                          : const Color.fromARGB(255, 18, 18, 18))),
              menuItemStyleData: MenuItemStyleData(
                  customHeights: provideData
                      .getCustomItemsHeight(provideData.finnceYears)),
              buttonStyleData: ButtonStyleData(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? const Color(0xffB5C0CF).withOpacity(.15)
                          : const Color(0xffF1F3F8),
                      // border: Border.all(color: Colors.grey),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(32)))),
              // buttonDecoration: const BoxDecoration(
              //     color: Color(0xffF1F3F8),
              //     // border: Border.all(color: Colors.grey),
              //     borderRadius: BorderRadius.all(Radius.circular(32))),
              // buttonSplashColor: Colors.transparent,
              isExpanded: true,
              style: 
                  TextWidget.textStyle(
                 fontSize: 12 , theme: theme.isDarkMode , fw: 0 ),	
              hint: 
                       TextWidget.paraText(
                      text: provideData.selcteFinYear,
                      color:  theme.isDarkMode ? colors.colorBlack : colors.colorBlack,
                      theme: theme.isDarkMode,
                      fw: 0),

              items: provideData.addDividersAfterStock(provideData.finnceYears),
              // customItemsHeights: provideData
              //     .getStochCustomItemsHeight(provideData.finnceYears),
              value: provideData.selcteFinYear,
              onChanged: (value) async {
                provideData.chngFinYear("$value");
              },
              // buttonHeight: 40,
              // buttonWidth: 100
            ))
          ],
        ),
      ),
      const SizedBox(height: 10),
      if (finData.selctedFinType == "Income") ...[
        IncomeSheetData(
            themes: theme,
            incomSheet: provideData.selcteFinType == "Consolidated"
                ? provideData
                    .fundamentalData!.stockFinancialsConsolidated!.incomeSheet!
                : provideData
                    .fundamentalData!.stockFinancialsStandalone!.incomeSheet!,
            financialYear: provideData.selcteFinYear)
      ] else if (finData.selctedFinType == "Balance sheet") ...[
        BalanceSheetData(
            balanceSheet: provideData.selcteFinType == "Consolidated"
                ? provideData
                    .fundamentalData!.stockFinancialsConsolidated!.balanceSheet!
                : provideData
                    .fundamentalData!.stockFinancialsStandalone!.balanceSheet!,
            financialYear: provideData.selcteFinYear)
      ] else ...[
        CashFlowSheetData(
            cashFlowSheet: provideData.selcteFinType == "Consolidated"
                ? provideData.fundamentalData!.stockFinancialsConsolidated!
                    .cashflowSheet!
                : provideData
                    .fundamentalData!.stockFinancialsStandalone!.cashflowSheet!,
            financialYear: provideData.selcteFinYear)
      ],
      const SizedBox(height: 8),
      Divider(color: colors.colorDivider),
      const SizedBox(height: 8),
    ]);
  }

 
}

class BalanceSheetData extends StatelessWidget {
  final List<BalanceSheet> balanceSheet;
  final String financialYear;
  const BalanceSheetData(
      {super.key, required this.balanceSheet, required this.financialYear});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return financialYear == balanceSheet[index].convDate
            ? Column(
                children: [
                  const SizedBox(height: 4),
                  StockRowTable(
                      title: "Current Asstes",
                      value: "${balanceSheet[index].totalCurrentAssets}",
                      showIcon: true),
                  Divider(color: colors.colorDivider),
                  StockRowTable(
                      title: "Non Current Asstes",
                      value: "${balanceSheet[index].totalNonCurrentAssets}",
                      showIcon: true),
                  Divider(color: colors.colorDivider),
                  StockRowTable(
                      title: "Current Liabilities",
                      value: "${balanceSheet[index].totalCurrentLiabilities}",
                      showIcon: true),
                ],
              )
            : Container();
      },
      itemCount: balanceSheet.length,
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return financialYear == incomSheet[index].convDate
            ? Column(
                children: [
                  const SizedBox(height: 4),
                  StockRowTable(
                      title: "Revenue",
                      value: "${incomSheet[index].revenue}",
                      showIcon: true),
                  Divider(
                      color: themes.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  StockRowTable(
                      title: "Expenditure",
                      value: "${incomSheet[index].expenditure}",
                      showIcon: true),
                  Divider(
                      color: themes.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  StockRowTable(
                      title: "Operating Profit",
                      value: "${incomSheet[index].operatingProfit}",
                      showIcon: true),
                  Divider(
                      color: themes.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  StockRowTable(
                      title: "Profit Before Tax",
                      value: "${incomSheet[index].profitBeforeTax}",
                      showIcon: true),
                  Divider(
                      color: themes.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  StockRowTable(
                      title: "Tax",
                      value: "${incomSheet[index].tax}",
                      showIcon: true),
                  Divider(
                      color: themes.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  StockRowTable(
                      title: "Profit After Tax",
                      value: "${incomSheet[index].profitAfterTax}",
                      showIcon: true),
                ],
              )
            : Container();
      },
      itemCount: incomSheet.length,
    );
  }
}

class CashFlowSheetData extends StatelessWidget {
  final List<CashflowSheet> cashFlowSheet;
  final String financialYear;
  const CashFlowSheetData(
      {super.key, required this.cashFlowSheet, required this.financialYear});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return financialYear == cashFlowSheet[index].convDate
            ? Column(
                children: [
                  const SizedBox(height: 4),
                  StockRowTable(
                      title: "Cash Flow From Investing Activities",
                      value:
                          "${cashFlowSheet[index].cashFlowFromInvestingActivities}",
                      showIcon: true),
                  Divider(color: colors.colorDivider),
                  StockRowTable(
                      title: "Cash From Financing Activities",
                      value:
                          "${cashFlowSheet[index].cashFromFinancingActivities}",
                      showIcon: true),
                  Divider(color: colors.colorDivider),
                  StockRowTable(
                      title: "Cash From Operating Activities",
                      value:
                          "${cashFlowSheet[index].cashFromOperatingActivities}",
                      showIcon: true),
                ],
              )
            : Container();
      },
      itemCount: cashFlowSheet.length,
    );
  }
}
