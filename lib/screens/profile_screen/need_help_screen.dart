import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/res/global_state_text.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../locator/constant.dart';
import '../../provider/thems.dart';
import '../../provider/user_profile_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_drag_handler.dart';

class NeedHelpScreen extends ConsumerStatefulWidget {
  const NeedHelpScreen({super.key});

  @override
  ConsumerState<NeedHelpScreen> createState() => _NeedHelpScreenState();
}

class _NeedHelpScreenState extends ConsumerState<NeedHelpScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final help = ref.read(userProfileProvider);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
       decoration: BoxDecoration(
             borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
           color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
           border: Border(
                                    top: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    left: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                    right: BorderSide(
                                      color: theme.isDarkMode
                                          ? colors.textSecondaryDark
                                              .withOpacity(0.5)
                                          : colors.colorWhite,
                                    ),
                                  ),
      
           
          ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              TextWidget.subText(
                  text: "Customer Support & Assistance",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0),
              const SizedBox(height: 14),
              InkWell(
                onTap: () async {
                  final Uri url = Uri(scheme: 'tel', path: "9380108010");
                  await launchUrl(url);
                },
                child: Row(children: [
                  SvgPicture.asset(assets.phone, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,),
                  const SizedBox(width: 10),
                  TextWidget.subText(
                    text: ConstantName.phoneNum,
                    theme: false,
                    color: !theme.isDarkMode
                        ? colors.textSecondaryLight
                        : colors.textSecondaryDark,
                    fw: 3,
                  )
                ]),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final Uri url = Uri(scheme: 'mailto', path: ConstantName.gamil);
                  await launchUrl(url);
                },
                child: Row(children: [
                  SvgPicture.asset(assets.sendMsg, color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,),
                  const SizedBox(width: 10),
                  TextWidget.subText(
                    text: ConstantName.gamil,
                    theme: false,
                    color: !theme.isDarkMode
                        ? colors.textSecondaryLight
                        : colors.textSecondaryDark,
                    fw: 3,
                  )
                ]),
              ),
              const SizedBox(height: 20),
              TextWidget.subText(
                  text: "Investor grievance:",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 0),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final Uri url =
                      Uri(scheme: 'mailto', path: ConstantName.gamil1);
                  await launchUrl(url);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: TextWidget.subText(
                    text: ConstantName.gamil1,
                    theme: false,
                    color: !theme.isDarkMode
                        ? colors.textSecondaryLight
                        : colors.textSecondaryDark,
                    fw: 3,
                  ),
                ),
              ),
              const SizedBox(height: 8),
      
              Divider(
                  color: theme.isDarkMode
                      ? colors.darkColorDivider
                      : colors.colorDivider,
                  thickness: 1),
              // const SizedBox(height: 8),
      
              TextWidget.subText(
                  text: "Follow us",
                  theme: false,
                  color: theme.isDarkMode
                      ? colors.textPrimaryDark
                      : colors.textPrimaryLight,
                  fw: 1),
              const SizedBox(height: 20),
              SizedBox(
                  height: 30,
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              launch("${help.socialMedaiIcons[index]['link']}");
                            },
                            child: SvgPicture.asset(
                                "${help.socialMedaiIcons[index]['icon']}" ,));
                      },
                      itemCount: help.socialMedaiIcons.length)),
              const SizedBox(height: 20)
            ]),
      ),
    );
  }
}
