import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/chart_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/screens/market_watch/tv_chart/webview_chart.dart';

class ChartOverlayWidget extends ConsumerWidget {
  const ChartOverlayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartState = ref.watch(chartProvider);
    final theme = ref.watch(themeProvider);

    return PopScope(
      canPop: !chartState.isVisible,
      onPopInvokedWithResult: (didPop, result) {
        if (chartState.isVisible) {
          final prevRoute = chartState.previousRoute;
          ref.read(chartProvider.notifier).hideChart();
          
          // Handle navigation after hiding chart
          if (prevRoute != null && prevRoute.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (prevRoute == Routes.optionChain) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.optionChain, 
                  (route) => route.settings.name == Routes.homeScreen || route.isFirst
                );
              } else {
                Navigator.of(context).pushReplacementNamed(prevRoute);
              }
            });
          }
        }
      },
      child: Positioned(
        bottom: chartState.isVisible ? 0 : (MediaQuery.of(context).size.height + 100),
        child: Material(
          type: MaterialType.transparency,
          child: AnimatedContainer(
            alignment: Alignment.center,
            duration: const Duration(milliseconds: 100),
            curve: Curves.fastLinearToSlowEaseIn,
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            ),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (chartState.chartArgs != null)
                    ChartScreenWebView(chartArgs: chartState.chartArgs!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}