import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/profile_all_details_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/fund_provider.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';
import '../../../sharedWidget/snack_bar.dart';

class cancelOrderScreenCopAction extends StatefulWidget {
  final dynamic data;
  const cancelOrderScreenCopAction({super.key, required this.data});

  @override
  State<cancelOrderScreenCopAction> createState() =>
      _cancelOrderScreenCopAction();
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

class _cancelOrderScreenCopAction extends State<cancelOrderScreenCopAction> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final ledgerprovider = ref.watch(ledgerProvider);
      final profiledetails = ref.watch(profileAllDetailsProvider);
      final fundState = ref.watch(fundProvider);

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
                    text: "Cancel order",
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
                    Column(
                      children: [
                        Container(
                          width: screenWidth * 0.90,
                          alignment: Alignment.center,
                          child: Text(
                            "Are you sure you want to ",
                            style: TextStyle(
                              color: colors.colorBlack,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true, // ensure text wraps
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10),
                          width: screenWidth * 0.90,
                          alignment: Alignment.center,
                          child: Text(
                            "cancel the order?",
                            style: TextStyle(
                              color: colors.colorBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            softWrap: true, // ensure text wraps
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(screenWidth * 0.45, 40),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: colors.kColorLightGrey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("No",
                                  textAlign: TextAlign.center,
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorBlack
                                          : colors.darkGrey,
                                      12,
                                      FontWeight.w500))),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 16.0, bottom: 16.0, left: 10),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(screenWidth * 0.45, 40),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: colors.colorBlack,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              onPressed: () async {
                                ledgerprovider.putordercopaction(
                                  ledgerprovider.selectvalueofcpaction,
                                  widget.data?.symbol ?? '',
                                  widget.data?.exchange ?? '',
                                  widget.data?.issueType ?? '',
                                  widget.data?.bidqty ?? '',
                                  widget.data?.orderprice ?? '',
                                  context,
                                  'CR',
                                  widget.data?.appno ?? '',
                                );
                                // ledgerprovider.putordercopaction(
                                //     widget.data?.exchange ?? '',
                                //     widget.data?.issueType ?? '',
                                //     widget.data?.symbol ?? '',
                                //     context);
                              },
                              child: Text("Yes",
                                  textAlign: TextAlign.center,
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      12,
                                      FontWeight.w500))),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }
}
