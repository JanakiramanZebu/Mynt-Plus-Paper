import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/models/notification_model/exchange_status_model.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';

class ExchangeAlert extends ConsumerWidget {
  const ExchangeAlert({super.key});

  /// Group exchange status items by exchange name
  Map<String, List<ExchangeStatusModel>> _groupByExchange(
      List<ExchangeStatusModel> items) {
    final Map<String, List<ExchangeStatusModel>> grouped = {};
    for (final item in items) {
      final key = item.exch ?? 'Unknown';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationprovider);
    final theme = ref.watch(themeProvider);

    if (notification.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final exchangeStatus = notification.exchangestatus;
    if (exchangeStatus == null || exchangeStatus.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFoundWeb(secondaryEnabled: false),
      );
    }

    if (exchangeStatus[0].stat == 'Not_Ok') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFoundWeb(secondaryEnabled: false),
      );
    }

    final grouped = _groupByExchange(exchangeStatus);
    final exchangeNames = grouped.keys.toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: exchangeNames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final exchName = exchangeNames[index];
        final items = grouped[exchName]!;
        return _buildExchangeCard(context, theme, exchName, items);
      },
    );
  }

  /// Builds a bordered container per exchange with equal-width segment cards
  Widget _buildExchangeCard(
    BuildContext context,
    ThemesProvider theme,
    String exchangeName,
    List<ExchangeStatusModel> items,
  ) {
    final borderColor = resolveThemeColor(
      context,
      dark: MyntColors.dividerDark,
      light: MyntColors.divider,
    );
    final textPrimary = resolveThemeColor(
      context,
      dark: MyntColors.textPrimaryDark,
      light: MyntColors.textPrimary,
    );

    const double cardSpacing = 10;
    const double containerPadding = 16;
    const int cardsPerRow = 3;

    final headerBg = resolveThemeColor(
      context,
      dark: MyntColors.primaryDark.withValues(alpha: 0.08),
      light: MyntColors.primary.withValues(alpha: 0.08),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exchange name header - full width with top border radius
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: headerBg,
              child: Text(
                exchangeName,
                style: MyntWebTextStyles.title(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  color: textPrimary,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: borderColor.withValues(alpha: 0.3),
            ),
          // Equal-width segment cards using LayoutBuilder
          LayoutBuilder(
            builder: (context, constraints) {
              final totalSpacing = cardSpacing * (cardsPerRow - 1);
              final availableWidth =
                  constraints.maxWidth - (containerPadding * 2) - totalSpacing;
              final cardWidth = availableWidth / cardsPerRow;

              return Padding(
                padding: const EdgeInsets.all(containerPadding),
                child: Wrap(
                  spacing: cardSpacing,
                  runSpacing: cardSpacing,
                  children: items
                      .map((item) => SizedBox(
                            width: cardWidth,
                            child: _buildSegmentCard(context, item),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  /// Builds an individual card for a market segment
  Widget _buildSegmentCard(
    BuildContext context,
    ExchangeStatusModel item,
  ) {
    final isOpen = _isStatusOpen(item.exchstat);
    final statusColor = isOpen
        ? resolveThemeColor(context,
            dark: MyntColors.profitDark, light: MyntColors.profit)
        : resolveThemeColor(context,
            dark: MyntColors.lossDark, light: MyntColors.loss);
    final textPrimary = resolveThemeColor(
      context,
      dark: MyntColors.textPrimaryDark,
      light: MyntColors.textPrimary,
    );
    final textSecondary = resolveThemeColor(
      context,
      dark: MyntColors.textSecondaryDark,
      light: MyntColors.textSecondary,
    );
    final borderColor = resolveThemeColor(
      context,
      dark: MyntColors.dividerDark,
      light: MyntColors.divider,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: type + status badge (left), date (right)
          Row(
            children: [
              // Market type
              Text(
                item.exchtype ?? 'N/A',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [                  
                    Text(
                      item.exchstat ?? 'Unknown',
                      style: MyntWebTextStyles.caption(
                        context,
                        fontWeight: MyntFonts.medium,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Date/time
              if (item.exchTm != null && item.exchTm!.isNotEmpty)
                Text(
                  item.exchTm!,
                  style: MyntWebTextStyles.para(
                    context,
                    fontWeight: MyntFonts.medium,
                    color: textPrimary,
                  ),
                ),
            ],
          ),
          // Row 2: Description (strip leading date/time since it's shown above)
          if (item.description != null && item.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _stripDateTime(item.description!),
              style: MyntWebTextStyles.bodySmall(
                context,
                fontWeight: MyntFonts.medium,
                color: textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Strips leading date/time pattern like "06-Feb-2026 15:30:00 " from description
  String _stripDateTime(String text) {
    // Matches patterns like "06-Feb-2026 15:30:00 " at the start
    final stripped = text.replaceFirst(
      RegExp(r'^\d{2}-\w{3}-\d{4}\s+\d{2}:\d{2}:\d{2}\s*'),
      '',
    );
    return stripped.isNotEmpty ? stripped : text;
  }

  bool _isStatusOpen(String? status) {
    if (status == null) return false;
    final lowerStatus = status.toLowerCase();
    return lowerStatus.contains('open') ||
        lowerStatus.contains('active') ||
        lowerStatus.contains('preopen');
  }
}
