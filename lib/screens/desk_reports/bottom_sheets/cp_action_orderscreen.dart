import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/snack_bar.dart';

class CPActionOrderScreen extends StatefulWidget {
  final dynamic data;
  const CPActionOrderScreen({super.key, required this.data});

  @override
  State<CPActionOrderScreen> createState() => _CPActionOrderScreen();
}

class DropdownItem {
  final String value;
  final String label;
  final bool isEnabled;

  DropdownItem({
    required this.value,
    required this.label,
    this.isEnabled = true,
  });
}

class _CPActionOrderScreen extends State<CPActionOrderScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final ledgerprovider = ref.watch(ledgerProvider);
      final theme = ref.read(themeProvider);

      // final myController = TextEditingController(text: ledgerprovider.selectnetpledge.text);
      // String selectedValue = ledgerprovider.segmentvalue;

// Optional: remove duplicates if needed (based on value)
      final seen = <String>{};

      return WillPopScope(
        onWillPop: () async {
          if (ledgerprovider.listforpledge == []) {
            ledgerprovider.changesegvaldummy('');
          }
          Navigator.pop(context);
          print(
              "objectobjectobjectobjectobjectobjectobjectobject ${screenheight * 0.00038}");
          return true;
        },
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.isDarkMode
                    ? Color.fromARGB(255, 0, 0, 0)
                    : Color.fromARGB(255, 255, 255, 255)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: const Color.fromARGB(255, 219, 218, 218),
                    width: 40,
                    height: 4.0,
                    padding: EdgeInsets.only(
                        top: 10, bottom: 25, left: 20, right: 20),
                    margin: EdgeInsets.only(top: 16),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, bottom: 8.0),
                child: TextWidget.heroText(
                    text: "${ledgerprovider.selectvalueofcpaction}",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    fw: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 2.0,
                  bottom: 6.0,
                ),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 6.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.40,
                              child: TextWidget.subText(
                                  text: "${widget.data?.name}",
                                  color: colors.colorBlack,
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: TextWidget.captionText(
                                  text:
                                      "${widget.data?.biddingStartDate} : ${widget.data?.biddingEndDate}",
                                  color: colors.kColorGreyDarkTheme,
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 1),
                            ),
                          ],
                        ),
                        TextWidget.paraText(
                            text: "${widget.data?.cutOffPrice}",
                            color: colors.colorBlack,
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 1),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget.paraText(
                            text: "Share this link Or copy link",
                            textOverflow: TextOverflow.ellipsis,
                            theme: theme.isDarkMode,
                            fw: 0),
                        Row(
                          children: [
                            Container(
                              width: screenWidth * 0.7,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 14),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: theme.isDarkMode
                                      ? const Color(0xffB5C0CF).withOpacity(.15)
                                      : const Color(0xffF1F3F8)),
                              child: TextWidget.paraText(
                                  text: "cdscfasa",
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
            ]),
          ),
        ),
      );
    });
  }
}
