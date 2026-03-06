import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../locator/locator.dart';
import '../../../../locator/preference.dart';
import '../../../../res/mynt_web_text_styles.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../sharedWidget/common_text_fields_web.dart';
import '../../../../sharedWidget/snack_bar.dart';

class ReferScreenWeb extends ConsumerStatefulWidget {
  const ReferScreenWeb({super.key});

  @override
  ConsumerState<ReferScreenWeb> createState() => _ReferScreenWebState();
}

class _ReferScreenWebState extends ConsumerState<ReferScreenWeb> {
  late final TextEditingController _linkController;
  late final String _refLink;

  @override
  void initState() {
    super.initState();
    final Preferences pref = locator<Preferences>();
    _refLink = 'https://oa.mynt.in/?ref=${pref.clientId ?? ''}';
    _linkController = TextEditingController(text: _refLink);
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = resolveThemeColor(context,
        dark: MyntColors.borderMutedDark, light: MyntColors.borderMuted);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeroCard(context, borderColor),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildShareLinkCard(context, borderColor)),
              const SizedBox(width: 24),
              Expanded(child: _buildReferActionsCard(context, borderColor)),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(Color borderColor) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor, width: 1),
    );
  }

  Widget _buildHeroCard(BuildContext context, Color borderColor) {
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);

    return Container(
      decoration: _cardDecoration(borderColor),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Refer your friends to Zebu',
            style: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.semiBold,
              darkColor: MyntColors.textPrimaryDark,
              lightColor: MyntColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: MyntWebTextStyles.hero(
                context,
                darkColor: MyntColors.textPrimaryDark,
                lightColor: MyntColors.textPrimary,
                fontWeight: MyntFonts.semiBold,
              ),
              children: [
                const TextSpan(text: 'Get '),
                TextSpan(
                  text: '20%',
                  style: MyntWebTextStyles.hero(
                    context,
                    color: primaryColor,
                    fontWeight: MyntFonts.bold,
                  ),
                ),
                const TextSpan(
                    text:
                        ' of brokerage fees for trades made\nby your friends! in every'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareLinkCard(BuildContext context, Color borderColor) {
    return Container(
      decoration: _cardDecoration(borderColor),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '1.',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.bold,
                  darkColor: MyntColors.primaryDark,
                  lightColor: MyntColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Share your referral link',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Copy the referral link below and share it with your family and friends to start earning.',
            style: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.regular,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          MyntTextField(
            controller: _linkController,
            placeholder: 'Referral link',
            readOnly: true,
            leadingWidget: Icon(
              Icons.person_outline,
              size: 18,
              color: resolveThemeColor(context,
                  dark: MyntColors.iconDark, light: MyntColors.icon),
            ),
            trailingWidget: IconButton(
              icon: Icon(
                Icons.copy,
                size: 18,
                color: resolveThemeColor(context,
                    dark: MyntColors.iconDark, light: MyntColors.icon),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _refLink));
                successMessage(context, 'Referral link copied!');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferActionsCard(BuildContext context, Color borderColor) {
    final primaryColor = resolveThemeColor(context,
        dark: MyntColors.primaryDark, light: MyntColors.primary);

    return Container(
      decoration: _cardDecoration(borderColor),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '2.',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.bold,
                  darkColor: MyntColors.primaryDark,
                  lightColor: MyntColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Refer your family and friends',
                style: MyntWebTextStyles.body(
                  context,
                  fontWeight: MyntFonts.semiBold,
                  darkColor: MyntColors.textPrimaryDark,
                  lightColor: MyntColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get discount on brokerages by referring them with your referral link.',
            style: MyntWebTextStyles.body(
              context,
              fontWeight: MyntFonts.regular,
              darkColor: MyntColors.textSecondaryDark,
              lightColor: MyntColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final message = Uri.encodeComponent(
                    'I invite you to explore Mynt by Zebu — from Stocks to Mutual funds and more.\nOpen your free demat account today\n👉 $_refLink',
                  );
                  launchUrl(
                    Uri.parse('https://wa.me/?text=$message'),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: const Icon(Icons.chat, color: Colors.white, size: 18),
                label: Text(
                  'Refer on whatsapp',
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: MyntFonts.medium,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  Share.share(
                    'I invite you to explore Mynt by Zebu — from Stocks to Mutual funds and more.\nOpen your free demat account today\n👉 $_refLink',
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  side: BorderSide(color: borderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'More ways to share',
                  style: MyntWebTextStyles.body(
                    context,
                    fontWeight: MyntFonts.medium,
                    darkColor: MyntColors.textPrimaryDark,
                    lightColor: MyntColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
