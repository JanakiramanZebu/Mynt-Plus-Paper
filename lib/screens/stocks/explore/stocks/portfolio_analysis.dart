// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mynt_plus/provider/thems.dart';
// import 'package:mynt_plus/res/global_state_text.dart';
// import 'package:mynt_plus/res/res.dart';
// import 'package:mynt_plus/sharedWidget/splash_loader.dart';
// import '../../../../provider/dashboard_provider.dart';
// import '../../../../models/explore_model/portfolioanalisys_models.dart';
// import '../../../../sharedWidget/no_data_found.dart';

// class PortfolioDashboardScreen extends ConsumerStatefulWidget {
//   const PortfolioDashboardScreen({super.key});

//   @override
//   ConsumerState<PortfolioDashboardScreen> createState() =>
//       _PortfolioDashboardScreenState();
// }

// class _PortfolioDashboardScreenState
//     extends ConsumerState<PortfolioDashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(dashboardProvider).getPortfolioAnalysis();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = ref.watch(themeProvider);
//     final portfolio = ref.watch(dashboardProvider);
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
//             highlightColor:
//                 theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: Container(
//               width: 44, // Increased touch area
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
//             text: "Portfolio Dashboard",
//             textOverflow: TextOverflow.ellipsis,
//             theme: theme.isDarkMode,
//             color: theme.isDarkMode
//                 ? colors.textPrimaryDark
//                 : colors.textPrimaryLight,
//             fw: 1),
//       ),
//       body: SafeArea(
//         child: Consumer(
//           builder: (context, ref, child) {
//             if (portfolio.isPortfolioLoading == true) {
//               return Center(
//                 child: Container(
//                   color: Colors.white,
//                   child: CircularLoaderImage(),
//                 ),
//               );
//             }
//             if (portfolio.portfolioAnalysis == null &&
//                 portfolio.isPortfolioLoading == false) {
//               return const Center(
//                 child: NoDataFound(),
//               );
//             }

//             return _buildDashboardContent(
//                 ref.watch(dashboardProvider).portfolioAnalysis!);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildDashboardContent(PortfolioResponse data) {
//     final theme = ref.watch(themeProvider);
//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // _buildPortfolioSummary(data),
//           // SizedBox(height: 16),
//           // _buildQuickStatsCards(data),
//           // SizedBox(height: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextWidget.titleText(
//                 text: 'Portfolio Summary',
//                 theme: theme.isDarkMode,
//                 color: theme.isDarkMode
//                     ? colors.textPrimaryDark
//                     : colors.textPrimaryLight,
//                 fw: 0,
//               ),
//               SizedBox(height: 12),
//             ],
//           ),
//           if (data.chartData != null)
//             _buildInvestmentChart(data.chartData!, data),
//           SizedBox(height: 16),
//           _buildAccountAllocation(data.accountAllocation),
//           SizedBox(height: 16),
//           _buildChartsSection(data),
//           SizedBox(height: 16),
//           // _buildTopStocks(data.topStocks),
//           // SizedBox(height: 16),
//           _buildSectorAllocationTable(data.sectorAllocation),
//           SizedBox(height: 16),
//           _buildFundamentalsTable(data.fundamentals),
//         ],
//       ),
//     );
//   }

//   // Widget _buildPortfolioSummary(PortfolioResponse data) {
//   //   final theme = ref.watch(themeProvider);
//   //   return Container(
//   //     width: double.infinity,
//   //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white,
//   //       borderRadius: BorderRadius.circular(12),
//   //     ),
//   //     child:
//   //   );
//   // }

//   Widget _buildQuickStatsCards(PortfolioResponse data) {
//     double currentValue = 0;
//     double investedValue = 0;

//     if (data.chartData != null &&
//         data.chartData!.totalCurrentValue.isNotEmpty) {
//       currentValue = data.chartData!.totalCurrentValue.last;
//       investedValue = data.chartData!.totalInvestedValue.last;
//     }

//     double pnl = currentValue - investedValue;
//     double pnlPercentage = investedValue > 0 ? (pnl / investedValue) * 100 : 0;

//     return Row(
//       children: [
//         Expanded(
//           child: _buildStatCard(
//             'Current Value',
//             '₹${ref.read(dashboardProvider).formatAmount(currentValue)}',
//             Color(0xFF059B3C),
//             Icons.account_balance_wallet,
//           ),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: _buildStatCard(
//             'P&L',
//             '₹${ref.read(dashboardProvider).formatAmount(pnl)}',
//             pnl >= 0 ? Color(0xFF059B3C) : Colors.red,
//             pnl >= 0 ? Icons.trending_up : Icons.trending_down,
//             subtitle: '${pnlPercentage.toStringAsFixed(2)}%',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(String title, String value, Color color, IconData icon,
//       {String? subtitle}) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: color, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Color(0xFF6C7B93),
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 16,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//           if (subtitle != null) ...[
//             SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 color: color,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInvestmentChart(ChartData chartData, PortfolioResponse data) {
//     final theme = ref.watch(themeProvider);
//     final portfolio = ref.watch(dashboardProvider);
//     if (chartData.dates.isEmpty) return SizedBox.shrink();

//     // Use all data points for better representation
//     List<FlSpot> investedSpots = [];
//     List<FlSpot> currentSpots = [];

//     for (int i = 0; i < chartData.dates.length; i++) {
//       investedSpots.add(FlSpot(i.toDouble(),
//           chartData.totalInvestedValue[i] / 1000)); // Convert to thousands
//       currentSpots
//           .add(FlSpot(i.toDouble(), chartData.totalCurrentValue[i] / 1000));
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     TextWidget.titleText(
//                       text: '${data.xirrResult.toStringAsFixed(2)}%',
//                       theme: theme.isDarkMode,
//                       color: data.xirrResult.toStringAsFixed(2).startsWith("-")
//                           ? theme.isDarkMode
//                               ? colors.lossDark
//                               : colors.lossLight
//                           : data.xirrResult == 0 || data.xirrResult == null
//                               ? colors.textSecondaryLight
//                               : theme.isDarkMode
//                                   ? colors.successDark
//                                   : colors.successLight,
//                       fw: 1,
//                     ),
//                     SizedBox(height: 4),
//                     TextWidget.subText(
//                       text: 'XIRR Return',
//                       theme: theme.isDarkMode,
//                       color: theme.isDarkMode
//                           ? colors.textSecondaryDark
//                           : colors.textSecondaryLight,
//                       fw: 3,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),

//         SizedBox(height: 16),
//         Container(
//           height: 200,
//           width: double.infinity,
//           child: LineChart(
//             LineChartData(
//               gridData: FlGridData(
//                 show: true,
//                 drawVerticalLine: false,
//                 drawHorizontalLine: true,
//                 getDrawingHorizontalLine: (value) => FlLine(
//                   color: const Color(0xFFE5E7EB),
//                   strokeWidth: 0.5,
//                   dashArray: [5, 5],
//                 ),
//                 horizontalInterval: 1,
//               ),
//               titlesData: FlTitlesData(
//                 leftTitles: AxisTitles(
//                   sideTitles: SideTitles(showTitles: false),
//                 ),
//                 bottomTitles: AxisTitles(
//                   sideTitles: SideTitles(
//                     showTitles: true,
//                     reservedSize: 35, // a bit bigger for padding
//                     interval: 1,
//                     getTitlesWidget: (value, meta) {
//                       if (value.toInt() < investedSpots.length) {
//                         final dataIndex =
//                             value.toInt().clamp(0, chartData.dates.length - 1);
//                         final totalPoints = investedSpots.length;
//                         final labelInterval =
//                             (totalPoints / 6).ceil().clamp(1, totalPoints);

//                         if (value.toInt() == 0 ||
//                             value.toInt() == investedSpots.length - 1 ||
//                             value.toInt() % labelInterval == 0) {
//                           final dateString = chartData.dates[dataIndex];

//                           try {
//                             final date = DateTime.parse(dateString);
//                             final month =
//                                 portfolio.getMonthAbbreviation(date.month);
//                             final year = date.year.toString().substring(2);

//                             return Padding(
//                               padding: EdgeInsets.only(
//                                 left: value.toInt() == 0
//                                     ? 20
//                                     : 0, // extra padding for first
//                                 right: value.toInt() == investedSpots.length - 1
//                                     ? 20
//                                     : 0, // extra padding for last
//                               ),
//                               child: TextWidget.captionText(
//                                 text: '$month $year',
//                                 theme: theme.isDarkMode,
//                                 color: theme.isDarkMode
//                                     ? colors.textSecondaryDark
//                                     : colors.textSecondaryLight,
//                                 fw: 3,
//                               ),
//                             );
//                           } catch (e) {
//                             return const Text('');
//                           }
//                         }
//                       }
//                       return const Text('');
//                     },
//                   ),
//                 ),
//                 topTitles:
//                     AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                 rightTitles:
//                     AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               ),
//               borderData: FlBorderData(show: false),
//               minX: 0,
//               maxX: (chartData.dates.length - 1).toDouble(),
//               minY: 0,
//               lineTouchData: LineTouchData(
//                 enabled: true,
//                 touchTooltipData: LineTouchTooltipData(
//                   tooltipBgColor: colors.searchBg,
//                   getTooltipItems: (touchedSpots) {
//                     return touchedSpots.map((spot) {
//                       return LineTooltipItem(
//                         '${spot.y.toStringAsFixed(2)}',
//                         TextWidget.textStyle(
//                           theme: false,
//                           color: theme.isDarkMode
//                               ? colors.textPrimaryDark
//                               : colors.textPrimaryLight,
//                           fw: 0,
//                           fontSize: 12,
//                         ),
//                       );
//                     }).toList();
//                   },
//                 ),
//               ),
//               lineBarsData: [
//                 LineChartBarData(
//                   spots: investedSpots,
//                   isCurved: true,
//                   color: const Color(0xFF3B82F6),
//                   barWidth: 2,
//                   dotData: FlDotData(show: false),
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: const Color(0xFF3B82F6).withOpacity(0.15),
//                   ),
//                 ),
//                 LineChartBarData(
//                   spots: currentSpots,
//                   isCurved: true,
//                   color: const Color(0xFF8B5CF6),
//                   barWidth: 2,
//                   dotData: FlDotData(show: false),
//                   belowBarData: BarAreaData(
//                     show: true,
//                     color: const Color(0xFF8B5CF6).withOpacity(0.15),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         // SizedBox(height: 12),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildChartLegend('Invested', Color(0xFF3B82F6)),
//             SizedBox(width: 20),
//             _buildChartLegend('Current', Color(0xFF8B5CF6)),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildChartLegend(String label, Color color) {
//     final theme = ref.watch(themeProvider);
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 12,
//           height: 3,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(2),
//           ),
//         ),
//         SizedBox(width: 6),
//         TextWidget.paraText(
//           text: label,
//           theme: false,
//           color: theme.isDarkMode
//               ? colors.textSecondaryDark
//               : colors.textSecondaryLight,
//           fw: 3,
//         ),
//       ],
//     );
//   }

//   Widget _buildAccountAllocation(Map<String, double> allocation) {
//     final theme = ref.watch(themeProvider);
//     if (allocation.isEmpty) return SizedBox.shrink();

//     final sortedEntries = allocation.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget.titleText(
//                 text: 'Account Allocation',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textPrimaryDark
//                     : colors.textPrimaryLight,
//                 fw: 0,
//               ),
//               // Icon(
//               //   Icons.arrow_forward_ios,
//               //   color: Color(0xFF6C7B93),
//               //   size: 16,
//               // ),
//             ],
//           ),
//           SizedBox(height: 12),
//           TextWidget.paraText(
//             text: 'Your portfolio distribution across different account types',
//             theme: theme.isDarkMode,
//             color: theme.isDarkMode
//                 ? colors.textSecondaryDark
//                 : colors.textSecondaryLight,
//             fw: 3,
//           ),
//           SizedBox(height: 24),
//           ...sortedEntries
//               .map((entry) => _buildAccountTypeCard(
//                     entry.key,
//                     entry.value,
//                     ref.read(dashboardProvider).getAccountTypeColor(entry.key),
//                     ref.read(dashboardProvider).getAccountTypeIcon(entry.key),
//                   ))
//               .toList(),
//         ],
//       ),
//     );
//   }

//   Color _getAccountTypeColor(String accountType) {
//     switch (accountType.toLowerCase()) {
//       case 'equity':
//         return Color(0xFF60A5FA); // Light blue
//       case 'mutual funds':
//         return Color(0xFF3B82F6); // Medium blue
//       case 'bonds':
//         return Color(0xFF1D4ED8); // Darker blue
//       case 'cash':
//         return Color(0xFF1E3A8A); // Darkest blue
//       case 'commodities':
//         return Color(0xFF0F172A); // Very dark blue
//       default:
//         // Use a blue color palette for other account types
//         List<Color> blueColors = [
//           Color(0xFF60A5FA), // Light blue
//           Color(0xFF3B82F6), // Medium blue
//           Color(0xFF1D4ED8), // Darker blue
//           Color(0xFF1E3A8A), // Darkest blue
//           Color(0xFF0F172A), // Very dark blue
//         ];
//         return blueColors[accountType.hashCode % blueColors.length];
//     }
//   }

//   IconData _getAccountTypeIcon(String accountType) {
//     switch (accountType.toLowerCase()) {
//       case 'equity':
//         return Icons.trending_up;
//       case 'mutual funds':
//         return Icons.account_balance;
//       case 'bonds':
//         return Icons.security;
//       case 'cash':
//         return Icons.account_balance_wallet;
//       case 'commodities':
//         return Icons.inventory;
//       default:
//         return Icons.account_balance;
//     }
//   }

//   Widget _buildAccountTypeCard(
//       String accountType, double percentage, Color color, IconData icon) {
//     final theme = ref.watch(themeProvider);
//     return Container(
//       // margin: EdgeInsets.only(bottom: 16),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: colors.colorWhite,
//         borderRadius: BorderRadius.circular(8),
//         // border: Border.all(
//         //     color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
//         //     width: 0.5),
//       ),
//       child: Row(
//         children: [
//           // Icon Container
//           Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: color,
//               size: 18,
//             ),
//           ),
//           SizedBox(width: 16),
//           // Account Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 TextWidget.subText(
//                   text: accountType,
//                   theme: false,
//                   color: theme.isDarkMode
//                       ? colors.textPrimaryDark
//                       : colors.textPrimaryLight,
//                   fw: 3,
//                 ),
//                 SizedBox(height: 4),
//                 TextWidget.captionText(
//                   text: '${percentage.toStringAsFixed(2)}% of portfolio',
//                   theme: false,
//                   color: theme.isDarkMode
//                       ? colors.textSecondaryDark
//                       : colors.textSecondaryLight,
//                   fw: 3,
//                 ),
//               ],
//             ),
//           ),
//           // Percentage Display
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(5),
//             ),
//             child: TextWidget.subText(
//               text: '${percentage.toStringAsFixed(1)}%',
//               theme: false,
//               color: color,
//               fw: 0,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChartsSection(PortfolioResponse data) {
//     return Column(
//       children: [
//         // _buildSectorAllocationChart(
//         //     data.sectorAllocation), // Sector allocation chart
//         SizedBox(height: 16),
//         _buildMarketCapChart(
//             data.marketCapAllocation), // Market cap allocation chart
//         SizedBox(height: 16),
//         // _buildSectorChart(data.sectorAllocation),
//       ],
//     );
//   }

//   Widget _buildSectorAllocationChart(Map<String, double> allocation) {
//     final theme = ref.watch(themeProvider);
//     if (allocation.isEmpty) return SizedBox.shrink();

//     // Get top sectors for display (similar to the image)
//     final sortedEntries = allocation.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     // Take top 4 sectors and group the rest as "Others"
//     final topSectors = sortedEntries.take(4).toList();
//     final otherSectors = sortedEntries.skip(4).toList();

//     // Calculate "Others" percentage
//     double othersPercentage = 0;
//     if (otherSectors.isNotEmpty) {
//       othersPercentage =
//           otherSectors.fold(0.0, (sum, entry) => sum + entry.value);
//     }

//     // Create final allocation map
//     Map<String, double> displayAllocation = Map.fromEntries(topSectors);
//     if (othersPercentage > 0) {
//       displayAllocation['Others'] = othersPercentage;
//     }

//     return Container(
//       width: double.infinity,
//       // padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget.titleText(
//                 text: 'Sector Allocation',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textPrimaryDark
//                     : colors.textPrimaryLight,
//                 fw: 0,
//               ),
//               // Icon(
//               //   Icons.arrow_forward_ios,
//               //   color: Color(0xFF6C7B93),
//               //   size: 16,
//               // ),
//             ],
//           ),
//           SizedBox(height: 24),
//           // // Text(
//           // //   'Your portfolio is currently overweight in the Industrial sector (15.11%) compared to the Nifty 50 average of 5.93%',
//           // //   style: TextStyle(
//           // //     color: Color(0xFF6C7B93),
//           // //     fontSize: 14,
//           // //     height: 1.4,
//           // //   ),
//           // // ),
//           // SizedBox(height: 24),
//           Row(
//             children: [
//               // Donut Chart
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                   height: 160,
//                   child: PieChart(
//                     PieChartData(
//                       sections: displayAllocation.entries.map((entry) {
//                         return PieChartSectionData(
//                           value: entry.value,
//                           title: '${entry.value.toStringAsFixed(1)}%',
//                           color: ref
//                               .read(dashboardProvider)
//                               .getSectorAllocationColor(entry.key),
//                           radius: 50,
//                           titleStyle: TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         );
//                       }).toList(),
//                       centerSpaceRadius: 35,
//                       sectionsSpace: 1,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 20),
//               // Legend
//               Expanded(
//                 flex: 1,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: displayAllocation.entries
//                       .map((entry) => _buildSectorLegend(
//                           entry.key,
//                           entry.value,
//                           ref
//                               .read(dashboardProvider)
//                               .getSectorAllocationColor(entry.key)))
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMarketCapChart(Map<String, double> allocation) {
//     final theme = ref.watch(themeProvider);
//     if (allocation.isEmpty) return SizedBox.shrink();

//     // Get top market cap types for display (similar to sector allocation)
//     final sortedEntries = allocation.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     // Take top 4 market cap types and group the rest as "Others"
//     final topMarketCaps = sortedEntries.take(4).toList();
//     final otherMarketCaps = sortedEntries.skip(4).toList();

//     // Calculate "Others" percentage
//     double othersPercentage = 0;
//     if (otherMarketCaps.isNotEmpty) {
//       othersPercentage =
//           otherMarketCaps.fold(0.0, (sum, entry) => sum + entry.value);
//     }

//     // Create final allocation map
//     Map<String, double> displayAllocation = Map.fromEntries(topMarketCaps);
//     if (othersPercentage > 0) {
//       displayAllocation['Others'] = othersPercentage;
//     }

//     return Container(
//       width: double.infinity,
//       // padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget.titleText(
//                 text: 'Market Cap Allocation',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textPrimaryDark
//                     : colors.textPrimaryLight,
//                 fw: 0,
//               ),
//               // Icon(
//               //   Icons.arrow_forward_ios,
//               //   color: Color(0xFF6C7B93),
//               //   size: 16,
//               // ),
//             ],
//           ),
//           SizedBox(height: 24),
//           Row(
//             children: [
//               // Donut Chart
//               Expanded(
//                 flex: 1,
//                 child: Container(
//                   height: 160,
//                   child: PieChart(
//                     PieChartData(
//                       sections: displayAllocation.entries.map((entry) {
//                         return PieChartSectionData(
//                           value: entry.value,
//                           title: '${entry.value.toStringAsFixed(1)}%',
//                           color: ref
//                               .read(dashboardProvider)
//                               .getMarketCapAllocationColor(entry.key),
//                           radius: 50,
//                           titleStyle: TextStyle(
//                             color: Colors.white,
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         );
//                       }).toList(),
//                       centerSpaceRadius: 35,
//                       sectionsSpace: 1,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 20),
//               // Legend
//               Expanded(
//                 flex: 1,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: displayAllocation.entries
//                       .map((entry) => _buildMarketCapLegend(
//                           entry.key,
//                           entry.value,
//                           ref
//                               .read(dashboardProvider)
//                               .getMarketCapAllocationColor(entry.key)))
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPieChartLegend(String label, Color color) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         SizedBox(width: 6),
//         Text(
//           label,
//           style: TextStyle(
//             color: Color(0xFF6C7B93),
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTopStocks(List<TopStock> stocks) {
//     if (stocks.isEmpty) return SizedBox.shrink();

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 4,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16),
//             child: Text(
//               'Top Holdings (${stocks.length})',
//               style: TextStyle(
//                 color: Color(0xFF2E3A59),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           ...stocks.take(10).map((stock) => _buildStockItem(stock)).toList(),
//           if (stocks.length > 10)
//             Padding(
//               padding: EdgeInsets.all(16),
//               child: Center(
//                 child: Text(
//                   'View All ${stocks.length} Holdings',
//                   style: TextStyle(
//                     color: Color(0xFF059B3C),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStockItem(TopStock stock) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(
//           bottom: BorderSide(color: Color(0xFFE8ECF1), width: 0.5),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: Color(0xFF059B3C).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 stock.tsym.length >= 2
//                     ? stock.tsym.substring(0, 2)
//                     : stock.tsym,
//                 style: TextStyle(
//                   color: Color(0xFF059B3C),
//                   fontWeight: FontWeight.w600,
//                   fontSize: 12,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   stock.name,
//                   style: TextStyle(
//                     color: Color(0xFF2E3A59),
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 2),
//                 Text(
//                   stock.tsym,
//                   style: TextStyle(
//                     color: Color(0xFF6C7B93),
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${stock.allocationPercent.toStringAsFixed(1)}%',
//                 style: TextStyle(
//                   color: Color(0xFF059B3C),
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               SizedBox(height: 2),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: ref
//                       .read(dashboardProvider)
//                       .getMarketCapColor(stock.marketCapType)
//                       .withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   stock.marketCapType,
//                   style: TextStyle(
//                     color: ref
//                         .read(dashboardProvider)
//                         .getMarketCapColor(stock.marketCapType),
//                     fontSize: 9,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectorAllocationTable(Map<String, double> allocation) {
//     final theme = ref.watch(themeProvider);
//     if (allocation.isEmpty) return SizedBox.shrink();

//     final sortedEntries = allocation.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget.titleText(
//                 text: 'Sector Allocation',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textPrimaryDark
//                     : colors.textPrimaryLight,
//                 fw: 0,
//               ),
//               // Icon(
//               //   Icons.arrow_forward_ios,
//               //   color: Color(0xFF6C7B93),
//               //   size: 16,
//               // ),
//             ],
//           ),
//           SizedBox(height: 12),
//           TextWidget.paraText(
//             text:
//                 'Your portfolio is currently overweight in the Industrial sector',
//             theme: false,
//             color: theme.isDarkMode
//                 ? colors.textSecondaryDark
//                 : colors.textSecondaryLight,
//             fw: 3,
//           ),
//           SizedBox(height: 12),
//           // Horizontal Stacked Bar Chart
//           Container(
//             height: 30,
//             width: double.infinity,
//             child: _buildHorizontalStackedBar(sortedEntries),
//           ),
//           SizedBox(height: 12),
//           // Two-column Legend
//           _buildTwoColumnLegend(sortedEntries),
//         ],
//       ),
//     );
//   }

//   Widget _buildFundamentalsTable(List<Fundamental> fundamentals) {
//     final theme = ref.watch(themeProvider);
//     if (fundamentals.isEmpty) return SizedBox.shrink();

//     return Container(
//       width: double.infinity,
//       // padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget.titleText(
//                 text: 'Top Stocks',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textPrimaryDark
//                     : colors.textPrimaryLight,
//                 fw: 0,
//               ),
//               // Icon(
//               //   Icons.arrow_forward_ios,
//               //   color: Color(0xFF6C7B93),
//               //   size: 16,
//               // ),
//             ],
//           ),
//           SizedBox(height: 12),
//           TextWidget.paraText(
//             text: 'Your portfolio performance across different sectors',
//             theme: false,
//             color: theme.isDarkMode
//                 ? colors.textSecondaryDark
//                 : colors.textSecondaryLight,
//             fw: 3,
//           ),
//           SizedBox(height: 16),
//           // Sector List with ListView.builder
//           Container(
//             height: fundamentals.length > 5
//                 ? 500
//                 : null, // Fixed height if more than 5 items
//             child: ListView.builder(
//               shrinkWrap: fundamentals.length <=
//                   5, // Only shrink wrap if 5 or fewer items
//               physics: fundamentals.length > 5
//                   ? AlwaysScrollableScrollPhysics()
//                   : NeverScrollableScrollPhysics(),
//               itemCount: fundamentals
//                   .where((entry) =>
//                       entry.companyName != null &&
//                       entry.marketCap != null &&
//                       entry.qty != null &&
//                       entry.marketCapType != null &&
//                       entry.roaPercent != null &&
//                       entry.exch != null)
//                   .length,
//               itemBuilder: (context, index) {
//                 final validFundamentals = fundamentals
//                     .where((entry) =>
//                         entry.companyName != null &&
//                         entry.marketCap != null &&
//                         entry.qty != null &&
//                         entry.marketCapType != null &&
//                         entry.roaPercent != null &&
//                         entry.exch != null)
//                     .toList();

//                 final entry = validFundamentals[index];
//                 final sector = entry.companyName!;
//                 final totalValue = entry.marketCap!;
//                 final qty = entry.qty!;
//                 final marketCapType = entry.marketCapType!;
//                 final allocationPercent = entry.roaPercent!;
//                 final exch = entry.exch!;

//                 return _buildSectorPerformanceItem(
//                   sector: sector,
//                   value: totalValue,
//                   marketCapType: marketCapType,
//                   allocationPercent: allocationPercent,
//                   qty: qty,
//                   exch: exch,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectorPerformanceItem({
//     required String sector,
//     required String marketCapType,
//     required double allocationPercent,
//     required double value,
//     required int qty,
//     required String exch,
//   }) {
//     final theme = ref.watch(themeProvider);
//     final performanceColor =
//         ref.read(dashboardProvider).getMarketCapColor(marketCapType);

//     return Container(
//       // margin: EdgeInsets.only(bottom: 16),
//       padding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
//       decoration: BoxDecoration(
//         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
//         // borderRadius: BorderRadius.circular(12),
//         border: Border(
//           bottom: BorderSide(
//             color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
//             width: 1,
//           ),
//           // horizontal: BorderSide(
//           //   color: theme.isDarkMode
//           //       ? colors.dividerDark
//           //       : colors.dividerLight,
//           //   width: 0.5,
//           // ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Sector Name and Navigation Arrow
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.5,
//                 child: TextWidget.subText(
//                   text: sector,
//                   theme: false,
//                   color: theme.isDarkMode
//                       ? colors.textPrimaryDark
//                       : colors.textPrimaryLight,
//                   fw: 3,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: performanceColor.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: TextWidget.paraText(
//                   text: '${marketCapType}',
//                   theme: false,
//                   color: performanceColor,
//                   fw: 0,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 6),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget.subText(
//                 text: '${exch}',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textSecondaryDark
//                     : colors.textSecondaryLight,
//                 fw: 3,
//               ),
//               TextWidget.subText(
//                 text: '${allocationPercent.toStringAsFixed(2)}%',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textSecondaryDark
//                     : colors.textSecondaryLight,
//                 fw: 3,
//               ),
//             ],
//           ),
//           SizedBox(height: 6),
//           // Value and Allocation
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextWidget.subText(
//                 text: '₹${_formatAmount(value)}',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textSecondaryDark
//                     : colors.textSecondaryLight,
//                 fw: 3,
//               ),
//               TextWidget.subText(
//                 text: '${qty}',
//                 theme: false,
//                 color: theme.isDarkMode
//                     ? colors.textSecondaryDark
//                     : colors.textSecondaryLight,
//                 fw: 3,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTableRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Color(0xFF2E3A59),
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: Color(0xFF059B3C),
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatAmount(double amount) {
//     if (amount >= 10000000) {
//       return '${(amount / 10000000).toStringAsFixed(2)}Cr';
//     } else if (amount >= 100000) {
//       return '${(amount / 100000).toStringAsFixed(2)}L';
//     } else if (amount >= 1000) {
//       return '${(amount / 1000).toStringAsFixed(2)}K';
//     } else {
//       return amount.toStringAsFixed(2);
//     }
//   }

//   Color _getMarketCapColor(String capType) {
//     switch (capType.toLowerCase()) {
//       case 'large cap':
//         return Color(0xFF059B3C);
//       case 'mid cap':
//         return Color(0xFF1976D2);
//       case 'small cap':
//         return Color(0xFFFF7043);
//       default:
//         return Color(0xFF6C7B93);
//     }
//   }

//   // Custom legend for sector allocation
//   Widget _buildSectorLegend(String sector, double percentage, Color color) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               sector,
//               style: TextStyle(
//                 color: Color(0xFF2E3A59),
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             '${percentage.toStringAsFixed(2)}%',
//             style: TextStyle(
//               color: Color(0xFF2E3A59),
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Custom colors for market cap allocation chart (blue theme like sector allocation)
//   Color _getMarketCapAllocationColor(String marketCapType) {
//     switch (marketCapType.toLowerCase()) {
//       case 'large cap':
//         return Color(0xFF60A5FA); // Light blue
//       case 'mid cap':
//         return Color(0xFF3B82F6); // Medium blue
//       case 'small cap':
//         return Color(0xFF1D4ED8); // Darker blue
//       case 'others':
//         return Color(0xFF1E3A8A); // Darkest blue
//       default:
//         // Use a blue color palette for other market cap types
//         List<Color> blueColors = [
//           Color(0xFF60A5FA), // Light blue
//           Color(0xFF3B82F6), // Medium blue
//           Color(0xFF1D4ED8), // Darker blue
//           Color(0xFF1E3A8A), // Darkest blue
//           Color(0xFF0F172A), // Very dark blue
//         ];
//         return blueColors[marketCapType.hashCode % blueColors.length];
//     }
//   }

//   // Custom legend for market cap allocation
//   Widget _buildMarketCapLegend(
//       String marketCapType, double percentage, Color color) {
//     final theme = ref.watch(themeProvider);
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: TextWidget.paraText(
//               text: marketCapType,
//               theme: false,
//               color: theme.isDarkMode
//                   ? colors.textPrimaryDark
//                   : colors.textPrimaryLight,
//               fw: 3,
//             ),
//           ),
//           TextWidget.paraText(
//             text: '${percentage.toStringAsFixed(2)}%',
//             theme: false,
//             color: theme.isDarkMode
//                 ? colors.textPrimaryDark
//                 : colors.textPrimaryLight,
//             fw: 3,
//           ),
//         ],
//       ),
//     );
//   }

//   // Horizontal stacked bar chart for sector allocation
//   Widget _buildHorizontalStackedBar(List<MapEntry<String, double>> entries) {
//     return Row(
//       children: entries.map((entry) {
//         return Expanded(
//           flex: (entry.value * 100).round(),
//           child: Container(
//             height: 20,
//             decoration: BoxDecoration(
//               color: ref
//                   .read(dashboardProvider)
//                   .getSectorAllocationColor(entry.key),
//               borderRadius: BorderRadius.horizontal(
//                 left: entry == entries.first ? Radius.circular(8) : Radius.zero,
//                 right: entry == entries.last ? Radius.circular(8) : Radius.zero,
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   // Two-column legend for sector allocation
//   Widget _buildTwoColumnLegend(List<MapEntry<String, double>> entries) {
//     final leftColumn = entries.take((entries.length / 2).ceil()).toList();
//     final rightColumn = entries.skip((entries.length / 2).ceil()).toList();

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left Column
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: leftColumn
//                 .map((entry) => _buildLegendItem(
//                     entry.key,
//                     entry.value,
//                     ref
//                         .read(dashboardProvider)
//                         .getSectorAllocationColor(entry.key)))
//                 .toList(),
//           ),
//         ),
//         SizedBox(width: 20),
//         // Right Column
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: rightColumn
//                 .map((entry) => _buildLegendItem(
//                     entry.key,
//                     entry.value,
//                     ref
//                         .read(dashboardProvider)
//                         .getSectorAllocationColor(entry.key)))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   // Individual legend item
//   Widget _buildLegendItem(String sector, double percentage, Color color) {
//     final theme = ref.watch(themeProvider);
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Container(
//             width: 12,
//             height: 12,
//             decoration: BoxDecoration(
//               color: color,
//               shape: BoxShape.circle,
//             ),
//           ),
//           SizedBox(width: 8),
//           Expanded(
//             child: TextWidget.paraText(
//               text: sector,
//               theme: false,
//               color: theme.isDarkMode
//                   ? colors.textPrimaryDark
//                   : colors.textPrimaryLight,
//               fw: 3,
//             ),
//           ),
//           TextWidget.paraText(
//             text: '${percentage.toStringAsFixed(2)}%',
//             theme: false,
//             color: theme.isDarkMode
//                 ? colors.textPrimaryDark
//                 : colors.textPrimaryLight,
//             fw: 3,
//           ),
//         ],
//       ),
//     );
//   }
// }
