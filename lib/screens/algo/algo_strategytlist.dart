import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/routes/route_names.dart';

import '../../models/strategy_model.dart';
import '../../provider/stocks_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';

class AlgoStrategyList extends ConsumerStatefulWidget {
  const AlgoStrategyList({super.key});

  @override
  ConsumerState<AlgoStrategyList> createState() => _AlgoStrategyListState();
}

class _AlgoStrategyListState extends ConsumerState<AlgoStrategyList> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stocksProvide).getstrategyList();
    });
  }


  // final List<_StrategyItem> _items = [
  //   _StrategyItem(
  //     name: 'BANKNIFTY intraday Strategy',
  //     symbol: 'BANKNIFTY',
  //     legsCount: 2,
  //     timeWindow: '09:35 - 15:15',
  //     createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  //   ),
  //   _StrategyItem(
  //     name: 'NIFTY positional Strategy',
  //     symbol: 'NIFTY',
  //     legsCount: 3,
  //     timeWindow: '09:35 - 15:15',
  //     createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
  //   ),
  // ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        centerTitle: false,
        leading: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor:
                theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
            highlightColor:
                theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 18,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
              ),
            ),
          ),
        ),
        elevation: 0.2,
        title: TextWidget.titleText(
            text: "Algo Strategies",
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1),
        actions: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor:
                  theme.isDarkMode ? colors.splashColorDark : colors.splashColorLight,
              highlightColor:
                  theme.isDarkMode ? colors.highlightDark : colors.highlightLight,
              borderRadius: BorderRadius.circular(6),
              onTap: () => Navigator.pushNamed(context, Routes.algoCreate),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                    ),
                    const SizedBox(width: 6),
                    TextWidget.subText(
                      text: 'Create',
                      theme: theme.isDarkMode,
                      color:
                          theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                      fw: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Builder(
        builder: (_) {
          final strategyList = ref.watch(stocksProvide).getStrategyList;
          if (strategyList == null || strategyList.data == null || strategyList.data!.isEmpty) {
            return _buildEmptyState(theme.isDarkMode);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: strategyList.data!.length,
            itemBuilder: (context, index) {
              return _buildStrategySummaryTile(strategyList.data![index], theme.isDarkMode);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_graph_outlined,
            size: 48,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
          ),
          const SizedBox(height: 8),
          TextWidget.subText(
            text: 'No strategies yet',
            theme: isDark,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 3,
          ),
          const SizedBox(height: 6),
          TextWidget.paraText(
            text: 'Tap Create to build your first strategy',
            theme: isDark,
            color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
            fw: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySummaryTile(Data data, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // color: isDark ? colors.searchBgDark : colors.searchBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.dividerDark : colors.dividerLight,
          // width: 1,
        ),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with strategy name and actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.subText(
                        text: data.statname ?? '',
                        theme: isDark,
                        color: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                        fw: 1,
                      ),
                      const SizedBox(height: 2),
                      TextWidget.paraText(
                        text: "${data.exch ?? ''} ${data.symbol ?? ''}",
                        theme: isDark,
                        color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                        fw: 3,
                      ),
                    ],
                  ),
                ),
               
              ],
            ),
          ),

          // Status badges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.paraText(
                  text: 'Expires: ${data.statlegs?.first.expiry ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
                TextWidget.paraText(
                  text: 'Strike: ${data.statlegs?.first.strike ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.paraText(
                  text: 'Qty: ${data.statlegs?.first.quantity ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
                TextWidget.paraText(
                  text: 'Option Type: ${data.statlegs?.first.optionType ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget.paraText(
                  text: 'Target: ${data.target?.value ?? ''} ${data.target?.type ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
                TextWidget.paraText(
                  text: 'Stoploss: ${data.stoploss?.value ?? ''} ${data.stoploss?.type ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
                ],
              ),
            ),
          



          const SizedBox(height: 16),

          // Execution time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                TextWidget.paraText(
                  text: '${data.starttime ?? ''} : ${data.endtime ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                ),
                const SizedBox(width: 6),
                TextWidget.paraText(
                  text: '${data.executionon?.join(', ') ?? ''}',
                  theme: isDark,
                  color: isDark ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
         

          // Deploy button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 45,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showDeployDialog(data);
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? colors.primaryDark : colors.primaryLight,
                  foregroundColor: isDark ? colors.textPrimaryDark : colors.textPrimaryLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: TextWidget.subText(
                  text: 'Deploy',
                  theme: false,
                  color: colors.colorWhite,
                  fw: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeployDialog(Data data) async {
    final theme = ref.read(themeProvider);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.colorWhite,
          titlePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          scrollable: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          actionsPadding:
              const EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 8),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          title: TextWidget.titleText(
            text: 'Deploy Strategy',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.subText(
                text: 'Deploy "${data.statname ?? ''}" for live trading?',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 3,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.isDarkMode ? colors.searchBgDark : colors.searchBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
                  ),
                ),
                child: Column(
                  children: [
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     TextWidget.paraText(
                    //       text: 'Peak Margin Required:',
                    //       theme: theme.isDarkMode,
                    //       color: theme.isDarkMode
                    //           ? colors.textSecondaryDark
                    //           : colors.textSecondaryLight,
                    //       fw: 3,
                    //     ),
                    //     TextWidget.subText(
                    //       text: '₹ 3.6L',
                    //       theme: theme.isDarkMode,
                    //       color: theme.isDarkMode
                    //           ? colors.textPrimaryDark
                    //           : colors.textPrimaryLight,
                    //       fw: 1,
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.paraText(
                          text: 'Execution Time:',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          fw: 3,
                        ),
                        TextWidget.paraText(
                          text: '${data.starttime ?? ''} - ${data.endtime ?? ''}',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 3,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
           
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(stocksProvide).deployStrategy(data.strategyid ?? '');
               
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: TextWidget.subText(
                text: 'Deploy',
                theme: false,
                color: colors.colorWhite,
                fw: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(int index) async {
    final theme = ref.read(themeProvider);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget.titleText(
            text: 'Delete strategy?',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1,
          ),
          content: TextWidget.subText(
            text: 'This action cannot be undone.',
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: TextWidget.subText(
                text: 'Cancel',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 1,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: TextWidget.subText(
                text: 'Delete',
                theme: theme.isDarkMode,
                color: theme.isDarkMode ? colors.lossDark : colors.lossLight,
                fw: 1,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // No delete API yet; clear full list from provider for now.
      ref.read(stocksProvide).clearStrategyList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Strategy deleted'),
            backgroundColor: theme.isDarkMode ? colors.lossDark : colors.lossLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StrategyItem {
  final String name;
  final String symbol;
  final int legsCount;
  final String timeWindow;
  final DateTime createdAt;

  _StrategyItem({
    required this.name,
    required this.symbol,
    required this.legsCount,
    required this.timeWindow,
    required this.createdAt,
  });
}


