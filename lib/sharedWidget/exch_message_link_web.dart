import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../res/mynt_web_text_styles.dart';
import '../res/mynt_web_color_styles.dart';

class LinkExtractorWeb extends StatelessWidget {
  final String text;
  const LinkExtractorWeb({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return _buildFormattedText(context, text);
  }

  Widget _buildFormattedText(BuildContext context, String text) {
    final htmlLinkRegex =
        RegExp(r'<a href="([^"]+)">([^<]+)</a>', caseSensitive: false);
    final urlRegex = RegExp(r'https?://[^\s]+', caseSensitive: false);
    final htmlMatches = htmlLinkRegex.allMatches(text);
    final urlMatches = urlRegex.allMatches(text);

    if (htmlMatches.isEmpty && urlMatches.isEmpty) {
      return ReadMoreText(
        text,
        style: MyntWebTextStyles.body(
          context,
          fontWeight: MyntFonts.medium,
          color: resolveThemeColor(
            context,
            dark: MyntColors.textPrimaryDark,
            light: MyntColors.textPrimary,
          ),
        ).copyWith(height: 1.5),
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
        trimExpandedText: 'Read less',
      );
    }
    return _buildTextWithLinks(context, text, htmlMatches, urlMatches);
  }

  Widget _buildTextWithLinks(
    BuildContext context,
    String text,
    Iterable<RegExpMatch> htmlMatches,
    Iterable<RegExpMatch> urlMatches,
  ) {
    List<Widget> widgets = [];
    int lastIndex = 0;
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

      if (match.start > lastIndex) {
        final beforeText = text.substring(lastIndex, match.start);
        if (beforeText.isNotEmpty) {
          widgets.add(
            ReadMoreText(
              beforeText,
              style: MyntWebTextStyles.body(
                context,
                fontWeight: MyntFonts.medium,
                color: resolveThemeColor(
                  context,
                  dark: MyntColors.textSecondaryDark,
                  light: MyntColors.textSecondary,
                ),
              ).copyWith(height: 1.5),
              textAlign: TextAlign.left,
              trimLines: 2,
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
              trimExpandedText: 'Read less',
            ),
          );
        }
      }

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
          _buildClickableLink(context, url, linkText),
        );
      }
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      final remainingText = text.substring(lastIndex);
      if (remainingText.isNotEmpty) {
        widgets.add(
          ReadMoreText(
            remainingText,
            style: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.medium,
              color: resolveThemeColor(
                context,
                dark: MyntColors.textSecondaryDark,
                light: MyntColors.textSecondary,
              ),
            ).copyWith(height: 1.5),
            textAlign: TextAlign.left,
            trimLines: 2,
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

  Widget _buildClickableLink(BuildContext context, String url, String linkText) {
    final primaryColor = resolveThemeColor(
      context,
      dark: MyntColors.primaryDark,
      light: MyntColors.primary,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () async {
            try {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } catch (e) {
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.link,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    linkText.isNotEmpty ? linkText : url,
                    style: MyntWebTextStyles.body(
                      context,
                      fontWeight: MyntFonts.medium,
                      color: primaryColor,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                      height: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
