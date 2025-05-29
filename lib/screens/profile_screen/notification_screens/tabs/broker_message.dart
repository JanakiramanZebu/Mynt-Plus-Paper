import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import '../../../../provider/notification_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/exch_message_link.dart';
import '../../../../sharedWidget/no_data_found.dart';

class BrokerMsg extends ConsumerWidget {
  const BrokerMsg({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noftification = ref.watch(notificationprovider);
    final theme = ref.read(themeProvider);

    return noftification.loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: noftification.brokermsg![0].dmsg == null
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 220),
                    child: NoDataFound(),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: noftification.brokermsg!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              " ${noftification.brokermsg![index].norentm}",
                              style: textStyles.notificationtimestyle,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            LinkExtractor(
                                theme: theme,
                                text: "${noftification.brokermsg![index].dmsg}")
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
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
