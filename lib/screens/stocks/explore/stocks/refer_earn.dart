import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/locator/preference.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../locator/locator.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/dashboard_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_back_btn.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/splash_loader.dart';

class ReferAndEarnScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends ConsumerState<ReferAndEarnScreen> {
  bool _isOpeningWhatsApp = false;
  Timer? _resetTimer;
  String _pendingFilterType = 'All'; // 'All', 'Pending', 'Removed'

  @override
  void initState() {
    super.initState();
    // Load referral rewards data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider).getReferralRewards();
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final dashboard = ref.watch(dashboardProvider);
    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId ?? ''}";

    return Scaffold(
      backgroundColor: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
      appBar: AppBar(
        leadingWidth: 48,
        titleSpacing: 0,
        centerTitle: false,
        leading: const CustomBackBtn(),
        elevation: 0.2,
        title: TextWidget.titleText(
            text: "Refer and Earn",
            textOverflow: TextOverflow.ellipsis,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            fw: 1),
      ),
      body: SafeArea(
        child: dashboard.isReferralRewardsLoading
            ? _buildLoadingState(theme)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReferCard(theme),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, theme, reflink),
                    const SizedBox(height: 12),
                    _buildTermsText(theme),
                    const SizedBox(height: 24),
                    _buildReferralStatsSection(theme, dashboard),
                    const SizedBox(height: 20),
                    _buildHowItWorksSection(theme),
                    // const SizedBox(height: 24),
                    // _buildReferralCodeSection(theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState(ThemesProvider theme) {
    return Center(
      child: Container(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        child: CircularLoaderImage(),
      ),
    );
  }

  Widget _buildReferCard(ThemesProvider theme) {
    return Container(
      // padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        // border: Border.all(color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight),
        // borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Image.asset(
              //   'assets/explore/surprise.png',
              //   width: 70,
              //   height: 70,
              // ),
              // const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextWidget.textStyle(
                          fontSize: 20,
                          fw: 0,
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                        ),
                        children: [
                          const TextSpan(text: 'Earn '),
                          TextSpan(
                            text: '₹300',
                            style: TextWidget.textStyle(
                              color: theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight, // highlight
                              fontSize: 20,
                              fw: 2,
                              theme: theme.isDarkMode,
                            ),
                          ),
                          const TextSpan(
                              text: ' for every friend you invite. They get '),
                          TextSpan(
                            text: '₹50',
                            style: TextWidget.textStyle(
                              color: theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight, // highlight
                              fontSize: 20,
                              fw: 2,
                              theme: theme.isDarkMode,
                            ),
                          ),
                          TextSpan(text: ' too!'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    //       TextWidget.custmText(
                    //   text: '₹300',
                    //   theme: theme.isDarkMode,
                    //   fs: 24,
                    //   fw: 2,
                    //   color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                    // ),

                    // const SizedBox(height: 8),
                    // TextWidget.custmText(
                    //         text: 'Rewarding you for spreading the word',
                    //         fs: 12,
                    //         fw: 0,
                    //         theme: theme.isDarkMode,
                    //         color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                    //       ),
                    // const SizedBox(height: 8),
                    // TextWidget.custmText(
                    //   text: 'Your friend earns ₹50 on their first investment',
                    //   fs: 12,
                    //   fw: 0,
                    //   theme: theme.isDarkMode,
                    //   color: theme.isDarkMode
                    //       ? colors.textSecondaryDark
                    //       : colors.textSecondaryLight,
                    // ),
                  ],
                ),
              ),
            ],
          ),
          // const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(ThemesProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget.subText(
          text: 'How It Works',
          theme: theme.isDarkMode,
          fw: 1,
        ),
        const SizedBox(height: 20),
        _buildNewStep(
          stepNumber: 1,
          title: 'Share Your Link',
          description:
              'Send your unique referral link to friends via WhatsApp, SMS, or social media',
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNewStep(
          stepNumber: 2,
          title: 'Friend Joins & Invests',
          description:
              'Your friend signs up and completes their first investment using your link',
          theme: theme,
        ),
        const SizedBox(height: 16),
        _buildNewStep(
          stepNumber: 3,
          title: 'Both Get Rewarded',
          description:
              'You both receive ₹300 instantly! No limits on how much you can earn',
          theme: theme,
          isLast: true,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: theme.isDarkMode
              ? colors.textSecondaryDark.withOpacity(0.04)
              : colors.textSecondaryLight.withOpacity(0.04),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.orange.shade700,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextWidget.custmText(
                  text:
                      'Tip: The more friends you refer, the more rewards you earn!',
                  fs: 12,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight,
                  fw: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // OLD IMPLEMENTATION - COMMENTED OUT
  // Widget _buildHowItWorksSection(ThemesProvider theme) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       TextWidget.subText(
  //         text: 'How It Works',
  //         theme: theme.isDarkMode,
  //         fw: 1,
  //       ),
  //       const SizedBox(height: 16),
  //       _buildStep(
  //         icon: Icons.chat_bubble_outline,
  //         iconColor: Colors.green.shade600,
  //         title: 'Share Your Link',
  //         description: 'Send your referral link via WhatsApp, SMS, or any messaging app',
  //         theme: theme,
  //       ),
  //       const SizedBox(height: 8),
  //       _buildStep(
  //         icon: Icons.person_outline,
  //         iconColor: Colors.blue.shade900,
  //         title: 'Friend Signs Up',
  //         description: 'Your friend creates their account using your unique referral link',
  //         theme: theme,
  //       ),
  //       const SizedBox(height: 8),
  //       _buildStep(
  //         icon: Icons.card_giftcard_outlined,
  //         iconColor: Colors.green.shade600,
  //         title: 'Both Get Rewarded',
  //         description: 'You both receive ₹300 once they complete their first investment',
  //         theme: theme,
  //       ),
  //       const SizedBox(height: 16),
  //       Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.all(8),
  //         color: theme.isDarkMode ? colors.textSecondaryDark.withOpacity(0.04) : colors.textSecondaryLight.withOpacity(0.04),
  //         child: Row(
  //           children: [
  //             Icon(
  //               Icons.lightbulb_outline,
  //               color: Colors.orange.shade700,
  //               size: 18,
  //             ),
  //             const SizedBox(width: 8),
  //             Expanded(
  //               child: TextWidget.custmText(
  //                 text: 'Tip: The more friends you refer, the more rewards you earn!',
  //                 fs: 12,
  //                 theme: theme.isDarkMode,
  //                 color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
  //                 fw: 0,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildNewStep({
    required int stepNumber,
    required String title,
    required String description,
    required ThemesProvider theme,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number with gradient circle and connecting line
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight,
                      theme.isDarkMode
                          ? colors.primaryDark.withOpacity(0.3)
                          : colors.primaryLight.withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget.subText(
                text: title,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 1,
              ),
              const SizedBox(height: 4),
              TextWidget.paraText(
                text: description,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                fw: 0,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required ThemesProvider theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        border: Border.all(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget.subText(
                  text: title,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0,
                ),
                const SizedBox(height: 4),
                TextWidget.custmText(
                  text: description,
                  fs: 12,
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark
                      : colors.textSecondaryLight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildReferralCodeSection(ThemesProvider theme) {
  //   return Column(
  //     children: [
  //       TextWidget.subText(
  //         text: 'Use the referral code to invite your friends',
  //         theme: theme.isDarkMode,
  //         color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
  //         align: TextAlign.center,
  //         fw: 0,
  //       ),
  //       const SizedBox(height: 12),
  //       Container(
  //         width: double.infinity,
  //         padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight),
  //           borderRadius: BorderRadius.circular(5),
  //           color: theme.isDarkMode ? colors.primaryDark.withOpacity(0.04) : colors.primaryLight.withOpacity(0.05),
  //         ),
  //         child: Center(
  //           child: TextWidget.headText(
  //             text: 'referralCode',
  //             theme: theme.isDarkMode,
  //             fw: 0,
  //             color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildActionButtons(
      BuildContext context, ThemesProvider theme, String reflink) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton(
            onPressed:
                _isOpeningWhatsApp ? null : () => _shareViaWhatsApp(context),
            // icon: Icon(Icons.chat_outlined, color: Colors.white),
            // ignore: sort_child_properties_last
            child: _isOpeningWhatsApp
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextWidget.subText(
                        text: 'Opening WhatsApp...',
                        theme: theme.isDarkMode,
                        fw: 2,
                        color: colors.colorWhite,
                      ),
                    ],
                  )
                : TextWidget.subText(
                    text: 'SHARE VIA WHATSAPP',
                    theme: theme.isDarkMode,
                    fw: 2,
                    color: colors.colorWhite,
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Share.share(
                    "I invite you to explore Mynt by Zebu — from Stocks to Mutual funds and more.\nOpen your free demat account today\n👉 ${Uri.parse(reflink)}",
                  );
                },
                icon: Icon(Icons.share, color: Colors.blue.shade900, size: 18),
                label: TextWidget.subText(
                  text: 'Share Invite Link',
                  theme: theme.isDarkMode,
                  color: theme.isDarkMode
                      ? colors.primaryDark
                      : colors.primaryLight,
                  fw: 2,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                      color: theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTermsText(ThemesProvider theme) {
    return InkWell(
      onTap: () {
        // launchUrl(Uri.parse('https://mynt.in/terms-and-conditions'));
      },
      child: TextWidget.captionText(
        text:
            'By sharing this referral, you agree to our Terms and Conditions. Offer valid for new users only.',
        theme: theme.isDarkMode,
        color: theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        fw: 0,
        align: TextAlign.center,
      ),
    );
  }

  Widget _buildReferralStatsSection(
      ThemesProvider theme, DashboardProvider dashboard) {
    final referralData = dashboard.referralRewards;
    final completedCount = referralData?.completed?.length ?? 0;
    final pendingCount = referralData?.pendingRemovedList?.length ?? 0;
    final totalRewards = completedCount * 300;

    return Column(
      children: [
        _buildStatCard(
          icon: Icons.card_giftcard,
          iconColor: Colors.teal,
          title: 'Referral Rewards',
          primaryTitle: '₹$totalRewards',
          onTap: () => _showReferralRewardsBottomSheet(theme, dashboard),
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          icon: Icons.person_outline,
          iconColor: Colors.blue.shade900,
          title: 'Pending Referrals',
          primaryTitle: '$pendingCount Invites',
          onTap: () => _showPendingReferralsBottomSheet(theme, dashboard),
          theme: theme,
        ),
        // const SizedBox(height: 12),
        // _buildMilestoneCard(theme),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String primaryTitle,
    required VoidCallback onTap,
    required ThemesProvider theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      text: title,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                    const SizedBox(height: 4),
                    TextWidget.subText(
                      text: primaryTitle,
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                      fw: 1,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : colors.textSecondaryLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsExpandedContent(
      ThemesProvider theme, DashboardProvider dashboard, [ScrollController? scrollController]) {
    final referralData = dashboard.referralRewards;
    final completedReferrals = referralData?.completed ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (completedReferrals.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(assets.noDatafound,
                        color: Color(0xff777777)),
                    const SizedBox(height: 2),
                    TextWidget.subText(
                        text: "No completed referrals yet",
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                        theme: theme.isDarkMode)
                  ]),
            ),
          )
          else
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: completedReferrals.length,
                separatorBuilder: (context, index) =>  Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      height: 0,
                    ),
                itemBuilder: (context, index) {
                  final referral = completedReferrals[index];
                  return _buildRewardListItem(
                    clientId: referral.clientcode ?? '',
                    rewardDate: _formatDate(referral.activateDt ?? ''),
                    mobileNo: referral.mobile ?? '',
                    reward : "₹300",
                    theme: theme,
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _buildPendingExpandedContent(
      ThemesProvider theme, DashboardProvider dashboard, [ScrollController? scrollController]) {
    final referralData = dashboard.referralRewards;
    final allPendingReferrals = referralData?.pendingRemovedList ?? [];
    
    // Filter based on selected filter type
    final pendingReferrals = _getFilteredPendingReferrals(allPendingReferrals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pendingReferrals.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(assets.noDatafound,
                        color: Color(0xff777777)),
                    const SizedBox(height: 2),
                    TextWidget.subText(
                        text: _getEmptyStateText(),
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        fw: 0,
                        theme: theme.isDarkMode)
                  ]),
            ),
          )
          else
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: pendingReferrals.length,
                separatorBuilder: (context, index) =>  Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      height: 0,
                    ),
                itemBuilder: (context, index) {
                  final referral = pendingReferrals[index];
                  return _buildPendingListItem(
                    mobileNo: referral.mobile ?? '',
                    initiatedDate: _formatDate(referral.initiatedDt ?? ''),
                    stage: referral.stage ?? '',
                    theme: theme,
                  );
                },
              ),
            ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String title,
    required String amount,
    required ThemesProvider theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextWidget.custmText(
            text: title,
            fs: 12,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0,
          ),
        ),
        TextWidget.custmText(
          text: amount,
          fs: 12,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
      ],
    );
  }

  Widget _buildPendingItem({
    required IconData icon,
    required String title,
    required String count,
    required ThemesProvider theme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.isDarkMode
              ? colors.textSecondaryDark
              : colors.textSecondaryLight,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextWidget.custmText(
            text: title,
            fs: 14,
            theme: theme.isDarkMode,
            color: theme.isDarkMode
                ? colors.textSecondaryDark
                : colors.textSecondaryLight,
            fw: 0,
          ),
        ),
        TextWidget.custmText(
          text: count,
          fs: 14,
          theme: theme.isDarkMode,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
      ],
    );
  }

  Widget _buildRewardListItem({
    required String clientId,
    required String rewardDate,
    required String mobileNo,
    required String reward,
    required ThemesProvider theme,
  }) {
    // Color statusColor;
    // switch (rewardStatus.toLowerCase()) {
    //   case 'completed':
    //     statusColor = Colors.green;
    //     break;
    //   case 'pending':
    //     statusColor = Colors.orange;
    //     break;
    //   case 'failed':
    //     statusColor = Colors.red;
    //     break;
    //   default:
    //     statusColor = theme.isDarkMode
    //         ? colors.textSecondaryDark
    //         : colors.textSecondaryLight;
    // }

    return ListTile(
      // contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: false,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextWidget.subText(
                text: clientId,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ),
            // const SizedBox(width: 8),
            TextWidget.subText(
              text: reward,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textPrimaryDark
                  : colors.textPrimaryLight,
              fw: 0,
            ),
          ],
        ),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: TextWidget.paraText(
              text: rewardDate,
              theme: theme.isDarkMode,
              color: theme.isDarkMode
                  ? colors.textSecondaryDark
                  : colors.textSecondaryLight,
              fw: 0,
            ),
          ),
         
        ],
      ),
    );

    // Right side - Status badge
  }

  Widget _buildPendingListItem({
    required String mobileNo,
    required String initiatedDate,
    required String stage,
    required ThemesProvider theme,
  }) {
    Color stageColor;
    switch (stage.toLowerCase()) {
      case 'pending':
        stageColor = colors.pending;
        break;
      case 'removed':
        stageColor = theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight;
        break;
      case 'completed':
        stageColor = theme.isDarkMode ? colors.profitDark : colors.profitLight;
        break;
      default:
        stageColor = theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight;
    }

    return ListTile(
      dense: false,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextWidget.subText(
                text: mobileNo,
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textPrimaryDark
                    : colors.textPrimaryLight,
                fw: 0,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: stageColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: stageColor.withOpacity(0.3)),
              ),
              child: TextWidget.custmText(
                text: stage.toUpperCase(),
                fs: 10,
                theme: theme.isDarkMode,
                color: stageColor,
                fw: 1,
              ),
            ),
          ],
        ),
      ),
      subtitle: TextWidget.paraText(
        text: initiatedDate,
        theme: theme.isDarkMode,
        color: theme.isDarkMode
            ? colors.textSecondaryDark
            : colors.textSecondaryLight,
        fw: 0,
      ),
    );
  }

  Widget _buildMilestoneCard(ThemesProvider theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
        border: Border.all(
            color: theme.isDarkMode ? colors.dividerDark : colors.dividerLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.isDarkMode
                      ? colors.profitDark.withOpacity(0.1)
                      : colors.profitLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.trending_up,
                  color:
                      theme.isDarkMode ? colors.profitDark : colors.profitLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                      text: 'Next Milestone',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                    const SizedBox(height: 4),
                    TextWidget.paraText(
                      text: 'Refer 5 friends to unlock bonus rewards',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? colors.textSecondaryDark
                          : colors.textSecondaryLight,
                      fw: 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget.captionText(
                text: '0 referrals',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : Colors.grey.shade600,
              ),
              TextWidget.captionText(
                text: '5 referrals',
                theme: theme.isDarkMode,
                color: theme.isDarkMode
                    ? colors.textSecondaryDark
                    : Colors.grey.shade600,
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: Colors.grey.shade300,
            color: theme.isDarkMode ? colors.primaryDark : colors.primaryLight,
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  void _shareViaWhatsApp(BuildContext context) async {
    setState(() {
      _isOpeningWhatsApp = true;
    });

    final Preferences pref = locator<Preferences>();
    final String reflink = "https://oa.mynt.in/?ref=${pref.clientId}";
    final String message =
        "I invite you to explore Mynt by Zebu — from Stocks to Mutual funds and more.\nOpen your free demat account today\n👉 $reflink";

    // WhatsApp URL scheme
    final String whatsappUrl =
        "https://wa.me/?text=${Uri.encodeComponent(message)}";

    try {
      final Uri whatsappUri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to regular share if WhatsApp is not available
        await Share.share(message);
      }
    } catch (e) {
      // Show error message and fallback to regular share
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: TextWidget.subText(
          text: 'WhatsApp not available. Opening share options...',
          theme: false,
          color: Colors.white,
        )),
      );
      await Share.share(message);
    } finally {
      // Reset the loading state after a delay
      _resetTimer?.cancel();
      _resetTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isOpeningWhatsApp = false;
          });
        }
      });
    }
  }

  // void _shareLink(BuildContext context) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: TextWidget.subText(
  //       text: 'Sharing link...',
  //       theme: false,
  //       color: Colors.white,
  //     )),
  //   );
  // }

  void _showReferralRewardsBottomSheet(
      ThemesProvider theme, DashboardProvider dashboard) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SafeArea(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
                left: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
                right: BorderSide(
                  color: theme.isDarkMode
                      ? colors.textSecondaryDark.withOpacity(0.5)
                      : colors.colorWhite,
                ),
              ),
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
            ),
            child: Column(
              children: [
                // Handle bar
                const CustomDragHandler(),
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget.titleText(
                        text:
                            'Referral Rewards (${dashboard.referralRewards?.completed?.length ?? 0})',
                        theme: theme.isDarkMode,
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fw: 1,
                      ),
                      Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 150));
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(20),
                          splashColor: theme.isDarkMode
                              ? Colors.white.withOpacity(0.15)
                              : Colors.black.withOpacity(0.15),
                          highlightColor: theme.isDarkMode
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: theme.isDarkMode
                                  ? colors.textSecondaryDark
                                  : colors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
               Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                      height: 0,
                    ),
                 // Content
                 Expanded(
                   child: _buildRewardsExpandedContent(theme, dashboard, scrollController),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPendingReferralsBottomSheet(
      ThemesProvider theme, DashboardProvider dashboard) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) => SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.5)
                        : colors.colorWhite,
                  ),
                  left: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.5)
                        : colors.colorWhite,
                  ),
                  right: BorderSide(
                    color: theme.isDarkMode
                        ? colors.textSecondaryDark.withOpacity(0.5)
                        : colors.colorWhite,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const CustomDragHandler(),
                  // Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget.titleText(
                          text:
                              'Pending Referrals (${_getFilteredPendingCount(dashboard)})',
                          theme: theme.isDarkMode,
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          fw: 1,
                        ),
                        Row(
                          children: [
                            // Filter Icon - only show when there are referrals
                            if (_getFilteredPendingCount(dashboard) > 0)
                              PopupMenuButton<String>(
                              color: theme.isDarkMode
                              ? colors.searchBgDark
                              : colors.searchBg,
                              constraints: const BoxConstraints(
                                minWidth: 120,
                                maxWidth: 150,
                              ),
                              onSelected: (String value) {
                                if (value != _pendingFilterType) {
                                  setState(() {
                                    _pendingFilterType = value;
                                  });
                                  setModalState(() {
                                    // Trigger modal rebuild
                                  });
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem<String>(
                                  value: 'All',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    child: Row(
                                      children: [
                                       
                                        TextWidget.subText(
                                          text: 'All',
                                          theme: theme.isDarkMode,
                                          color: _pendingFilterType == 'All' 
                                            ? (theme.isDarkMode ? colors.primaryDark : colors.primaryLight)
                                            : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                                          fw: _pendingFilterType == 'All' ? 1 : 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Pending',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    child: Row(
                                      children: [
                                       
                                        TextWidget.subText(
                                          text: 'Pending',
                                          theme: theme.isDarkMode,
                                          color: _pendingFilterType == 'Pending' 
                                            ? (theme.isDarkMode ? colors.primaryDark : colors.primaryLight)
                                            : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                                          fw: _pendingFilterType == 'Pending' ? 1 : 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: 'Removed',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    child: Row(
                                      children: [
                                        
                                        TextWidget.subText(
                                          text: 'Removed',
                                          theme: theme.isDarkMode,
                                          color: _pendingFilterType == 'Removed' 
                                            ? (theme.isDarkMode ? colors.primaryDark : colors.primaryLight)
                                            : (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight),
                                          fw: _pendingFilterType == 'Removed' ? 1 : 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  splashColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.15),
                                  highlightColor: theme.isDarkMode
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.08),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Icon(
                                      Icons.filter_list_rounded,
                                      size: 22,
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                          : colors.textSecondaryLight,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_getFilteredPendingCount(dashboard) > 0)
                              const SizedBox(width: 8),
                            // Close Icon
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () async {
                                  await Future.delayed(
                                      const Duration(milliseconds: 150));
                                  Navigator.pop(context);
                                },
                                borderRadius: BorderRadius.circular(20),
                                splashColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.15),
                                highlightColor: theme.isDarkMode
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.08),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 22,
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                        : colors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                        color: theme.isDarkMode
                            ? colors.darkColorDivider
                            : colors.colorDivider,
                        height: 0,
                      ),
                   // Content
                   Expanded(
                     child: _buildPendingExpandedContent(theme, dashboard, scrollController),
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get filtered pending referrals count
  int _getFilteredPendingCount(DashboardProvider dashboard) {
    final allPendingReferrals = dashboard.referralRewards?.pendingRemovedList ?? [];
    return _getFilteredPendingReferrals(allPendingReferrals).length;
  }

  // Helper method to filter pending referrals based on selected filter
  List<dynamic> _getFilteredPendingReferrals(List<dynamic> allPendingReferrals) {
    switch (_pendingFilterType) {
      case 'Pending':
        return allPendingReferrals.where((referral) => 
          (referral.stage ?? '').toLowerCase() == 'pending').toList();
      case 'Removed':
        return allPendingReferrals.where((referral) => 
          (referral.stage ?? '').toLowerCase() == 'removed').toList();
      case 'All':
      default:
        return allPendingReferrals;
    }
  }

  // Helper method to get empty state text based on filter
  String _getEmptyStateText() {
    switch (_pendingFilterType) {
      case 'Pending':
        return "No pending referrals";
      case 'Removed':
        return "No removed referrals";
      case 'All':
      default:
        return "No referrals found";
    }
  }

}
