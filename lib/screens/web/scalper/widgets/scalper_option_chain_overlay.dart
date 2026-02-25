import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../sharedWidget/hover_actions_web.dart';
import '../scalper_provider.dart';

/// Option Chain overlay matching the stock depth option chain UI exactly
/// Layout: [Call Cell (OI+OI% | LTP+CH%)] [Strike (150px)] [Put Cell (LTP+CH% | OI+OI%)]
/// Hover shows chart icon - clicking it selects the option for the target chart
class ScalperOptionChainOverlay extends ConsumerWidget {
  final VoidCallback onClose;
  final Function(OptionValues option) onOptionSelected;

  const ScalperOptionChainOverlay({
    super.key,
    required this.onClose,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scalper = ref.watch(scalperProvider);
    final indexName = scalper.selectedIndex.name;
    final spotPrice = scalper.currentIndexLTP;
    final indexToken = scalper.selectedIndex.token;

    // Get index data from websocket
    final indexData = ref.watch(websocketProvider).socketDatas[indexToken];
    final change = indexData?['chng']?.toString() ?? '0.00';
    final perChange = indexData?['pc']?.toString() ?? '0.00';

    final isPositive =
        !change.startsWith('-') && change != '0.00' && change != '0';
    final changeColor = isPositive
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);

    return Column(
      children: [
        // Header
        _buildHeader(
            context, indexName, spotPrice, change, perChange, changeColor),
        // Two-row column headers matching stock depth
        _buildColumnHeaders(context),
        // Option chain rows
        Expanded(
          child: _buildOptionChainList(context, ref, scalper),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String indexName, double spotPrice,
      String change, String perChange, Color changeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: resolveThemeColor(
        context,
        dark: MyntColors.listItemBgDark,
        light: MyntColors.listItemBg,
      ),
      child: Row(
        children: [
          Text(
            indexName,
            style: MyntWebTextStyles.title(
              context,
              fontWeight: MyntFonts.semiBold,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Spot: ${spotPrice.toStringAsFixed(2)}',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$change ($perChange%)',
                style: MyntWebTextStyles.para(context, color: changeColor),
              ),
            ],
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close,
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

  /// Two-row column headers matching the stock depth option chain exactly
  Widget _buildColumnHeaders(BuildContext context) {
    final headerColor = resolveThemeColor(context,
        dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
    final subHeaderColor = resolveThemeColor(context,
        dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    final borderColor = resolveThemeColor(context,
        dark: const Color(0xFFF1F3F8),
        light: MyntColors.primary.withValues(alpha: 0.07));

    return Column(
      children: [
        // Row 1: CALLS | STRIKES | PUTS
        Container(
          height: 35,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Center(
                  child: Text(
                    'CALLS',
                    style: MyntWebTextStyles.body(context,
                        fontWeight: MyntFonts.medium, color: headerColor),
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: Center(
                  child: Text(
                    'STRIKES',
                    style: MyntWebTextStyles.body(context,
                        fontWeight: MyntFonts.medium, color: headerColor),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Center(
                  child: Text(
                    'PUTS',
                    style: MyntWebTextStyles.body(context,
                        fontWeight: MyntFonts.medium, color: headerColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Row 2: OI/(OI ch) | LTP/(CH) | (empty 150px) | LTP/(CH) | OI/(OI ch)
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              // Call sub-headers: OI/(OI ch) | LTP/(CH)
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    Expanded(
                        child: _buildStackedSubHeader(
                            context, 'OI', 'OI ch', headerColor, subHeaderColor)),
                    Expanded(
                        child: _buildStackedSubHeader(
                            context, 'LTP', 'CH', headerColor, subHeaderColor)),
                  ],
                ),
              ),
              const SizedBox(width: 150),
              // Put sub-headers: LTP/(CH) | OI/(OI ch)
              Expanded(
                flex: 6,
                child: Row(
                  children: [
                    Expanded(
                        child: _buildStackedSubHeader(
                            context, 'LTP', 'CH', headerColor, subHeaderColor)),
                    Expanded(
                        child: _buildStackedSubHeader(
                            context, 'OI', 'OI ch', headerColor, subHeaderColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStackedSubHeader(BuildContext context, String topText,
      String bottomText, Color topColor, Color bottomColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          topText,
          style: MyntWebTextStyles.para(context,
              fontWeight: MyntFonts.medium, color: topColor),
          textAlign: TextAlign.center,
        ),
        Text(
          '($bottomText)',
          style: MyntWebTextStyles.para(context,
              fontWeight: MyntFonts.regular, color: bottomColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOptionChainList(
      BuildContext context, WidgetRef ref, ScalperProvider scalper) {
    final strikes = scalper.getDisplayStrikes();
    final atmStrike = scalper.atmStrike;
    final spotPrice = scalper.currentIndexLTP;

    if (strikes.isEmpty) {
      return Center(
        child: Text(
          'Loading option chain...',
          style: MyntWebTextStyles.body(
            context,
            color: resolveThemeColor(context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary),
          ),
        ),
      );
    }

    // Find where to insert the LTP center line
    final ltpLineIndex = _findSpotInsertIndex(strikes, spotPrice);
    final totalItemCount = strikes.length + 1; // +1 for LTP line

    return ListView.builder(
      itemCount: totalItemCount,
      itemExtent: 56, // Fixed height matching stock depth
      itemBuilder: (context, index) {
        if (index == ltpLineIndex) {
          return _buildLtpCenterLine(context, spotPrice);
        }

        final strikeIndex = index > ltpLineIndex ? index - 1 : index;
        if (strikeIndex >= strikes.length) return const SizedBox.shrink();

        final strike = strikes[strikeIndex];
        final call = scalper.getCallForStrike(strike);
        final put = scalper.getPutForStrike(strike);
        final isATM = strike == atmStrike;
        final strikeNum = double.tryParse(strike) ?? 0;
        final isITMCall = strikeNum < spotPrice;
        final isITMPut = strikeNum > spotPrice;

        return _ScalperOptionChainRow(
          key: ValueKey('row-$strike'),
          strike: strike,
          call: call,
          put: put,
          isATM: isATM,
          isITMCall: isITMCall,
          isITMPut: isITMPut,
          callStrike: scalper.callStrike,
          putStrike: scalper.putStrike,
          onCallTap: call != null ? () => onOptionSelected(call) : null,
          onPutTap: put != null ? () => onOptionSelected(put) : null,
        );
      },
    );
  }

  int _findSpotInsertIndex(List<String> strikes, double spotPrice) {
    for (int i = 0; i < strikes.length; i++) {
      final strikePrice = double.tryParse(strikes[i]) ?? 0;
      if (strikePrice > spotPrice) return i;
    }
    return strikes.length;
  }

  /// LTP center line matching the stock depth option chain
  Widget _buildLtpCenterLine(BuildContext context, double spotPrice) {
    final primary = resolveThemeColor(
        context, dark: MyntColors.primaryDark, light: MyntColors.primary);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Left gradient line (Calls side)
          Expanded(
            flex: 6,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, primary],
                ),
              ),
            ),
          ),
          // Center LTP badge
          Container(
            width: 150,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                spotPrice.toStringAsFixed(2),
                textAlign: TextAlign.center,
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Right gradient line (Puts side)
          Expanded(
            flex: 6,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual row matching the stock depth option chain layout exactly
/// [Call Cell (OI+OI% | LTP+CH%)] [Strike (150px)] [Put Cell (LTP+CH% | OI+OI%)]
/// Hover shows chart icon - clicking it selects the strike for that chart
class _ScalperOptionChainRow extends ConsumerStatefulWidget {
  final String strike;
  final OptionValues? call;
  final OptionValues? put;
  final bool isATM;
  final bool isITMCall;
  final bool isITMPut;
  final String callStrike;
  final String putStrike;
  final VoidCallback? onCallTap;
  final VoidCallback? onPutTap;

  const _ScalperOptionChainRow({
    super.key,
    required this.strike,
    required this.call,
    required this.put,
    required this.isATM,
    required this.isITMCall,
    required this.isITMPut,
    required this.callStrike,
    required this.putStrike,
    required this.onCallTap,
    required this.onPutTap,
  });

  @override
  ConsumerState<_ScalperOptionChainRow> createState() =>
      _ScalperOptionChainRowState();
}

class _ScalperOptionChainRowState
    extends ConsumerState<_ScalperOptionChainRow> {
  // PERFORMANCE: Use ValueNotifier for hover - no setState rebuilds
  final _isCallHovered = ValueNotifier<bool>(false);
  final _isPutHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isCallHovered.dispose();
    _isPutHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wsData = ref.watch(websocketProvider).socketDatas;
    final callSocketData =
        widget.call?.token != null ? wsData[widget.call!.token] : null;
    final putSocketData =
        widget.put?.token != null ? wsData[widget.put!.token] : null;

    return RepaintBoundary(
      child: Row(
        children: [
          // CALL cell (flex: 6)
          Expanded(
            flex: 6,
            child: _buildCallCell(context, callSocketData),
          ),
          // STRIKE cell (fixed width: 150)
          _buildStrikeCell(context),
          // PUT cell (flex: 6)
          Expanded(
            flex: 6,
            child: _buildPutCell(context, putSocketData),
          ),
        ],
      ),
    );
  }

  Widget _buildCallCell(
      BuildContext context, Map<String, dynamic>? socketData) {
    final option = widget.call;
    if (option == null) return const SizedBox.shrink();

    // Calculate values from websocket data (with fallbacks)
    final lp =
        socketData?['lp']?.toString() ?? option.lp ?? option.close ?? '0.00';
    final perChange =
        socketData?['pc']?.toString() ?? option.perChange ?? '0.00';
    final currentOI =
        double.tryParse(socketData?['oi']?.toString() ?? option.oi ?? '0') ??
            0.0;
    final oiLack = (currentOI / 100000).toStringAsFixed(2);

    // Calculate OI percentage change
    final poi = double.tryParse(
            socketData?['poi']?.toString() ?? option.poi ?? '0') ??
        0.0;
    String oiPerChng = '0.00';
    if (poi > 0) {
      oiPerChng = (((currentOI - poi) / poi) * 100).toStringAsFixed(2);
    }

    final changeColor = _priceChangeColor(context, perChange);
    final isSelected = widget.strike == widget.callStrike;

    return MouseRegion(
      onEnter: (_) => _isCallHovered.value = true,
      onExit: (_) => _isCallHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isCallHovered,
        builder: (context, isHovered, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            color: isSelected
                ? resolveThemeColor(context,
                    dark: MyntColors.primaryDark.withValues(alpha: 0.2),
                    light: MyntColors.primary.withValues(alpha: 0.12))
                : isHovered
                    ? resolveThemeColor(context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary)
                        .withValues(alpha: 0.15)
                    : Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Data row - CALLS: OI/(OI ch) | LTP/(CH%)
                Row(
                  children: [
                    // OI column with OI% below
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            oiLack,
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.body(
                              context,
                              fontWeight: FontWeight.w500,
                              color: _valueColor(context, oiLack),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '(${oiPerChng == "NaN" ? "0.00" : oiPerChng}%)',
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.para(
                              context,
                              fontWeight: FontWeight.w400,
                              color: _oiChangeColor(context, oiPerChng),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // LTP column with CH% below
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lp,
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.body(
                              context,
                              fontWeight: FontWeight.w500,
                              color: _valueColor(context, lp),
                            ),
                          ),
                          Text(
                            '($perChange%)',
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.para(
                              context,
                              fontWeight: FontWeight.w400,
                              color: changeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Hover action: select icon to choose this strike for call chart
                if (isHovered && widget.onCallTap != null)
                  Center(
                    child: GestureDetector(
                      onTap: widget.onCallTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textWhite,
                            light: MyntColors.textWhite,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: resolveThemeColor(
                                context,
                                dark: Colors.transparent,
                                light: Colors.grey,
                              ),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPutCell(
      BuildContext context, Map<String, dynamic>? socketData) {
    final option = widget.put;
    if (option == null) return const SizedBox.shrink();

    // Calculate values from websocket data (with fallbacks)
    final lp =
        socketData?['lp']?.toString() ?? option.lp ?? option.close ?? '0.00';
    final perChange =
        socketData?['pc']?.toString() ?? option.perChange ?? '0.00';
    final currentOI =
        double.tryParse(socketData?['oi']?.toString() ?? option.oi ?? '0') ??
            0.0;
    final oiLack = (currentOI / 100000).toStringAsFixed(2);

    // Calculate OI percentage change
    final poi = double.tryParse(
            socketData?['poi']?.toString() ?? option.poi ?? '0') ??
        0.0;
    String oiPerChng = '0.00';
    if (poi > 0) {
      oiPerChng = (((currentOI - poi) / poi) * 100).toStringAsFixed(2);
    }

    final changeColor = _priceChangeColor(context, perChange);
    final isSelected = widget.strike == widget.putStrike;

    return MouseRegion(
      onEnter: (_) => _isPutHovered.value = true,
      onExit: (_) => _isPutHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isPutHovered,
        builder: (context, isHovered, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            color: isSelected
                ? resolveThemeColor(context,
                    dark: MyntColors.primaryDark.withValues(alpha: 0.2),
                    light: MyntColors.primary.withValues(alpha: 0.12))
                : isHovered
                    ? resolveThemeColor(context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary)
                        .withValues(alpha: 0.15)
                    : Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Data row - PUTS: LTP/(CH%) | OI/(OI ch) (mirrored layout)
                Row(
                  children: [
                    // LTP column with CH% below
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lp,
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.body(
                              context,
                              fontWeight: FontWeight.w500,
                              color: _valueColor(context, lp),
                            ),
                          ),
                          Text(
                            '($perChange%)',
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.para(
                              context,
                              fontWeight: FontWeight.w400,
                              color: changeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // OI column with OI% below
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            oiLack,
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.body(
                              context,
                              fontWeight: FontWeight.w500,
                              color: _valueColor(context, oiLack),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '(${oiPerChng == "NaN" ? "0.00" : oiPerChng}%)',
                            textAlign: TextAlign.center,
                            style: MyntWebTextStyles.para(
                              context,
                              fontWeight: FontWeight.w400,
                              color: _oiChangeColor(context, oiPerChng),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Hover action: select icon to choose this strike for put chart
                if (isHovered && widget.onPutTap != null)
                  Center(
                    child: GestureDetector(
                      onTap: widget.onPutTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textWhite,
                            light: MyntColors.textWhite,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: resolveThemeColor(
                                context,
                                dark: Colors.transparent,
                                light: Colors.grey,
                              ),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.primaryDark,
                            light: MyntColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrikeCell(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(
              color: resolveThemeColor(context,
                  dark: MyntColors.dividerDark, light: MyntColors.divider),
              width: 0.5,
            ),
          ),
        ),
        child: Text(
          widget.strike,
          style: MyntWebTextStyles.body(
            context,
            fontWeight: FontWeight.w500,
            color: resolveThemeColor(context,
                dark: MyntColors.textPrimaryDark,
                light: MyntColors.textPrimary),
          ),
        ),
      ),
    );
  }

  /// Color for value text (dimmed when zero)
  Color _valueColor(BuildContext context, String value) {
    return (value == '0.00' || value == '0.0')
        ? resolveThemeColor(context,
            dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary)
        : resolveThemeColor(context,
            dark: MyntColors.textPrimaryDark, light: MyntColors.textPrimary);
  }

  /// Color for price change percentage
  Color _priceChangeColor(BuildContext context, String perChange) {
    if (perChange.startsWith('-')) {
      return resolveThemeColor(context,
          dark: MyntColors.lossDark, light: MyntColors.loss);
    }
    if (perChange == '0.00' || perChange == '0.0') {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }
    return resolveThemeColor(context,
        dark: MyntColors.profitDark, light: MyntColors.profit);
  }

  /// Color for OI change percentage
  Color _oiChangeColor(BuildContext context, String oiPerChng) {
    if (oiPerChng == '0.00' || oiPerChng == '0.0') {
      return resolveThemeColor(context,
          dark: MyntColors.textSecondaryDark, light: MyntColors.textSecondary);
    }
    return oiPerChng.startsWith('-')
        ? resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss)
        : resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit);
  }
}
