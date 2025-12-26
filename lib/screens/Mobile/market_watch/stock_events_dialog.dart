import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../provider/market_watch_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/custom_drag_handler.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/no_data_found.dart';

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

    // Build list of events for ListView
    final List<Map<String, dynamic>> eventList = [];
    if (events['dividend'] != null) {
      eventList.add({
        'type': 'dividend',
        'title': 'Dividend',
        'icon': Icons.monetization_on_outlined,
        'iconColor': Colors.green,
        'data': events['dividend'],
      });
    }
    if (events['bonus'] != null) {
      eventList.add({
        'type': 'bonus',
        'title': 'Bonus',
        'icon': Icons.card_giftcard_outlined,
        'iconColor': Colors.blue,
        'data': events['bonus'],
      });
    }
    if (events['split'] != null) {
      eventList.add({
        'type': 'split',
        'title': 'Stock Split',
        'icon': Icons.call_split_outlined,
        'iconColor': Colors.orange,
        'data': events['split'],
      });
    }
    if (events['rights'] != null) {
      eventList.add({
        'type': 'rights',
        'title': 'Rights Issue',
        'icon': Icons.assignment_outlined,
        'iconColor': Colors.purple,
        'data': events['rights'],
      });
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          border: Border(
            top: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            left: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
            right: BorderSide(
              color: theme.isDarkMode
                  ? colors.textSecondaryDark.withOpacity(0.5)
                  : colors.colorWhite,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomDragHandler(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, left: 16.0, right: 16.0, bottom: 8.0),
              child: TextWidget.titleText(
                text: stockName.replaceAll("-EQ", "").toUpperCase(),
                textOverflow: TextOverflow.ellipsis,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                theme: theme.isDarkMode,
                fw: 1,
              ),
            ),
            eventList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: NoDataFound(),
                    ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const ListDivider(),
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: eventList.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final event = eventList[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row(
                                    //   children: [
                                    //     Icon(
                                    //       event['icon'] as IconData,
                                    //       size: 20,
                                    //       color: event['iconColor'] as Color,
                                    //     ),
                                    //     const SizedBox(width: 8),
                                    //     TextWidget.subText(
                                    //       text: event['title'] as String,
                                    //       color: theme.isDarkMode
                                    //           ? colors.textPrimaryDark
                                    //           : colors.textPrimaryLight,
                                    //       textOverflow: TextOverflow.ellipsis,
                                    //       theme: theme.isDarkMode,
                                    //       fw: 0,
                                    //     ),
                                    //   ],
                                    // ),
                                    // const SizedBox(height: 12),
                                    _EventRow(
                                      theme: theme,
                                      label: 'Event',
                                      value: event['title'],
                                    ),
                                    _EventRow(
                                      theme: theme,
                                      label: 'Ratio',
                                      value: event['data'].ratio ?? '-',
                                    ),
                                    _EventRow(
                                      theme: theme,
                                      label: 'Ex-Date',
                                      value: _formatDate(event['data'].exDate),
                                    ),
                                    // _EventRow(
                                    //   theme: theme,
                                    //   label: 'Exchange',
                                    //   value: event['data'].exch ?? '-',
                                    // ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const ListDivider();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.subText(
                text: label,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 0,
              ),
              TextWidget.subText(
                text: value,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                textOverflow: TextOverflow.ellipsis,
                theme: theme.isDarkMode,
                fw: 0,
              ),
            ],
          ),
        ),
        Divider(
          color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight,
          thickness: 0,
        ),
      ],
    );
  }
}
