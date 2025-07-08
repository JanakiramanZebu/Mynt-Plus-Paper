// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/res/res.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/fund_provider.dart';
import '../../../provider/mf_provider.dart';
import '../../../provider/thems.dart';
import '../../../routes/route_names.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/loader_ui.dart';

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
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color:
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Text(
            "New Fund Offer",
            style: textStyles.appBarTitleTxt.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            ),
          ),
        ),
      ),
      body: TransparentLoaderScreen(
        isLoading: mf.investloader,
        child: _buildContent(context, mf, theme),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, MFProvider mf, ThemesProvider theme) {
    if (mf.mfNFOList!.nfoList!.isEmpty) {
      return const Center(child: NoDataFound());
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              itemCount: mf.mfNFOList!.nfoList!.length,
              itemBuilder: (BuildContext context, int index) {
                final nfoItem = mf.mfNFOList!.nfoList![index];

                return Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        try {
                          mf.chngMandate("Lumpsum");
                          await mf.fetchUpiDetail();
                          await mf.fetchBankDetail();

                          if (nfoItem.sIPFLAG == "Y") {
                            await mf.fetchMFSipData(
                              nfoItem.iSIN!,
                              nfoItem.schemeCode!,
                            );
                            await mf.fetchMFMandateDetail();
                          }
                          mf.orderpagetite("NFO");

                          if (context.mounted) {
                            Navigator.pushNamed(
                              context,
                              Routes.mforderScreen,
                              arguments: nfoItem,
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${e.toString()}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    "https://v3.mynt.in/mf/static/images/mf/${nfoItem.aMCCode ?? 'default'}.png",
                                  ),
                                  onBackgroundImageError: (_, __) {},
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.65,
                                            child: 
                                            
                                            
                                            TextWidget.subText(
                                                    align: TextAlign.start,
                                                    text: nfoItem.fSchemeName ??
                                                  "Unknown Fund",
                                                    color: theme.isDarkMode
                                                        ?  colors.textPrimaryDark:
                                                         colors.textPrimaryLight
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                                    
                                                    
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                           TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text: "Open ${_formatDate(nfoItem.startDate)}",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark
                                                        :  colors.textSecondaryLight 
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                           
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child:TextWidget.paraText(
                                                    align: TextAlign.start,
                                                    text:  "Closing ${_formatDate(nfoItem.endDate)}",
                                                    color: theme.isDarkMode
                                                        ?  colors.textSecondaryDark
                                                        :  colors.textSecondaryLight 
                                                             ,
                                                    textOverflow:
                                                        TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                    theme: theme.isDarkMode,
                                                    fw: 3),
                                           
                                            
                                            
                                              
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Divider(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : colors.colorDivider,
                              thickness: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
