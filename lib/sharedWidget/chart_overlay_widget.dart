import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/chart_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';
import 'package:mynt_plus/main.dart' show getNavigatorState;

import '../screens/Mobile/market_watch/tv_chart/webview_chart.dart';

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
          final originalArgs = chartState.originalArgs;
          ref.read(chartProvider.notifier).hideChart();
          
          // Handle navigation after hiding chart
          if (prevRoute != null && prevRoute.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (prevRoute == Routes.optionChain && originalArgs != null) {
                // Use the stored original DepthInputArgs to navigate back to option chain
                getNavigatorState()?.pushNamedAndRemoveUntil(
                  Routes.optionChain, 
                  (route) => route.settings.name == Routes.homeScreen || route.isFirst,
                  arguments: originalArgs
                );
              } else if (prevRoute == Routes.positionGroupDetail ||
                         prevRoute == Routes.positionDetail ||
                         prevRoute == Routes.holdingDetail) {
                // For portfolio screens, navigate back without special arguments
                getNavigatorState()?.pushNamedAndRemoveUntil(
                  prevRoute, 
                  (route) => route.settings.name == Routes.homeScreen || route.isFirst
                );
              } else {
                getNavigatorState()?.pushReplacementNamed(prevRoute);
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
                    ChartScreenWebView(
                      chartArgs: chartState.chartArgs!,
                      onSearchTap: () {
                        // Hide chart overlay before opening search
                        ref.read(chartProvider.notifier).hideChart();
                        getNavigatorState()?.pushNamed(
                          Routes.searchScrip,
                          arguments: "Chart||Is",
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}