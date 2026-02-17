import 'package:flutter/material.dart';

import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../scalper_chart_manager.dart';

/// TradingView chart panel for the scalper screen
/// Uses LOCAL TradingView library from web/tv/ folder
class ScalperChartPanel extends StatelessWidget {
  final String indexSymbol;
  final String token;

  const ScalperChartPanel({
    super.key,
    required this.indexSymbol,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: resolveThemeColor(
        context,
        dark: MyntColors.backgroundColorDark,
        light: MyntColors.backgroundColor,
      ),
      child: Column(
        children: [
          // Chart header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: resolveThemeColor(
              context,
              dark: MyntColors.listItemBgDark,
              light: MyntColors.listItemBg,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 16,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  indexSymbol,
                  style: MyntWebTextStyles.bodySmall(
                    context,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Local chart indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.profitDark.withValues(alpha: 0.2),
                      light: MyntColors.profit.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'LOCAL',
                    style: webText(
                      context,
                      size: 9,
                      weight: MyntFonts.semiBold,
                      darkColor: MyntColors.profitDark,
                      lightColor: MyntColors.profit,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
          // Chart - uses LOCAL TradingView from web/tv/
          Expanded(
            child: ClipRect(
              child: HtmlElementView(
                key: const ValueKey(ScalperChartManager.viewType),
                viewType: ScalperChartManager.viewType,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
