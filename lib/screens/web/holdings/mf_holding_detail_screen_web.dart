import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../../../../provider/thems.dart';
import '../../../res/mynt_web_text_styles.dart';
import '../../../res/mynt_web_color_styles.dart';

class MfHoldingDetailScreenWeb extends ConsumerStatefulWidget {
  final dynamic holding;

  const MfHoldingDetailScreenWeb({
    super.key,
    required this.holding,
  });

  @override
  ConsumerState<MfHoldingDetailScreenWeb> createState() =>
      _MfHoldingDetailScreenWebState();
}

class _MfHoldingDetailScreenWebState
    extends ConsumerState<MfHoldingDetailScreenWeb> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      color: resolveThemeColor(context,
          dark: MyntColors.listItemBgDark, light: MyntColors.textWhite),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Close icon and "Holding Details" title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: resolveThemeColor(context,
                      dark: MyntColors.dividerDark, light: MyntColors.divider),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                shadcn.IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => shadcn.closeSheet(context),
                  variance: shadcn.ButtonVariance.ghost,
                  size: shadcn.ButtonSize.small,
                ),
                const SizedBox(width: 12),
                Text(
                  "Holding Details",
                  style: MyntWebTextStyles.title(
                    context,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textPrimaryDark,
                        light: MyntColors.textPrimary),
                    fontWeight: MyntFonts.medium,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fund Name
                  Text(
                    widget.holding.name ?? 'Mutual Fund',
                    style: MyntWebTextStyles.head(
                      context,
                      color: resolveThemeColor(context,
                          dark: MyntColors.textPrimaryDark,
                          light: MyntColors.textPrimary),
                      fontWeight: MyntFonts.medium,
                    ),
                  ),
                  const SizedBox(height: 1),

                  // Action Buttons (keep existing logic but styled)
                  _buildActionButtons(theme),
                  const SizedBox(height: 5),

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
    return const SizedBox.shrink();
  }

  Widget _buildDetailsSection(ThemesProvider theme) {
    final pnlValue = widget.holding.profitLoss ?? "0.00";
    final pnlPer = widget.holding.changeprofitLoss ?? "0.00";
    final pnlColor = _getValueColor(pnlValue, context);

    return Column(
      children: [
        // Returns item
        _rowOfInfoData(
          "Returns",
          Text(
            "$pnlValue ($pnlPer %)",
            style: MyntWebTextStyles.body(context,
                color: pnlColor, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Units",
          Text(
            "${widget.holding.avgQty ?? '0'}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Avg Price",
          Text(
            "${widget.holding.avgNav ?? '0.00'}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "NAV",
          Text(
            "${widget.holding.curNav ?? '0.00'}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Pledged Units",
          Text(
            "0",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Current",
          Text(
            "${widget.holding.currentValue ?? '0.00'}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
        ),
        _rowOfInfoData(
          "Invested",
          Text(
            "${widget.holding.investedValue ?? '0.00'}",
            style:
                MyntWebTextStyles.body(context, fontWeight: MyntFonts.medium),
          ),
          theme,
          showDivider: false,
        ),
      ],
    );
  }

  Widget _rowOfInfoData(String title1, Widget valueWidget, ThemesProvider theme,
      {bool showDivider = true}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title1,
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                  fontWeight: MyntFonts.medium,
                ),
              ),
              valueWidget,
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: resolveThemeColor(context,
                dark: MyntColors.dividerDark, light: MyntColors.divider),
          ),
      ],
    );
  }

  Color _getValueColor(String value, BuildContext context) {
    final numValue = double.tryParse(value) ?? 0.0;

    if (numValue > 0) {
      return resolveThemeColor(context,
          dark: MyntColors.profitDark, light: MyntColors.profit);
    } else if (numValue < 0) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    } else {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }
  }
}
