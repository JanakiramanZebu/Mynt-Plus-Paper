import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mynt_plus/sharedWidget/loader_ui.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:mynt_plus/sharedWidget/snack_bar.dart';
import '../../provider/fund_provider.dart';
import '../../provider/mf_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';

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
            child: mfData.mfsiporderlist?.xsip?.isEmpty ?? true
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

  Widget _buildSipOrderList(BuildContext context, dynamic mfData, dynamic theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: mfData.mfsiporderlist?.xsip?.length ?? 0,
      itemBuilder: (BuildContext context, int index) {
        final item = mfData.mfsiporderlist?.xsip?[index];
        if (item == null) return const SizedBox.shrink();
        
        return Column(
          children: [
            InkWell(
              onTap: () async {
                try {
                  mfData.loaderfun();
                  final xsipRegId = item.xsipRegId;
                  
                  if (xsipRegId != null) {
                    await mfData.fetchmfsipsinglepage(xsipRegId);
                    
                    if (mfData.mfsinglepageres?.stat == "Ok") {
                      Navigator.pushNamed(context, Routes.mfSipdetScren);
                    } else {
                      final errorMsg = mfData.mfsinglepageres?.Msg ?? "Failed to fetch SIP details";
                      ScaffoldMessenger.of(context).showSnackBar(
                        successMessage(context, errorMsg)
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      successMessage(context, "Missing SIP registration ID")
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    successMessage(context, "Error: ${e.toString()}")
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffEEF0F2),
                      width: 0,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.7,
                                      child: Text(
                                        item.schemeName ?? "Unknown Scheme",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textStyles.scripNameTxtStyle.copyWith(
                                          color: theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  SvgPicture.asset(
                                    item.liveCancel == "LIVE"
                                        ? assets.completedIcon
                                        : assets.cancelledIcon,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text(
                                      item.liveCancel == "LIVE" ? "Live" : "Cancel",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  CustomExchBadge(
                                    exch: item.frequencyType ?? "Unknown",
                                  ),
                                  const SizedBox(width: 5),
                                  CustomExchBadge(
                                    exch: item.dateTime ?? "Unknown Date",
                                  ),
                                  const SizedBox(width: 5),
                                  if (item.liveCancel == "LIVE" && item.nextSipDate != null) 
                                    CustomExchBadge(
                                      exch: "Due Date : ${item.nextSipDate}",
                                    ),
                                  const Spacer(),
                                  Text(
                                    item.amount ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Divider between items
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : const Color(0xffECEDEE),
              thickness: 2.0,
            ),
          ],
        );
      },
    );
  }
}