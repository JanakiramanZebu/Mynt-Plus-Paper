import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart';
import '../../../../provider/notification_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart';

class ExchangeMessage extends ConsumerWidget {
  const ExchangeMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noftification = ref.watch(notificationprovider);

    final theme = ref.read(themeProvider);
    return noftification.loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: noftification.exchangemessage![0].exchMsg == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 220),
                    child: NoDataFound(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: noftification.exchangemessage!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.paraText(
                                text:
                                    "${noftification.exchangemessage![index].exchTm} (${noftification.exchangemessage![index].exch})",
                                theme: false,
                                color: colors.textSecondaryLight,
                                fw: 0),
                            const SizedBox(
                              height: 5,
                            ),
                            ReadMoreText(
                              "${noftification.exchangemessage![index].exchMsg}",
                              style: TextWidget.textStyle(
                                  fontSize: 14,
                                  theme: false,
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  height: 1.5,
                                  letterSpacing: 0.5),
                              textAlign: TextAlign.left,
                              trimLines: 2,
                              moreStyle: TextWidget.textStyle(
                                fontSize: 12,
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.colorLightBlue
                                    : colors.colorBlue,
                              ),
                              lessStyle: TextWidget.textStyle(
                                fontSize: 12,
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.colorLightBlue
                                    : colors.colorBlue,
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
                  ));
  }
}
