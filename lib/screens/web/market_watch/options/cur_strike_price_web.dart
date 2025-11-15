import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/market_watch_provider.dart';
import '../../../../provider/websocket_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/web_colors.dart';
import '../../../../res/global_font_web.dart';

class CurStrkprice extends ConsumerWidget {
  final String token;

  const CurStrkprice({super.key, required this.token});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strikePrc = ref.watch(marketWatchProvider).getStikePrc ?? ref.watch(marketWatchProvider).getQuotes;
    final theme = ref.watch(themeProvider);
    
    return StreamBuilder<Map>(
      stream: ref.watch(websocketProvider).socketDataStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildStrikePriceWidget(strikePrc!.lp ?? "0.00", strikePrc.pc ?? "0.00", theme);
        }
        
        final socketDatas = snapshot.data!;
        String price = strikePrc!.lp ?? "0.00";
        String pc = strikePrc.pc ?? "0.00";
        if (socketDatas.containsKey(token)) {
          price = "${socketDatas[token]['lp']}";
          pc = "${socketDatas[token]['pc']}";
        }
        
        ref.watch(marketWatchProvider).updateOptStrPrc(price);
        return _buildStrikePriceWidget(price, pc, theme);
      },
    );
  }
  
  Widget _buildStrikePriceWidget(String price, String pc, ThemesProvider theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            height: 0,
            thickness: 2.5,
            color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
            borderRadius: BorderRadius.circular(40),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(
            "₹$price (${(double.tryParse(pc) ?? 0).toStringAsFixed(2)}%)",
            style: WebTextStyles.sub(
              isDarkTheme: theme.isDarkMode,
              color: Colors.white,
              fontWeight: WebFonts.medium,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            height: 0,
            thickness: 2.5,
            color: theme.isDarkMode ? WebDarkColors.textSecondary : WebColors.textSecondary,
          ),
        ),
      ],
    );
  }

 
}
