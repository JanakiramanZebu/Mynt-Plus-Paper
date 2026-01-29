import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/res/mynt_web_text_styles.dart';
import 'package:mynt_plus/res/mynt_web_color_styles.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class InformationMessage extends ConsumerWidget {
  const InformationMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationprovider);

    // Better null safety check
    final messages = notification.informationMessages;

    if (notification.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (messages == null || messages.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: NoDataFound(
          secondaryEnabled: false,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        final item = messages[index];

        // Check if this message should be highlighted (from push notification tap)
        final bool isHighlighted = notification.highlightedMessageId != null &&
            item.uniqueId != null &&
            notification.highlightedMessageId == item.uniqueId;

        return Container(
          // Add visual highlight if this is the notification that was tapped
          decoration: isHighlighted
              ? BoxDecoration(
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.primary.withOpacity(0.1),
                    light: MyntColors.primary.withOpacity(0.08),
                  ),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timestamp
              Text(
                _formatDateTime(item.datetime),
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
              // Title
              if (item.title.isNotEmpty) ...[
                Text(
                  item.title,
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
              ],
              // Message content with ReadMore
              ReadMoreText(
                item.msg,
                style: MyntWebTextStyles.body(
                  context,
                  color: resolveThemeColor(
                    context,
                    dark: MyntColors.textSecondaryDark,
                    light: MyntColors.textSecondary,
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
              // Image if available
              if (item.imageurl.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageurl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.dividerDark,
                            light: MyntColors.divider,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          color: resolveThemeColor(
                            context,
                            dark: MyntColors.textSecondaryDark,
                            light: MyntColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  String _formatDateTime(String datetime) {
    try {
      final date = DateTime.parse(datetime);
      return "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return datetime;
    }
  }
}
