import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; 
import '../../provider/thems.dart';
import '../../res/res.dart';
import 'custom_exch_badge.dart';

class AlertDialogue extends ConsumerWidget {
  final String scripName;
  final String exch;
  final String content;
  const AlertDialogue(
      {super.key,
      required this.scripName,
      required this.exch,
      required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.read(themeProvider);
    return AlertDialog(
       backgroundColor:theme.isDarkMode? const Color.fromARGB(255, 18, 18, 18):colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      scrollable: true,
      actionsPadding:
          const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      titlePadding: const EdgeInsets.only(left: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Information',
              style: textStyle( theme.isDarkMode?colors.colorWhite:colors.colorBlack, 16, FontWeight.w600)),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded))
        ],
      ),
      content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            Divider(color: colors.colorDivider, height: 0),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$scripName  ",
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.appBarTitleTxt.copyWith(color: theme.isDarkMode?colors.colorWhite:colors.colorBlack)),
                 CustomExchBadge(exch: exch)
              ],
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: Text(content,
                      style: textStyle(
                           theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)))
            ]),
            const SizedBox(height: 10),
          ])),
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor:  theme.isDarkMode?colors.colorWhite:colors.colorBlack,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: Text("Ok",
                style: textStyle( !theme.isDarkMode?colors.colorWhite:colors.colorBlack, 14, FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  Text headerTitleText(String text) {
    return Text(text,
        style: textStyle(const Color(0xff000000), 14, FontWeight.w500));
  }
}
