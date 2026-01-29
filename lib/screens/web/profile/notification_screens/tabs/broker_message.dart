import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/exch_message_link_web.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'dart:convert';

class BrokerMsg extends ConsumerWidget {
  const BrokerMsg({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationprovider);

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

    // Check if data is loading
    if (notification.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if brokermsg is null or empty
    final brokermsg = notification.brokermsg;
    if (brokermsg == null || brokermsg.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFound(
          secondaryEnabled: false,
        ),
      );
    }

    // Check if first message has no content
    if (brokermsg[0].dmsg == null || brokermsg[0].dmsg!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFound(
          secondaryEnabled: false,
        ),
      );
    }

    // Display list of messages
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: brokermsg.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp
              Text(
                brokermsg[index].norentm ?? '',
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
              // Message content - using web version
              LinkExtractorWeb(
                text: cleanMessage(brokermsg[index].dmsg ?? ''),
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
