import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';

class StockEventsDialog extends ConsumerWidget {
  final String stockToken;
  final String stockName;

  const StockEventsDialog({
    super.key,
    required this.stockToken,
    required this.stockName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final marketWatch = ref.watch(marketWatchProvider);
    final events = marketWatch.filterStockEventsByToken(stockToken);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        boxShadow: const [
          BoxShadow(
            color: Color(0xff999999),
            blurRadius: 4.0,
            offset: Offset(2.0, 0.0),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomDragHandler(),
          // Header
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 4, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleText(
                        text: stockName.replaceAll("-EQ", "").toUpperCase(),
                        theme: theme.isDarkMode,
                        fw: 0,
                        color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                      ),
                      // const SizedBox(height: 4),
                      // TextWidget.paraText(
                      //   text: ,
                      //   color: theme.isDarkMode
                      //       ? colors.textSecondaryDark
                      //       : colors.textSecondaryLight,
                      //   theme: theme.isDarkMode,
                      //   fw: 0,
                      // ),
                    ],
                  ),
                ),
                // Material(
                //   color: Colors.transparent,
                //   shape: const CircleBorder(),
                //   child: InkWell(
                //     onTap: () async {
                //       await Future.delayed(const Duration(milliseconds: 150));
                //       Navigator.pop(context);
                //     },
                //     borderRadius: BorderRadius.circular(20),
                //     splashColor: theme.isDarkMode
                //         ? Colors.white.withOpacity(0.15)
                //         : Colors.black.withOpacity(0.15),
                //     highlightColor: theme.isDarkMode
                //         ? Colors.white.withOpacity(0.08)
                //         : Colors.black.withOpacity(0.08),
                //     child: Padding(
                //       padding: const EdgeInsets.all(6.0),
                //       child: Icon(
                //         Icons.close_rounded,
                //         size: 22,
                //         color: theme.isDarkMode
                //             ? const Color(0xffBDBDBD)
                //             : colors.colorGrey,
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
          Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
            height: 1,
          ),
          // Events content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Dividend
                  if (events['dividend'] != null)
                    _EventCard(
                      theme: theme,
                      title: 'Dividend',
                      icon: Icons.monetization_on_outlined,
                      iconColor: Colors.green,
                      children: [
                        _EventRow(
                          theme: theme,
                          label: 'Ex-Date',
                          value: _formatDate(events['dividend'].exDate),
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Ratio',
                          value: events['dividend'].ratio ?? '-',
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Exchange',
                          value: events['dividend'].exch ?? '-',
                        ),
                      ],
                    ),
                  // Bonus
                  if (events['bonus'] != null)
                    _EventCard(
                      theme: theme,
                      title: 'Bonus',
                      icon: Icons.card_giftcard_outlined,
                      iconColor: Colors.blue,
                      children: [
                        _EventRow(
                          theme: theme,
                          label: 'Ex-Date',
                          value: _formatDate(events['bonus'].exDate),
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Ratio',
                          value: events['bonus'].ratio ?? '-',
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Exchange',
                          value: events['bonus'].exch ?? '-',
                        ),
                      ],
                    ),
                  // split
                  if (events['split'] != null)
                    _EventCard(
                      theme: theme,
                      title: 'Stock Split',
                      icon: Icons.call_split_outlined,
                      iconColor: Colors.orange,
                      children: [
                        _EventRow(
                          theme: theme,
                          label: 'Ex-Date',
                          value: _formatDate(events['split'].exDate),
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Ratio',
                          value: events['split'].ratio ?? '-',
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Exchange',
                          value: events['split'].exch ?? '-',
                        ),
                      ],
                    ),
                  // Rights
                  if (events['rights'] != null)
                    _EventCard(
                      theme: theme,
                      title: 'Rights Issue',
                      icon: Icons.assignment_outlined,
                      iconColor: Colors.purple,
                      children: [
                        _EventRow(
                          theme: theme,
                          label: 'Ex-Date',
                          value: _formatDate(events['rights'].exDate),
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Ratio',
                          value: events['rights'].ratio ?? '-',
                        ),
                        _EventRow(
                          theme: theme,
                          label: 'Exchange',
                          value: events['rights'].exch ?? '-',
                        ),
                      ],
                    ),
                  // No events message
                  if (events['dividend'] == null &&
                      events['bonus'] == null &&
                      events['split'] == null &&
                      events['rights'] == null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy_outlined,
                              size: 48,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                            ),
                            const SizedBox(height: 16),
                            TextWidget.paraText(
                              text: 'No corporate action events available',
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                              theme: theme.isDarkMode,
                              fw: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }
}

class _EventCard extends StatelessWidget {
  final dynamic theme;
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _EventCard({
    required this.theme,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.isDarkMode
            ? colors.colorBlack.withOpacity(0.3)
            : colors.colorGrey.withOpacity(0.1),
        border: Border.all(
          color: theme.isDarkMode
              ? colors.darkColorDivider
              : colors.colorDivider,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
                const SizedBox(width: 8),
                TextWidget.titleText(
                  text: title,
                  theme: theme.isDarkMode,
                  fw: 1,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final dynamic theme;
  final String label;
  final String value;

  const _EventRow({
    required this.theme,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextWidget.paraText(
            text: label,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            theme: theme.isDarkMode,
            fw: 0,
          ),
          TextWidget.paraText(
            text: value,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            theme: theme.isDarkMode,
            fw: 1,
          ),
        ],
      ),
    );
  }
}
