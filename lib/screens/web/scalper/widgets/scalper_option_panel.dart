import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import 'scalper_option_row.dart';

/// Option panel (Calls or Puts) with list of strikes
class ScalperOptionPanel extends ConsumerWidget {
  final bool isCall;
  final List<OptionValues> options;
  final List<String> strikes;
  final String atmStrike;
  final String lotSize;

  const ScalperOptionPanel({
    super.key,
    required this.isCall,
    required this.options,
    required this.strikes,
    required this.atmStrike,
    required this.lotSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build a map for O(1) lookup
    final optionsMap = <String, OptionValues>{};
    for (final option in options) {
      if (option.strprc != null) {
        optionsMap[option.strprc!] = option;
      }
    }

    return Container(
      color: isCall
          ? resolveThemeColor(
              context,
              dark: MyntColors.profitDark.withValues(alpha: 0.03),
              light: MyntColors.profit.withValues(alpha: 0.03),
            )
          : resolveThemeColor(
              context,
              dark: MyntColors.lossDark.withValues(alpha: 0.03),
              light: MyntColors.loss.withValues(alpha: 0.03),
            ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          Divider(
            height: 1,
            color: resolveThemeColor(
              context,
              dark: MyntColors.dividerDark,
              light: MyntColors.divider,
            ),
          ),
          // Options list
          Expanded(
            child: strikes.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    itemCount: strikes.length,
                    itemExtent: 56, // Fixed height for performance
                    itemBuilder: (context, index) {
                      final strike = strikes[index];
                      final option = optionsMap[strike];
                      final isATM = strike == atmStrike;

                      return ScalperOptionRow(
                        isCall: isCall,
                        strike: strike,
                        option: option,
                        isATM: isATM,
                        lotSize: lotSize,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final headerColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);

    final topStyle = MyntWebTextStyles.para(
      context, fontWeight: MyntFonts.medium, color: headerColor,
    );
    final subStyle = MyntWebTextStyles.caption(context, color: subColor);

    Widget buildStacked(String top, String sub) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(top, style: topStyle, textAlign: TextAlign.center),
          Text('($sub)', style: subStyle, textAlign: TextAlign.center),
        ],
      );
    }

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: resolveThemeColor(
        context,
        dark: MyntColors.listItemBgDark,
        light: MyntColors.listItemBg,
      ),
      child: Row(
        children: isCall
            ? [
                // CALLS: OI(L) | LTP(CH%) | Strike | Actions
                Expanded(child: buildStacked('OI', 'L')),
                Expanded(child: buildStacked('LTP', 'CH%')),
                SizedBox(
                  width: 70,
                  child: Center(
                    child: Text('STRIKE', style: MyntWebTextStyles.para(
                      context, fontWeight: MyntFonts.semiBold, color: headerColor,
                    )),
                  ),
                ),
                const SizedBox(width: 120),
              ]
            : [
                // PUTS: Actions | Strike | LTP(CH%) | OI(L)
                const SizedBox(width: 120),
                SizedBox(
                  width: 70,
                  child: Center(
                    child: Text('STRIKE', style: MyntWebTextStyles.para(
                      context, fontWeight: MyntFonts.semiBold, color: headerColor,
                    )),
                  ),
                ),
                Expanded(child: buildStacked('LTP', 'CH%')),
                Expanded(child: buildStacked('OI', 'L')),
              ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 32,
            color: resolveThemeColor(
              context,
              dark: MyntColors.textSecondaryDark,
              light: MyntColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Loading options...',
            style: MyntWebTextStyles.body(
              context,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
