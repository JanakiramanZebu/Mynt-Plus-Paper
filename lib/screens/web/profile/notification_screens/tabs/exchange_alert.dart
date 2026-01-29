import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class ExchangeAlert extends ConsumerWidget {
  const ExchangeAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationprovider);
    final theme = ref.watch(themeProvider);

    // Check if data is loading
    if (notification.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if exchangestatus is null or empty
    final exchangeStatus = notification.exchangestatus;
    if (exchangeStatus == null || exchangeStatus.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFound(
          secondaryEnabled: false,
        ),
      );
    }

    // Check for error response
    if (exchangeStatus[0].stat == 'Not_Ok') {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFound(
          secondaryEnabled: false,
        ),
      );
    }

    // Display list of exchange status alerts
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: exchangeStatus.length,
      itemBuilder: (BuildContext context, int index) {
        final alert = exchangeStatus[index];
        return _buildAlertItem(context, theme, alert, index + 1);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          color: resolveThemeColor(
            context,
            dark: MyntColors.dividerDark,
            light: MyntColors.divider,
          ),
          height: 1,
        );
      },
    );
  }

  Widget _buildAlertItem(
    BuildContext context,
    ThemesProvider theme,
    dynamic alert,
    int index,
  ) {
    // Determine status color based on exchstat
    final isOpen = _isStatusOpen(alert.exchstat);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Index + Exchange Name
          Text(
            '$index. ${alert.exch ?? 'N/A'}',
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
          const SizedBox(height: 6),

          // Row 2: Status dot + Status text + Market type
          Row(
            children: [
              Text(
                'Status: ',
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
              // Status dot
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOpen
                      ? resolveThemeColor(
                          context,
                          dark: MyntColors.profitDark,
                          light: MyntColors.profit,
                        )
                      : resolveThemeColor(
                          context,
                          dark: MyntColors.lossDark,
                          light: MyntColors.loss,
                        ),
                ),
              ),
              const SizedBox(width: 4),
              // Status text
              Text(
                alert.exchstat ?? 'Unknown',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.medium,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
              ),
              // Separator
              Text(
                ' | ',
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
              // Market type
              Text(
                'Market type: ',
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
              Text(
                alert.exchtype ?? 'N/A',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.medium,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          // Row 3: Description/Timestamp
          if (alert.description != null && alert.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              alert.description!,
              style: MyntWebTextStyles.body(
                context,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isStatusOpen(String? status) {
    if (status == null) return false;
    final lowerStatus = status.toLowerCase();
    return lowerStatus.contains('open') ||
           lowerStatus.contains('active') ||
           lowerStatus.contains('preopen');
  }
}
