import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mynt_plus/provider/ledger_provider.dart';
import 'package:mynt_plus/sharedWidget/functions.dart'; 
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/cust_text_formfield.dart';

class PledgeDeytails extends StatefulWidget {
  final int data;
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
    final theme = context.read(themeProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    double notional = 0.0;
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ledgerdata = watch(ledgerProvider);
    // String selectedValue = ledgerdata.segmentvalue;
    String? selectedValue;
    print("$selectedValue selectedValueselectedValueselectedValueselectedValue");

      int netValue = ledgerdata.screenpledge == 'pledge'
          ? (ledgerdata.pledgeandunpledge!.data![widget.data].nET is String)
              ? double.parse(
                      ledgerdata.pledgeandunpledge!.data![widget.data].nET!)
                  .toInt()
              : (ledgerdata.pledgeandunpledge!.data![widget.data].cOLQTY
                      as double)
                  .toInt()
          : (ledgerdata.pledgeandunpledge!.data![widget.data].cOLQTY is String)
              ? double.parse(
                      ledgerdata.pledgeandunpledge!.data![widget.data].cOLQTY!)
                  .toInt()
              : (ledgerdata.pledgeandunpledge!.data![widget.data].cOLQTY
                      as double)
                  .toInt();
      List<DropdownItem> dropdownItems = [];

      final segmentMap = {
        'Futures And Options': ['NSE_FNO', 'BSE_FNO'],
        'Commodities': ['MCX'],
        'Currencies': ['CD_NSE', 'CD_BSE'],
      };

      final eligibleSegments =
          ledgerdata.pledgeandunpledge!.data![widget.data].eligibleSegments!;
      final companyCodes = ledgerdata.segresponse['company_code'];

      for (final segment in eligibleSegments) {
        final matchingCodes = segmentMap[segment];

        if (matchingCodes != null) {
          final hasMatchingCode =
              companyCodes.any((code) => matchingCodes.contains(code));

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
        } else {
          print("Segment $segment is not in segmentMap");
        }
      }
      dropdownItems.add(
        DropdownItem(
          value: "Margin Trading Facility",
          label: "Margin Trading Facility",
          isEnabled:
              ledgerdata.segresponse['mtf_status'] == false ? false : true,
        ),
      );
// Optional: remove duplicates if needed (based on value)
      final seen = <String>{};
      dropdownItems =
          dropdownItems.where((item) => seen.add(item.value)).toList();

      print("${dropdownItems} printprintprintpritn");

      return DraggableScrollableSheet(
        initialChildSize: ledgerdata.screenpledge == 'pledge' ?  ledgerdata.dayforpledgeunpledge == 'Saturday' || ledgerdata.dayforpledgeunpledge == 'Sunday' ? 0.70 : 0.62 : ledgerdata.screenpledge == 'unpledge' ?  ledgerdata.dayforpledgeunpledge == 'Saturday' || ledgerdata.dayforpledgeunpledge == 'Sunday' ? 0.50 : 0.4 : 0,
        minChildSize: .4,
        maxChildSize: .99,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: theme.isDarkMode
                      ? Color.fromARGB(255, 0, 0, 0)
                      : Color.fromARGB(255, 255, 255, 255)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16.0, bottom: 8.0),
                      child: TextWidget.heroText(
                          text: "Pledge Details",
                          textOverflow: TextOverflow.ellipsis,
                          theme: theme.isDarkMode,
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
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  TextWidget.titleText(
                                      text: 'Symbol : ',
                                      color: Color(0xFF696969),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  TextWidget.titleText(
                                      text: ledgerdata.pledgeandunpledge!
                                          .data![widget.data].nSESYMBOL
                                          .toString(),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                ],
                              ),
                              Row(
                                children: [
                                  TextWidget.titleText(
                                      text: 'Total Qty : ',
                                      color: Color(0xFF696969),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                  TextWidget.titleText(
                                      text: netValue.toString(),
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 1),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              children: [
                                TextWidget.titleText(
                                    text: 'Mar / Est : ',
                                    color: Color(0xFF696969),
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 0),
                                TextWidget.titleText(
                                    text:
                                        "${ledgerdata.pledgeandunpledge!.data![widget.data].estimated} (${ledgerdata.pledgeandunpledge!.data![widget.data].estPercentage}%)",
                                    textOverflow: TextOverflow.ellipsis,
                                    theme: theme.isDarkMode,
                                    fw: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget.paraText(
                              text:
                                  "${ledgerdata.screenpledge == 'pledge' ? 'Pledge' : 'Unpledge'} Qty up to ${netValue.toString()}",
                              textOverflow: TextOverflow.ellipsis,
                              theme: theme.isDarkMode,
                              fw: 0),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                height: 44,
                                child: CustomTextFormField(
                                    textAlign: TextAlign.start,
                                    fillColor: theme.isDarkMode
                                        ? colors.darkGrey
                                        : const Color(0xffF1F3F8),
                                    hintText: '0',
                                    keyboardType: TextInputType.number,
                                    hintStyle: textStyle(
                                        const Color(0xff666666),
                                        15,
                                        FontWeight.w400),
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        16,
                                        FontWeight.w600),
                                    textCtrl: TextEditingController(
                                        text: ((ledgerdata.selectnetpledge))
                                            .toString()),
                                    onChanged: (value) {
                                      netValue = 0;
                                      ledgerdata.screenpledge == 'pledge'
                                          ? ledgerdata.setselectnetpledge(value,
                                              "${(double.parse(ledgerdata.pledgeandunpledge!.data![widget.data].nET.toString()).toInt())}")
                                          : ledgerdata.setselectnetpledge(value,
                                              "${(double.parse(ledgerdata.pledgeandunpledge!.data![widget.data].cOLQTY.toString()).toInt())}");
                                      print("${value} lololololol");
                                    })),
                          ),
                          ledgerdata.screenpledge == 'pledge'
                              ? Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: const Color(0xffFCEFD4)),
                                  child: Text(
                                      "Note: Please ensure that you submit separate pledge requests for MTF and other segments (FO, CD, and Commodities). Combining pledges for MTF and other segments is not permitted. However, combining pledges for FO, CD, and Commodities segments is allowed.",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          11,
                                          FontWeight.w500)),
                                )
                              : SizedBox(),
                          ledgerdata.screenpledge == 'pledge'
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextWidget.paraText(
                                      text:
                                          "Which segment do you want to pledge the stocks",
                                      textOverflow: TextOverflow.ellipsis,
                                      theme: theme.isDarkMode,
                                      fw: 0),
                                )
                              : SizedBox(),
                          ledgerdata.screenpledge == 'pledge'
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      menuItemStyleData: MenuItemStyleData(
                                        customHeights: List.filled(
                                            dropdownItems.length, 40),
                                      ),
                                      buttonStyleData: ButtonStyleData(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffF1F3F8),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(32)),
                                        ),
                                      ),
                                      dropdownStyleData: DropdownStyleData(
                                        maxHeight: 250,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        offset: const Offset(0, 8),
                                      ),
                                      isExpanded: true,
                                      style: textStyle(const Color(0xFF000000),
                                          13, FontWeight.w500),
                                      hint: Text(
                                        "Select Segment",
                                        style: textStyle(
                                            const Color(0xFF000000),
                                            13,
                                            FontWeight.w500),
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
                                      value: ledgerdata.segmentvalue != '' ? ledgerdata.segmentvalue : selectedValue,
                                      onChanged: (value) {
                                        ledgerdata
                                            .changesegval(value.toString());
                                      },
                                    ),
                                  ),
                                )
                              : SizedBox(),
                              ledgerdata.dayforpledgeunpledge == 'Saturday' || ledgerdata.dayforpledgeunpledge == 'Sunday'
                              ? Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: const Color(0xffFCEFD4)),
                                  child: Text(
                                      "Note: Pledge requests process on exchange working days, submissions on weekends or exchange holidays are handled the next working day.",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          11,
                                          FontWeight.w500)),
                                )
                              : SizedBox(),
                          Container(
                              height: 40,
                              width: screenWidth,
                              margin: const EdgeInsets.only(top: 24.0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      backgroundColor:
                                          ledgerdata.pledgesubtn == false
                                              ? colors.colorbluegrey
                                              : colors.colorBlack,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50))),
                                  onPressed: () {
                                    if (ledgerdata.screenpledge == 'pledge') {
                                      ledgerdata.dummypledgeval(
                                        widget.data,
                                        ledgerdata.selectnetpledge.toString(),"pledge"
                                      );
                                      ledgerdata.listforpledgefunction(
                                        context,
                                          ledgerdata.segmentvalue,
                                          ledgerdata.pledgeandunpledge!
                                              .data![widget.data].nSESYMBOL
                                              .toString(),
                                          ledgerdata.pledgeandunpledge!
                                              .data![widget.data].iSIN
                                              .toString(),
                                          ledgerdata.pledgeandunpledge!
                                              .data![widget.data].aMOUNT
                                              .toString(),
                                          ledgerdata.selectnetpledge
                                              .toString(),ledgerdata.pledgeandunpledge!
                                              .data![widget.data].nET
                                              .toString(),
                                              "pledge");
                                    } else {
                                      ledgerdata.dummypledgeval(
                                        widget.data,
                                        ledgerdata.selectnetpledge.toString(),"unpledge"
                                      );
                                      ledgerdata.listforpledgefunction(
                                        context,
                                          ledgerdata.segmentvalue,
                                          ledgerdata.pledgeandunpledge!
                                              .data![widget.data].nSESYMBOL
                                              .toString(),
                                          ledgerdata.pledgeandunpledge!
                                              .data![widget.data].iSIN
                                              .toString(),
                                          ledgerdata.pledgeandunpledge!
                                              .data![widget.data].aMOUNT
                                              .toString(),
                                          ledgerdata.selectnetpledge
                                              .toString(),
                                              ledgerdata.pledgeandunpledge!
                                              .data![widget.data].nET
                                              .toString(),
                                              "unpledge");
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text("Submit",
                                      textAlign: TextAlign.center,
                                      style: textStyle(
                                          !theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          12,
                                          FontWeight.w500)))),
                        ],
                      ),
                    ),
                  ]),
            ),
          );
        },
      );
    });
  }
}
