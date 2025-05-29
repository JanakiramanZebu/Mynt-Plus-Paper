import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readmore/readmore.dart'; 
import '../../../../provider/notification_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/no_data_found.dart'; 


class ExchangeMessage extends ConsumerWidget {
  const ExchangeMessage({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noftification = ref.watch(notificationprovider);

   final theme =ref.read(themeProvider);
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
                            Text(
                              "${noftification.exchangemessage![index].exchTm} (${noftification.exchangemessage![index].exch})",
                              style: textStyles.notificationtimestyle,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            ReadMoreText(
                              "${noftification.exchangemessage![index].exchMsg}",
                              style: textStyles.notificationtextstyle.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack),
                              textAlign: TextAlign.left,
                              trimLines: 2,
                              moreStyle: textStyles.morestyle.copyWith(color: theme.isDarkMode?colors.colorLightBlue:colors.colorBlue),
                              lessStyle: textStyles.morestyle.copyWith(color: theme.isDarkMode?colors.colorLightBlue:colors.colorBlue),
                              colorClickableText:    theme.isDarkMode?colors.colorLightBlue:colors.colorBlue ,
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
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Divider(
                          
                          color: theme.isDarkMode
                          ?colors.darkColorDivider
                          :colors.colorDivider,
                        ),
                      );
                    },
                  ));
  }


  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}





