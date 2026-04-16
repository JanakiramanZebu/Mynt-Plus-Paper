import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';

class CurStrkprice extends ConsumerWidget {
  final String token;

  const CurStrkprice({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // PERFORMANCE FIX: Use .select() to watch ONLY this token's socket data
    // This replaces StreamBuilder which was causing continuous rebuilds
    final socketData = ref.watch(
      websocketProvider.select((provider) => provider.socketDatas[token])
    );

    // Watch only the specific fields we need, not entire provider
    final strikePrc = ref.watch(marketWatchProvider.select((p) => p.getStikePrc)) ??
                      ref.watch(marketWatchProvider.select((p) => p.getQuotes));
    final theme = ref.watch(themeProvider);

    // Get price from socket data or fall back to strike price data
    final price = socketData?['lp']?.toString() ?? strikePrc?.lp ?? "0.00";
    final pc = socketData?['pc']?.toString() ?? strikePrc?.pc ?? "0.00";

    // PERFORMANCE FIX: Removed mutation from build()
    // ref.watch(...).updateOptStrPrc() was causing rebuild loops
    // If this update is needed, it should be done via ref.listen() in a StatefulWidget
    // or handled in the provider itself when socket data changes

    return _buildStrikePriceWidget(context, price, pc, theme);
  }

  Widget _buildStrikePriceWidget(
      BuildContext context, String price, String pc , ThemesProvider theme) {
    final secondaryColor = resolveThemeColor(
      context,
      dark: MyntColors.textSecondaryDark,
      light: MyntColors.textSecondary,
    );

    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 0,
            thickness: 2.5,
            color: secondaryColor,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(
            "₹$price (${(double.tryParse(pc) ?? 0).toStringAsFixed(2)}%)",
            style: MyntWebTextStyles.body(
              context,
              color: Colors.white,
              fontWeight: MyntFonts.medium,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: 0,
            thickness: 2.5,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}
