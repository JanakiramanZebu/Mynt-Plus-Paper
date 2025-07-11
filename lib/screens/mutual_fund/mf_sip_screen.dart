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
                                      child: TextWidget.subText(
                                                    align: TextAlign.start,
                                                    text: item.schemeName ?? "Unknown Scheme",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    maxLines: 2,
                                                    fw: 3),
                                      
                                       
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
                                    child: 
                                    TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text:  item.liveCancel == "LIVE" ? "Live" : "Cancel",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    maxLines: 2,
                                                    fw: 3),
                                    
                                    
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                   TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text:  item.frequencyType ?? "Unknown",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    maxLines: 2,
                                                    fw: 3),
                                 
                                  const SizedBox(width: 5),
                                     TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text:  item.dateTime ?? "Unknown Date",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    maxLines: 2,
                                                    fw: 3),
                                  
                                  const SizedBox(width: 5),
                                  if (item.liveCancel == "LIVE" && item.nextSipDate != null) 
                                   TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text:  "Due Date : ${item.nextSipDate}",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    maxLines: 2,
                                                    fw: 3),
                                     
                                  const Spacer(),
                                   TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text:  item.amount ?? 'N/A',
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                    theme: theme.isDarkMode,
                                                    maxLines: 2,
                                                    fw: 3),
                                  
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