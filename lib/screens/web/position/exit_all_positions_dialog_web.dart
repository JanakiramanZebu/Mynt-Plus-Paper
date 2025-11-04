import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/portfolio_model/position_book_model.dart';
import '../../../provider/portfolio_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_font_web.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
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
            style: WebTextStyles.custom(
              fontSize: 14,
              color: theme.isDarkMode ? WebDarkColors.textPrimary : WebColors.textPrimary,
              isDarkTheme: theme.isDarkMode,
              fontWeight: WebFonts.bold,
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
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: TextWidget.textStyle(
                      fontSize: 10,
                      color: theme.isDarkMode 
                          ? const Color(0xFFFF6B6B) 
                          : const Color(0xFF856404),
                      theme: theme.isDarkMode,
                      fw: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Selected positions count
          Text(
            widget.selectedPositions.length > 1 
                ? 'Selected Positions (${widget.selectedPositions.length})'
                : 'Selected Position',
            style: TextWidget.textStyle(
              fontSize: 14,
              color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
              theme: theme.isDarkMode,
              fw: 2,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Positions list
          Expanded(
            child: Container(
              
              child: ListView.builder(
                itemCount: widget.selectedPositions.length,
                itemBuilder: (context, index) {
                  final position = widget.selectedPositions[index];
                  return _buildPositionItem(position, theme);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionItem(PositionBookModel position, ThemesProvider theme) {
    final qty = int.tryParse(position.qty ?? '0') ?? 0;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // border: Border(
        //   bottom: BorderSide(
        //     color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
        //     width: 0.5,
        //   ),
        // ),
      ),
      child: Row(
        children: [
          // Symbol info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${position.symbol ?? ''} ${position.exch ?? ''}',
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position.sPrdtAli ?? 'N/A',
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Qty',
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatQty(qty.toString()),
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: _getQtyColor(qty.toString(), theme),
                    theme: false,
                    fw: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // P&L
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'P&L',
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position.profitNloss ?? '0.00',
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: _getValueColor(position.profitNloss ?? '0.00', theme),
                    theme: false,
                    fw: 2,
                  ),
                ),
              ],
            ),
          ),
          
          // LTP
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'LTP',
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position.lp ?? '0.00',
                  style: TextWidget.textStyle(
                    fontSize: 13,
                    color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
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
      child: Row(
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
                      ? (theme.isDarkMode ? colors.dividerDark : colors.dividerLight)
                      : const Color(0xFFEF4444),
                  foregroundColor: widget.selectedPositions.length == 0 
                      ? (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight)
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
                        style: TextWidget.textStyle(
                          fontSize: 14,
                          color: Colors.white,
                          theme: false,
                          fw: 2,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Color _getValueColor(String value, ThemesProvider theme) {
    final numValue = double.tryParse(value) ?? 0.0;
    if (numValue > 0) {
      return const Color(0xFF10B981); // Green
    } else if (numValue < 0) {
      return const Color(0xFFEF4444); // Red
    } else {
      return const Color(0xFF6B7280); // Grey
    }
  }

  Color _getQtyColor(String qty, ThemesProvider theme) {
    final numQty = int.tryParse(qty) ?? 0;
    if (numQty > 0) {
      return Colors.green;
    } else if (numQty < 0) {
      return Colors.red;
    } else {
      return theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight;
    }
  }

  String _formatQty(String qty) {
    final numQty = int.tryParse(qty) ?? 0;
    return numQty > 0 ? '+$qty' : qty;
  }
}
