// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mynt_plus/provider/dashboard_provider.dart';
// import 'package:mynt_plus/provider/thems.dart';
// import 'package:mynt_plus/res/res.dart';
// import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/collection_basket_list.dart';
// import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/create_baskerscreen.dart';
// import 'package:mynt_plus/sharedWidget/splash_loader.dart';

// import '../../../../res/global_state_text.dart';

// class FundSelectionScreen extends ConsumerStatefulWidget {
//   const FundSelectionScreen({super.key});

//   @override
//   ConsumerState<FundSelectionScreen> createState() => _FundSelectionScreenState();
// }

// class _FundSelectionScreenState extends ConsumerState<FundSelectionScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = ref.watch(themeProvider);
//     final strategy = ref.watch(dashboardProvider);
//     final filteredFunds = strategy.getFilteredFunds();
    
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
//             splashColor: theme.isDarkMode
//                 ? colors.splashColorDark
//                 : colors.splashColorLight,
//             highlightColor: theme.isDarkMode
//                 ? colors.highlightDark
//                 : colors.highlightLight,
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
//         child: strategy.isStrategyLoading
//             ? Center(child: CircularLoaderImage())
//             : Column(
//                 children: [
//                   // Search and Filter Section
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         // Search Bar
//                         Container(
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: TextFormField(
//                             controller: strategy.searchController,
//                             style: TextWidget.textStyle(
//                               fontSize: 16,
//                               theme: theme.isDarkMode,
//                               color: theme.isDarkMode
//                                   ? colors.textPrimaryDark
//                                   : colors.textPrimaryLight,
//                               fw: 0,
//                             ),
//                             decoration: InputDecoration(
//                               hintText: "Search funds",
//                               hintStyle: TextWidget.textStyle(
//                                 fontSize: 14,
//                                 theme: theme.isDarkMode,
//                                 color: theme.isDarkMode
//                                     ? colors.textSecondaryDark
//                                     : colors.textSecondaryLight,
//                                 fw: 0,
//                               ),
//                               prefixIcon: Icon(
//                                 Icons.search,
//                                 color: theme.isDarkMode
//                                     ? colors.textSecondaryDark
//                                     : colors.textSecondaryLight,
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             ),
//                             onChanged: (value) {
//                               // The provider will handle the filtering automatically
//                               strategy.Basketsearch(value);
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 12),
                        
//                         // Filter Chips
//                         SizedBox(
//                           height: 40,
//                           child: ListView(
//                             scrollDirection: Axis.horizontal,
//                             children: ['All', 'Equity', 'Debt', 'Hybrid', 'Commodities']
//                                 .map((filter) => _buildFilterChip(filter, theme))
//                                 .toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   // Selected Funds Count
//                   if (strategy.selectedFunds.isNotEmpty)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           TextWidget.subText(
//                             text: '${strategy.selectedFunds.length} funds selected',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textSecondaryDark
//                                 : colors.textSecondaryLight,
//                             fw: 0,
//                           ),
//                           TextButton(
//                             onPressed: () => strategy.clearStrategy(),
//                             child: TextWidget.subText(
//                               text: 'Clear All',
//                               theme: theme.isDarkMode,
//                               color: colors.colorBlue,
//                               fw: 0,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                  
//                   // Fund List
//                   Expanded(
//                     child: ListView.separated(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       separatorBuilder: (_, __) => const Divider(height: 1),
//                       itemCount: filteredFunds.length,
//                       itemBuilder: (context, index) {
//                         final fund = filteredFunds[index];
//                         final isSelected = strategy.isFundSelected(fund);
                        
//                         return _buildFundItem(fund, isSelected, theme);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(String filter, ThemesProvider theme) {
//     final strategy = ref.watch(dashboardProvider);
//     final isSelected = strategy.selectedFilter == filter;
    
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
//           strategy.updateSelectedFilter(filter);
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
//     final strategy = ref.read(dashboardProvider);
    
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         splashColor: theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
//         highlightColor: theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
//         onTap: () {
//           if (isSelected) {
//             strategy.removeFundFromStrategy(fund);
//           } else {
//             strategy.addFundToStrategy(fund);
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
//                   color: strategy.getFundTypeColor(fund.type).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   strategy.getFundTypeIcon(fund.type),
//                   color: strategy.getFundTypeColor(fund.type),
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
// }


