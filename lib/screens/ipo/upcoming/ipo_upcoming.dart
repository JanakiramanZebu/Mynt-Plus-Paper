// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';

class UpcomingIpo extends StatelessWidget {
  const UpcomingIpo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ipos = watch(ipoProvide);
      final theme = watch(themeProvider);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 0),
              child: Text(
                "Upcoming",
                style: textStyle(
                    theme.isDarkMode
                        ? colors.colorWhite.withOpacity(0.3)
                        : colors.colorBlack.withOpacity(0.3),
                    16,
                    FontWeight.w600),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {},
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        title: Row(
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
                            SizedBox(
                              width: 280,
                              child: Text(
                                  ipos.upcomingModel!.upcoming![index]
                                      .companyName!
                                      .split(" ")
                                      .map((word) => word.isNotEmpty
                                          ? word[0].toUpperCase() +
                                              word.substring(1).toLowerCase()
                                          : "")
                                      .join(" "),
                                      overflow: TextOverflow.ellipsis,
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600)),
                            ),

                              ],
                            )
                           ,
                            
                            GestureDetector(
  onTap: () {
    final String? drhpUrl = ipos.upcomingModel!.upcoming![index].drhp;
    if (drhpUrl != null && drhpUrl.isNotEmpty) {
      _launchURL(drhpUrl);
    } else {
      debugPrint("DRHP link is missing.");
    }
  },
  child:Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Icon(
      Icons.open_in_new, // External link icon
      size: 14,
      color: Color(0xFF0037B7),
    ),
    SizedBox(width: 2), // Spacing between icon and text
    Text(
      'DRHP',
      style: textStyle(
        const Color(0xFF0037B7),
        12,
        FontWeight.w600,
      ),
    ),
  ],
)

)

                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: ipos.upcomingModel!.upcoming!.length,
              separatorBuilder: (context, index) {
                return Container(
                  height: 7,
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : const Color(0xffF1F3F8),
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
