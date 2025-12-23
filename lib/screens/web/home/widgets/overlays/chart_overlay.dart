import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/provider/user_profile_provider.dart';
import 'package:mynt_plus/res/web_colors.dart';
import 'package:mynt_plus/screens/web/market_watch/tv_chart/webview_chart.dart';
import 'package:mynt_plus/models/marketwatch_model/market_watch_scrip_model.dart';

class ChartOverlay extends ConsumerWidget {
  const ChartOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showChart = ref.watch(
        userProfileProvider.select((userProfile) => userProfile.showchartof));
    final webViewKey = ref.watch(
        userProfileProvider.select((userProfile) => userProfile.webViewKey));
    final theme = ref.watch(themeProvider);

    return Positioned(
      key: webViewKey,
      bottom: showChart ? 0 : (MediaQuery.of(context).size.height + 100),
      child: AnimatedContainer(
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastLinearToSlowEaseIn,
        decoration: BoxDecoration(
          color: theme.isDarkMode ? WebDarkColors.surface : WebColors.surface,
        ),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ChartScreenWebViews(
                  chartArgs:
                      ChartArgs(exch: 'ABC', tsym: 'ABCD', token: '0123')),
            ],
          ),
        ),
      ),
    );
  }
}
