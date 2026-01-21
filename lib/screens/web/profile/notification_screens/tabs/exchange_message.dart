import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class ExchangeMessage extends ConsumerWidget {
  const ExchangeMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noftification = ref.watch(notificationprovider);

    final theme = ref.read(themeProvider);
    
    // Check if data is loading
    if (noftification.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if exchangemessage is null or empty
    final exchangemessage = noftification.exchangemessage;
    if (exchangemessage == null || exchangemessage.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 220),
        child: NoDataFound(
          secondaryEnabled: false,
        ),
      );
    }

    // Check if first message has no content
    if (exchangemessage[0].exchMsg == null || exchangemessage[0].exchMsg!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 220),
        child: NoDataFound(
          secondaryEnabled: false,
        ),
      );
    }

    // Display list of messages
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: exchangemessage.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.paraText(
                  text: "${exchangemessage[index].exchTm ?? ''} (${exchangemessage[index].exch ?? ''})",
                  theme: false,
                  color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                  fw: 0,
                ),
                const SizedBox(
                  height: 5,
                ),
                ReadMoreText(
                  "${exchangemessage[index].exchMsg ?? ''}",
                  style: TextWidget.textStyle(
                      fontSize: 14,
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      height: 1.5,
                      fw: 0,
                      letterSpacing: 0.5),
                  textAlign: TextAlign.left,
                  trimLines: 5,
                  moreStyle: TextWidget.textStyle(
                    fontSize: 12,
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                    fw: 2,
                  ),
                  lessStyle: TextWidget.textStyle(
                    fontSize: 12,
                    theme: false,
                    color: theme.isDarkMode
                        ? colors.colorLightBlue
                        : colors.colorBlue,
                    fw: 2,
                  ),
                  colorClickableText: theme.isDarkMode
                      ? colors.colorLightBlue
                      : colors.colorBlue,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'Read more',
                  trimExpandedText: ' Read less',
                ),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
          );
        },
      ),
    );
  }
}
