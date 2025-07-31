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
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';
import 'mf_sip_details_screen.dart';
import 'mf_sip_order_history.dart';

class MFSipdetScreen extends ConsumerWidget {
  const MFSipdetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    return Scaffold(
      body: Stack(
        children: [
          TransparentLoaderScreen(
            isLoading: mfData.bestmfloader ?? false,
            child: mfData.mfsiporderlist?.data?.isEmpty ?? true
                ? const Center(child: NoDataFound())
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
    );
  }

  Widget _buildSipOrderList(
      BuildContext context, dynamic mfData, dynamic theme) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => const ListDivider(),
      // padding: const EdgeInsets.all(0),
      itemCount: (mfData.mfsiporderlist?.data?.length ?? 0) + 1,
      itemBuilder: (BuildContext context, int index) {
       
        if (index == mfData.mfsiporderlist?.data?.length) {
          return InkWell(
            onTap: () {
              mfData.fetchmfsipnotlivelist();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MFSipOrderHistoryScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget.subText(
                    text: "View SIP Order History",
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    theme: theme.isDarkMode,
                    fw: 3,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                  ),
                ],
              ),
            ),
          );
        }
        
        final item = mfData.mfsiporderlist?.data?[index];
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
                            maxLines: 1,
                            fw: 3),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.status == "ACTIVE"
                              ? colors.profit.withOpacity(0.1)
                              : colors.loss.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextWidget.paraText(
                            // align: TextAlign.start,
                            text: item.status == "ACTIVE" ? "Live" : item.status,
                            color: item.status == "ACTIVE"
                                ? colors.profit
                                : colors.loss,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            maxLines: 2,
                            fw: 3),
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
                                ? colors.textPrimaryDark
                                : colors.textPrimaryLight,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            maxLines: 2,
                            fw: 3),
                      const Spacer(),
                      TextWidget.paraText(
                          align: TextAlign.start,
                          text: item.installmentAmount ?? 'N/A',
                          color: theme.isDarkMode
                              ? colors.textPrimaryDark
                              : colors.textPrimaryLight,
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          maxLines: 2,
                          fw: 3),
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
