import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn hide Colors;
import 'package:intl/intl.dart';

import '../../../../models/bonds_model/bonds_order_book_model.dart';
import '../../../../provider/bonds_provider.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../sharedWidget/mynt_loader.dart';
import '../../../../sharedWidget/no_data_found.dart';


import '../../../../sharedWidget/common_search_fields_web.dart';
import 'bonds_details_sidebar_web.dart';
import 'bond_cancel_alert/bonds_cancel_alert_web.dart';
import '../../../../res/res.dart';
import '../../../../provider/thems.dart';

class BondsMyBidsWeb extends ConsumerStatefulWidget {
  const BondsMyBidsWeb({super.key});

  @override
  ConsumerState<BondsMyBidsWeb> createState() => _BondsMyBidsWebState();
}

class _BondsMyBidsWebState extends ConsumerState<BondsMyBidsWeb> {
  late ScrollController _verticalScrollController;
  final ValueNotifier<int?> _hoveredRowIndex = ValueNotifier<int?>(null);

  int? _sortColumnIndex = 2; // Default sort by Datetime
  bool _sortAscending = false; // Default newest first
  int _selectedSubTab = 0; // 0: Open, 1: Close

  // Popover state management
  shadcn.PopoverController? _activePopoverController;
  int? _popoverRowIndex;
  bool _isHoveringDropdown = false;
  Timer? _popoverCloseTimer;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _hoveredRowIndex.addListener(_onHoverChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bondsProvider).fetchBondsOrderBook();
    });
  }

  @override
  void dispose() {
    _cancelPopoverCloseTimer();
    _hoveredRowIndex.removeListener(_onHoverChanged);
    _verticalScrollController.dispose();
    _hoveredRowIndex.dispose();
    super.dispose();
  }

  void _onHoverChanged() {
    if (_activePopoverController != null) {
      final currentHover = _hoveredRowIndex.value;
      if (currentHover == _popoverRowIndex) {
        _cancelPopoverCloseTimer();
        return;
      }
      if (_isHoveringDropdown) {
        _cancelPopoverCloseTimer();
        return;
      }
      _startPopoverCloseTimer();
    }
  }

  void _startPopoverCloseTimer() {
    _cancelPopoverCloseTimer();
    _popoverCloseTimer = Timer(const Duration(milliseconds: 150), () {
      if (!_isHoveringDropdown && _hoveredRowIndex.value != _popoverRowIndex) {
        _closePopover();
      }
    });
  }

  void _cancelPopoverCloseTimer() {
    _popoverCloseTimer?.cancel();
    _popoverCloseTimer = null;
  }

  void _closePopover() {
    _cancelPopoverCloseTimer();
    try {
      _activePopoverController?.close();
    } catch (_) {}
    final needsRebuild = _activePopoverController != null || _popoverRowIndex != null;
    _activePopoverController = null;
    _popoverRowIndex = null;
    _isHoveringDropdown = false;
    if (needsRebuild && mounted) {
      setState(() {});
    }
  }

  void _onSort(int columnIndex) {
    setState(() {
      if (_sortColumnIndex == columnIndex) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = columnIndex;
        _sortAscending = true;
      }
    });
  }

  List<BondsOrderBookModel> _sortData(List<BondsOrderBookModel> data) {
    if (_sortColumnIndex == null) return data;

    var sorted = List<BondsOrderBookModel>.from(data);
    sorted.sort((a, b) {
      int cmp = 0;
      switch (_sortColumnIndex) {
        case 0: // Symbol
          cmp = (a.symbol ?? '').compareTo(b.symbol ?? '');
          break;
        case 1: // Order Number
          cmp = (a.orderNumber ?? '').compareTo(b.orderNumber ?? '');
          break;
        case 2: // Datetime
          DateTime? dA = DateTime.tryParse(a.responseDatetime ?? '');
          DateTime? dB = DateTime.tryParse(b.responseDatetime ?? '');
          if (dA == null) {
            cmp = 1;
          } else if (dB == null) {
            cmp = -1;
          } else {
            cmp = dA.compareTo(dB);
          }
          break;
        case 3: // Amount
          double vA = double.tryParse(a.investmentValue ?? '0') ?? 0;
          double vB = double.tryParse(b.investmentValue ?? '0') ?? 0;
          cmp = vA.compareTo(vB);
          break;
        case 4: // Reason
          String rA = _getReasonText(a);
          String rB = _getReasonText(b);
          cmp = rA.compareTo(rB);
          break;
        case 5: // Status
          cmp = (a.orderStatus ?? '').compareTo(b.orderStatus ?? '');
          break;
      }
      return _sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final bonds = ref.watch(bondsProvider);

    // Show loader while data is being fetched
    if (bonds.bondsMyBidsload) {
      return const Center(
        child: MyntLoader(size: MyntLoaderSize.large),
      );
    }

    // Get Data
    final openOrders = bonds.filterOpenOrdersBySearch();
    final closeOrders = bonds.filterCloseOrdersBySearch();

    // Calculate counts
    final closeCount = closeOrders.length;

    final displayData = _sortData(_selectedSubTab == 0 ? openOrders : closeOrders);

    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            // border: Border(
            //   bottom: BorderSide(
            //     color: resolveThemeColor(context, dark: Colors.white10, light: Colors.grey[200]!),
            //     width: 1,
            //   ),
            // ),
          ),
          child: Row(
            children: [
              _buildSubTab("Open Orders", 0),
              const SizedBox(width: 12),
              _buildSubTab("Close Orders", 1, count: closeCount),
              
              const Spacer(),
              
              // Search
              SizedBox(
                  width: 300,
                  child: MyntSearchTextField(
                    controller: bonds.bondscommonsearchcontroller,
                    placeholder: "Search",
                    leadingIcon: assets.searchIcon,
                    onChanged: (value) {
                      bonds.searchCommonBonds(value, context);
                    },
                  ),
               ),
               const SizedBox(width: 12),
               
               // Filter & Refresh
              //  Material(
              //    color: Colors.transparent,
              //    child: InkWell(
              //      borderRadius: BorderRadius.circular(4),
              //      onTap: () {},
              //      child: Padding(
              //        padding: const EdgeInsets.all(8.0),
              //        child: SvgPicture.asset(assets.filterLines, width: 20, color: WebColors.textSecondary),
              //      ),
              //    ),
              //  ),
               Material(
                 color: Colors.transparent,
                  child: InkWell(
                   borderRadius: BorderRadius.circular(4),
                   onTap: () {
                      ref.read(bondsProvider).fetchBondsOrderBook();
                   },
                   child: const Padding(
                     padding: EdgeInsets.all(8.0),
                     child: Icon(Icons.refresh, size: 20, color: WebColors.textSecondary),
                   ),
                 ),
               ),
            ],
          ),
        ),

        // Table
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  // Distribute width
                  // Symbol: 20%
                  // Order: 22%
                  // Date: 16%
                  // Amount: 12%
                  // Reason: 30%
                  final col0 = width * 0.18;
                  final col1 = width * 0.20;
                  final col2 = width * 0.16;
                  final col3 = width * 0.12;
                  final col4 = width * 0.20;
                  final col5 = width * 0.14;

                  return shadcn.OutlinedContainer(
                    child: Column(
                    children: [
                      // Fixed Header Table
                      SizedBox(
                        height: 48,
                        child: shadcn.Table(
                          columnWidths: {
                            0: shadcn.FixedTableSize(col0),
                            1: shadcn.FixedTableSize(col1),
                            2: shadcn.FixedTableSize(col2),
                            3: shadcn.FixedTableSize(col3),
                            4: shadcn.FixedTableSize(col4),
                            5: shadcn.FixedTableSize(col5),
                          },
                          defaultRowHeight: const shadcn.FixedTableSize(48),
                          rows: [
                            shadcn.TableHeader(
                              cells: [
                                _buildHeaderCell("Symbol", 0),
                                _buildHeaderCell("Order Number", 1),
                                _buildHeaderCell("Datetime", 2),
                                _buildHeaderCell("Amount", 3),
                                _buildHeaderCell("Reason", 4),
                                _buildHeaderCell("Status", 5),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Scrollable Body Table
                      Expanded(
                        child: displayData.isEmpty
                          ? Center(
                              child: NoDataFoundWeb(
                                  title: "There's nothing here yet.",
                                  subtitle: "Buy some bonds to see them here.",
                                  assetIcon: assets.documentIcon,
                                  iconSize: 120,
                                  primaryEnabled: false,
                                  secondaryEnabled: false,
                               ))
                          : RawScrollbar(
                           controller: _verticalScrollController,
                           thumbVisibility: true,
                           trackVisibility: true,
                           trackColor: resolveThemeColor(context,
                               dark: Colors.grey.withOpacity(0.1),
                               light: Colors.grey.withOpacity(0.1)),
                           thumbColor: resolveThemeColor(context,
                               dark: Colors.grey.withOpacity(0.3),
                               light: Colors.grey.withOpacity(0.3)),
                           thickness: 6,
                           radius: const Radius.circular(3),
                           interactive: true,
                          child: SingleChildScrollView(
                            controller: _verticalScrollController,
                            scrollDirection: Axis.vertical,
                            child: shadcn.Table(
                              columnWidths: {
                                0: shadcn.FixedTableSize(col0),
                                1: shadcn.FixedTableSize(col1),
                                2: shadcn.FixedTableSize(col2),
                                3: shadcn.FixedTableSize(col3),
                                4: shadcn.FixedTableSize(col4),
                                5: shadcn.FixedTableSize(col5),
                              },
                              defaultRowHeight: const shadcn.FixedTableSize(50),
                              rows: displayData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final order = entry.value;
                                return shadcn.TableRow(
                                  cells: [
                                    _buildSymbolCellWithActions(
                                        order: order,
                                        rowIndex: index,
                                        onTap: () => _openDetails(order)),
                                    _buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 1,
                                        onTap: () => _openDetails(order),
                                        child: Text(order.orderNumber ?? '-',
                                            style: MyntWebTextStyles.body(
                                                context,
                                                fontWeight: MyntFonts.medium))),
                                    _buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 2,
                                        onTap: () => _openDetails(order),
                                        child: Text(
                                            _formatDate(order.responseDatetime),
                                            style: MyntWebTextStyles.body(
                                                context,
                                                fontWeight: MyntFonts.medium))),
                                    _buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 3,
                                        onTap: () => _openDetails(order),
                                        child: Text(
                                            "₹${order.investmentValue ?? '0'}",
                                            style: MyntWebTextStyles.body(
                                                context,
                                                fontWeight: MyntFonts.medium))),
                                    _buildCellWithHover(
                                      rowIndex: index,
                                      columnIndex: 4,
                                      onTap: () => _openDetails(order),
                                      child: Tooltip(
                                        message: _getReasonText(order),
                                        child: Text(
                                          _getReasonText(order),
                                          style: MyntWebTextStyles.body(
                                              context,
                                              fontWeight: MyntFonts.medium),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    _buildCellWithHover(
                                        rowIndex: index,
                                        columnIndex: 5,
                                        onTap: () => _openDetails(order),
                                        child: _buildStatusChip(context, order.reponseStatus)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget _buildSubTab(String title, int index, {int? count}) {
     final isSelected = _selectedSubTab == index;
     final theme = ref.watch(themeProvider);
     final isDark = theme.isDarkMode;
     
     // Colors
     final activeBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF1F4F9);
     final inactiveBg = Colors.transparent;
     final activeText = isDark ? Colors.white : Colors.black;
     final inactiveText = isDark ? Colors.grey[400] : const Color(0xFF666666);
     
     return InkWell(
        onTap: () => setState(() => _selectedSubTab = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
           decoration: BoxDecoration(
              color: isSelected ? activeBg : inactiveBg,
              borderRadius: BorderRadius.circular(6),
           ),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 title,
                 style: MyntWebTextStyles.body(
                    context, 
                    fontWeight: isSelected ? MyntFonts.semiBold : MyntFonts.medium,
                    color: isSelected ? activeText : inactiveText
                 )
               ),
               if (count != null && count > 0) ...[
                  const SizedBox(width: 4),
                   Transform.translate(
                     offset: const Offset(0, -2),
                     child: Text(
                       "$count",
                       style: MyntWebTextStyles.caption(
                          context, 
                          fontWeight: MyntFonts.semiBold,
                          color: isSelected ? activeText : inactiveText
                       ).copyWith(fontSize: 10),
                     ),
                   ),
               ]
             ],
           ),
        ),
     );
  }

  shadcn.TableCell _buildHeaderCell(String label, int index) {
     final headerBgColor = resolveThemeColor(
      context,
      dark: const Color(0xff0D0D0D),
      light: const Color(0xffF9FAFB),
    );
  
    return shadcn.TableCell(
      theme: shadcn.TableCellTheme(
         border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide(color: resolveThemeColor(context, dark: Colors.white24, light: Colors.grey[200]!), width: 1),
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
         )
      ),
      child: Container(
        color: headerBgColor,
        child: InkWell(
          onTap: () => _onSort(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Text(
                  label, 
                  style: MyntWebTextStyles.tableHeader(
                      context, lightColor: WebColors.textSecondary, darkColor: WebColors.textSecondaryDark
                  )
                ),
                if (_sortColumnIndex == index) ...[
                   const SizedBox(width: 4),
                   Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: WebColors.textSecondary),
                ] else if (label == 'Datetime') ...[
                   const SizedBox(width: 4),
                   const Icon(Icons.arrow_downward, size: 14, color: WebColors.textSecondary),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  shadcn.TableCell _buildCellWithHover({
    required Widget child,
    required int rowIndex,
    required int columnIndex,
    VoidCallback? onTap,
  }) {
    // Add extra horizontal padding for first and last columns
    final isFirstColumn = columnIndex == 0;
    final isLastColumn = columnIndex == 5;

    EdgeInsets cellPadding;
    if (isFirstColumn) {
      cellPadding = const EdgeInsets.fromLTRB(16, 8, 4, 8);
    } else if (isLastColumn) {
      cellPadding = const EdgeInsets.fromLTRB(4, 8, 16, 8);
    } else {
      cellPadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    }

    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: GestureDetector(
          onTap: onTap,
          child: ValueListenableBuilder<int?>(
            valueListenable: _hoveredRowIndex,
            builder: (context, hoveredIndex, _) {
              // Also highlight when popover is open for this row
              final isRowHovered = hoveredIndex == rowIndex || _popoverRowIndex == rowIndex;
              return Container(
                padding: cellPadding,
                color: isRowHovered
                    ? resolveThemeColor(context,
                        dark: MyntColors.primary.withValues(alpha: 0.08),
                        light: MyntColors.primary.withValues(alpha: 0.08))
                    : null,
                alignment: Alignment.centerLeft,
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }

  void _openDetails(BondsOrderBookModel order) {
    shadcn.openSheet(
      context: context,
      builder: (sheetContext) {
        final screenWidth = MediaQuery.of(sheetContext).size.width;
        final sheetWidth = screenWidth < 1300 ? screenWidth * 0.3 : 480.0;
        return Container(
          width: sheetWidth,
          decoration: BoxDecoration(
            color: resolveThemeColor(context,
                dark: MyntColors.backgroundColorDark,
                light: MyntColors.backgroundColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: BondsDetailsSidebarWeb(order: order, isOpenOrder: _selectedSubTab == 0),
        );
      },
      position: shadcn.OverlayPosition.end,
      barrierColor: Colors.transparent,
    );
  }

  // Build symbol cell with hover dropdown button
  shadcn.TableCell _buildSymbolCellWithActions({
    required BondsOrderBookModel order,
    required int rowIndex,
    VoidCallback? onTap,
  }) {
    return shadcn.TableCell(
      theme: const shadcn.TableCellTheme(
        border: shadcn.WidgetStatePropertyAll(
          shadcn.Border(
            top: shadcn.BorderSide.none,
            bottom: shadcn.BorderSide.none,
            left: shadcn.BorderSide.none,
            right: shadcn.BorderSide.none,
          ),
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => _hoveredRowIndex.value = rowIndex,
        onExit: (_) => _hoveredRowIndex.value = null,
        child: GestureDetector(
          onTap: onTap,
          child: ValueListenableBuilder<int?>(
            valueListenable: _hoveredRowIndex,
            builder: (context, hoveredIndex, _) {
              final isHovered = hoveredIndex == rowIndex || _popoverRowIndex == rowIndex;
              return Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                color: isHovered
                    ? resolveThemeColor(context,
                        dark: MyntColors.primary.withValues(alpha: 0.08),
                        light: MyntColors.primary.withValues(alpha: 0.08))
                    : null,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      // Symbol content
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(right: isHovered ? 40.0 : 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(order.symbol ?? '',
                                  style: MyntWebTextStyles.body(context,
                                      fontWeight: MyntFonts.medium)),
                              Text(
                                  (order.symbol?.contains('T') == true &&
                                          !(order.symbol?.contains('GS') == true))
                                      ? 'T-BILL'
                                      : 'G-SEC',
                                  style: MyntWebTextStyles.caption(context,
                                      color: WebColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                      // Dropdown button on hover
                      if (isHovered)
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: _buildOptionsMenuButton(order, rowIndex),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getReasonText(BondsOrderBookModel order) {
      if (order.failReason != null && order.failReason!.isNotEmpty) return order.failReason!;
      if (order.clearingReason != null && order.clearingReason!.isNotEmpty) return order.clearingReason!;
       return '-';
  }

  Widget _buildStatusChip(BuildContext context, String? status) {
    final theme = ref.read(themeProvider);
    final statusLower = (status ?? '').toLowerCase();
    final bool isFailed = statusLower == 'failed';
    final bool isSuccess = statusLower == 'success';

    // Get status color based on status type
    Color statusColor;
    if (isSuccess) {
      statusColor = theme.isDarkMode ? colors.profitDark : colors.profitLight;
    } else if (isFailed) {
      statusColor = theme.isDarkMode ? colors.lossDark : colors.lossLight;
    } else {
      statusColor = colors.pending;
    }

    String displayText = status ?? '-';
    if (displayText.isNotEmpty && displayText != '-') {
      displayText = displayText[0].toUpperCase() + displayText.substring(1).toLowerCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText.toUpperCase(),
        style: MyntWebTextStyles.bodySmall(
          context,
          color: statusColor,
          fontWeight: MyntFonts.medium,
        ),
      ),
    );
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      // Handle "2025-08-02 10:48:27.344237" format
      final date = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return dateTimeStr;
    }
  }

  // Build the 3-dot options menu button with shadcn dropdown
  Widget _buildOptionsMenuButton(BondsOrderBookModel order, int rowIndex) {
    return Builder(
      builder: (buttonContext) {
        return GestureDetector(
          onTap: () {
            // Close any existing popover first
            _closePopover();

            // Build menu items
            List<shadcn.MenuItem> menuItems = [];
            final iconColor = resolveThemeColor(context,
                dark: WebColors.textPrimaryDark,
                light: WebColors.textPrimary);
            final textColor = resolveThemeColor(context,
                dark: WebColors.textPrimaryDark,
                light: WebColors.textPrimary);

            // Cancel option (only for open orders)
            if (_selectedSubTab == 0) {
              menuItems.add(
                _buildMenuButton(
                  icon: Icons.cancel_outlined,
                  title: 'Cancel',
                  iconColor: MyntColors.tertiary,
                  textColor: textColor,
                  onPressed: (ctx) {
                    _closePopover();
                    showDialog(
                      context: context,
                      barrierColor: Colors.black54,
                      builder: (BuildContext context) {
                        return BondCancelAlertWeb(bondcancel: order);
                      },
                    );
                  },
                ),
              );
              menuItems.add(const shadcn.MenuDivider());
            }

            // Info option
            menuItems.add(
              _buildMenuButton(
                icon: Icons.info_outline,
                title: 'Info',
                iconColor: iconColor,
                textColor: textColor,
                onPressed: (ctx) {
                  _closePopover();
                  _openDetails(order);
                },
              ),
            );

            // Create a controller for this popover
            final controller = shadcn.PopoverController();
            _activePopoverController = controller;
            _popoverRowIndex = rowIndex;

            // Show the shadcn popover menu anchored to this button
            controller.show(
              context: buttonContext,
              alignment: Alignment.topRight,
              offset: const Offset(0, 4),
              builder: (ctx) {
                return MouseRegion(
                  onEnter: (_) {
                    _isHoveringDropdown = true;
                    _cancelPopoverCloseTimer();
                  },
                  onExit: (_) {
                    _isHoveringDropdown = false;
                    // Start delayed close
                    _startPopoverCloseTimer();
                  },
                  child: shadcn.DropdownMenu(
                    children: menuItems,
                  ),
                );
              },
            );

            // Force rebuild to show row highlight
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: resolveThemeColor(context,
                  dark: MyntColors.textWhite,
                  light: MyntColors.textWhite),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: resolveThemeColor(context,
                      dark: Colors.grey, light: Colors.grey),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.more_vert,
              size: 18,
              color: resolveThemeColor(context,
                  dark: MyntColors.textPrimaryDark,
                  light: MyntColors.textPrimary),
            ),
          ),
        );
      },
    );
  }

  // Helper method for building menu buttons
  shadcn.MenuButton _buildMenuButton({
    required IconData icon,
    required String title,
    required void Function(BuildContext) onPressed,
    required Color iconColor,
    required Color textColor,
  }) {
    return shadcn.MenuButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.medium,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
