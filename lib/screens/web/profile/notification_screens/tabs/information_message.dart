import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:mynt_plus/provider/notification_provider.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/list_divider.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';

class InformationMessage extends ConsumerWidget {
  const InformationMessage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(notificationprovider);
    final theme = ref.read(themeProvider);

    // Better null safety check
    final messages = notification.informationMessages;
    
    return notification.loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          physics: ClampingScrollPhysics(),
            child: messages == null || messages.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 220),
                    child: NoDataFound(
                        secondaryEnabled: false,
                    ),
                  )
                : ListView.separated(
                    // padding: const EdgeInsets.symmetric(vertical: 20),
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
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
                                color: theme.isDarkMode
                                    ? colors.secondaryDark.withOpacity(0.1)
                                    : colors.secondaryLight.withOpacity(0.1),
                               
                                // borderRadius: BorderRadius.circular(8),
                              )
                            : null,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          
                          // vertical: isHighlighted ? 12 : 0,
                        
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget.paraText(
                              text: _formatDateTime(item.datetime),
                              theme: false,
                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                              fw: 0,
                            ),
                            const SizedBox(height: 5),
                            if (item.title.isNotEmpty) ...[
                              TextWidget.subText(
                                text: item.title,
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 0,
                              ),
                              const SizedBox(height: 5),
                            ],
                            ReadMoreText(
                              item.msg,
                              style: TextWidget.textStyle(
                                fontSize: 14,
                                theme: false,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                height: 1.5,
                                letterSpacing: 0.5,
                                fw: 0,
                              ),
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
                            if (item.imageurl.isNotEmpty) ...[
                              const SizedBox(height: 8),
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
                                      color: colors.colorDivider,
                                      child: const Icon(Icons.image_not_supported),
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
                      return ListDivider();
                    },
                  ),
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