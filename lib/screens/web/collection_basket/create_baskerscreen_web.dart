// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mynt_plus/models/explore_model/basketcollection_model.dart';
// import 'package:mynt_plus/provider/dashboard_provider.dart';
// import 'package:mynt_plus/res/mynt_web_color_styles.dart';
// import 'package:mynt_plus/res/mynt_web_text_styles.dart';
// import 'package:mynt_plus/res/res.dart';

// import 'package:mynt_plus/sharedWidget/common_buttons_web.dart';
// import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';
// import 'package:mynt_plus/sharedWidget/mynt_loader.dart';
// import 'package:mynt_plus/sharedWidget/snack_bar.dart';
// import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;

// import '../../../../models/trading_personality_model.dart';

// import '../../../../sharedWidget/list_divider.dart';
// import '../../../../sharedWidget/cust_text_formfield.dart';
// import 'basket_invest_dialog.dart';

// class StrategyBuilderScreenWeb extends ConsumerStatefulWidget {
//   final VoidCallback? onBack;
//   final VoidCallback? onSaveStrategy;
//   final VoidCallback? onBacktest;

//   const StrategyBuilderScreenWeb({
//     super.key,
//     this.onBack,
//     this.onSaveStrategy,
//     this.onBacktest,
//   });

//   @override
//   ConsumerState<StrategyBuilderScreenWeb> createState() =>
//       _StrategyBuilderScreenState();
// }

// class _StrategyBuilderScreenState extends ConsumerState<StrategyBuilderScreenWeb> {

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(dashboardProvider).Basketsearch("");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final strategy = ref.watch(dashboardProvider);
//     final dark = isDarkMode(context);

//     return PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) async {
//           if (didPop) return;
//           if (strategy.hasStrategyChanged) {
//             await _showUnsavedChangesDialog();
//             strategy.stratergySavebackbutton(true);
//           } else {
//             _navigateBackToDashboard();
//           }
//         },
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: Scaffold(
//             backgroundColor: resolveThemeColor(context,
//                 dark: MyntColors.backgroundColorDark,
//                 light: MyntColors.backgroundColor),
//             body: Column(
//               children: [
//                 // Top action bar
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     children: [
//                       Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           borderRadius: BorderRadius.circular(20),
//                           onTap: () => _handleBackNavigation(),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Icon(
//                               Icons.arrow_back,
//                               size: 20,
//                               color: resolveThemeColor(context,
//                                   dark: MyntColors.textPrimaryDark,
//                                   light: MyntColors.textPrimary),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           strategy.isEditingMode
//                               ? strategy.strategyNameController.text
//                               : "New Strategy",
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 1,
//                           style: MyntWebTextStyles.title(context,
//                               fontWeight: MyntFonts.semiBold,
//                               darkColor: MyntColors.textPrimaryDark,
//                               lightColor: MyntColors.textPrimary),
//                         ),
//                       ),
//                       if (strategy.selectedFunds.isNotEmpty) ...[
//                         Material(
//                           color: Colors.transparent,
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(5),
//                             onTap: () => _showFundSelectionDialog(),
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               child: Text(
//                                 'Add funds',
//                                 style: MyntWebTextStyles.body(context,
//                                     fontWeight: MyntFonts.semiBold,
//                                     color: MyntColors.primary),
//                               ),
//                             ),
//                           ),
//                         ),
//                         if (!strategy.isEditingMode) ...[
//                           Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(5),
//                               onTap: strategy.isStrategyValid
//                                   ? () => _handleCreateStrategy(context)
//                                   : null,
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 child: Text(
//                                   'Save',
//                                   style: MyntWebTextStyles.body(context,
//                                       fontWeight: MyntFonts.semiBold,
//                                       color: strategy.isStrategyValid
//                                           ? MyntColors.primary
//                                           : MyntColors.textSecondary),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ],
//                       if (strategy.isEditingMode) ...[
//                         PopupMenuButton<String>(
//                           icon: Icon(
//                             Icons.more_vert,
//                             color: resolveThemeColor(context,
//                                 dark: MyntColors.textSecondaryDark,
//                                 light: MyntColors.textSecondary),
//                             size: 20,
//                           ),
//                           color: resolveThemeColor(context,
//                               dark: colors.searchBgDark,
//                               light: colors.searchBg),
//                           onSelected: (value) {
//                             if (value == 'edit') {
//                               _navigateToEditStrategy(context);
//                             } else if (value == 'delete') {
//                               _showDeleteConfirmationDialog(context);
//                             }
//                           },
//                           itemBuilder: (context) => [
//                             PopupMenuItem<String>(
//                               value: 'edit',
//                               child: Text(
//                                 'Edit',
//                                 style: MyntWebTextStyles.para(context,
//                                     fontWeight: MyntFonts.regular,
//                                     darkColor: MyntColors.textSecondaryDark,
//                                     lightColor: MyntColors.textSecondary),
//                               ),
//                             ),
//                             PopupMenuItem<String>(
//                               value: 'delete',
//                               child: Text(
//                                 'Delete',
//                                 style: MyntWebTextStyles.para(context,
//                                     fontWeight: MyntFonts.semiBold,
//                                     color: MyntColors.loss),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 // Body
//                 Expanded(
//                   child: strategy.isStrategyLoading
//                       ? Center(child: MyntLoader.branded())
//                       : Column(
//                           children: [
//                             Expanded(
//                               child: SingleChildScrollView(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         if (strategy.selectedFunds.isEmpty) ...[
//                                           SizedBox(
//                                             width: double.infinity,
//                                             height: MediaQuery.of(context).size.height * 0.5,
//                                             child: NoDataFoundWeb(
//                                               title: 'No Funds',
//                                               subtitle: 'Start building your investment strategy',
//                                               primaryLabel: 'Add Funds',
//                                               primaryEnabled: true,
//                                               secondaryEnabled: false,
//                                               onPrimary: () => _showFundSelectionDialog(),
//                                             ),
//                                           ),
//                                         ] else ...[
//                                           _buildGroupedFundsList(strategy, context),
//                                         ],
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             if (strategy.selectedFunds.isNotEmpty) ...[
//                               Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(right: 8.0),
//                                         child: SizedBox(
//                                           height: 45,
//                                           child: ElevatedButton(
//                                             onPressed: strategy.isStrategyValid
//                                                 ? () {
//                                                 strategy.stratergySavebackbutton(false);
//                                                 _showInvestmentDetailsBottomSheet(context);
//                                                   }
//                                                 : null,
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: MyntColors.primary,
//                                               disabledBackgroundColor:
//                                                   MyntColors.textSecondary.withOpacity(0.3),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(5),
//                                               ),
//                                             ),
//                                               child: Text(
//                                               'Analyse',
//                                                 style: MyntWebTextStyles.body(context,
//                                                     fontWeight: MyntFonts.semiBold,
//                                                     color: MyntColors.textWhite),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     if (strategy.isEditingMode) ...[
//                                       Expanded(
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(left: 8.0),
//                                           child: SizedBox(
//                                                 height: 45,
//                                             child: ElevatedButton(
//                                               onPressed: strategy.isStrategyValid
//                                                   ? () {}
//                                                   : null,
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor: MyntColors.primary,
//                                                 disabledBackgroundColor:
//                                                     MyntColors.textSecondary.withOpacity(0.3),
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius: BorderRadius.circular(5),
//                                                 ),
//                                               ),
//                                                 child: Text(
//                                                   'Invest',
//                                                   style: MyntWebTextStyles.body(context,
//                                                       fontWeight: MyntFonts.semiBold,
//                                                       color: MyntColors.textWhite),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                             ]
//                           ],
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }

//   Widget _buildStrategyTypeChip(
//       String text, bool isSelected, BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(5),
//         splashColor: isDarkMode(context)
//             ? Colors.white.withOpacity(0.15)
//             : Colors.black.withOpacity(0.15),
//         highlightColor: isDarkMode(context)
//             ? Colors.white.withOpacity(0.08)
//             : Colors.black.withOpacity(0.08),
//         onTap: () {
//           ref.read(dashboardProvider).updateStrategyType(text);
//         },
//         child: Container(
//           height: 35,
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? resolveThemeColor(context,
//                     dark: colors.searchBgDark,
//                     light: const Color(0xffF1F3F8))
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(5),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Center(
//             child: Text(
//               text,
//               style: MyntWebTextStyles.body(context,
//                   fontWeight: MyntFonts.semiBold,
//                   color: isSelected
//                       ? resolveThemeColor(context,
//                           dark: MyntColors.textPrimaryDark,
//                           light: MyntColors.textPrimary)
//                       : resolveThemeColor(context,
//                           dark: MyntColors.textSecondaryDark,
//                           light: MyntColors.textSecondary)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGroupedFundsList(DashboardProvider strategy, BuildContext context) {
//     final groupedFunds = strategy.groupedSelectedFunds;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: groupedFunds.entries.map((entry) {
//         final category = entry.key;
//         final funds = entry.value;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildSectionHeader(category, context),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ...funds.asMap().entries.map((fundEntry) {
//               final index = fundEntry.key;
//               final fund = fundEntry.value;

//               return Column(
//                 children: [
//                   _buildSwipeableStrategyFundItem(fund, context),
//                   if (index < funds.length - 1) const ListDivider(),
//                 ],
//               );
//             }),
//             const SizedBox(height: 16),
//           ],
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildSectionHeader(String category, BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           category.toUpperCase(),
//           style: MyntWebTextStyles.body(context,
//               fontWeight: MyntFonts.medium,
//               darkColor: MyntColors.textSecondaryDark,
//               lightColor: MyntColors.textSecondary),
//         ),
//       ],
//     );
//   }

//   Color _getCategoryColor(String category, BuildContext context) {
//     switch (category) {
//       case 'Equity':
//         return MyntColors.primary;
//       case 'Hybrid':
//         return colors.kColorGreenButton;
//       case 'Debt':
//         return colors.kColorOrange;
//       default:
//         return resolveThemeColor(context,
//             dark: MyntColors.textSecondaryDark,
//             light: MyntColors.textSecondary);
//     }
//   }

//   Widget _buildPlanetAvatarSelector(DashboardProvider strategy, BuildContext context) {
//     final selectedPlanet = TradingPersonalities.getPersonality(strategy.selectedPersonality);

//     return GestureDetector(
//       onTap: () => _showPlanetSelectionModal(context, strategy),
//       child: Container(
//         width: 80,
//         height: 80,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               selectedPlanet.primaryColor,
//               selectedPlanet.secondaryColor,
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: selectedPlanet.primaryColor.withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Center(
//           child: Text(
//             selectedPlanet.emoji,
//             style: const TextStyle(fontSize: 32),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showPlanetSelectionModal(BuildContext context, DashboardProvider strategy) {
//     final dark = isDarkMode(context);
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Container(
//         decoration: BoxDecoration(
//           color: resolveThemeColor(context,
//               dark: MyntColors.backgroundColorDark,
//               light: MyntColors.backgroundColor),
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: resolveThemeColor(context,
//                     dark: MyntColors.textSecondaryDark,
//                     light: MyntColors.textSecondary).withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Choose Your Planet',
//               style: MyntWebTextStyles.title(context,
//                   fontWeight: MyntFonts.semiBold,
//                   darkColor: MyntColors.textPrimaryDark,
//                   lightColor: MyntColors.textPrimary),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Select a planet that represents your investment strategy',
//               style: MyntWebTextStyles.para(context,
//                   fontWeight: MyntFonts.regular,
//                   darkColor: MyntColors.textSecondaryDark,
//                   lightColor: MyntColors.textSecondary),
//             ),
//             const SizedBox(height: 24),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 5,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//                 childAspectRatio: 1,
//               ),
//               itemCount: TradingPersonalities.personalities.length,
//               itemBuilder: (context, index) {
//                 final planet = TradingPersonalities.personalities[index];
//                 final isSelected = planet.type == strategy.selectedPersonality;

//                 return GestureDetector(
//                   onTap: () {
//                     strategy.updateSelectedPersonality(planet.type);
//                     Navigator.pop(context);
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           planet.primaryColor,
//                           planet.secondaryColor,
//                         ],
//                       ),
//                       border: isSelected
//                           ? Border.all(
//                               color: MyntColors.primaryDark,
//                               width: 3,
//                             )
//                           : null,
//                       boxShadow: [
//                         BoxShadow(
//                           color: planet.primaryColor.withOpacity(0.3),
//                           blurRadius: isSelected ? 8 : 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: Text(
//                         planet.emoji,
//                         style: TextStyle(
//                           fontSize: isSelected ? 28 : 24,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSwipeableStrategyFundItem(FundListModel fund, BuildContext context) {
//     final strategy = ref.read(dashboardProvider);
//     return _SwipeToDeleteItem(
//       key: Key(fund.name),
//       fund: fund,
//       strategy: strategy,
//       onDelete: () {
//         strategy.removeFundFromStrategy(fund);
//       },
//       child: _buildStrategyFundItem(fund, context),
//     );
//   }

//   Widget _buildStrategyFundItem(FundListModel fund, BuildContext context) {
//     final strategy = ref.read(dashboardProvider);
//     final dark = isDarkMode(context);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _capitalizeEachWord(fund.name),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: MyntWebTextStyles.body(context,
//                       fontWeight: MyntFonts.medium,
//                       darkColor: MyntColors.textPrimaryDark,
//                       lightColor: MyntColors.textPrimary),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Row(
//             children: [
//               SizedBox(
//                 width: 90,
//                 height: 40,
//                 child: CustomTextFormField(
//                   fillColor: dark ? colors.darkGrey : const Color(0xffF1F3F8),
//                   hintText: "0",
//                   hintStyle: MyntWebTextStyles.body(context,
//                       fontWeight: MyntFonts.regular,
//                       darkColor: MyntColors.textSecondaryDark.withOpacity(0.4),
//                       lightColor: MyntColors.textSecondary.withOpacity(0.4)),
//                   inputFormate: [FilteringTextInputFormatter.digitsOnly],
//                   keyboardType: TextInputType.number,
//                   style: MyntWebTextStyles.body(context,
//                       fontWeight: MyntFonts.regular,
//                       darkColor: MyntColors.textPrimaryDark,
//                       lightColor: MyntColors.textPrimary),
//                   textCtrl: strategy.percentageControllers[fund.name] ?? TextEditingController(),
//                   textAlign: TextAlign.center,
//                   onChanged: (value) {
//                     final intValue = int.tryParse(value);
//                     if (intValue != null && intValue > 0 && intValue <= 100) {
//                       strategy.updateFundPercentage(fund, intValue.toDouble());
//                     } else if (value.isEmpty) {
//                       strategy.updateFundPercentage(fund, 0);
//                     } else if (intValue == 0) {
//                       strategy.updateFundPercentage(fund, 0);
//                     } else {
//                       strategy.updateFundPercentage(fund, fund.percentage);
//                     }
//                     strategy.validatepercentage(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 8),
//           Material(
//             color: Colors.transparent,
//             shape: const CircleBorder(),
//             clipBehavior: Clip.hardEdge,
//             child: InkWell(
//               onTap: () async {
//                 await Future.delayed(const Duration(milliseconds: 150), () {
//                   strategy.toggleFundLock(fund, context);
//                 });
//               },
//               child: Container(
//                 width: 32,
//                 height: 32,
//                 alignment: Alignment.center,
//                 child: Icon(
//                   fund.isLocked ? Icons.lock : Icons.lock_open,
//                   color: strategy.selectedFunds.length == 1
//                       ? resolveThemeColor(context,
//                           dark: MyntColors.textSecondaryDark,
//                           light: MyntColors.textSecondary).withOpacity(0.3)
//                       : fund.isLocked
//                           ? MyntColors.primaryDark
//                           : resolveThemeColor(context,
//                               dark: MyntColors.textSecondaryDark,
//                               light: MyntColors.textSecondary),
//                   size: 20,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInvestmentTypeChip(
//       String text, bool isSelected, BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(5),
//         splashColor: isDarkMode(context)
//             ? Colors.white.withOpacity(0.15)
//             : Colors.black.withOpacity(0.15),
//         highlightColor: isDarkMode(context)
//             ? Colors.white.withOpacity(0.08)
//             : Colors.black.withOpacity(0.08),
//         onTap: () {
//           ref.read(dashboardProvider).updateInvestmentType(text);
//         },
//         child: Container(
//           height: 35,
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? resolveThemeColor(context,
//                     dark: colors.searchBgDark,
//                     light: const Color(0xffF1F3F8))
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(5),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Center(
//             child: Text(
//               text,
//               style: MyntWebTextStyles.body(context,
//                   fontWeight: MyntFonts.semiBold,
//                   color: isSelected
//                       ? resolveThemeColor(context,
//                           dark: MyntColors.textPrimaryDark,
//                           light: MyntColors.textPrimary)
//                       : resolveThemeColor(context,
//                           dark: MyntColors.textSecondaryDark,
//                           light: MyntColors.textSecondary)),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDurationChip(
//       String text, bool isSelected, BuildContext context) {
//     final dark = isDarkMode(context);
//     return TextButton(
//       onPressed: () {
//         ref.read(dashboardProvider).updateDuration(text);
//         FocusScope.of(context).unfocus();
//       },
//       style: TextButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
//         backgroundColor: !dark
//             ? isSelected
//                 ? const Color(0xffF1F3F8)
//                 : Colors.transparent
//             : isSelected
//                 ? colors.darkGrey
//                 : Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(4),
//           side: isSelected
//               ? BorderSide(color: MyntColors.primaryDark, width: 1)
//               : BorderSide.none,
//         ),
//       ),
//       child: Text(
//         text,
//         style: MyntWebTextStyles.body(context,
//             fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.regular,
//             darkColor: MyntColors.textPrimaryDark,
//             lightColor: MyntColors.textPrimary),
//       ),
//     );
//   }

//   void _handleBackNavigation() async {
//     final strategy = ref.read(dashboardProvider);
//     if (strategy.hasStrategyChanged) {
//       await _showUnsavedChangesDialog();
//       strategy.stratergySavebackbutton(true);
//     } else {
//       _navigateBackToDashboard();
//     }
//   }

//   Future<void> _showUnsavedChangesDialog() async {
//     return showDialog(
//       context: context,
//       builder: (ctx) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Center(
//             child: shadcn.Card(
//               borderRadius: BorderRadius.circular(8),
//               padding: EdgeInsets.zero,
//               child: SizedBox(
//                 width: 400,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: shadcn.Theme.of(ctx).colorScheme.border,
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Unsaved Changes',
//                             style: MyntWebTextStyles.title(
//                               ctx,
//                               color: resolveThemeColor(ctx,
//                                   dark: MyntColors.textPrimaryDark,
//                                   light: MyntColors.textPrimary),
//                               fontWeight: MyntFonts.medium,
//                             ),
//                           ),
//                           MyntCloseButton(
//                             onPressed: () => Navigator.of(ctx).pop(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Content
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Text(
//                             'You have unsaved changes. Do you want to save them before leaving?',
//                             textAlign: TextAlign.center,
//                             style: MyntWebTextStyles.body(
//                               ctx,
//                               color: resolveThemeColor(ctx,
//                                   dark: MyntColors.textPrimaryDark,
//                                   light: MyntColors.textPrimary),
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: SizedBox(
//                                   height: 44,
//                                   child: MyntOutlinedButton(
//                                     label: 'Discard',
//                                     isFullWidth: true,
//                                     textColor: resolveThemeColor(ctx,
//                                         dark: MyntColors.textWhite,
//                                         light: MyntColors.primary),
//                                     onPressed: () {
//                                       Navigator.of(ctx).pop();
//                                       _navigateBackToDashboard();
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: SizedBox(
//                                   height: 44,
//                                   child: MyntPrimaryButton(
//                                     label: 'Save',
//                                     isFullWidth: true,
//                                     onPressed: () async {
//                                       final strategy =
//                                           ref.read(dashboardProvider);
//                                       try {
//                                         if (strategy.isEditingMode) {
//                                           await strategy
//                                               .updateStrategy(context);
//                                         } else {
//                                           Navigator.of(ctx).pop();
//                                           _showSaveStrategyDialog();
//                                         }
//                                       } catch (e) {}
//                                     },
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _handleBacktest2Action(BuildContext dialogContext) async {
//     try {
//       final strategy = ref.read(dashboardProvider);
//       // Close the Investment Details dialog first
//       Navigator.of(dialogContext).pop();
//       if (!strategy.isEditingMode || strategy.hasStrategyChanged) {
//         if (strategy.isEditingMode) {
//           await strategy.updateStrategy(context);
//         } else {
//           _showSaveStrategyDialog(triggerBacktest: true);
//           return;
//         }
//       }
//       await _performBacktest(context);
//     } catch (e) {}
//   }

//   void _handleCreateStrategy(BuildContext context) async {
//     try {
//       _showSaveStrategyDialog();
//     } catch (e) {
//       error(context, 'Failed to create strategy. Please try again.');
//     }
//   }

//   void _handleInvestStrategy(BuildContext context) async {
//     try {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Invest functionality coming soon!',
//             style: MyntWebTextStyles.body(context,
//                 fontWeight: MyntFonts.medium,
//                 color: MyntColors.textWhite),
//           ),
//           backgroundColor: MyntColors.primary,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     } catch (e) {
//       error(context, 'Failed to process investment. Please try again.');
//     }
//   }

//   void _handleBacktestAction(BuildContext context) async {
//     final strategy = ref.read(dashboardProvider);
//     try {
//       if (!strategy.isEditingMode || strategy.hasStrategyChanged) {
//         if (strategy.isEditingMode) {
//           await strategy.updateStrategy(context);
//         } else {
//           _showSaveStrategyDialog(triggerBacktest: true);
//           return;
//         }
//       }
//       await _performBacktest(context);
//     } catch (e) {}
//   }

//   Future<void> _performBacktest(BuildContext context) async {
//     final strategy = ref.read(dashboardProvider);
//     try {
//       await strategy.backtestAnalysis(
//           uuid: strategy.editingStrategy?.data?.first.uuid ?? '');
//       if (strategy.analysisData != null) {
//         widget.onBacktest?.call();
//       } else {
//         if (mounted) {
//           error(context, 'Failed to get backtest data. Please try again.');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         error(context, 'Failed to start backtest. Please try again.');
//       }
//     }
//   }

//   void _showInvestmentDetailsBottomSheet(BuildContext context) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Investment Details',
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: const Duration(milliseconds: 200),
//       pageBuilder: (ctx, animation, secondaryAnimation) {
//         return const SizedBox.shrink();
//       },
//       transitionBuilder: (ctx, animation, secondaryAnimation, child) {
//         return FadeTransition(
//           opacity: animation,
//           child: Center(
//             child: Material(
//               color: Colors.transparent,
//               child: Consumer(
//                 builder: (ctx, ref, child) {
//                   final strategy = ref.watch(dashboardProvider);
//                   final dark = isDarkMode(ctx);
//                   final screenWidth = MediaQuery.of(ctx).size.width;
//                   final dialogWidth = screenWidth * 0.3 < 380 ? 380.0 : screenWidth * 0.3;

//                   return Container(
//                     width: dialogWidth,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(8),
//                       color: resolveThemeColor(ctx,
//                           dark: MyntColors.backgroundColorDark,
//                           light: MyntColors.backgroundColor),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 20,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Investment Details',
//                                 style: MyntWebTextStyles.title(ctx,
//                                     fontWeight: MyntFonts.semiBold,
//                                     darkColor: MyntColors.textPrimaryDark,
//                                     lightColor: MyntColors.textPrimary),
//                               ),
//                               Material(
//                                 color: Colors.transparent,
//                                 shape: const CircleBorder(),
//                                 child: InkWell(
//                                   onTap: () => Navigator.pop(ctx),
//                                   borderRadius: BorderRadius.circular(20),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(6.0),
//                                     child: Icon(
//                                       Icons.close_rounded,
//                                       size: 22,
//                                       color: dark
//                                           ? MyntColors.textSecondaryDark
//                                           : MyntColors.textSecondary,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Type',
//                                 style: MyntWebTextStyles.body(ctx,
//                                     fontWeight: MyntFonts.medium,
//                                     darkColor: MyntColors.textPrimaryDark,
//                                     lightColor: MyntColors.textPrimary),
//                               ),
//                               const SizedBox(height: 12),
//                               Row(
//                                 children: [
//                                   'One-time',
//                                 ]
//                                     .map((type) => Padding(
//                                           padding: const EdgeInsets.only(right: 8),
//                                           child: _buildInvestmentTypeChip(
//                                               type,
//                                               strategy.selectedInvestmentType == type,
//                                               ctx),
//                                         ))
//                                     .toList(),
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'Initial amount',
//                                 style: MyntWebTextStyles.body(ctx,
//                                     fontWeight: MyntFonts.medium,
//                                     darkColor: MyntColors.textPrimaryDark,
//                                     lightColor: MyntColors.textPrimary),
//                               ),
//                               const SizedBox(height: 12),
//                               SizedBox(
//                                 height: 50,
//                                 child: TextFormField(
//                                   controller: strategy.investmentController,
//                                   style: MyntWebTextStyles.body(ctx,
//                                       fontWeight: MyntFonts.regular,
//                                       darkColor: MyntColors.textPrimaryDark,
//                                       lightColor: MyntColors.textPrimary),
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.allow(
//                                         RegExp(r'^\d*\.?\d{0,2}$'))
//                                   ],
//                                   decoration: InputDecoration(
//                                     fillColor: dark ? colors.darkGrey : const Color(0xffF1F3F8),
//                                     filled: true,
//                                     prefixText: '₹ ',
//                                     prefixStyle: MyntWebTextStyles.title(ctx,
//                                         fontWeight: MyntFonts.medium,
//                                         darkColor: MyntColors.textPrimaryDark,
//                                         lightColor: MyntColors.textPrimary),
//                                     contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//                                     enabledBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(color: MyntColors.primary),
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     disabledBorder: InputBorder.none,
//                                     focusedBorder: OutlineInputBorder(
//                                       borderSide: BorderSide(color: MyntColors.primary),
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                     border: OutlineInputBorder(
//                                       borderSide: BorderSide.none,
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                   ),
//                                   onChanged: (value) {
//                                     strategy.validateInvestmentAmount(value);
//                                   },
//                                   keyboardType: TextInputType.number,
//                                 ),
//                               ),
//                               if (strategy.investmentError != null) ...[
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   strategy.investmentError!,
//                                   style: MyntWebTextStyles.caption(ctx,
//                                       fontWeight: MyntFonts.regular,
//                                       color: MyntColors.loss),
//                                 ),
//                               ],
//                               const SizedBox(height: 24),
//                               Text(
//                                 'Over a duration of',
//                                 style: MyntWebTextStyles.body(ctx,
//                                     fontWeight: MyntFonts.medium,
//                                     darkColor: MyntColors.textPrimaryDark,
//                                     lightColor: MyntColors.textPrimary),
//                               ),
//                               const SizedBox(height: 12),
//                               Wrap(
//                                 spacing: 8,
//                                 children: ['1Y', '3Y', '5Y']
//                                     .map((duration) => _buildDurationChip(duration,
//                                         strategy.selectedDuration == duration, ctx))
//                                     .toList(),
//                               ),
//                               const SizedBox(height: 32),
//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 45,
//                                 child: ElevatedButton(
//                                   onPressed: strategy.isStrategyValid
//                                       ? () => _handleBacktest2Action(ctx)
//                                       : null,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: MyntColors.primary,
//                                     disabledBackgroundColor:
//                                         MyntColors.textSecondary.withOpacity(0.3),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     strategy.backtestButtonText,
//                                     style: MyntWebTextStyles.body(ctx,
//                                         fontWeight: MyntFonts.semiBold,
//                                         color: MyntColors.textWhite),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showUpdateSuccessDialog() {
//     final dark = isDarkMode(context);
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: resolveThemeColor(context,
//             dark: MyntColors.backgroundColorDark,
//             light: MyntColors.backgroundColor),
//         title: Text(
//           'Strategy Updated',
//           style: MyntWebTextStyles.title(context,
//               fontWeight: MyntFonts.semiBold,
//               darkColor: MyntColors.textPrimaryDark,
//               lightColor: MyntColors.textPrimary),
//         ),
//         content: Text(
//           'Your investment strategy has been updated successfully.',
//           style: MyntWebTextStyles.body(context,
//               fontWeight: MyntFonts.regular,
//               darkColor: MyntColors.textSecondaryDark,
//               lightColor: MyntColors.textSecondary),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               'OK',
//               style: MyntWebTextStyles.body(context,
//                   fontWeight: MyntFonts.medium,
//                   color: MyntColors.primary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: resolveThemeColor(context,
//             dark: MyntColors.backgroundColorDark,
//             light: MyntColors.backgroundColor),
//         title: Text(
//           'Strategy Saved',
//           style: MyntWebTextStyles.title(context,
//               fontWeight: MyntFonts.semiBold,
//               darkColor: MyntColors.textPrimaryDark,
//               lightColor: MyntColors.textPrimary),
//         ),
//         content: Text(
//           'Your investment strategy has been saved successfully.',
//           style: MyntWebTextStyles.body(context,
//               fontWeight: MyntFonts.regular,
//               darkColor: MyntColors.textSecondaryDark,
//               lightColor: MyntColors.textSecondary),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               'OK',
//               style: MyntWebTextStyles.body(context,
//                   fontWeight: MyntFonts.medium,
//                   color: MyntColors.primary),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _capitalizeEachWord(String text) {
//     if (text.isEmpty) return text;
//     return text.split(' ').map((word) {
//       if (word.isEmpty) return word;
//       return word[0].toUpperCase() + word.substring(1).toLowerCase();
//     }).join(' ');
//   }

//   String _formatAumValue(double aum) {
//     if (aum >= 10000000) {
//       return '${(aum / 10000000).toStringAsFixed(1)}Cr';
//     } else if (aum >= 100000) {
//       return '${(aum / 100000).toStringAsFixed(1)}L';
//     } else if (aum >= 1000) {
//       return '${(aum / 1000).toStringAsFixed(1)}K';
//     } else {
//       return aum.toStringAsFixed(0);
//     }
//   }

//   void _showDeleteConfirmationDialog(BuildContext context) {
//     final strategy = ref.read(dashboardProvider);

//     if (strategy.editingStrategy?.data?.first == null) return;

//     final strategyData = strategy.editingStrategy!.data!.first;

//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Center(
//             child: shadcn.Card(
//               borderRadius: BorderRadius.circular(8),
//               padding: EdgeInsets.zero,
//               child: SizedBox(
//                 width: 400,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: shadcn.Theme.of(dialogContext).colorScheme.border,
//                           ),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Delete Strategy',
//                             style: MyntWebTextStyles.title(
//                               dialogContext,
//                               color: resolveThemeColor(dialogContext,
//                                   dark: MyntColors.textPrimaryDark,
//                                   light: MyntColors.textPrimary),
//                               fontWeight: MyntFonts.medium,
//                             ),
//                           ),
//                           MyntCloseButton(
//                             onPressed: () => Navigator.of(dialogContext).pop(),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Content
//                     Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Text(
//                             'Are you sure you want to delete "${strategyData.basketName ?? 'this strategy'}"?',
//                             textAlign: TextAlign.center,
//                             style: MyntWebTextStyles.body(
//                               dialogContext,
//                               color: resolveThemeColor(dialogContext,
//                                   dark: MyntColors.textPrimaryDark,
//                                   light: MyntColors.textPrimary),
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           MyntPrimaryButton(
//                             label: 'Delete',
//                             isFullWidth: true,
//                             backgroundColor: resolveThemeColor(dialogContext,
//                                 dark: MyntColors.lossDark,
//                                 light: MyntColors.loss),
//                             onPressed: () {
//                               strategy.deleteStrategy(strategyData.uuid ?? '', dialogContext);
//                               Navigator.of(dialogContext).pop();
//                               _navigateBackToDashboard();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showFundSelectionDialog() {
//     final strategy = ref.read(dashboardProvider);
//     strategy.searchController.clear();
//     strategy.Basketsearch("");

//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Fund Selection',
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: const Duration(milliseconds: 200),
//       pageBuilder: (context, animation, secondaryAnimation) {
//         return const SizedBox.shrink();
//       },
//       transitionBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeTransition(
//           opacity: animation,
//           child: Center(
//             child: Material(
//               color: Colors.transparent,
//               child: _FundSelectionDialogContent(
//                 onDone: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showSaveStrategyDialog({bool triggerBacktest = false}) {
//     showGeneralDialog(
//       context: context,
//       barrierDismissible: true,
//       barrierLabel: 'Save Strategy',
//       barrierColor: Colors.black.withOpacity(0.5),
//       transitionDuration: const Duration(milliseconds: 200),
//       pageBuilder: (ctx, animation, secondaryAnimation) {
//         return const SizedBox.shrink();
//       },
//       transitionBuilder: (ctx, animation, secondaryAnimation, child) {
//         return FadeTransition(
//           opacity: animation,
//           child: Center(
//             child: Material(
//               color: Colors.transparent,
//               child: _SaveStrategyDialogContent(
//                 onSaved: () {
//                   Navigator.of(ctx).pop();
//                   if (triggerBacktest) {
//                     _performBacktest(context);
//                   }
//                 },
//                 onBacktest: () {
//                   Navigator.of(ctx).pop();
//                   widget.onBacktest?.call();
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _navigateBackToDashboard() {
//     widget.onBack?.call();
//   }

//   void _navigateToEditStrategy(BuildContext context) {
//     final strategy = ref.read(dashboardProvider);

//     if (strategy.editingStrategy?.data?.first == null) return;

//     final strategyData = strategy.editingStrategy!.data!.first;
//     strategy.strategyNameController.text = strategyData.basketName ?? '';

//     _showSaveStrategyDialog();
//   }
// }

// class _SwipeToDeleteItem extends StatefulWidget {
//   final Key key;
//   final FundListModel fund;
//   final DashboardProvider strategy;
//   final VoidCallback onDelete;
//   final Widget child;

//   const _SwipeToDeleteItem({
//     required this.key,
//     required this.fund,
//     required this.strategy,
//     required this.onDelete,
//     required this.child,
//   }) : super(key: key);

//   @override
//   State<_SwipeToDeleteItem> createState() => _SwipeToDeleteItemState();
// }

// class _SwipeToDeleteItemState extends State<_SwipeToDeleteItem>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;
//   bool _isDeleteVisible = false;
//   bool _hasShownHint = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0.14, 0),
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showHintIfNeeded();
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _showHintIfNeeded() {
//     if (widget.strategy.selectedFunds.length == 1 && !_hasShownHint) {
//       Future.delayed(const Duration(milliseconds: 2000), () {
//         if (mounted && !_hasShownHint) {
//           _showHint();
//         }
//       });
//     }
//   }

//   void _showHint() {
//     if (!_hasShownHint) {
//       setState(() {
//         _hasShownHint = true;
//         _isDeleteVisible = true;
//       });

//       _controller.forward().then((_) {
//         if (mounted) {
//           Future.delayed(const Duration(milliseconds: 1500), () {
//             if (mounted) {
//               _controller.reverse().then((_) {
//                 if (mounted) {
//                   setState(() {
//                     _isDeleteVisible = false;
//                   });
//                 }
//               });
//             }
//           });
//         }
//       });
//     }
//   }

//   void _showDelete() {
//     if (!_isDeleteVisible) {
//       setState(() {
//         _isDeleteVisible = true;
//       });
//       _controller.forward();
//     }
//   }

//   void _hideDelete() {
//     if (_isDeleteVisible) {
//       _controller.reverse().then((_) {
//         if (mounted) {
//           setState(() {
//             _isDeleteVisible = false;
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanUpdate: (details) {
//         if (details.delta.dx > 5 && !_isDeleteVisible) {
//           _showDelete();
//         } else if (details.delta.dx < -5 && _isDeleteVisible) {
//           _hideDelete();
//         }
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: _isDeleteVisible ? MyntColors.loss : Colors.transparent,
//         ),
//         child: Stack(
//           children: [
//             if (_isDeleteVisible)
//               Positioned(
//                 left: 0,
//                 top: 0,
//                 bottom: 0,
//                 child: Container(
//                   width: 50,
//                   decoration: BoxDecoration(
//                     color: MyntColors.loss,
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () {
//                         widget.onDelete();
//                       },
//                       child: const Center(
//                         child: Icon(
//                           Icons.delete_outlined,
//                           color: Colors.white,
//                           size: 22,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             SlideTransition(
//               position: _slideAnimation,
//               child: Container(
//                 color: resolveThemeColor(context,
//                     dark: MyntColors.backgroundColorDark,
//                     light: MyntColors.backgroundColor),
//                 child: widget.child,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _SaveStrategyDialogContent extends ConsumerStatefulWidget {
//   final VoidCallback onSaved;
//   final VoidCallback? onBacktest;

//   const _SaveStrategyDialogContent({
//     required this.onSaved,
//     this.onBacktest,
//   });

//   @override
//   ConsumerState<_SaveStrategyDialogContent> createState() =>
//       _SaveStrategyDialogContentState();
// }

// class _SaveStrategyDialogContentState
//     extends ConsumerState<_SaveStrategyDialogContent> {
//   String? _currentError;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ref.read(dashboardProvider).clearStrategyNameError();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final strategy = ref.watch(dashboardProvider);
//     final dark = isDarkMode(context);
//     const dialogWidth = 380.0;
//     final selectedPlanet =
//         TradingPersonalities.getPersonality(strategy.selectedPersonality);

//     return Container(
//       width: dialogWidth,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: resolveThemeColor(context,
//             dark: MyntColors.backgroundColorDark,
//             light: MyntColors.backgroundColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   strategy.isEditingMode ? 'Update Strategy' : 'Save Strategy',
//                   style: MyntWebTextStyles.title(context,
//                       fontWeight: MyntFonts.semiBold,
//                       darkColor: MyntColors.textPrimaryDark,
//                       lightColor: MyntColors.textPrimary),
//                 ),
//                 Material(
//                   color: Colors.transparent,
//                   shape: const CircleBorder(),
//                   child: InkWell(
//                     onTap: () => Navigator.pop(context),
//                     borderRadius: BorderRadius.circular(20),
//                     child: Padding(
//                       padding: const EdgeInsets.all(6.0),
//                       child: Icon(
//                         Icons.close_rounded,
//                         size: 22,
//                         color: dark
//                             ? MyntColors.textSecondaryDark
//                             : MyntColors.textSecondary,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Content
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // // Planet Avatar
//                 // Center(
//                 //   child: Column(
//                 //     children: [
//                 //       GestureDetector(
//                 //         onTap: () =>
//                 //             _showPlanetSelectionDialog(context, strategy),
//                 //         child: Container(
//                 //           width: 80,
//                 //           height: 80,
//                 //           decoration: BoxDecoration(
//                 //             shape: BoxShape.circle,
//                 //             gradient: LinearGradient(
//                 //               begin: Alignment.topLeft,
//                 //               end: Alignment.bottomRight,
//                 //               colors: [
//                 //                 selectedPlanet.primaryColor,
//                 //                 selectedPlanet.secondaryColor,
//                 //               ],
//                 //             ),
//                 //             boxShadow: [
//                 //               BoxShadow(
//                 //                 color: selectedPlanet.primaryColor
//                 //                     .withOpacity(0.4),
//                 //                 blurRadius: 12,
//                 //                 offset: const Offset(0, 4),
//                 //               ),
//                 //             ],
//                 //           ),
//                 //           child: Center(
//                 //             child: Text(
//                 //               selectedPlanet.emoji,
//                 //               style: const TextStyle(fontSize: 32),
//                 //             ),
//                 //           ),
//                 //         ),
//                 //       ),
//                 //       const SizedBox(height: 8),
//                 //       Text(
//                 //         selectedPlanet.name,
//                 //         style: MyntWebTextStyles.body(context,
//                 //             fontWeight: MyntFonts.medium,
//                 //             darkColor: MyntColors.textPrimaryDark,
//                 //             lightColor: MyntColors.textPrimary),
//                 //       ),
//                 //       const SizedBox(height: 4),
//                 //       Text(
//                 //         selectedPlanet.description,
//                 //         style: MyntWebTextStyles.para(context,
//                 //             fontWeight: MyntFonts.regular,
//                 //             darkColor: MyntColors.textSecondaryDark,
//                 //             lightColor: MyntColors.textSecondary),
//                 //       ),
//                 //       const SizedBox(height: 20),
//                 //     ],
//                 //   ),
//                 // ),
//                 // Strategy Name
//                 Text(
//                   'Enter a name for your strategy',
//                   style: MyntWebTextStyles.body(context,
//                       fontWeight: MyntFonts.regular,
//                       darkColor: MyntColors.textPrimaryDark,
//                       lightColor: MyntColors.textPrimary),
//                 ),
//                 const SizedBox(height: 12),
//                 TextFormField(
//                   controller: strategy.strategyNameController,
//                   onChanged: (value) {
//                     if (strategy.strategyNameError != null) {
//                       strategy.clearStrategyNameError();
//                     }
//                     if (_currentError != null) {
//                       setState(() {
//                         _currentError = null;
//                       });
//                     }
//                   },
//                   inputFormatters: [
//                     TextInputFormatter.withFunction((oldValue, newValue) {
//                       if (newValue.text.isNotEmpty) {
//                         String filteredText = newValue.text
//                             .replaceAll(RegExp(r'[^\w\s\-\.]'), '');
//                         String capitalizedText = filteredText.isNotEmpty
//                             ? filteredText[0].toUpperCase() +
//                                 (filteredText.length > 1
//                                     ? filteredText.substring(1)
//                                     : '')
//                             : '';
//                         return TextEditingValue(
//                           text: capitalizedText,
//                           selection: TextSelection.collapsed(
//                               offset: capitalizedText.length),
//                         );
//                       }
//                       return newValue;
//                     }),
//                   ],
//                   style: MyntWebTextStyles.body(context,
//                       fontWeight: MyntFonts.regular,
//                       darkColor: MyntColors.textPrimaryDark,
//                       lightColor: MyntColors.textPrimary),
//                   decoration: InputDecoration(
//                     fillColor:
//                         dark ? colors.darkGrey : const Color(0xffF1F3F8),
//                     filled: true,
//                     hintText: 'Strategy name',
//                     hintStyle: MyntWebTextStyles.para(context,
//                         fontWeight: MyntFonts.regular,
//                         color: resolveThemeColor(context,
//                                 dark: MyntColors.textSecondaryDark,
//                                 light: MyntColors.textSecondary)
//                             .withOpacity(0.4)),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 10),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: MyntColors.primary),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     disabledBorder: InputBorder.none,
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: MyntColors.primary),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     border: OutlineInputBorder(
//                       borderSide: BorderSide.none,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                 ),
//                 if (strategy.strategyNameError != null) ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     strategy.strategyNameError!,
//                     style: MyntWebTextStyles.para(context,
//                         fontWeight: MyntFonts.regular,
//                         color: resolveThemeColor(context,
//                             dark: MyntColors.lossDark,
//                             light: MyntColors.loss)),
//                   ),
//                 ],
//                 if (_currentError != null) ...[
//                   const SizedBox(height: 8),
//                   Text(
//                     _currentError!,
//                     style: MyntWebTextStyles.para(context,
//                         fontWeight: MyntFonts.regular, color: Colors.red),
//                   ),
//                 ],
//                 const SizedBox(height: 24),
//                 // Save button
//                 SizedBox(
//                   width: double.infinity,
//                   height: 45,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       if (strategy.strategyNameController.text
//                           .trim()
//                           .isNotEmpty) {
//                         try {
//                           if (strategy.isEditingMode) {
//                             await strategy.updateStrategy(context);
//                           } else {
//                             await ref
//                                 .read(dashboardProvider)
//                                 .saveStrategy(
//                                     strategy.strategyNameController.text.trim(),
//                                     context);
//                           }
//                           if (mounted) {
//                             widget.onSaved();
//                           }
//                         } catch (e) {
//                           if (mounted) {
//                             Navigator.of(context).pop();
//                             error(context,
//                                 'Failed to save strategy. Please try again.');
//                           }
//                         }
//                       } else {
//                         setState(() {
//                           _currentError = 'Please enter a strategy name.';
//                         });
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: MyntColors.primary,
//                       disabledBackgroundColor: resolveThemeColor(context,
//                               dark: MyntColors.textSecondaryDark,
//                               light: MyntColors.textSecondary)
//                           .withOpacity(0.3),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: Text(
//                       'Save',
//                       style: MyntWebTextStyles.body(context,
//                           fontWeight: MyntFonts.semiBold,
//                           color: MyntColors.textWhite),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showPlanetSelectionDialog(
//       BuildContext context, DashboardProvider strategy) {
//     showDialog(
//       context: context,
//       builder: (ctx) => Dialog(
//         backgroundColor: resolveThemeColor(context,
//             dark: MyntColors.backgroundColorDark,
//             light: MyntColors.backgroundColor),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Container(
//           width: 500,
//           height: 500,
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               Text(
//                 'Choose Your Planet',
//                 style: MyntWebTextStyles.title(context,
//                     fontWeight: MyntFonts.medium,
//                     darkColor: MyntColors.textPrimaryDark,
//                     lightColor: MyntColors.textPrimary),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Select a planet that represents your investment strategy',
//                 style: MyntWebTextStyles.para(context,
//                     fontWeight: MyntFonts.regular,
//                     darkColor: MyntColors.textSecondaryDark,
//                     lightColor: MyntColors.textSecondary),
//               ),
//               const SizedBox(height: 24),
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     mainAxisSpacing: 20,
//                     crossAxisSpacing: 20,
//                     childAspectRatio: 0.8,
//                   ),
//                   itemCount: TradingPersonalities.personalities.length,
//                   itemBuilder: (context, index) {
//                     final planet = TradingPersonalities.personalities[index];
//                     final isSelected =
//                         planet.type == strategy.selectedPersonality;

//                     return GestureDetector(
//                       onTap: () {
//                         strategy.updateSelectedPersonality(planet.type);
//                         Navigator.pop(ctx);
//                       },
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   planet.primaryColor,
//                                   planet.secondaryColor,
//                                 ],
//                               ),
//                               border: isSelected
//                                   ? Border.all(
//                                       color: resolveThemeColor(context,
//                                           dark: MyntColors.primaryDark,
//                                           light: MyntColors.primary),
//                                       width: 3,
//                                     )
//                                   : null,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color:
//                                       planet.primaryColor.withOpacity(0.3),
//                                   blurRadius: isSelected ? 12 : 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Center(
//                               child: Text(
//                                 planet.emoji,
//                                 style: TextStyle(
//                                   fontSize: isSelected ? 32 : 28,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             planet.name,
//                             style: MyntWebTextStyles.para(context,
//                                 fontWeight: isSelected
//                                     ? MyntFonts.medium
//                                     : MyntFonts.regular,
//                                 color: isSelected
//                                     ? resolveThemeColor(context,
//                                         dark: MyntColors.primaryDark,
//                                         light: MyntColors.primary)
//                                     : resolveThemeColor(context,
//                                         dark: MyntColors.textSecondaryDark,
//                                         light: MyntColors.textSecondary)),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FundSelectionDialogContent extends ConsumerStatefulWidget {
//   final VoidCallback onDone;

//   const _FundSelectionDialogContent({required this.onDone});

//   @override
//   ConsumerState<_FundSelectionDialogContent> createState() =>
//       _FundSelectionDialogContentState();
// }

// class _FundSelectionDialogContentState
//     extends ConsumerState<_FundSelectionDialogContent> {
//   String selectedFilter = 'All';

//   List<FundListModel> getFilteredFunds(DashboardProvider strategy) {
//     List<FundListModel> funds = (strategy.basketSearchItems ?? [])
//         .map((item) => FundListModel(
//               name: item.name ?? "Unknown Scheme",
//               schemeName: item.schemeName ?? "Unknown Scheme",
//               type: _getFundTypeFromScheme(item.schemeType),
//               fiveYearCAGR: 0.0,
//               threeYearCAGR: 0.0,
//               aum: double.tryParse(item.aUM ?? "0") ?? 0.0,
//               sharpe: 0.0,
//               aMCCode: item.aMCCode,
//               isin: item.iSIN,
//               schemeCode: item.schemeCode,
//               minimumPurchaseAmount: double.tryParse(item.minimumPurchaseAmount ?? "100") ?? 100.0,
//               nav: double.tryParse(item.nETASSETVALUE ?? "0") ?? 0.0,
//             ))
//         .toList();

//     if (selectedFilter != 'All') {
//       funds = funds.where((fund) => fund.type == selectedFilter).toList();
//     }

//     if (strategy.searchController.text.isNotEmpty) {
//       funds = funds
//           .where((fund) => fund.name
//               .toLowerCase()
//               .contains(strategy.searchController.text.toLowerCase()))
//           .toList();
//     }

//     return funds;
//   }

//   String _getFundTypeFromScheme(String? schemeType) {
//     if (schemeType == null) return "Equity";
//     final type = schemeType.toLowerCase();
//     if (type.contains("debt")) return "Debt";
//     if (type.contains("hybrid")) return "Hybrid";
//     if (type.contains("commodity")) return "Commodities";
//     return "Equity";
//   }

//   String _capitalizeEachWord(String text) {
//     if (text.isEmpty) return text;
//     return text.split(' ').map((word) {
//       if (word.isEmpty) return word;
//       return word[0].toUpperCase() + word.substring(1).toLowerCase();
//     }).join(' ');
//   }

//   @override
//   Widget build(BuildContext context) {
//     final strategy = ref.watch(dashboardProvider);
//     final dark = isDarkMode(context);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final dialogWidth = screenWidth * 0.35 < 400 ? 400.0 : screenWidth * 0.35;
//     final dialogHeight = screenHeight * 0.7;

//     return Container(
//       width: dialogWidth,
//       height: dialogHeight,
//       decoration: BoxDecoration(
//         color: resolveThemeColor(context,
//             dark: MyntColors.backgroundColorDark,
//             light: MyntColors.backgroundColor),
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header with search and close
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
//             child: Row(
//               children: [
//                 // Search bar
//                 Expanded(
//                   child: Container(
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: resolveThemeColor(context,
//                           dark: colors.searchBgDark,
//                           light: colors.searchBg),
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: Row(
//                       children: [
//                         const SizedBox(width: 12),
//                         Icon(
//                           Icons.search,
//                           size: 18,
//                           color: resolveThemeColor(context,
//                               dark: MyntColors.textSecondaryDark,
//                               light: MyntColors.textSecondary),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: TextFormField(
//                             controller: strategy.searchController,
//                             style: MyntWebTextStyles.body(context,
//                                 fontWeight: MyntFonts.regular,
//                                 darkColor: MyntColors.textPrimaryDark,
//                                 lightColor: MyntColors.textPrimary),
//                             decoration: InputDecoration(
//                               isCollapsed: true,
//                               border: InputBorder.none,
//                               enabledBorder: InputBorder.none,
//                               focusedBorder: InputBorder.none,
//                               hintText: "Search funds...",
//                               hintStyle: MyntWebTextStyles.body(context,
//                                   fontWeight: MyntFonts.regular,
//                                   darkColor: MyntColors.textSecondaryDark
//                                       .withOpacity(0.4),
//                                   lightColor: MyntColors.textSecondary
//                                       .withOpacity(0.4)),
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 0, vertical: 12),
//                             ),
//                             onChanged: (value) {
//                               strategy.Basketsearch(value);
//                             },
//                           ),
//                         ),
//                         if (strategy.searchController.text.isNotEmpty)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 8),
//                             child: Material(
//                               color: Colors.transparent,
//                               shape: const CircleBorder(),
//                               child: InkWell(
//                                 customBorder: const CircleBorder(),
//                                 onTap: () {
//                                   strategy.searchController.clear();
//                                   strategy.Basketsearch("");
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Icon(
//                                     Icons.close,
//                                     size: 16,
//                                     color: resolveThemeColor(context,
//                                         dark: MyntColors.textSecondaryDark,
//                                         light: MyntColors.textSecondary),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 4),
//                 // Done / Close button
//                 if (strategy.selectedFunds.isNotEmpty)
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(5),
//                       onTap: () {
//                         strategy.searchController.clear();
//                         strategy.Basketsearch("");
//                         widget.onDone();
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 8),
//                         child: Text(
//                           'Done',
//                           style: MyntWebTextStyles.body(context,
//                               fontWeight: MyntFonts.semiBold,
//                               color: MyntColors.primary),
//                         ),
//                       ),
//                     ),
//                   )
//                 else
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       customBorder: const CircleBorder(),
//                       onTap: () {
//                         strategy.searchController.clear();
//                         strategy.Basketsearch("");
//                         widget.onDone();
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Icon(
//                           Icons.close,
//                           size: 20,
//                           color: resolveThemeColor(context,
//                               dark: MyntColors.textSecondaryDark,
//                               light: MyntColors.textSecondary),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           // Filter tabs
//           Container(
//             height: 36,
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: _buildFilterTabs(),
//           ),
//           const Divider(height: 1),
//           // Fund list
//           Expanded(
//             child: _buildFundList(strategy),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterTabs() {
//     final filterList = ['All', 'Equity', 'Debt', 'Hybrid', 'Commodities'];

//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       physics: const BouncingScrollPhysics(),
//       itemCount: filterList.length,
//       itemBuilder: (context, index) {
//         final filter = filterList[index];
//         final isSelected = selectedFilter == filter;

//         return Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () {
//               setState(() {
//                 selectedFilter = filter;
//               });
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               alignment: Alignment.center,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Text(
//                     filter,
//                     style: MyntWebTextStyles.para(context,
//                         fontWeight: MyntFonts.semiBold,
//                         color: isSelected
//                             ? MyntColors.primary
//                             : resolveThemeColor(context,
//                                 dark: MyntColors.textSecondaryDark,
//                                 light: MyntColors.textSecondary)),
//                   ),
//                   const SizedBox(height: 6),
//                   AnimatedContainer(
//                     duration: const Duration(milliseconds: 250),
//                     curve: Curves.easeInOut,
//                     height: 2,
//                     width: isSelected ? 40 : 0,
//                     decoration: BoxDecoration(
//                       color: MyntColors.primary,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFundList(DashboardProvider strategy) {
//     final funds = getFilteredFunds(strategy);

//     if (funds.isEmpty) {
//       return const NoDataFoundWeb(
//         title: 'No funds found',
//         subtitle: 'Try a different search term or category',
//         iconSize: 48,
//         primaryEnabled: false,
//         secondaryEnabled: false,
//       );
//     }

//     return ListView.separated(
//       physics: const ClampingScrollPhysics(),
//       separatorBuilder: (context, index) => Divider(
//         height: 1,
//         color: resolveThemeColor(context,
//             dark: MyntColors.cardBorderDark,
//             light: MyntColors.cardBorder),
//       ),
//       itemCount: funds.length,
//       itemBuilder: (context, index) {
//         final fund = funds[index];
//         final isSelected = strategy.selectedFunds.any((f) => f.name == fund.name);

//         return _buildFundItem(fund, isSelected, strategy);
//       },
//     );
//   }

//   Widget _buildFundItem(
//       FundListModel fund, bool isSelected, DashboardProvider strategy) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () {
//           if (isSelected) {
//             strategy.removeFundFromStrategy(fund);
//           } else {
//             strategy.addFundToStrategy(fund);
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           child: Row(
//             children: [
//               // Fund icon
//               CircleAvatar(
//                 radius: 18,
//                 backgroundColor: resolveThemeColor(context,
//                     dark: MyntColors.backgroundColorDark,
//                     light: MyntColors.backgroundColor),
//                 child: ClipOval(
//                   child: Image.network(
//                     "https://v3.mynt.in/mfapi/static/images/mf/${fund.aMCCode ?? ""}.png",
//                     width: 36,
//                     height: 36,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Icon(
//                         Icons.account_balance,
//                         size: 18,
//                         color: resolveThemeColor(context,
//                             dark: MyntColors.textSecondaryDark,
//                             light: MyntColors.textSecondary),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               // Fund details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _capitalizeEachWord(fund.name),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: MyntWebTextStyles.body(context,
//                           fontWeight: MyntFonts.medium,
//                           darkColor: MyntColors.textPrimaryDark,
//                           lightColor: MyntColors.textPrimary),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       fund.type.toUpperCase(),
//                       style: MyntWebTextStyles.para(context,
//                           fontWeight: MyntFonts.medium,
//                           darkColor: MyntColors.textSecondaryDark,
//                           lightColor: MyntColors.textSecondary),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // Bookmark icon
//               Material(
//                 color: Colors.transparent,
//                 shape: const CircleBorder(),
//                 child: InkWell(
//                   customBorder: const CircleBorder(),
//                   onTap: () {
//                     if (isSelected) {
//                       strategy.removeFundFromStrategy(fund);
//                     } else {
//                       strategy.addFundToStrategy(fund);
//                     }
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.all(6),
//                     child: SvgPicture.asset(
//                       isSelected
//                           ? assets.bookmarkIcon
//                           : assets.bookmarkedIcon,
//                       color: isSelected
//                           ? MyntColors.primary
//                           : colors.colorGrey,
//                       width: 20,
//                       height: 20,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
