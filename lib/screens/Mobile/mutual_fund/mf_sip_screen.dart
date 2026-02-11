import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/custom_exch_badge.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';
import 'mf_sip_details_screen.dart';
import 'mf_sip_order_history.dart';

class MFSipdetScreen extends ConsumerWidget {
  const MFSipdetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final mfData = ref.watch(mfProvider);

    if (mfData.mfsiporderlist?.data?.isEmpty ?? true) {
      return Center(child: NoDataFound(
                title: "No SIP Orders Found",
                subtitle: "There's nothing here yet. Buy some SIP to see them here.",
                // onSecondary: () {
                //   ref.read(mfProvider).mfExTabchange(0);
                // },
                secondaryEnabled: false,
                // secondaryLabel: "Buy SIP",
              ));
    }

    return  Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: TransparentLoaderScreen(
              isLoading: mfData.bestmfloader ?? false,
              child: RefreshIndicator(
                      onRefresh: () async {
                        await mfData.fetchmfsipnotlivelist();
                        await mfData.fetchmfsiplist();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSipOrderList(context, mfData, theme),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
    // );
  }

  Widget _buildSipOrderList(
      BuildContext context, dynamic mfData, dynamic theme) {
    return ListView.separated(
      // padding: EdgeInsets.only(bottom: 80),
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (context, index) => const ListDivider(),
      padding: EdgeInsets.zero,
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
                        ? colors.primaryDark
                        : colors.primaryLight,
                    theme: theme.isDarkMode,
                    fw: 2,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.isDarkMode
                        ? colors.primaryDark
                        : colors.primaryLight,
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
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Pre-load SIP data before showing details
                await mfData.fetchMFSipData(item.iSIN, item.schemeCode);
                mfData.clearPauseError();
                
                // Hide loading dialog
                Navigator.pop(context);
                
                // Show details screen with correct buttons
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                    builder: (context) => mfSipdetScren(data: item));
              } catch (e) {
                // Hide loading dialog on error
                Navigator.pop(context);
                
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to load SIP details: ${e.toString()}"))
                );
              }
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
                              ? theme.isDarkMode ? colors.profitDark.withOpacity(0.1) : colors.profitLight.withOpacity(0.1)
                              : theme.isDarkMode ? colors.lossDark.withOpacity(0.1) : colors.lossLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: TextWidget.paraText(
                            // align: TextAlign.start,
                            text:
                                item.status == "ACTIVE" ? "LIVE" : item.status,
                            color: item.status == "ACTIVE"
                                ? theme.isDarkMode ? colors.profitDark : colors.profitLight
                                : theme.isDarkMode ? colors.lossDark : colors.lossLight,
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
                      if (item.status == "ACTIVE" && item.NextSIPDate != "")
                        TextWidget.paraText(
                            align: TextAlign.start,
                            text: "Due Date : ${item.NextSIPDate}",
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
