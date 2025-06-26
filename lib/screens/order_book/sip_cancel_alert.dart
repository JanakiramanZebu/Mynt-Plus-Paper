import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/order_book_model/sip_order_book.dart';
import '../../../res/res.dart';
import '../../provider/order_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
import '../../sharedWidget/functions.dart';

class SipCancelAlert extends ConsumerWidget {
  final SipDetails sipdetails;
  const SipCancelAlert({
    super.key,
    required this.sipdetails,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return AlertDialog(
      backgroundColor: theme.isDarkMode
          ? const Color.fromARGB(255, 18, 18, 18)
          : colors.colorWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      scrollable: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      titlePadding: const EdgeInsets.all(0),
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset("assets/icon/ipo_cancel_icon.svg"),
      ),
      content: Column(
        children: [
          TextWidget.titleText(text: "Are you sure you want to cancel the (${sipdetails.scrips![0].tsym.toString().toUpperCase()})",theme:theme.isDarkMode,fw: 1,align: TextAlign.center),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xffF1F3F8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: TextWidget.paraText(text: "No",theme: false, color: colors.colorGrey,fw: 1)),
            ),
            const SizedBox(width: 16),
            Expanded(
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
                    ref.read(orderProvider).fetchSipOrderCancel(
                        "${sipdetails.internal!.sipId}", context);
                  },
                  child: TextWidget.paraText(text: "Yes",theme: theme.isDarkMode,fw: 1)),
            )
          ],
        ),
      ],
    );
  }
}
