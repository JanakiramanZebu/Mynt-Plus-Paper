// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mynt_plus/provider/dashboard_provider.dart';
// import 'package:mynt_plus/provider/thems.dart';
// import 'package:mynt_plus/res/global_state_text.dart';
// import 'package:mynt_plus/res/res.dart';
// import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/create_baskerscreen.dart';

// class FundSelectionScreen extends ConsumerStatefulWidget {
//   const FundSelectionScreen({super.key});

//   @override
//   ConsumerState<FundSelectionScreen> createState() => _FundSelectionScreenState();
// }

// class _FundSelectionScreenState extends ConsumerState<FundSelectionScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String selectedFilter = 'All';

//   // Static fund list based on your images
//   final List<FundModel> staticFunds = [
//     FundModel(
//       name: 'SBI Nifty 50 ETF',
//       type: 'Equity',
//       fiveYearCAGR: 17.7,
//       threeYearCAGR: 13.19,
//       aum: 20815.73,
//       sharpe: 0.8,
//     ),
//     FundModel(
//       name: 'SBI BSE Sensex ETF',
//       type: 'Equity',
//       fiveYearCAGR: 16.82,
//       threeYearCAGR: 12.29,
//       aum: 11725.54,
//       sharpe: 0.74,
//     ),
//     FundModel(
//       name: 'Parag Parikh Flexi Cap Fund - Regular Plan',
//       type: 'Equity',
//       fiveYearCAGR: 21.77,
//       threeYearCAGR: 20.49,
//       aum: 11328.67,
//       sharpe: 1.23,
//     ),
//     FundModel(
//       name: 'HDFC Balanced Advantage Fund - Regular Plan',
//       type: 'Hybrid',
//       fiveYearCAGR: 22.34,
//       threeYearCAGR: 18.24,
//       aum: 10772.60,
//       sharpe: 1.4,
//     ),
//     FundModel(
//       name: 'Aditya Birla Sun Life Liquid Fund - Direct Plan',
//       type: 'Debt',
//       fiveYearCAGR: 5.73,
//       threeYearCAGR: 7.13,
//       aum: 51915.25,
//       sharpe: 1.59,
//     ),
//     FundModel(
//       name: 'ICICI Prudential Large Cap Fund',
//       type: 'Equity',
//       fiveYearCAGR: 25.54,
//       threeYearCAGR: 21.63,
//       aum: 5375.52,
//       sharpe: 1.41,
//     ),
//   ];

//   List<FundModel> get filteredFunds {
//     List<FundModel> funds = staticFunds;
    
//     // Apply filter
//     if (selectedFilter != 'All') {
//       funds = funds.where((fund) => fund.type == selectedFilter).toList();
//     }
    
//     // Apply search
//     if (_searchController.text.isNotEmpty) {
//       funds = funds.where((fund) => 
//         fund.name.toLowerCase().contains(_searchController.text.toLowerCase())
//       ).toList();
//     }
    
//     return funds;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = ref.watch(themeProvider);
//     final strategy = ref.watch(dashboardProvider);
    
//     return Scaffold(
//       backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
//       appBar: AppBar(
//         leadingWidth: 48,
//         titleSpacing: 0,
//         centerTitle: false,
//         leading: Material(
//           color: Colors.transparent,
//           shape: const CircleBorder(),
//           clipBehavior: Clip.hardEdge,
//           child: InkWell(
//             customBorder: const CircleBorder(),
//             onTap: () => Navigator.pop(context),
//             child: Container(
//               width: 44,
//               height: 44,
//               alignment: Alignment.center,
//               child: Icon(
//                 Icons.arrow_back_ios_outlined,
//                 size: 18,
//                 color: theme.isDarkMode
//                     ? colors.textSecondaryDark
//                     : colors.textSecondaryLight,
//               ),
//             ),
//           ),
//         ),
//         elevation: 0.2,
//         title: TextWidget.titleText(
//           text: "Add Funds to Strategy",
//           textOverflow: TextOverflow.ellipsis,
//           theme: theme.isDarkMode,
//           color: theme.isDarkMode
//               ? colors.textPrimaryDark
//               : colors.textPrimaryLight,
//           fw: 1,
//         ),
//         actions: [
//           if (strategy.selectedFunds.isNotEmpty)
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const StrategyBuilderScreen(),
//                   ),
//                 );
//               },
//               child: TextWidget.subText(
//                 text: 'Next',
//                 theme: theme.isDarkMode,
//                 color: colors.colorBlue,
//                 fw: 1,
//               ),
//             ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Search and Filter Section
//             Container(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Search Bar
//                   Container(
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: TextFormField(
//                       controller: _searchController,
//                       style: TextWidget.textStyle(
//                         fontSize: 16,
//                         theme: theme.isDarkMode,
//                         color: theme.isDarkMode
//                             ? colors.textPrimaryDark
//                             : colors.textPrimaryLight,
//                         fw: 0,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: "Search funds",
//                         hintStyle: TextWidget.textStyle(
//                           fontSize: 14,
//                           theme: theme.isDarkMode,
//                           color: theme.isDarkMode
//                               ? colors.textSecondaryDark
//                               : colors.textSecondaryLight,
//                           fw: 0,
//                         ),
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: theme.isDarkMode
//                               ? colors.textSecondaryDark
//                               : colors.textSecondaryLight,
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       ),
//                       onChanged: (value) => setState(() {}),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
                  
//                   // Filter Chips
//                   SizedBox(
//                     height: 40,
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       children: ['All', 'Equity', 'Debt', 'Hybrid', 'Commodities']
//                           .map((filter) => _buildFilterChip(filter, theme))
//                           .toList(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Selected Funds Count
//             if (strategy.selectedFunds.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     TextWidget.subText(
//                       text: '${strategy.selectedFunds.length} funds selected',
//                       theme: theme.isDarkMode,
//                       color: theme.isDarkMode
//                           ? colors.textSecondaryDark
//                           : colors.textSecondaryLight,
//                       fw: 0,
//                     ),
//                     TextButton(
//                       onPressed: () => ref.read(dashboardProvider).clearStrategy(),
//                       child: TextWidget.subText(
//                         text: 'Clear All',
//                         theme: theme.isDarkMode,
//                         color: colors.colorBlue,
//                         fw: 0,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
            
//             // Fund List
//             Expanded(
//               child: ListView.separated(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 separatorBuilder: (_, __) => const Divider(height: 1),
//                 itemCount: filteredFunds.length,
//                 itemBuilder: (context, index) {
//                   final fund = filteredFunds[index];
//                   final isSelected = strategy.selectedFunds.any((f) => f.name == fund.name);
                  
//                   return _buildFundItem(fund, isSelected, theme);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(String filter, ThemesProvider theme) {
//     final isSelected = selectedFilter == filter;
    
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: FilterChip(
//         label: TextWidget.subText(
//           text: filter,
//           theme: theme.isDarkMode,
//           color: isSelected
//               ? colors.colorWhite
//               : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
//           fw: isSelected ? 1 : 0,
//         ),
//         selected: isSelected,
//         onSelected: (selected) {
//           setState(() {
//             selectedFilter = filter;
//           });
//         },
//         backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
//         selectedColor: colors.colorBlue,
//         side: BorderSide(
//           color: isSelected
//               ? colors.colorBlue
//               : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
//         ),
//       ),
//     );
//   }

//   Widget _buildFundItem(FundModel fund, bool isSelected, ThemesProvider theme) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           if (isSelected) {
//             ref.read(dashboardProvider).removeFundFromStrategy(fund);
//           } else {
//             ref.read(dashboardProvider).addFundToStrategy(fund);
//           }
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Row(
//             children: [
//               // Fund Type Icon
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: _getFundTypeColor(fund.type).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   _getFundTypeIcon(fund.type),
//                   color: _getFundTypeColor(fund.type),
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
              
//               // Fund Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextWidget.subText(
//                       text: fund.name,
//                       theme: theme.isDarkMode,
//                       color: theme.isDarkMode
//                           ? colors.textPrimaryDark
//                           : colors.textPrimaryLight,
//                       fw: 0,
//                     ),
//                     const SizedBox(height: 4),
//                     TextWidget.paraText(
//                       text: fund.type.toUpperCase(),
//                       theme: theme.isDarkMode,
//                       color: theme.isDarkMode
//                           ? colors.textSecondaryDark
//                           : colors.textSecondaryLight,
//                       fw: 0,
//                     ),
//                   ],
//                 ),
//               ),
              
//               // Performance Metrics
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Row(
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           TextWidget.subText(
//                             text: '${fund.fiveYearCAGR.toStringAsFixed(1)}%',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textPrimaryDark
//                                 : colors.textPrimaryLight,
//                             fw: 0,
//                           ),
//                           TextWidget.captionText(
//                             text: '5 yr CAGR',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textSecondaryDark
//                                 : colors.textSecondaryLight,
//                             fw: 0,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           TextWidget.subText(
//                             text: '${fund.sharpe.toStringAsFixed(2)}',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textPrimaryDark
//                                 : colors.textPrimaryLight,
//                             fw: 0,
//                           ),
//                           TextWidget.captionText(
//                             text: 'Sharpe',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textSecondaryDark
//                                 : colors.textSecondaryLight,
//                             fw: 0,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(width: 12),
                      
//                       // Selection Indicator
//                       Container(
//                         width: 24,
//                         height: 24,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: isSelected ? colors.colorBlue : Colors.transparent,
//                           border: Border.all(
//                             color: isSelected 
//                                 ? colors.colorBlue 
//                                 : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
//                           ),
//                         ),
//                         child: isSelected
//                             ? const Icon(
//                                 Icons.check,
//                                 size: 16,
//                                 color: Colors.white,
//                               )
//                             : null,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getFundTypeColor(String type) {
//     switch (type.toLowerCase()) {
//       case 'equity':
//         return colors.colorBlue;
//       case 'debt':
//         return colors.successLight;
//       case 'hybrid':
//         return colors.KColorLightBlueBg;
//       case 'commodities':
//         return colors.colorbluegrey;
//       default:
//         return colors.textSecondaryLight;
//     }
//   }

//   IconData _getFundTypeIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'equity':
//         return Icons.trending_up;
//       case 'debt':
//         return Icons.account_balance;
//       case 'hybrid':
//         return Icons.pie_chart;
//       case 'commodities':
//         return Icons.landscape;
//       default:
//         return Icons.monetization_on;
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

