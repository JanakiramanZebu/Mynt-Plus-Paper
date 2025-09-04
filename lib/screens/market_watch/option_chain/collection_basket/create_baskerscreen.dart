// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mynt_plus/provider/dashboard_provider.dart';
// import 'package:mynt_plus/provider/thems.dart';
// import 'package:mynt_plus/res/global_state_text.dart';
// import 'package:mynt_plus/res/res.dart';
// import 'package:mynt_plus/screens/market_watch/option_chain/collection_basket/collection_basket_list.dart';
// import 'package:mynt_plus/sharedWidget/splash_loader.dart';
// import 'package:mynt_plus/sharedWidget/snack_bar.dart';

// class StrategyBuilderScreen extends ConsumerStatefulWidget {
//   const StrategyBuilderScreen({super.key});

//   @override
//   ConsumerState<StrategyBuilderScreen> createState() => _StrategyBuilderScreenState();
// }

// class _StrategyBuilderScreenState extends ConsumerState<StrategyBuilderScreen> {
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
//           text: "New Strategy",
//           textOverflow: TextOverflow.ellipsis,
//           theme: theme.isDarkMode,
//           color: theme.isDarkMode
//               ? colors.textPrimaryDark
//               : colors.textPrimaryLight,
//           fw: 1,
//         ),
//         actions: [
//           TextButton(
//             onPressed: strategy.isStrategyValid ? () async {
//               try {
//                 await ref.read(dashboardProvider).saveStrategy();
//                 _showSuccessDialog();
//               } catch (e) {
//                 error(context, 'Failed to save strategy. Please try again.');
//               }
//             } : null,
//             child: TextWidget.subText(
//               text: 'Save',
//               theme: theme.isDarkMode,
//               color: strategy.isStrategyValid ? colors.colorBlue : colors.textSecondaryLight,
//               fw: 1,
//             ),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: strategy.isStrategyLoading
//             ? Center(child: CircularLoaderImage())
//             : SingleChildScrollView(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Strategy Type Selection
//                     Row(
//                       children: ['Buy and Hold', 'Rebalance', 'Risk Targeting']
//                           .map((type) => Padding(
//                                 padding: const EdgeInsets.only(right: 8),
//                                 child: _buildStrategyTypeChip(type, strategy.selectedStrategyType == type, theme),
//                               ))
//                           .toList(),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Strategy Builder Section
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Selected Funds List
//                           ...strategy.selectedFunds.map((fund) => _buildStrategyFundItem(fund, theme)),
                          
//                           const Divider(height: 1),
                          
//                           // Add More Funds Button
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               splashColor: theme.isDarkMode
//                                   ? colors.splashColorDark
//                                   : colors.splashColorLight,
//                               highlightColor: theme.isDarkMode
//                                   ? colors.highlightDark
//                                   : colors.highlightLight,
//                               onTap: () => Navigator.pop(context),
//                               child: Container(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.add_circle_outline,
//                                       color: colors.colorBlue,
//                                       size: 24,
//                                     ),
//                                     const SizedBox(width: 12),
//                                     TextWidget.subText(
//                                       text: 'Add more funds',
//                                       theme: theme.isDarkMode,
//                                       color: colors.colorBlue,
//                                       fw: 0,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
                          
//                           // Total Percentage
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             decoration: BoxDecoration(
//                               color: colors.colorBlue.withOpacity(0.05),
//                               borderRadius: const BorderRadius.only(
//                                 bottomLeft: Radius.circular(12),
//                                 bottomRight: Radius.circular(12),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 TextWidget.subText(
//                                   text: 'Total',
//                                   theme: theme.isDarkMode,
//                                   color: theme.isDarkMode
//                                       ? colors.textPrimaryDark
//                                       : colors.textPrimaryLight,
//                                   fw: 1,
//                                 ),
//                                 TextWidget.subText(
//                                   text: '${strategy.totalPercentage.toStringAsFixed(0)}%',
//                                   theme: theme.isDarkMode,
//                                   color: strategy.totalPercentage == 100 
//                                       ? colors.successLight 
//                                       : colors.lossLight,
//                                   fw: 1,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Investment Details
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           TextWidget.subText(
//                             text: 'Investment Details',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textPrimaryDark
//                                 : colors.textPrimaryLight,
//                             fw: 1,
//                           ),
//                           const SizedBox(height: 16),
                          
//                           // Investment Type
//                           Row(
//                             children: ['One-time', 'Monthly SIP']
//                                 .map((type) => Padding(
//                                       padding: const EdgeInsets.only(right: 8),
//                                       child: _buildInvestmentTypeChip(type, strategy.selectedInvestmentType == type, theme),
//                                     ))
//                                 .toList(),
//                           ),
//                           const SizedBox(height: 16),
                          
//                           // Initial Amount
//                           TextWidget.subText(
//                             text: 'Initial amount',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textPrimaryDark
//                                 : colors.textPrimaryLight,
//                             fw: 0,
//                           ),
//                           const SizedBox(height: 8),
//                           TextFormField(
//                             controller: strategy.investmentController,
//                             style: TextWidget.textStyle(
//                               fontSize: 18,
//                               theme: theme.isDarkMode,
//                               color: theme.isDarkMode
//                                   ? colors.textPrimaryDark
//                                   : colors.textPrimaryLight,
//                               fw: 1,
//                             ),
//                             decoration: InputDecoration(
//                               prefixText: '₹ ',
//                               prefixStyle: TextWidget.textStyle(
//                                 fontSize: 18,
//                                 theme: theme.isDarkMode,
//                                 color: theme.isDarkMode
//                                     ? colors.textPrimaryDark
//                                     : colors.textPrimaryLight,
//                                 fw: 1,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide(
//                                   color: theme.isDarkMode
//                                       ? colors.textSecondaryDark
//                                       : colors.textSecondaryLight,
//                                 ),
//                               ),
//                             ),
//                             keyboardType: TextInputType.number,
//                           ),
//                           const SizedBox(height: 16),
                          
//                           // Duration
//                           TextWidget.subText(
//                             text: 'Over a duration of',
//                             theme: theme.isDarkMode,
//                             color: theme.isDarkMode
//                                 ? colors.textPrimaryDark
//                                 : colors.textPrimaryLight,
//                             fw: 0,
//                           ),
//                           const SizedBox(height: 8),
//                           Wrap(
//                             spacing: 8,
//                             children: ['1Y', '3Y', '5Y', '10Y', 'Custom']
//                                 .map((duration) => _buildDurationChip(duration, strategy.selectedDuration == duration, theme))
//                                 .toList(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
                    
//                     // Backtest Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 45,
//                       child: ElevatedButton(
//                         onPressed: strategy.isStrategyValid ? () {
//                           // Handle backtest
//                           successMessage(context, 'Backtest functionality will be implemented');
//                         } : null,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: colors.colorBlue,
//                           disabledBackgroundColor: colors.textSecondaryLight.withOpacity(0.3),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: TextWidget.subText(
//                           text: 'Backtest',
//                           theme: theme.isDarkMode,
//                           color: Colors.white,
//                           fw: 1,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }

//   Widget _buildStrategyTypeChip(String text, bool isSelected, ThemesProvider theme) {
//     return GestureDetector(
//       onTap: () {
//         ref.read(dashboardProvider).updateStrategyType(text);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? colors.colorBlue : Colors.transparent,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? colors.colorBlue : colors.textSecondaryLight,
//           ),
//         ),
//         child: TextWidget.subText(
//           text: text,
//           theme: theme.isDarkMode,
//           color: isSelected ? Colors.white : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
//           fw: isSelected ? 1 : 0,
//         ),
//       ),
//     );
//   }

//   Widget _buildStrategyFundItem(FundModel fund, ThemesProvider theme) {
//     final strategy = ref.read(dashboardProvider);
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Row(
//         children: [
//           // Fund Type Icon
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: strategy.getFundTypeColor(fund.type).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(
//               strategy.getFundTypeIcon(fund.type),
//               color: strategy.getFundTypeColor(fund.type),
//               size: 16,
//             ),
//           ),
//           const SizedBox(width: 12),
          
//           // Fund Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextWidget.subText(
//                   text: fund.name,
//                   theme: theme.isDarkMode,
//                   color: theme.isDarkMode
//                       ? colors.textPrimaryDark
//                       : colors.textPrimaryLight,
//                   fw: 0,
//                 ),
//                 const SizedBox(height: 2),
//                 TextWidget.paraText(
//                   text: fund.type.toUpperCase(),
//                   theme: theme.isDarkMode,
//                   color: theme.isDarkMode
//                       ? colors.textSecondaryDark
//                       : colors.textSecondaryLight,
//                   fw: 0,
//                 ),
//               ],
//             ),
//           ),
          
//           // Percentage
//           Container(
//             width: 60,
//             child: TextWidget.subText(
//               text: '${fund.percentage.toStringAsFixed(1)}%',
//               theme: theme.isDarkMode,
//               color: theme.isDarkMode
//                   ? colors.textPrimaryDark
//                   : colors.textPrimaryLight,
//               fw: 1,
//             ),
//           ),
          
//           // Remove Button
//           Material(
//             color: Colors.transparent,
//             shape: const CircleBorder(),
//             clipBehavior: Clip.hardEdge,
//             child: InkWell(
//               splashColor: theme.isDarkMode
//                   ? colors.splashColorDark
//                   : colors.splashColorLight,
//               highlightColor: theme.isDarkMode
//                   ? colors.highlightDark
//                   : colors.highlightLight,
//               onTap: () {
//                 strategy.removeFundFromStrategy(fund);
//               },
//               child: Container(
//                 width: 32,
//                 height: 32,
//                 alignment: Alignment.center,
//                 child: Icon(
//                   Icons.remove_circle_outline,
//                   size: 18,
//                   color: colors.lossLight,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInvestmentTypeChip(String text, bool isSelected, ThemesProvider theme) {
//     return GestureDetector(
//       onTap: () {
//         ref.read(dashboardProvider).updateInvestmentType(text);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? colors.colorBlue : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected ? colors.colorBlue : colors.textSecondaryLight,
//           ),
//         ),
//         child: TextWidget.subText(
//           text: text,
//           theme: theme.isDarkMode,
//           color: isSelected ? Colors.white : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
//           fw: isSelected ? 1 : 0,
//         ),
//       ),
//     );
//   }

//   Widget _buildDurationChip(String text, bool isSelected, ThemesProvider theme) {
//     return GestureDetector(
//       onTap: () {
//         ref.read(dashboardProvider).updateDuration(text);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? colors.colorBlue : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected ? colors.colorBlue : colors.textSecondaryLight,
//           ),
//         ),
//         child: TextWidget.subText(
//           text: text,
//           theme: theme.isDarkMode,
//           color: isSelected ? Colors.white : (theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight),
//           fw: isSelected ? 1 : 0,
//         ),
//       ),
//     );
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: colors.colorWhite,
//         title: TextWidget.titleText(
//           text: 'Strategy Saved',
//           theme: false,
//           color: colors.textPrimaryLight,
//           fw: 1,
//         ),
//         content: TextWidget.subText(
//           text: 'Your investment strategy has been saved successfully.',
//           theme: false,
//           color: colors.textSecondaryLight,
//           fw: 0,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).pop();
//               Navigator.of(context).pop();
//             },
//             child: TextWidget.subText(
//               text: 'OK',
//               theme: false,
//               color: colors.colorBlue,
//               fw: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


