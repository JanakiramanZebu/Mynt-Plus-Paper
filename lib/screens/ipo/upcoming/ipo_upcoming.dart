// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';

class UpcomingIpo extends StatelessWidget {
  const UpcomingIpo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final ipos = ref.watch(ipoProvide);
      final theme = ref.watch(themeProvider);
      final dev_height = MediaQuery.of(context).size.height;

      void _launchURL(String url) async {
        Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          debugPrint("Could not launch $url");
        }
      }

      return SingleChildScrollView(
        child: ipos.upcomingModel?.upcoming?.isEmpty ?? true ? Padding(
              padding: const EdgeInsets.only(top: 225),
              child: SizedBox(
                height: dev_height - 140,
                child: const Column(
                  children: [
                    NoDataFound(),
                  ],
                ),
              ),
            )
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding:
            //       const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
            //   child: Text(
            //     "Upcoming",
            //     style: textStyle(
            //         theme.isDarkMode
            //             ? colors.colorWhite.withOpacity(0.3)
            //             : colors.colorBlack.withOpacity(0.3),
            //         16,
            //         FontWeight.w600),
            //   ),
            // ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              //    ClipOval(
                              //   child: Container(
                              //     color: colors.colorDivider.withOpacity(.3),
                              //     width: 40,
                              //     height: 40,
                              //     child: Container(
                              //       padding: const EdgeInsets.all(3),
                              //       child: Image.network(
                              //       ipos.upcomingModel!.upcoming![index].imageLink!,

                              //       ),
                              //     ),
                              //   ),
                              // ),

                              // SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 280,
                                    child: Text(
                                        ipos.upcomingModel!.upcoming![index]
                                            .companyName!,
                                        overflow: TextOverflow.ellipsis,
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w600)),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: ipos
                                                      .upcomingModel!
                                                      .upcoming![index]
                                                      .ipoType ==
                                                  "SME"
                                              ? theme.isDarkMode
                                                  ? colors.colorGrey
                                                      .withOpacity(.3)
                                                  : const Color.fromARGB(
                                                      255, 243, 242, 174)
                                              : theme.isDarkMode
                                                  ? colors.colorGrey
                                                      .withOpacity(.3)
                                                  : const Color.fromARGB(
                                                      255,
                                                      251,
                                                      215,
                                                      148), //(0xffF1F3F8),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                          "${ipos.upcomingModel!.upcoming![index].ipoType}",
                                          style: textStyle(
                                              const Color(0xff666666),
                                              10,
                                              FontWeight.w500))),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              final String? drhpUrl =
                                  ipos.upcomingModel!.upcoming![index].drhp;
                              if (drhpUrl != null && drhpUrl.isNotEmpty) {
                                _launchURL(drhpUrl);
                              } else {
                                debugPrint("DRHP link is missing.");
                              }
                            },
                            behavior: HitTestBehavior
                                .translucent, // Ensures the entire area is tappable
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  right: 8,
                                  top: 8,
                                  bottom: 8), // Adjust as needed
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.open_in_new,
                                    size: 14,
                                    color: Color(0xFF0037B7),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'DRHP',
                                    style: textStyle(
                                      const Color(0xFF0037B7),
                                      12,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
              itemCount: ipos.upcomingModel!.upcoming!.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 0,
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : const Color(0xffECEDEE),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}
