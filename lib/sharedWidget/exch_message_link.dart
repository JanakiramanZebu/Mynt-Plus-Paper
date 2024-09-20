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
    final regex = RegExp(r'<a href=(.*?)>(.*?)<\/a>');
    final match = regex.firstMatch(text);
    final url = match?.group(1);
    final linkText = match?.group(2);
    final displayText = text.replaceAll(regex, '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReadMoreText(
          match == null ? text : displayText,
          style: textStyles.notificationtextstyle.copyWith(
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
          textAlign: TextAlign.left,
          trimLines: 2,
          moreStyle: textStyles.morestyle.copyWith(
              color:
                  theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue),
          lessStyle: textStyles.morestyle.copyWith(
              color:
                  theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue),
          colorClickableText:
              theme.isDarkMode ? colors.colorLightBlue : colors.colorBlue,
          trimMode: TrimMode.Line,
          trimCollapsedText: 'Read more',
          trimExpandedText: 'Read less',
        ),
        const SizedBox(height: 5),
        match == null
            ? Container()
            : GestureDetector(
                onTap: () async {
                  if (url != null && await canLaunch(url)) {
                    await launch(url);
                  }
                },
                child: Text(
                  linkText ?? '',
                  style: textStyles.notificationtextstyle.copyWith(
                      color: colors.colorBlue,
                      decoration: TextDecoration.underline),
                ),
              ),
      ],
    );
  }
}