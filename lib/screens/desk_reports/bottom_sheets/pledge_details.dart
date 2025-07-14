import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';

class PledgeDeytails extends StatefulWidget {
  final dynamic data;
  const PledgeDeytails({super.key, required this.data});

  @override
  State<PledgeDeytails> createState() => _PledgeDeytails();
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

class _PledgeDeytails extends State<PledgeDeytails> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;

    return Consumer(builder: (context, WidgetRef ref, _) {
      final theme = ref.read(themeProvider);
      final ledgerdata = ref.watch(ledgerProvider);
      // final myController = TextEditingController(text: ledgerdata.selectnetpledge.text);
      // String selectedValue = ledgerdata.segmentvalue;
      String? selectedValue;
      print(
          "$selectedValue selectedValueselectedValueselectedValueselectedValue");
      //     if (ledgerdata.pledgeandunpledge!.data!.isNotEmpty) {
      //       for (var i = 0; i < ledgerdata.pledgeandunpledge!.data!.length; i++) {
      //         final val = ledgerdata.pledgeandunpledge!.data![i];
      //       if (val.nSESYMBOL == ) {}}
      //     }

      int netValue = ledgerdata.screenpledge == 'pledge'
          ? (widget.data.nET is String)
              ? double.parse(widget.data.nET!).toInt()
              : (widget.data.cOLQTY as double).toInt()
          : (widget.data.cOLQTY is String)
              ? double.parse(widget.data.cOLQTY!).toInt()
              : (widget.data.cOLQTY as double).toInt();
      List<DropdownItem> dropdownItems = [];

      final segmentMap = {
        'Futures And Options': ['NSE_FNO', 'BSE_FNO'],
        'Commodities': ['MCX'],
        'Currencies': ['CD_NSE', 'CD_BSE'],
      };

      final eligibleSegments = widget.data.eligibleSegments!;
      final companyCodes = ledgerdata.segresponse['company_code'];

      for (final segment in eligibleSegments) {
        final matchingCodes = segmentMap[segment];

        if (matchingCodes != null) {
          final hasMatchingCode =
              companyCodes.any((code) => matchingCodes.contains(code));

          if (ledgerdata.segresponse['mtf_status'] == true) {
            if (ledgerdata.segmentvaluedummy == 'Margin Trading Facility') {
              if (hasMatchingCode) {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: false,
                  ),
                );
                print("Added: $segment");
              } else {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: false,
                  ),
                );
                print("No matching company code for $segment");
              }
              dropdownItems.add(
                DropdownItem(
                  value: "Margin Trading Facility",
                  label: "Margin Trading Facility",
                  isEnabled: true,
                ),
              );
            } else if (ledgerdata.segmentvaluedummy == '') {
              if (hasMatchingCode) {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("Added: $segment");
              } else {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("No matching company code for $segment");
              }
              dropdownItems.add(
                DropdownItem(
                  value: "Margin Trading Facility",
                  label: "Margin Trading Facility",
                  isEnabled: true,
                ),
              );
            } else {
              if (hasMatchingCode) {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("Added: $segment");
              } else {
                dropdownItems.add(
                  DropdownItem(
                    value: segment,
                    label: segment,
                    isEnabled: true,
                  ),
                );
                print("No matching company code for $segment");
              }
              dropdownItems.add(
                DropdownItem(
                  value: "Margin Trading Facility",
                  label: "Margin Trading Facility",
                  isEnabled: false,
                ),
              );
            }
          } else {
            if (hasMatchingCode) {
              dropdownItems.add(
                DropdownItem(
                  value: segment,
                  label: segment,
                  isEnabled: true,
                ),
              );
              print("Added: $segment");
            } else {
              dropdownItems.add(
                DropdownItem(
                  value: segment,
                  label: segment,
                  isEnabled: false,
                ),
              );
              print("No matching company code for $segment");
            }
            dropdownItems.add(
              DropdownItem(
                value: "Margin Trading Facility",
                label: "Margin Trading Facility",
                isEnabled: false,
              ),
            );
          }
        } else {
          print("Segment $segment is not in segmentMap");
        }
      }

// Optional: remove duplicates if needed (based on value)
      final seen = <String>{};
      dropdownItems =
          dropdownItems.where((item) => seen.add(item.value)).toList();

      print("${dropdownItems} printprintprintpritn");

      return WillPopScope(
        onWillPop: () async {
          if (ledgerdata.listforpledge == []) {
            ledgerdata.changesegvaldummy('');
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
                child: TextWidget.titleText(
                    text: ledgerdata.screenpledge == 'pledge'
                        ? "Pledge Details"
                        : "Unpledge Details",
                    textOverflow: TextOverflow.ellipsis,
                    theme: theme.isDarkMode,
                    color: theme.isDarkMode
                        ? colors.textPrimaryDark
                        : colors.textPrimaryLight,
                    fw: 1),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 2.0,
                  bottom: 0.0,
                ),
                child: Divider(
                  color: theme.isDarkMode
                      ? const Color(0xffB5C0CF).withOpacity(.15)
                      : const Color(0xffF1F3F8),
                  thickness: 6.0,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TextWidget.paraText(
                                text: 'Symbol : ',
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 3),
                            TextWidget.paraText(
                                text: widget.data.nSESYMBOL.toString(),
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 3),
                          ],
                        ),
                        Row(
                          children: [
                            TextWidget.paraText(
                                text: 'Total Qty : ',
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 3),
                            TextWidget.paraText(
                                text: netValue.toString(),
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                fw: 3),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              TextWidget.paraText(
                                  text: 'Mar / Est : ',
                                  color: theme.isDarkMode
                                      ? colors.textSecondaryDark
                                      : colors.textSecondaryLight,
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 3),
                              TextWidget.paraText(
                                  text:
                                      "${double.tryParse(widget.data.estimated.toString())!.toStringAsFixed(2)} (${widget.data.estPercentage}%)",
                                  textOverflow: TextOverflow.ellipsis,
                                  theme: theme.isDarkMode,
                                  fw: 3),
                            ],
                          ),
                          if ((double.tryParse(widget.data.cOLQTY.toString())!
                                      .toInt() >
                                  0) &&
                              ledgerdata.screenpledge == 'pledge')
                            Row(
                              children: [
                                TextWidget.subText(
                                    text: 'Pledged Qty : ',
                                    color: Color(0xFF696969),
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 0),
                                TextWidget.subText(
                                    text:
                                        "${double.tryParse(widget.data.cOLQTY.toString())!.toInt()} ",
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 1),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget.subText(
                        text:
                            "${ledgerdata.screenpledge == 'pledge' ? 'Pledge' : 'Unpledge'} Qty up to ${netValue.toString()}",
                        textOverflow: TextOverflow.ellipsis,
                        theme: theme.isDarkMode,
                        fw: 3),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                          height: 44,
                          child: CustomTextFormField(
                              textAlign: TextAlign.start,
                              fillColor: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              inputFormate: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                                LengthLimitingTextInputFormatter(
                                    15), // Limit to 15 characters
                              ],
                              hintStyle: textStyle(
                                  const Color(0xff666666), 15, FontWeight.w400),
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w400),
                              textCtrl: ledgerdata.selectnetpledge,
                              onChanged: (value) {
                                netValue = 0;
                                ledgerdata.screenpledge == 'pledge'
                                    ? ledgerdata.setselectnetpledge(value,
                                        "${(double.parse(widget.data.nSOHQTY.toString()).toInt()) + (double.parse(widget.data.sOHQTY.toString()).toInt())}")
                                    : ledgerdata.setselectnetpledge(value,
                                        "${(double.parse(widget.data.cOLQTY.toString()).toInt()) + (double.parse(widget.data.sOHQTY.toString()).toInt())}");
                              })),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextWidget.captionText(
                          text: ledgerdata.pledgeerrormsg,
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
                          color: Colors.red,
                          fw: 0),
                    ),
                    ledgerdata.screenpledge == 'pledge'
                        ? Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xffFCEFD4)),
                            child: TextWidget.captionText(
                                text:
                                    "Note: Please ensure that you submit separate pledge requests for MTF and other segments (FO, CD, and Commodities). Combining pledges for MTF and other segments is not permitted. However, combining pledges for FO, CD, and Commodities segments is allowed.",
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textSecondaryDark
                                    : colors.textSecondaryLight,
                                maxLines: 7,
                                fw: 3),
                          )
                        : SizedBox(),
                    ledgerdata.screenpledge == 'pledge'
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextWidget.subText(
                                text:
                                    "Which segment do you want to pledge the stocks",
                                textOverflow: TextOverflow.ellipsis,
                                theme: theme.isDarkMode,
                                color: theme.isDarkMode
                                    ? colors.textPrimaryDark
                                    : colors.textPrimaryLight,
                                fw: 3),
                          )
                        : SizedBox(),
                    ledgerdata.screenpledge == 'pledge'
                        ? Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 16.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                menuItemStyleData: MenuItemStyleData(
                                  customHeights:
                                      List.filled(dropdownItems.length, 40),
                                ),
                                buttonStyleData: ButtonStyleData(
                                  
                                  height: 44,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: colors.colorBlue),
                                    color: const Color(0xffF1F3F8),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(5)),
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  offset: const Offset(0, 8),
                                ),
                                isExpanded: true,
                                style: textStyle(const Color(0xFF000000), 13,
                                    FontWeight.w400),
                                hint: Text(
                                  "Select Segment",
                                  style: textStyle(const Color(0xFF000000), 13,
                                      FontWeight.w400),
                                ),
                                items: dropdownItems.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.value,
                                    enabled: item.isEnabled,
                                    child: Text(
                                      item.label,
                                      style: item.isEnabled
                                          ? null
                                          : textStyle(
                                              Colors.grey,
                                              13,
                                              FontWeight
                                                  .w400), // style for disabled
                                    ),
                                  );
                                }).toList(),
                                value: widget.data.segmentselect != "null"
                                    ? widget.data.segmentselect
                                    : selectedValue,
                                onChanged: (value) {
                                  ledgerdata.changesegval(
                                      value.toString(), widget.data);
                                  if (ledgerdata.listforpledge.isEmpty) {
                                    ledgerdata.changesegvaldummy("");
                                  } else {
                                    ledgerdata
                                        .changesegvaldummy(value.toString());
                                  }
                                },
                              ),
                            ),
                          )
                        : SizedBox(),
                    ledgerdata.dayforpledgeunpledge == 'Saturday' ||
                            ledgerdata.dayforpledgeunpledge == 'Sunday'
                        ? Container(
                            margin:
                                const EdgeInsets.only(bottom: 16.0, top: 8.0),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: const Color(0xffFCEFD4)),
                            child: Text(
                                "Note: Pledge requests process on exchange working days, submissions on weekends or exchange holidays are handled the next working day.",
                                style: textStyle(
                                    colors.colorBlack, 11, FontWeight.w500)),
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                          height: 40,
                          width: screenWidth,
                          margin: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  backgroundColor: ((ledgerdata.screenpledge ==
                                                  'unpledge' &&
                                              (ledgerdata.pledgesubtn ==
                                                  false)) ||
                                          (ledgerdata.screenpledge == 'pledge' &&
                                              (ledgerdata.pledgesubtn == false ||
                                                  widget.data.segmentselect
                                                          .toString() ==
                                                      "null")))
                                      ? colors.colorbluegrey
                                      : theme.isDarkMode
                                          ? colors.primaryDark
                                          : colors.primaryLight,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              onPressed: () {
                                if ((ledgerdata.screenpledge == 'pledge' &&
                                        (widget.data.segmentselect != 'null' &&
                                            ledgerdata.pledgesubtn != false)) ||
                                    (ledgerdata.screenpledge == 'unpledge' &&
                                        (ledgerdata.pledgesubtn != false))) {
                                  if (ledgerdata.screenpledge == 'pledge') {
                                    ledgerdata.dummypledgeval(
                                        widget.data,
                                        ledgerdata.selectnetpledge.text,
                                        "pledge");
                                    ledgerdata.changesegval(
                                        widget.data.segmentselect.toString(),
                                        widget.data);
                                    ledgerdata.listforpledgefunction(
                                        context,
                                        ledgerdata.segmentvalue,
                                        widget.data.nSESYMBOL.toString(),
                                        widget.data.iSIN.toString(),
                                        widget.data.aMOUNT.toString(),
                                        ledgerdata.selectnetpledge.text,
                                        widget.data.nET.toString(),
                                        "pledge",
                                        widget.data);
                                    ledgerdata.changesegvaldummy(
                                        widget.data.segmentselect.toString());
                                  } else {
                                    ledgerdata.dummypledgeval(
                                        widget.data,
                                        ledgerdata.selectnetpledge.text,
                                        "unpledge");
                                    ledgerdata.listforpledgefunction(
                                        context,
                                        ledgerdata.segmentvalue,
                                        widget.data.nSESYMBOL.toString(),
                                        widget.data.iSIN.toString(),
                                        widget.data.aMOUNT.toString(),
                                        ledgerdata.selectnetpledge.text,
                                        widget.data.nET.toString(),
                                        "unpledge",
                                        widget.data);
                                  }
                                  // ledgerdata.changesegval("");
                                  Navigator.pop(context);
                                }
                              },
                              child: Text("Submit",
                                  textAlign: TextAlign.center,
                                  style: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      12,
                                      FontWeight.w500)))),
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
