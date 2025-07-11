import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/thems.dart';
import '../res/res.dart';

class LinkExtractor extends StatelessWidget {
  final String text;
  final ThemesProvider theme;
  const LinkExtractor({super.key, required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return _buildFormattedText(text);
  }

  Widget _buildFormattedText(String text) {
    // Simple regex to match HTML anchor tags
    final htmlLinkRegex =
        RegExp(r'<a href="([^"]+)">([^<]+)</a>', caseSensitive: false);
    // Simple regex to match URLs
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);

    final htmlMatches = htmlLinkRegex.allMatches(text);
    final urlMatches = urlRegex.allMatches(text);

    if (htmlMatches.isEmpty && urlMatches.isEmpty) {
      // No links found, return simple ReadMoreText
      return ReadMoreText(
        text,
        style: textStyles.notificationtextstyle.copyWith(
          color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
        ),
        textAlign: TextAlign.left,
        trimLines: 2,
        moreStyle: textStyles.morestyle.copyWith(
          color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
        ),
        lessStyle: textStyles.morestyle.copyWith(
          color: theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
        ),
        colorClickableText:
            theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'Read more',
        trimExpandedText: 'Read less',
      );
    }

    // Process text with links
    return _buildTextWithLinks(text, htmlMatches, urlMatches);
  }

  Widget _buildTextWithLinks(String text, Iterable<RegExpMatch> htmlMatches,
      Iterable<RegExpMatch> urlMatches) {
    List<Widget> widgets = [];
    int lastIndex = 0;

    // Combine and sort all matches by their start position
    List<MapEntry<int, Map<String, dynamic>>> allMatches = [];

    for (final match in htmlMatches) {
      allMatches.add(MapEntry(match.start, {
        'type': 'html',
        'match': match,
        'end': match.end,
      }));
    }

    for (final match in urlMatches) {
      allMatches.add(MapEntry(match.start, {
        'type': 'url',
        'match': match,
        'end': match.end,
      }));
    }

    allMatches.sort((a, b) => a.key.compareTo(b.key));

    for (final entry in allMatches) {
      final match = entry.value['match'] as RegExpMatch;
      final matchType = entry.value['type'] as String;

      // Add text before the link
      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          widgets.add(
            ReadMoreText(
              beforeText,
              style: textStyles.notificationtextstyle.copyWith(
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
              textAlign: TextAlign.left,
              trimLines: 2,
              moreStyle: textStyles.morestyle.copyWith(
                color:
                    theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
              ),
              lessStyle: textStyles.morestyle.copyWith(
                color:
                    theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
              ),
              colorClickableText:
                  theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Read more',
              trimExpandedText: 'Read less',
            ),
          );
        }
      }

      // Add the link
      String? url;
      String linkText;

      if (matchType == 'html') {
        url = match.group(1);
        linkText = match.group(2) ?? '';
      } else {
        url = match.group(0);
        linkText = url ?? '';
      }

      if (url != null) {
        widgets.add(
          _buildClickableLink(url, linkText),
        );
      }

      lastIndex = match.end;
    }

    // Add remaining text after the last link
    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        widgets.add(
          ReadMoreText(
            remainingText,
            style: textStyles.notificationtextstyle.copyWith(
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
            textAlign: TextAlign.left,
            trimLines: 2,
            moreStyle: textStyles.morestyle.copyWith(
              color:
                  theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
            ),
            lessStyle: textStyles.morestyle.copyWith(
              color:
                  theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
            ),
            colorClickableText:
                theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
            trimMode: TrimMode.Line,
            trimCollapsedText: 'Read more',
            trimExpandedText: 'Read less',
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildClickableLink(String url, String linkText) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: GestureDetector(
        onTap: () async {
          try {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              // Fallback for older url_launcher versions
              if (await canLaunch(url)) {
                await launch(url);
              }
            }
          } catch (e) {
            // Handle invalid URLs silently or show a snackbar
            debugPrint('Error launching URL: $e');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: theme.isDarkMode
                ? colors.colorBlue.withOpacity(0.1)
                : colors.colorBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: colors.colorBlue.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.link,
                size: 16,
                color: colors.colorBlue,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  linkText.isNotEmpty ? linkText : url,
                  style: textStyles.notificationtextstyle.copyWith(
                    color: colors.colorBlue,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
