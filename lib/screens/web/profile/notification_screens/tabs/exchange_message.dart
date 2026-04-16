import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/sharedWidget/no_data_found_web.dart';
import 'package:readmore/readmore.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class ExchangeMessage extends ConsumerWidget {
  const ExchangeMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationprovider);

    // Check if data is loading
    if (notification.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if exchangemessage is null or empty
    final exchangemessage = notification.exchangemessage;
    if (exchangemessage == null || exchangemessage.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFoundWeb(
          secondaryEnabled: false,
        ),
      );
    }

    // Check if first message has no content
    if (exchangemessage[0].exchMsg == null || exchangemessage[0].exchMsg!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFoundWeb(
          secondaryEnabled: false,
        ),
      );
    }

    // Display list of messages
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: exchangemessage.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp and Exchange
              Text(
                '${exchangemessage[index].exchTm ?? ''} (${exchangemessage[index].exch ?? ''})',
                style: MyntWebTextStyles.para(
                  context,
                  fontWeight: MyntFonts.medium,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Message content with ReadMore
              ReadMoreText(
                exchangemessage[index].exchMsg ?? '',
                style: MyntWebTextStyles.body(
                  context,
                    fontWeight: MyntFonts.medium,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textPrimaryDark,
                    light: MyntColors.textPrimary,
                  ),
                ).copyWith(height: 1.5),
                textAlign: TextAlign.left,
                trimLines: 5,
                moreStyle: MyntWebTextStyles.para(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary,
                  ),
                ),
                lessStyle: MyntWebTextStyles.para(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.primaryDark,
                    light: MyntColors.primary,
                  ),
                ),
                colorClickableText: resolveThemeColor(
                  context,
                  dark: MyntColors.primaryDark,
                  light: MyntColors.primary,
                ),
                trimMode: TrimMode.Line,
                trimCollapsedText: 'Read more',
                trimExpandedText: ' Read less',
              ),
            ],
          ),
        );
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
}
