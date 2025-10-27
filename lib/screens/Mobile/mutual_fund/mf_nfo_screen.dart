// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../routes/route_names.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../sharedWidget/custom_back_btn.dart';
import '../../../sharedWidget/list_divider.dart';
import '../../../sharedWidget/loader_ui.dart';

class MFNFOScreen extends ConsumerWidget {
  const MFNFOScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mf = ref.watch(mfProvider);
    final theme = ref.watch(themeProvider);
    final fund = ref.watch(fundProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          elevation: 0.2,
          leadingWidth: 41,
          centerTitle: false,
          titleSpacing: 6,
          leading: const CustomBackBtn(),
          title: TextWidget.titleText(
            text: "New Fund Offer",
            color: theme.isDarkMode
                ? colors.textPrimaryDark
                : colors.textPrimaryLight,
            theme: theme.isDarkMode,
            fw: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: TransparentLoaderScreen(
          isLoading: mf.investloader,
          child: _buildContent(context, mf, theme, ref, fund),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MFProvider mf,
      ThemesProvider theme, WidgetRef ref, FundProvider fund) {
    if (mf.mfNFOList!.mutualFundList!.isEmpty) {
      return const Center(child: NoDataFound());
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const ListDivider(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: mf.mfNFOList!.mutualFundList!.length,
              itemBuilder: (BuildContext context, int index) {
                final nfoItem = mf.mfNFOList!.mutualFundList![index];

                return InkWell(
                  onTap: () async {
                    try {
                      final isin = nfoItem.iSIN;
                      final schemeCode = nfoItem.schemeCode;
                      if ((nfoItem.sIPFLAG == "Y" &&
                          isin != null &&
                          schemeCode != null)) {
                        mf.invertfun(isin, schemeCode, context);
                      }
                      if (mf.mfOrderTpye == "One-time") {
                        String amt = nfoItem.minimumPurchaseAmount ?? "0";
                        mf.invAmt.text = amt.split('.').first;
                      } else {
                        String amt = nfoItem.minimumPurchaseAmount ?? "0";
                        mf.installmentAmt.text = amt.split('.').first;
                      }
                      fund.fetchFunds(context);
                      ref.read(transcationProvider).initialdata(context);

                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          Routes.mforderScreen,
                          arguments: nfoItem,
                        );
                        mf.chngOrderType("One-time");
                        mf.orderchangetitle("One-time");
                        mf.orderpagetite("NFO");
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showResponsiveErrorMessage(context, "Error: ${e.toString()}");
                      }
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    dense: false,
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://v3.mynt.in/mfapi/static/images/mf/${nfoItem.aMCCode ?? 'default'}.png",
                      ),
                      onBackgroundImageError: (_, __) {},
                    ),
                    title: Container(
                      margin: EdgeInsets.only(
                        right: MediaQuery.of(context).size.width * 0.1,
                      ),
                      child: TextWidget.subText(
                          align: TextAlign.start,
                          text: nfoItem.name ?? "Unknown Fund",
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          theme: theme.isDarkMode,
                          fw: 3),
                    ),
                    subtitle: TextWidget.paraText(
                        align: TextAlign.start,
                        text: "Closes on ${_formatDate(nfoItem.endDate)}",
                        color: theme.isDarkMode
                            ? colors.textSecondaryDark
                            : colors.textSecondaryLight,
                        textOverflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        theme: theme.isDarkMode,
                        fw: 3),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  // Helper method to format date strings
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "N/A";
    }
    return date.replaceAll(RegExp(r'\s+'), ' ');
  }
}
