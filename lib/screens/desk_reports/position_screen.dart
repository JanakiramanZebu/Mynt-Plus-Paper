import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/provider/index_list_provider.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/custom_drag_handler.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/splash_loader.dart';
import 'package:mynt_plus/utils/no_emoji_inputformatter.dart';

import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/custom_text_form_field.dart';

class PositionScreen extends StatefulWidget {
  final String ddd;
  const PositionScreen({super.key, required this.ddd});

  @override
  _PositionScreen createState() => _PositionScreen();
}

class _PositionScreen extends State<PositionScreen>
    with SingleTickerProviderStateMixin {
  
  // Search and sort state variables
  bool _showSearch = false;
  String _currentSortType = "position";
  bool _scripAscending = true;
  bool _priceAscending = true;
  bool _qtyAscending = true;
  bool _pnlAscending = true;
  bool _positionFilter = false;
  final TextEditingController _searchController = TextEditingController();
  
  // Search query
  String _searchQuery = "";
  

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get filtered and sorted positions
  List<dynamic> _getFilteredPositions(LDProvider ledgerprovider) {
    if (ledgerprovider.positiondata?.data == null) return [];
    
    List<dynamic> positions = List.from(ledgerprovider.positiondata!.data!);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      positions = positions.where((position) {
        final symbol = position.tsym?.toString().toLowerCase() ?? '';
        final exchange = position.exch?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        
        return symbol.contains(query) || exchange.contains(query);
      }).toList();
    }
    
    // Apply position filter (Open/Close)
    if (_currentSortType == "position") {
      if (_positionFilter) {
        // "Open Position" - show closed positions (zero quantity) at the top
        positions.sort((a, b) {
          int aQty = int.tryParse(a.netqty?.toString() ?? '0') ?? 0;
          int bQty = int.tryParse(b.netqty?.toString() ?? '0') ?? 0;
          
          // If both are closed (zero), maintain original order
          if (aQty == 0 && bQty == 0) return 0;
          // If both are open (non-zero), maintain original order
          if (aQty != 0 && bQty != 0) return 0;
          // If a is closed (zero), move it to top
          if (aQty == 0) return -1;
          // If b is closed (zero), move it to top
          if (bQty == 0) return 1;
          // Fallback to quantity comparison
          return aQty.compareTo(bQty);
        });
      } else {
        // "Close Position" - show closed positions (zero quantity) at the bottom
        positions.sort((a, b) {
          int aQty = int.tryParse(a.netqty?.toString() ?? '0') ?? 0;
          int bQty = int.tryParse(b.netqty?.toString() ?? '0') ?? 0;
          
          // If both are closed (zero), maintain original order
          if (aQty == 0 && bQty == 0) return 0;
          // If both are open (non-zero), maintain original order
          if (aQty != 0 && bQty != 0) return 0;
          // If a is closed (zero), move it to bottom
          if (aQty == 0) return 1;
          // If b is closed (zero), move it to bottom
          if (bQty == 0) return -1;
          // Fallback to quantity comparison
          return aQty.compareTo(bQty);
        });
      }
    }
    
    // Apply sorting
    if (_currentSortType.isNotEmpty) {
      positions.sort((a, b) {
        int comparison = 0;
        
        switch (_currentSortType) {
          case "scrip":
            final aSymbol = a.tsym?.toString() ?? '';
            final bSymbol = b.tsym?.toString() ?? '';
            comparison = aSymbol.compareTo(bSymbol);
            break;
          case "price":
            final aLtp = double.tryParse(a.ltp?.toString() ?? '0') ?? 0;
            final bLtp = double.tryParse(b.ltp?.toString() ?? '0') ?? 0;
            comparison = aLtp.compareTo(bLtp);
            break;
          case "qty":
            final aQty = double.tryParse(a.netqty?.toString() ?? '0') ?? 0;
            final bQty = double.tryParse(b.netqty?.toString() ?? '0') ?? 0;
            comparison = aQty.compareTo(bQty);
            break;
          case "pnl":
            final aPnl = double.tryParse(a.rpnl?.toString() ?? '0') ?? 0;
            final bPnl = double.tryParse(b.rpnl?.toString() ?? '0') ?? 0;
            comparison = aPnl.compareTo(bPnl);
            break;
        }
        
        // Apply sort direction
        bool isAscending = true;
        switch (_currentSortType) {
          case "scrip":
            isAscending = _scripAscending;
            break;
          case "price":
            isAscending = _priceAscending;
            break;
          case "qty":
            isAscending = _qtyAscending;
            break;
          case "pnl":
            isAscending = _pnlAscending;
            break;
        }
        
        return isAscending ? comparison : -comparison;
      });
    }
    
    return positions;
  }

  @override
  Widget build(BuildContext context) {

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.watch(themeProvider);

      final ledgerprovider = ref.watch(ledgerProvider);
      Future<void> _refresh() async {
        await Future.delayed(Duration(milliseconds: 100)); // simulate refresh delay
        ledgerprovider.fetchposition(context);
      }

      double realised = 0.0;
      double realisedmtm = 0.0;
      int closed = 0;
      // int negative = 0;
      // int positive = 0;
      double unrealised = 0.0;
      double unrealisedmtm = 0.0;
      if (ledgerprovider.positiondata?.data != null) {
        for (var i = 0; i < ledgerprovider.positiondata!.data!.length; i++) {
          if (double.tryParse(
                      ledgerprovider.positiondata!.data![i].netqty.toString())!
                  .toInt() ==
              0) {
            final rpnl = double.tryParse(
                    ledgerprovider.positiondata!.data![i].rpnl.toString()) ??
                0;
            realised += double.parse(
                rpnl.toStringAsFixed(2)); // rounds to 2 decimal places

            final rmtm = double.tryParse(
                    ledgerprovider.positiondata!.data![i].rmtm.toString()) ??
                0.0;
            realisedmtm +=
                double.parse(rmtm.toStringAsFixed(2)); // optional rounding
            ;
            closed = closed + 1;
          } else {
            final rpnl = double.tryParse(
                    ledgerprovider.positiondata!.data![i].rpnl.toString()) ??
                0.0;
            unrealised +=
                double.parse(rpnl.toStringAsFixed(2)); // optional rounding

            final rmtm = double.tryParse(
                    ledgerprovider.positiondata!.data![i].rmtm.toString()) ??
                0.0;
            unrealisedmtm +=
                double.parse(rmtm.toStringAsFixed(2)); // Optional rounding
          }

          // if (double.tryParse(
          //             ledgerprovider.positiondata!.data![i].rpnl.toString())!
          //         .toInt() >
          //     0) {
          //   positive = positive + 1;
          // } else {
          //   negative = negative + 1;
          // }
        }
      }
      // String tdebit = ledgerprovider.ledgerAllData?.drAmt ?? '0.0';
      // String tcredit = ledgerprovider.ledgerAllData?.crAmt ?? '0.0';

      return RefreshIndicator(
        onRefresh: _refresh,
        child: WillPopScope(
          onWillPop: () async {
            ledgerprovider.falseloader('ledger');
            ledgerprovider.settime = '';
            ledgerprovider.ccancelalltimes();
            Navigator.pop(context);
            // print('Timer before cancel: ${ledgerprovider.timer}');
            // ledgerprovider.timer?.cancel();
            // print('Timer before cancel 2: ${ledgerprovider.timer}');

            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              // automaticallyImplyLeading: false,
              leadingWidth: 41,
              titleSpacing: 6,
              centerTitle: false,
              leading: Material(
                   color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
                  child: InkWell(
                      customBorder: const CircleBorder(),
              splashColor: theme.isDarkMode
                                                ? colors.splashColorDark
                                                : colors.splashColorLight,
                                            highlightColor: theme.isDarkMode
                                                ? colors.highlightDark
                                                : colors.highlightLight,
                      onTap: () {
                        // Don't clear data when leaving screen, just reset to default segment
                        // Use switchToSegment to ensure proper data handling
                        ledgerprovider.falseloader('ledger');
                  ledgerprovider.settime = '';
                  ledgerprovider.timer?.cancel();
                  Navigator.pop(context);
                      },
                      child:  Container(
                  width: 44, // Increased touch area
                  height: 44,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_outlined,
                    size: 18,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                  ),
                ),),
                ),
              elevation: 0.2,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget.titleText(
                    text: "Positions-(Beta)",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1),
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 8.0),
                  //   child: TextWidget.captionText(
                  //       text: "Last update : ${ledgerprovider.timedis}",
                  //       textOverflow: TextOverflow.ellipsis,
                  //       theme: theme.isDarkMode,
                  //       fw: 1),
                  // ),
                ],
              ),
              // leading: InkWell(
              //   onTap: () {

              //   },
              //   child: Icon(Icons.ios_share)),
            ),
            body: ledgerprovider.positionloading ? Center(
                      child: Container(
                        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                        child: CircularLoaderImage(),
                      ),
                    ) :
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text("${ddd}")
                // Padding(
                //     padding: EdgeInsets.only(left: 4.0, top: 10.0),
                //     child: Text(
                //       "Financial activities through debits and credits ",
                //       style: textStyle(colors.colorBlack, 14, FontWeight.w600),
                //     )),
                // Header with P&L info - matching portfolio screen design
                if(ledgerprovider.positiondata?.data?.isNotEmpty ?? false)
                _PositionHeaderSection(
                  theme: theme,
                  ledgerprovider: ledgerprovider,
                  realised: realised,
                  realisedmtm: realisedmtm,
                  unrealised: unrealised,
                  unrealisedmtm: unrealisedmtm,
                ),
            
                    // Search section - matching portfolio screen design
                    if(ledgerprovider.positiondata?.data?.isNotEmpty ?? false)
                    if (!_showSearch) ...[
                      _buildSearchSection(context, theme, ledgerprovider), ]
                    else if (_showSearch) ...[
                      _buildSearchBar(context, theme, ledgerprovider),
                    ],
            
                // Padding(
                //   padding: const EdgeInsets.only(left: 30 , right: 30),
                //   child: Row(
                //     children: [
                //       // Static Column
                //       Column(
                //         children: [
                //           Container(
                //             margin: EdgeInsets.only(top: 20),
                //             width: 100,
                //             color: Colors
                //                 .cardbgrey, // Header cell for the static column
                //             padding: EdgeInsets.all(8.0),
                //             child: Text(
                //               'Exchange',
                //               style: TextStyle(fontWeight: FontWeight.bold),
                //             ),
                //           ),
                //           for (var item in ledgerprovider.ledgerAllData!.fullStat!)
                //             Container(
                //               width: 100, // Fixed width for the static column
                //               height: 50,
            
                //               padding: EdgeInsets.all(8.0),
                //               decoration: BoxDecoration(
                //                 border: Border.all(color: const Color.fromARGB(255, 224, 224, 224)),
                //               ),
                //               child: Text("${item.cOCD}",
                //               style: textStyle(Colors.black, 14, FontWeight.w600),
                //               ),
                //             ),
                //         ],
                //       ),
                //       // Scrollable Content
            
                //       Expanded(
                //         child: SingleChildScrollView(
                //           scrollDirection: Axis.horizontal,
                //           child: Column(
                //             children: [
                //               // Header Row for the scrollable content
                //               Row(
                //                 children: [
                //                   for (int i = 0; i < Header.length; i++)
                //                     Container(
                //                        margin: EdgeInsets.only(top: 20),
                //                       width: i == 4 ? 275 : 100, // Column width
            
                //                       padding: EdgeInsets.all(8.0),
                //                       color: Color(0xFFEEEEEE),
                //                       child: Text(
                //                         '${Header[i]}',
                //                         style:
                //                             TextStyle(fontWeight: FontWeight.bold),
                //                       ),
                //                     ),
                //                 ],
                //               ),
                //               // Data Rows for the scrollable content
                //               for (int rowIndex = 0;
                //                   rowIndex <
                //                       ledgerprovider
                //                           .ledgerAllData!.fullStat!.length;
                //                   rowIndex++)
                //                 Row(
                //                   children: [
                //                     for (int colIndex = 0; colIndex < 5; colIndex++)
                //                       Container(
                //                          width: colIndex == 4 ? 275 : 100,  // Column width
                //                         height: 50,
                //                         padding: EdgeInsets.all(8.0),
                //                         decoration: BoxDecoration(
                //                           border: Border.all(color: Color.fromARGB(255, 224, 224, 224)),
                //                         ),
                //                         child: Text(colIndex == 0 ? dateFormatChangeForLedger(ledgerprovider
                //                             .tablearray[rowIndex][colIndex]) : ledgerprovider
                //                             .tablearray[rowIndex][colIndex] ,
                //                             textAlign: colIndex == 1 ||colIndex == 2 || colIndex == 3  ? TextAlign.right : TextAlign.start ,
                //                             ) ,
                //                         //  child: Text(  ledgerprovider
                //                         //     .tablearray[rowIndex][colIndex] ) ,
                //                       ),
                //                   ],
                //                 ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Position list section
                _getFilteredPositions(ledgerprovider).isEmpty
                    ?  Expanded(
                      child: Center(
                          child: NoDataFound(
                              title: "No positions Found",
                              subtitle: "There's nothing here yet. Buy some stocks to see them here.",
                              secondaryLabel: "Explore",
                              secondaryEnabled: true,
                              onSecondary: () {
                                ref.read(indexListProvider).bottomMenu(1, context);
                              },
                              tipText: '',
                            ),
        ))
                    : Expanded(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ListView.separated(
                            physics: ScrollPhysics(),
                            itemCount: _getFilteredPositions(ledgerprovider).length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final val = _getFilteredPositions(ledgerprovider)[index];
            
                              return _PositionItem(
                                position: val,
                                theme: theme,
                                ledgerprovider: ledgerprovider,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Divider(
                                height: 1,
                                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
                              );
                            },
                          ),
                        ),
                      )
                                      ],
                                    ),
          ),
        ),
      );
    });
  }

  void _showBottomSheet(BuildContext context, Widget bottomSheet) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        context: context,
        isScrollControlled: true,
        builder: (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: bottomSheet));
  }

  // Header section with P&L info - matching portfolio screen card design
  Widget _PositionHeaderSection({
    required ThemesProvider theme,
    required LDProvider ledgerprovider,
    required double realised,
    required double realisedmtm,
    required double unrealised,
    required double unrealisedmtm,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 8.0, right: 8.0, bottom: 15),
      child: Column(
        children: [
          // Main P&L display with switch
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                TextWidget.subText(
                  text: !ledgerprovider.pnlrmtm ? "Total MTM" : "Total P&L",
                                                    theme: theme.isDarkMode,
                                                    color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                  fw: 0),
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.highlightDark
                      : colors.highlightLight,
                  onTap: () {
                    ledgerprovider.clickchangemtmandpnl = !ledgerprovider.pnlrmtm;
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(
                      assets.switchIcon,
                      width: 20,
                      height: 20,
                    ),
                  ),
                                            ),
                                          ),
                                        ],
                                      ),
          const SizedBox(height: 4),
          // Main P&L value
          _buildValueText(
            ledgerprovider.pnlrmtm == true 
                ? (realised + unrealised).toStringAsFixed(2)
                : (realisedmtm + unrealisedmtm).toStringAsFixed(2),
            _getValueColor(
              ledgerprovider.pnlrmtm == true 
                  ? (realised + unrealised).toStringAsFixed(2)
                  : (realisedmtm + unrealisedmtm).toStringAsFixed(2),
              theme
            )
          ),
          const SizedBox(height: 16),
          // Detailed breakdown in card format
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //                               color: theme.isDarkMode
          //         ? const Color(0xffB5C0CF).withOpacity(.15)
          //         : const Color(0xffF1F3F8),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Column(
          //                               children: [
          //       // Realised and Unrealised row
          //                                 Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //                                   children: [
          //                                     TextWidget.subText(
          //                     text: "${ledgerprovider.pnlrmtm == true ? "Realised" : "Realised MTM"}",
          //                                         color: theme.isDarkMode
          //                                             ? colors.textSecondaryDark
          //                         : colors.textSecondaryLight,
          //                     textOverflow: TextOverflow.ellipsis,
          //                                         theme: theme.isDarkMode,
          //                                         fw: 0),
          //                 const SizedBox(height: 4),
          //                 TextWidget.headText(
          //                     text: "₹ ${ledgerprovider.pnlrmtm == true ? realised.toStringAsFixed(2) : realisedmtm.toStringAsFixed(2)}",
          //                     textOverflow: TextOverflow.ellipsis,
          //                     color: ledgerprovider.pnlrmtm == true
          //                         ? realised > 0
          //                             ? theme.isDarkMode ? colors.profitDark : colors.profitLight
          //                             : realised < 0
          //                                 ? theme.isDarkMode ? colors.lossDark : colors.lossLight
          //                                 : theme.isDarkMode
          //                                     ? colors.colorWhite
          //                                     : colors.colorBlack
          //                         : realisedmtm > 0
          //                             ? theme.isDarkMode ? colors.profitDark : colors.profitLight
          //                             : realisedmtm < 0
          //                                 ? theme.isDarkMode ? colors.lossDark : colors.lossLight
          //                                 : theme.isDarkMode
          //                                             ? colors.colorWhite
          //                                             : colors.colorBlack,
          //                                         theme: theme.isDarkMode,
          //                     fw: 0),
          //               ],
          //             ),
          //           ),
          //           const SizedBox(width: 16),
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.end,
          //                                     children: [
          //                                       TextWidget.subText(
          //                     text: "${ledgerprovider.pnlrmtm == true ? "Unrealised" : "Unrealised MTM"}",
          //                     color: theme.isDarkMode
          //                         ? colors.textSecondaryDark
          //                         : colors.textSecondaryLight,
          //                     textOverflow: TextOverflow.ellipsis,
          //                                           theme: theme.isDarkMode,
          //                                           fw: 0),
          //                 const SizedBox(height: 4),
          //                 TextWidget.headText(
          //                     text: "₹ ${ledgerprovider.pnlrmtm == true ? unrealised.toStringAsFixed(2) : unrealisedmtm.toStringAsFixed(2)}",
          //                     color: ledgerprovider.pnlrmtm == true
          //                         ? unrealised > 0
          //                             ? theme.isDarkMode ? colors.profitDark : colors.profitLight
          //                             : unrealised < 0
          //                                 ? theme.isDarkMode ? colors.lossDark : colors.lossLight
          //                                 : theme.isDarkMode
          //                                     ? colors.colorWhite
          //                                     : colors.colorBlack
          //                         : unrealisedmtm > 0
          //                             ? theme.isDarkMode ? colors.profitDark : colors.profitLight
          //                             : unrealisedmtm < 0
          //                                 ? theme.isDarkMode ? colors.lossDark : colors.lossLight
          //                                 : theme.isDarkMode
          //                                               ? colors.colorWhite
          //                                               : colors.colorBlack,
          //                     textOverflow: TextOverflow.ellipsis,
          //                                           theme: theme.isDarkMode,
          //                     fw: 0),
          //                                     ],
          //                                   ),
          //                                 ),
          //                               ],
          //                             ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildValueText(String value, Color color) {
    return TextWidget.headText(
        text: "₹$value", fw: 0, theme: false, color: color);
  }

  Color _getValueColor(String value, ThemesProvider theme) {
    if (value.startsWith("-")) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else if (value == "0.00") {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    } else {
      return theme.isDarkMode ? colors.profitDark : colors.profitLight;
    }
  }


  // Search section - matching portfolio screen design
  Widget _buildSearchSection(BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 8),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                                    Padding(
                    padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                        children: [
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            splashColor: theme.isDarkMode
                                ? colors.splashColorDark
                                : colors.splashColorLight,
                            highlightColor: theme.isDarkMode
                                ? colors.highlightDark
                                : colors.highlightLight,
                            onTap: () {
                              Future.delayed(const Duration(milliseconds: 150), () {
                                _showSearchBar(context, theme, ledgerprovider);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                assets.searchIcon,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                width: 20,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            splashColor: theme.isDarkMode
                                ? colors.splashColorDark
                                : colors.splashColorLight,
                            highlightColor: theme.isDarkMode
                                ? colors.highlightDark
                                : colors.highlightLight,
                            onTap: () async {
                              Future.delayed(const Duration(milliseconds: 150), () {
                                _showFilterBottomSheet(context, theme, ledgerprovider);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                assets.filterLinesDark,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  //                         Row(
                  //                           children: [
                  //                             TextWidget.subText(
                  //       text: "P&L",
                  //                                 theme: theme.isDarkMode,
                  //       color: theme.isDarkMode
                  //           ? colors.textSecondaryDark
                  //           : colors.textSecondaryLight,
                  //                                 fw: 0),
                  //     const SizedBox(width: 6),
                  //     CustomSwitch(
                  //         onChanged: (bool value) {
                  //           ledgerprovider.clickchangemtmandpnl = value;
                  //         },
                  //         color: Color.fromARGB(255, 211, 211, 211),
                  //         value: ledgerprovider.pnlrmtm),
                  //     const SizedBox(width: 6),
                  //                             TextWidget.subText(
                  //       text: "MTM",
                  //       theme: theme.isDarkMode,
                  //                                 color: theme.isDarkMode
                  //           ? colors.textSecondaryDark
                  //           : colors.textSecondaryLight,
                  //       fw: 0),
                  //   ],
                  // )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Search bar widget - matching portfolio screen
  Widget _buildSearchBar(BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        height: 40,
        child: TextFormField(
          autofocus: true,
          controller: _searchController,
          style: TextWidget.textStyle(
            fontSize: 16,
                                                  theme: theme.isDarkMode,
                                                  color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 0,
          ),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            UpperCaseTextFormatter(),
            NoEmojiInputFormatter(),
            FilteringTextInputFormatter.deny(RegExp('[π£•₹€℅™∆√¶/.,]'))
          ],
          decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextWidget.textStyle(
                fontSize: 14,
                                                  theme: theme.isDarkMode,
                color: (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight)
                    .withOpacity(0.4),
                fw: 0,
              ),
              fillColor: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
              filled: true,
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(assets.searchIcon,
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight,
                    fit: BoxFit.scaleDown,
                    width: 20),
              ),
              suffixIcon: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  splashColor: theme.isDarkMode
                      ? colors.splashColorDark
                      : colors.splashColorLight,
                  highlightColor: theme.isDarkMode
                      ? colors.highlightDark
                      : colors.highlightLight,
                  onTap: () async {
                    Future.delayed(const Duration(milliseconds: 150), () {
                      _searchController.clear();
                      _searchQuery = "";
                      _hideSearchBar();
                    });
                  },
                  child: SvgPicture.asset(assets.removeIcon,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fit: BoxFit.scaleDown,
                      width: 20),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              disabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20))),
          onChanged: (value) {
            _performSearch(value, ledgerprovider);
          },
        ),
      ),
    );
  }

  // Position item widget - matching portfolio screen design
  Widget _PositionItem({
    required dynamic position,
    required ThemesProvider theme,
    required LDProvider ledgerprovider,
  }) {
    // Check if quantity is zero
    final isZeroQty = (double.tryParse(position.netqty?.toString() ?? '0') ?? 0) == 0;
    
    return Container(
      color: isZeroQty
          ? theme.isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.2)
              : colors.textSecondaryLight.withOpacity(0.2)
          : null,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildHeaderRow(theme, position, isZeroQty),
          const SizedBox(height: 8),
          _buildQuantityRow(position, theme, ledgerprovider, isZeroQty),
          const SizedBox(height: 8),
          _buildAveragePriceRow(theme, position, isZeroQty),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(ThemesProvider theme, dynamic position, bool isZeroQty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          TextWidget.subText(
            text: "${position.tsym?.replaceAll("-EQ", "")}",
            theme: theme.isDarkMode,
            color: (theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight),
            textOverflow: TextOverflow.ellipsis,
            fw: 0),
        ]),
        Row(children: [
          TextWidget.subText(
            text: "${position.exch}",
            theme: theme.isDarkMode,
            color: (theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight),
            fw: 0),
        ])
      ],
    );
  }

  Widget _buildQuantityRow(dynamic position, ThemesProvider theme, LDProvider ledgerprovider, bool isZeroQty) {
    final pnlValue = ledgerprovider.pnlrmtm == true 
        ? double.tryParse(position.rpnl.toString())!.toStringAsFixed(2)
        : double.tryParse(position.rmtm.toString())!.toStringAsFixed(2);
    
    final pnlColor = _getPnlColor(pnlValue, theme);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "QTY ",
              style: TextWidget.textStyle(
                fontSize: 12,
                color: (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
            Text(
              "${position.netqty}",
              style: TextWidget.textStyle(
                fontSize: 12,
                color: (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              "AVG ",
              style: TextWidget.textStyle(
                fontSize: 12,
                color: (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
            Text(
              ledgerprovider.pnlrmtm == true 
                  ? double.tryParse(position.netAvgPrc.toString())!.toStringAsFixed(2)
                  : double.tryParse(position.netavgpricemtm.toString())!.toStringAsFixed(2),
              style: TextWidget.textStyle(
                fontSize: 12,
                color: (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
          ],
        ),
        Text(
          "₹$pnlValue",
          style: TextWidget.textStyle(
            fontSize: 16,
            color: pnlColor,
            theme: theme.isDarkMode,
            fw: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildAveragePriceRow(ThemesProvider theme, dynamic position, bool isZeroQty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "NRML",
          overflow: TextOverflow.ellipsis,
          style: TextWidget.textStyle(
            fontSize: 12,
            color: (theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight),
            theme: theme.isDarkMode,
            fw: 0,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "LTP ",
              style: TextWidget.textStyle(
                fontSize: 12,
                color: (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ),
            Text(
              "${position.ltp}",
              style: TextWidget.textStyle(
                fontSize: 12,
                color: (theme.isDarkMode
                        ? colors.textSecondaryDark
                        : colors.textSecondaryLight),
                theme: theme.isDarkMode,
                fw: 0,
              ),
            )
          ],
        ),
      ],
    );
  }

  Color _getPnlColor(String value, ThemesProvider theme) {
    if (value.startsWith("-")) {
      return theme.isDarkMode ? colors.lossDark : colors.lossLight;
    }
    if (value == "0.00") {
      return theme.isDarkMode
          ? colors.textSecondaryDark
          : colors.textSecondaryLight;
    }
    return theme.isDarkMode ? colors.profitDark : colors.profitLight;
  }

  // Show search bar - matching portfolio screen behavior
  void _showSearchBar(BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    // Toggle search visibility - you can add this to your provider
    // For now, we'll show the search bar inline
    setState(() {
      _showSearch = true;
    });
  }

  // Hide search bar
  void _hideSearchBar() {
    setState(() {
      _showSearch = false;
      _searchQuery = "";
      _searchController.clear();
    });
  }

  // Filter bottom sheet - matching portfolio screen exactly
  void _showFilterBottomSheet(BuildContext context, ThemesProvider theme, LDProvider ledgerprovider) {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
        builder: (context) => SafeArea(
          child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              top: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              left: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
              right: BorderSide(
                color: theme.isDarkMode
                    ? colors.textSecondaryDark.withOpacity(0.5)
                    : colors.colorWhite,
              ),
            ),
            color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom drag handler
              const CustomDragHandler(),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextWidget.titleText(
                  text: "Sort by",
                  theme: false,
                  color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  fw: 1,
                ),
              ),
              const SizedBox(height: 8),
              Divider(
                color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
              ),
              // Sort options
              _buildSortOption(
                context,
                theme,
                "Scrip Name",
                "scrip",
                Icons.arrow_upward,
                Icons.arrow_downward,
                _scripAscending,
              ),
              _buildSortOption(
                context,
                theme,
                "LTP",
                "price",
                Icons.arrow_upward,
                Icons.arrow_downward,
                _priceAscending,
              ),
              _buildSortOption(
                context,
                theme,
                "Qty",
                "qty",
                Icons.arrow_upward,
                Icons.arrow_downward,
                _qtyAscending,
              ),
               _buildSortOption(
                 context,
                 theme,
                 "P&L",
                 "pnl",
                 Icons.arrow_upward,
                 Icons.arrow_downward,
                 _pnlAscending,
               ),
              _buildPositionSortOption(
                context,
                theme,
                _positionFilter ? "Close Position" : "Open Position",
                "position",
                _positionFilter ? Icons.arrow_downward : Icons.arrow_upward,
              ),
              // 
               const SizedBox(height: 16),
             ],
           ),
                 ),
         ),
    );
  }

  // Build sort option row
  Widget _buildSortOption(
    BuildContext context,
    ThemesProvider theme,
    String title,
    String type,
    IconData upIcon,
    IconData downIcon,
    bool isAscending,
  ) {
    final isActive = _currentSortType == type;
    
    return InkWell(
      onTap: () => _applySortForType(type),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isAscending ? upIcon : downIcon,
                  size: 20,
                  color: isActive
                      ? theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight
                      : theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextWidget.textStyle(
                    fontSize: 14,
                    color: isActive
                        ? theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight
                        : theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: isActive ? 2 : 0,
                  ),
                ),
                ],
              ),
            ),
          Divider(
            color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
            height: 1,
          ),
        ],
      ),
    );
  }

  // Build position sort option row (Open/Close Position)
  Widget _buildPositionSortOption(
    BuildContext context,
    ThemesProvider theme,
    String title,
    String type,
    IconData icon,
  ) {
    final isActive = _currentSortType == type;
    
    return InkWell(
      onTap: () => _applySortForType(type),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive
                      ? theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight
                      : theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: TextWidget.textStyle(
                    fontSize: 14,
                    color: isActive
                        ? theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight
                        : theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: isActive ? 2 : 0,
                  ),
                ),
                ],
              ),
            ),
          Divider(
            color: theme.isDarkMode ? colors.darkColorDivider : colors.colorDivider,
            height: 1,
          ),
        ],
      ),
    );
  }

  // Apply sort
  void _applySortForType(String type) {
    setState(() {
      if (_currentSortType == type) {
        // Toggle direction
        switch (type) {
          case "scrip":
            _scripAscending = !_scripAscending;
            break;
          case "price":
            _priceAscending = !_priceAscending;
            break;
          case "qty":
            _qtyAscending = !_qtyAscending;
            break;
          case "pnl":
            _pnlAscending = !_pnlAscending;
            break;
          case "position":
            _positionFilter = !_positionFilter;
            break;
        }
      } else {
        // Set new sort type
        _currentSortType = type;
      }
    });
    
    // Close the sheet
    Navigator.pop(context);
  }

  // Search functionality
  void _performSearch(String query, LDProvider ledgerprovider) {
    setState(() {
      _searchQuery = query;
    });
  }

  // Reset all filters and search
  void _resetFilters() {
    setState(() {
      _searchQuery = "";
      _currentSortType = "";
      _scripAscending = true;
      _priceAscending = true;
      _qtyAscending = true;
      _pnlAscending = true;
      _searchController.clear();
    });
  }
}
