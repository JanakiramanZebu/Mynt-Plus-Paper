import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/global_font_web.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../provider/thems.dart';
import '../../../../provider/mf_provider.dart';
import '../../../res/web_colors.dart';
import '../../../res/global_font_web.dart' hide WebTextStyles;
import '../ordersbook/mf/redeem_bottom_sheet_web.dart';
import '../../../../main.dart';

class MfHoldingDetailScreenWeb extends ConsumerStatefulWidget {
  final dynamic holding;
  
  const MfHoldingDetailScreenWeb({
    super.key,
    required this.holding,
  });

  @override
  ConsumerState<MfHoldingDetailScreenWeb> createState() => _MfHoldingDetailScreenWebState();
}

class _MfHoldingDetailScreenWebState extends ConsumerState<MfHoldingDetailScreenWeb> {
  @override
  Widget build(BuildContext context) {
    // Use read instead of watch to avoid rebuilds - theme won't change while sheet is open
    final theme = ref.read(themeProvider);
    final isDarkMode = theme.isDarkMode;

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    widget.holding.name ?? 'N/A',
                    style: WebTextStyles.dialogTitle(
                      isDarkTheme: isDarkMode,
                      color: shadcn.Theme.of(context).colorScheme.foreground,
                    ),
                  ),
                ),
                shadcn.TextButton(
                  density: shadcn.ButtonDensity.icon,
                  child: const Icon(Icons.close),
                  onPressed: () {
                    shadcn.closeSheet(context);
                  },
                ),
              ],
            ),
          ),
          // Border after header
          Container(
            height: 1,
            color: shadcn.Theme.of(context).colorScheme.border,
          ),
          // Content
          Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Returns Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _buildReturnsSection(theme),
                  ),
                  
                  // Action Buttons
                  _buildActionButtons(theme),
                  
                  // Details Section
                  _buildDetailsSection(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildActionButtons(ThemesProvider theme) {
    final avgQty = double.tryParse(widget.holding.avgQty ?? '0') ?? 0.0;
    final hasQty = avgQty > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Redeem button
          if (hasQty) ...[
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    "Redeem",
                    false,
                    theme,
                    _handleRedeem,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    bool isPrimary,
    ThemesProvider theme,
    VoidCallback onPressed,
  ) {
    // Redeem button uses tertiary color to match table styling
    final isRedeem = text == 'Redeem';
    final backgroundColor = isRedeem
        ? (theme.isDarkMode ? WebDarkColors.tertiary : WebColors.tertiary)
        : (isPrimary
            ? (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary)
            : (theme.isDarkMode
                ? WebDarkColors.buttonSecondary
                : WebColors.buttonSecondary));
    final textColor = isRedeem || isPrimary
        ? Colors.white
        : (theme.isDarkMode ? Colors.white : (theme.isDarkMode ? WebDarkColors.primary : WebColors.primary));
    
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: isRedeem || isPrimary
            ? null
            : Border.all(
                color: theme.isDarkMode ? WebDarkColors.primary : WebColors.primary,
                width: 1,
              ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: shadcn.TextButton(
        size: shadcn.ButtonSize.large,
        density: shadcn.ButtonDensity.dense,
        onPressed: onPressed,
        shape: shadcn.ButtonShape.rectangle,
        child: Text(
          text,
          style: WebTextStyles.buttonMd(
            isDarkTheme: theme.isDarkMode,
            color: textColor,
            fontWeight: WebFonts.bold,
          ),
        ),
      ),
    );
  }

  void _handleRedeem() {
    final mfData = ref.read(mfProvider);
    // Set the holding data for redemption using the ISIN
    mfData.fetchmfholdsingpage(widget.holding.iSIN ?? '');
    // Call the redeem evaluation function
    mfData.recdemevalu();
    
    // Get root context before closing sheet
    final rootContext = rootNavigatorKey.currentContext ?? context;
    
    // Close the sheet
    shadcn.closeSheet(context);
    
    // Show web redeem dialog using root context to ensure it shows even after sheet closes
    Future.delayed(const Duration(milliseconds: 150), () {
      if (rootContext.mounted) {
        showDialog(
          context: rootContext,
          builder: (context) => const RedemptionBottomSheetWeb(),
        );
      }
    });
  }

  Widget _buildReturnsSection(ThemesProvider theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              "Returns",
              style: WebTextStyles.title(
                isDarkTheme: theme.isDarkMode,
                color: shadcn.Theme.of(context).colorScheme.mutedForeground,
                fontWeight: WebFonts.medium,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${widget.holding.profitLoss ?? "0.00"}",
              style: WebTextStyles.head(
                isDarkTheme: theme.isDarkMode,
                color: _getValueColor(widget.holding.profitLoss ?? '0.00', context),
                fontWeight: WebFonts.medium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowOfInfoData("Units", widget.holding.avgQty ?? '0', theme),
          const SizedBox(height: 8),
          _rowOfInfoData("Avg Price", widget.holding.avgNav ?? '0.00', theme),
          const SizedBox(height: 8),
          _rowOfInfoData("NAV", widget.holding.curNav ?? '0.00', theme),
          const SizedBox(height: 8),
          _rowOfInfoData("Pledged Units", "0", theme),
          const SizedBox(height: 8),
          _rowOfInfoData("Current Value", widget.holding.currentValue ?? '0.00', theme),
          const SizedBox(height: 8),
          _rowOfInfoData("Invested", widget.holding.investedValue ?? '0.00', theme),
        ],
      ),
    );
  }

  Widget _rowOfInfoData(String title1, String value1, ThemesProvider theme) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title1,
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: colorScheme.mutedForeground,
              fontWeight: WebFonts.medium,
            ),
          ),
          Text(
            value1,
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: colorScheme.foreground,
              fontWeight: WebFonts.medium,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      
    ]);
  }

  Color _getValueColor(String value, BuildContext context) {
    final colorScheme = shadcn.Theme.of(context).colorScheme;
    final numValue = double.tryParse(value) ?? 0.0;
    
    if (numValue > 0) {
      return colorScheme.chart2;
    } else if (numValue < 0) {
      return colorScheme.destructive;
    } else {
      return colorScheme.mutedForeground;
    }
  }
}
