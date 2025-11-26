import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import 'mf_sip_details_screen.dart';

class MFSipOrderHistoryScreen extends ConsumerWidget {
  const MFSipOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextWidget.titleText(
          text: "SIP Order History",
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          theme: theme.isDarkMode,
          fw: 1,
        ),
        elevation: 0,
        leadingWidth: 41,
        centerTitle: false,
        titleSpacing: 6,
        leading: const CustomBackBtn(),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            TransparentLoaderScreen(
              isLoading: mfData.bestmfloader ?? false,
              child: mfData.mfnotlivesiporderlist?.data?.isEmpty ?? true
                  ? const Center(child: NoDataFound(
                    secondaryEnabled: false,
                  ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildSipOrderList(context, mfData, theme),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSipOrderList(
      BuildContext context, dynamic mfData, dynamic theme) {
    return ListView.separated(
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      separatorBuilder: (context, index) => const ListDivider(),
      // padding: const EdgeInsets.all(0),
      itemCount: mfData.mfnotlivesiporderlist?.data?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final item = mfData.mfnotlivesiporderlist?.data?[index];
        if (item == null) return const SizedBox.shrink();

        return InkWell(
          onTap: () async {
            // try {
            // mfData.loaderfun();
            final sIPRegnNo = item.sIPRegnNo;

            if (sIPRegnNo != null) {
              // await mfData.fetchmfsipsinglepage(sIPRegnNo);

              // if (mfData.mfsinglepageres?.stat == "Ok") {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  // backgroundColor: Colors.transparent,
                  builder: (context) => mfSipdetScren(data: item));
              // Navigator.pushNamed(context, Routes.mfSipdetScren);
              // } else {
              // final errorMsg = mfData.mfsinglepageres?.Msg ?? "Failed to fetch SIP details";
              // ScaffoldMessenger.of(context).showSnackBar(
              //   successMessage(context, errorMsg)
              // );
              //   }
              // } else {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     successMessage(context, "Missing SIP registration ID")
              //   );
              // }
              // } catch (e) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     successMessage(context, "Error: ${e.toString()}")
              //   );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: TextWidget.subText(
                            align: TextAlign.start,
                            text: item.name ?? "Unknown Scheme",
                            color: theme.isDarkMode
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            maxLines: 2,
                            fw: 0),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == "ACTIVE"
                              ? theme.isDarkMode ? colors.profitDark.withOpacity(0.1) : colors.profitLight.withOpacity(0.1) : item.status == "ACTIVE" ? colors.pending.withOpacity(0.1)
                              : theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextWidget.paraText(
                            // align: TextAlign.start,
                            text: item.status == "ACTIVE" ? "LIVE" : item.status,
                            color: item.status == "ACTIVE"
                              ? theme.isDarkMode ? colors.profitDark : colors.profitLight  : item.status == "ACTIVE" ? colors.pending 
                              : theme.isDarkMode ? colors.lossDark : colors.lossLight ,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            maxLines: 2,
                            fw: 0),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      // TextWidget.paraText(
                      //     align: TextAlign.start,
                      //     text: item.frequencyType ?? "Unknown",
                      //     color: theme.isDarkMode
                      //         ? colors.textPrimaryDark
                      //         : colors.textPrimaryLight,
                      //     textOverflow: TextOverflow.ellipsis,
                      //     theme: theme.isDarkMode,
                      //     maxLines: 2,
                      //     fw: 3),
                      // const SizedBox(width: 5),
                      // TextWidget.paraText(
                      //     align: TextAlign.start,
                      //     text: item.datetime ?? "Unknown Date",
                      //     color: theme.isDarkMode
                      //         ? colors.textPrimaryDark
                      //         : colors.textPrimaryLight,
                      //     textOverflow: TextOverflow.ellipsis,
                      //     theme: theme.isDarkMode,
                      //     maxLines: 2,
                      //     fw: 3),
                      // const SizedBox(width: 5),
                      if (item.status == "ACTIVE" && item.startDate != null)
                        TextWidget.paraText(
                            align: TextAlign.start,
                            text: "Due Date : ${item.startDate}",
                            color: theme.isDarkMode
                                ? colors.textSecondaryDark
                                : colors.textSecondaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            maxLines: 2,
                            fw: 0),
                      const Spacer(),
                      TextWidget.paraText(
                          align: TextAlign.start,
                          text: item.installmentAmount ?? 'N/A',
                          color: theme.isDarkMode
                              ? colors.textSecondaryDark
                              : colors.textSecondaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          maxLines: 2,
                          fw: 0),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
