import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import 'scalper_order_buttons.dart';

/// Single option row for the scalper screen
/// Shows: OI | LTP | Strike | Order Buttons (for calls)
/// Or: Order Buttons | Strike | LTP | OI (for puts - mirrored)
class ScalperOptionRow extends ConsumerStatefulWidget {
  final bool isCall;
  final String strike;
  final OptionValues? option;
  final bool isATM;
  final String lotSize;

  const ScalperOptionRow({
    super.key,
    required this.isCall,
    required this.strike,
    required this.option,
    required this.isATM,
    required this.lotSize,
  });

  @override
  ConsumerState<ScalperOptionRow> createState() => _ScalperOptionRowState();
}

class _ScalperOptionRowState extends ConsumerState<ScalperOptionRow> {
  // PERFORMANCE: Use ValueNotifier for hover - no setState rebuilds
  final _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketData = widget.option?.token != null
        ? ref.watch(websocketProvider).socketDatas[widget.option!.token]
        : null;

    // Calculate values from websocket data (with fallbacks)
    final lp = socketData?['lp']?.toString() ??
        widget.option?.lp ??
        widget.option?.close ??
        "0.00";
    final perChange =
        socketData?['pc']?.toString() ?? widget.option?.perChange ?? "0.00";
    final currentOI =
        double.tryParse(socketData?['oi']?.toString() ?? widget.option?.oi ?? "0") ?? 0.0;
    final oiLakh = (currentOI / 100000).toStringAsFixed(2);

    final changeColor = perChange.startsWith("-")
        ? resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss)
        : (perChange == "0.00" || perChange == "0.0" || perChange == "0")
            ? resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary)
            : resolveThemeColor(context,
                dark: MyntColors.profitDark, light: MyntColors.profit);

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => _isHovered.value = true,
        onExit: (_) => _isHovered.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isHovered,
          builder: (context, isHovered, child) {
            return Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: widget.isATM
                    ? resolveThemeColor(
                        context,
                        dark: MyntColors.primaryDark.withValues(alpha: 0.12),
                        light: MyntColors.primary.withValues(alpha: 0.12),
                      )
                    : isHovered
                        ? resolveThemeColor(
                            context,
                            dark: MyntColors.listItemBgDark,
                            light: MyntColors.listItemBg,
                          )
                        : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: resolveThemeColor(
                      context,
                      dark: MyntColors.dividerDark.withValues(alpha: 0.5),
                      light: MyntColors.divider.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              child: widget.isCall
                  ? _buildCallRow(context, lp, perChange, oiLakh, changeColor)
                  : _buildPutRow(context, lp, perChange, oiLakh, changeColor),
            );
          },
        ),
      ),
    );
  }

  /// Build row for CALL options: OI | LTP | Strike | Buttons
  Widget _buildCallRow(
    BuildContext context,
    String ltp,
    String perChange,
    String oiLakh,
    Color changeColor,
  ) {
    return Row(
      children: [
        // OI column
        Expanded(
          child: _buildOICell(context, oiLakh),
        ),
        // LTP column
        Expanded(
          child: _buildLTPCell(context, ltp, perChange, changeColor),
        ),
        // Strike price
        _buildStrikeCell(context),
        // Order buttons
        ScalperOrderButtons(
          option: widget.option,
          lotSize: widget.lotSize,
          isCall: true,
        ),
      ],
    );
  }

  /// Build row for PUT options: Buttons | Strike | LTP | OI
  Widget _buildPutRow(
    BuildContext context,
    String ltp,
    String perChange,
    String oiLakh,
    Color changeColor,
  ) {
    return Row(
      children: [
        // Order buttons
        ScalperOrderButtons(
          option: widget.option,
          lotSize: widget.lotSize,
          isCall: false,
        ),
        // Strike price
        _buildStrikeCell(context),
        // LTP column
        Expanded(
          child: _buildLTPCell(context, ltp, perChange, changeColor),
        ),
        // OI column
        Expanded(
          child: _buildOICell(context, oiLakh),
        ),
      ],
    );
  }

  Widget _buildOICell(BuildContext context, String oiLakh) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          oiLakh,
          textAlign: TextAlign.center,
          style: MyntWebTextStyles.body(
            context,
            fontWeight: MyntFonts.medium,
            color: (oiLakh == "0.00" || oiLakh == "0.0")
                ? resolveThemeColor(context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary)
                : resolveThemeColor(context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary),
          ),
        ),
        Text(
          'L',
          style: MyntWebTextStyles.caption(
            context,
            color: resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildLTPCell(
    BuildContext context,
    String ltp,
    String perChange,
    Color changeColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          ltp,
          textAlign: TextAlign.center,
          style: MyntWebTextStyles.body(
            context,
            fontWeight: MyntFonts.medium,
            color: resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary),
          ),
        ),
        Text(
          '$perChange%',
          textAlign: TextAlign.center,
          style: MyntWebTextStyles.para(
            context,
            color: changeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStrikeCell(BuildContext context) {
    return Container(
      width: 70,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.strike,
            style: MyntWebTextStyles.body(
              context,
              fontWeight: widget.isATM ? MyntFonts.bold : MyntFonts.semiBold,
              color: widget.isATM
                  ? resolveThemeColor(context,
                      dark: MyntColors.primaryDark, light: MyntColors.primary)
                  : resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
            ),
          ),
          if (widget.isATM)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: resolveThemeColor(context,
                    dark: MyntColors.primaryDark, light: MyntColors.primary),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'ATM',
                style: MyntWebTextStyles.caption(
                  context,
                  fontWeight: MyntFonts.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
