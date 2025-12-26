import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../provider/thems.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_drag_handler.dart';

class IosNOUpiAppsSheet extends StatelessWidget {
  final ThemesProvider theme;

  const IosNOUpiAppsSheet({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          boxShadow: const [
            BoxShadow(
                color: Color(0xff999999),
                blurRadius: 4.0,
                offset: Offset(2.0, 0.0))
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 6,
          ),
          const CustomDragHandler(),
          const SizedBox(
            height: 6,
          ),
          SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
          const SizedBox(
            height: 10,
          ),
          TextWidget.titleText(
              text:
              "No suitable app available, kindly choose a different mode of payment",
              theme: false,
              color: theme.isDarkMode ? colors.colorGrey : colors.colorBlack,
              fw: 1,
              align: TextAlign.center),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.isDarkMode
                        ? colors.colorbluegrey
                        : colors.colorBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                onPressed: () async {
                  launch("https://apps.apple.com/app");
                },
              child: TextWidget.paraText(
                  text: "Get UPI Apps",
                  theme: false,
                  color:
                      theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                  fw: 1),
            ),
          ),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }
}
