import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/notification_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/exch_message_link.dart';
import '../../../../sharedWidget/no_data_found.dart';
import 'dart:convert';

class BrokerMsg extends ConsumerWidget {
  const BrokerMsg({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noftification = ref.watch(notificationprovider);
    final theme = ref.read(themeProvider);

    String cleanMessage(String text) {
      try {
        // Step 1: Fix encoding issues (Latin1 -> UTF-8)
        final bytes = latin1.encode(text);
        String decoded = utf8.decode(bytes);

        // Step 2: Remove common corrupted characters
        decoded = decoded.replaceAll(RegExp(r'[âÂ�]+'), '');

        // Step 3: Remove weird control characters except line breaks and spaces
        decoded =
            decoded.replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'), '');

        // Step 4: Trim unnecessary whitespace & blank lines
        decoded = decoded
            .replaceAll(RegExp(r'(^[ \t]*\n)+', multiLine: true),
                '') // leading blank lines
            .replaceAll(RegExp(r'\n{2,}'), '\n') // collapse multiple newlines
            .trim();

        return decoded;
      } catch (_) {
        // Fallback if decoding fails, just clean up basic characters
        return text
            .replaceAll(RegExp(r'[âÂ�]+'), '')
            .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'), '')
            .replaceAll(RegExp(r'(^[ \t]*\n)+', multiLine: true), '')
            .replaceAll(RegExp(r'\n{2,}'), '\n')
            .trim();
      }
    }

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
                            TextWidget.paraText(
                              text:
                                  "${noftification.brokermsg![index].norentm}",
                              theme: false,
                              color: colors.textSecondaryLight,
                              fw: 0,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            LinkExtractor(
                                theme: theme,
                                text: cleanMessage(
                                    "${noftification.brokermsg![index].dmsg}"))
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
