import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_font_web.dart';
import '../../../res/web_colors.dart';

class ExitAllPositionsDialogWeb extends ConsumerStatefulWidget {
  final List<PositionBookModel> selectedPositions;
  final List<int> selectedIndices;
  
  const ExitAllPositionsDialogWeb({
    super.key,
    required this.selectedPositions,
    required this.selectedIndices,
  });

  @override
  ConsumerState<ExitAllPositionsDialogWeb> createState() => _ExitAllPositionsDialogWebState();
}

class _ExitAllPositionsDialogWebState extends ConsumerState<ExitAllPositionsDialogWeb> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final positionBook = ref.read(portfolioProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        height: 520,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: theme.isDarkMode ? WebDarkColors.divider : WebColors.divider,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(theme),
            
            // Content
            Expanded(
              child: _buildContent(theme),
            ),
            
            // Footer
            _buildFooter(theme, positionBook),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemesProvider theme) {
    return Container(
     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.isDarkMode
                          ? WebDarkColors.divider
                          : WebColors.divider,
                    ),
                  ),
                ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         
          Text(
            widget.selectedPositions.length > 1 ? 'Exit All Positions' : 'Exit Position',
            style: WebTextStyles.dialogTitle(
              isDarkTheme: theme.isDarkMode,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
            ),
          ),
          Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        splashColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.15)
                            : Colors.black.withOpacity(.15),
                        highlightColor: theme.isDarkMode
                            ? Colors.white.withOpacity(.08)
                            : Colors.black.withOpacity(.08),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: theme.isDarkMode
                                ? WebDarkColors.iconSecondary
                                : WebColors.iconSecondary,
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 16),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
        columnSpacing: 10,
        horizontalMargin: 0,
        showCheckboxColumn: false,
        headingRowHeight: 44,
        headingRowColor: WidgetStateProperty.all(Colors.transparent),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  .withOpacity(0.05);
            }
            if (states.contains(WidgetState.selected)) {
              return (theme.isDarkMode
                      ? WebDarkColors.primary
                      : WebColors.primary)
                  .withOpacity(0.1);
            }
            return null;
          },
        ),
        columns: [
          DataColumn(
            label: Text(
              'Instrument',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Product',
              style: WebTextStyles.tableHeader(
                isDarkTheme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? WebDarkColors.textPrimary
                    : WebColors.textPrimary,
              ),
            ),
          ),
          DataColumn(
            label: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Qty',
                style: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
              ),
            ),
          ),
          DataColumn(
            label: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'P&L',
                style: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
              ),
            ),
          ),
          DataColumn(
            label: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'LTP',
                style: WebTextStyles.tableHeader(
                  isDarkTheme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? WebDarkColors.textPrimary
                      : WebColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
        rows: widget.selectedPositions.map((position) {
          final qty = int.tryParse(position.qty ?? '0') ?? 0;
          final isClosed = _isPositionClosed(position);
          
          return DataRow(
            cells: [
              // Instrument
              DataCell(
                Text(
                  '${position.symbol ?? ''} ${position.exch ?? ''}',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ),
              // Product
              DataCell(
                Text(
                  position.sPrdtAli ?? 'N/A',
                  style: WebTextStyles.tableDataCompact(
                    isDarkTheme: theme.isDarkMode,
                    color: _getPositionTextColor(position, theme),
                  ),
                ),
              ),
              // Qty
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatQty(qty.toString()),
                    style: WebTextStyles.tableDataCompact(
                      isDarkTheme: theme.isDarkMode,
                      color: isClosed 
                          ? Colors.grey
                          : _getQtyColor(qty.toString(), theme),
                    ),
                  ),
                ),
              ),
              // P&L
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    position.profitNloss ?? '0.00',
                    style: WebTextStyles.tableDataCompact(
                      isDarkTheme: theme.isDarkMode,
                      color: isClosed 
                          ? Colors.grey
                          : _getValueColor(position.profitNloss ?? '0.00', theme),
                    ),
                  ),
                ),
              ),
              // LTP
              DataCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    position.lp ?? '0.00',
                    style: WebTextStyles.tableDataCompact(
                      isDarkTheme: theme.isDarkMode,
                      color: _getPositionTextColor(position, theme),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
          ),
        ),
      ),
    );
  }


  Widget _buildFooter(ThemesProvider theme, PortfolioProvider positionBook) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 16),
      decoration: BoxDecoration(       
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
       
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning message
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: theme.isDarkMode 
                  ? const Color(0xFF2D1B1B) 
                  : const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: theme.isDarkMode 
                    ? const Color(0xFF5D2D2D) 
                    : const Color(0xFFFFEAA7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.isDarkMode 
                      ? const Color(0xFFFF6B6B) 
                      : const Color(0xFF856404),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.selectedPositions.length > 1 
                        ? 'This action will place market orders to exit all selected positions. This action cannot be undone.'
                        : 'This action will place a market order to exit the selected position. This action cannot be undone.',
                    style: WebTextStyles.caption(
                      isDarkTheme: theme.isDarkMode,
                      color: theme.isDarkMode 
                          ? const Color(0xFFFF6B6B) 
                          : const Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exit All button
          Row(
            children: [
              // Cancel button
              // Expanded(
              //   child: SizedBox(
              //     height: 40,
              //     child: OutlinedButton(
              //       onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              //       style: OutlinedButton.styleFrom(
              //         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              //         side: BorderSide(
              //           color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
              //           width: 1,
              //         ),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(8),
              //         ),
              //         backgroundColor: theme.isDarkMode ? colors.kColorLightGreyDarkTheme : colors.kColorLightGrey,
              //       ),
              //       child: Text(
              //         'Cancel',
              //         style: TextWidget.textStyle(
              //           fontSize: 14,
              //           color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              //           theme: theme.isDarkMode,
              //           fw: 2,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              
              // const SizedBox(width: 16),
              
              // Exit All button
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: _isLoading || widget.selectedPositions.length == 0
                          ? null
                          : () => positionBook.exitPosition(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.selectedPositions.length == 0 
                      ? (theme.isDarkMode ? WebDarkColors.divider : WebColors.divider)
                      : WebColors.tertiary,
                  foregroundColor: widget.selectedPositions.length == 0 
                      ? (theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.selectedPositions.length > 1 ? 'Exit All Positions' : 'Exit Position',
                        style: WebTextStyles.buttonMd(
                          isDarkTheme: theme.isDarkMode,
                          color: Colors.white,
                          fontWeight: WebFonts.medium,
                        ),
                      ),
              ),
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success; // Green
    } else if (numValue < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error; // Red
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary; // Grey
    }
  }

  Color _getQtyColor(String qty, ThemesProvider theme) {
    final numQty = int.tryParse(qty) ?? 0;
    if (numQty > 0) {
      return theme.isDarkMode ? WebDarkColors.success : WebColors.success;
    } else if (numQty < 0) {
      return theme.isDarkMode ? WebDarkColors.error : WebColors.error;
    } else {
      return theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary;
    }
  }

  bool _isPositionClosed(PositionBookModel position) {
    final qty = int.tryParse(position.qty ?? '0') ?? 0;
    return qty == 0;
  }

  Color _getPositionTextColor(PositionBookModel position, ThemesProvider theme) {
    if (_isPositionClosed(position)) {
      return theme.isDarkMode 
          ? WebDarkColors.textSecondary.withOpacity(0.6)
          : WebColors.textSecondary.withOpacity(0.6);
    }
    return theme.isDarkMode
        ? WebDarkColors.textPrimary
        : WebColors.textPrimary;
  }

  String _formatQty(String qty) {
    final numQty = int.tryParse(qty) ?? 0;
    return numQty > 0 ? '+$qty' : qty;
  }
}
