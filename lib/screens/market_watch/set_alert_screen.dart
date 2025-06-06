import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/list_divider.dart';

class SetAlert extends StatefulWidget {
  final GetQuotes depthdata;
  final DepthInputArgs wlvalue;
  const SetAlert({super.key, required this.depthdata, required this.wlvalue});

  @override
  State<SetAlert> createState() => _SetAlertState();
}

class _SetAlertState extends State<SetAlert> {
  bool _handlesetalert = false;
  TextEditingController valueCtrl = TextEditingController();
  TextEditingController remark = TextEditingController();
  final List<String> alterItems = ['Above', 'Below'];
  final List<String> alertType = ["LTP", "Perc.Change"];
  String alertValue = "";
  String alertTypeVal = "";
  String validityTypeVal = "";
  String errorText = "";
  @override
  void initState() {
    alertValue = alterItems[0];
    alertTypeVal = alertType[0];
    super.initState();
  }

validatesetalret(value){
   try {
                      if (alertTypeVal == "LTP" && value.isNotEmpty) {
                        double enteredValue = double.parse(value);
                        double currentLtp = double.parse(widget.depthdata.lp ?? "0.0");
                        
                        // Format numbers to always show 2 decimal places
                        String formattedLtp = currentLtp.toStringAsFixed(2);
                        String formattedEnteredValue = enteredValue.toStringAsFixed(2);
                        
                        if (alertValue == "Above" && enteredValue <= currentLtp) {
                          errorText = "The Current LTP (₹$formattedLtp) is already above ₹$formattedEnteredValue";
                        } else if (alertValue == "Below" && enteredValue >= currentLtp) {
                          errorText = "The Current LTP (₹$formattedLtp) is already below ₹$formattedEnteredValue";
                        } else {
                          errorText = "";
                        }
                      } else {
                        errorText = "";
                      }
                    } catch (e) {
                      errorText = "Please enter a valid number";
                    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, WidgetRef ref, _) {
      final scripInfo = ref.watch(marketWatchProvider);

      final theme = ref.read(themeProvider);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Type',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 44,
              width: MediaQuery.of(context).size.width,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: !theme.isDarkMode
                              ? colors.colorWhite
                              : const Color.fromARGB(255, 16, 16, 16))),
                  buttonStyleData: ButtonStyleData(
                      height: 40,
                      width: 124,
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          // border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(32)))),

                  isExpanded: true,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500),
                  hint: Text(
                    alertTypeVal,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  items: alertType
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                item,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ))
                      .toList(),
                  value: alertTypeVal,
                  onChanged: (value) {
                    setState(() {
                      alertTypeVal = value!;
                      valueCtrl.clear();
                    });
                    validatesetalret(value);
                  },
                  // buttonDecoration: const BoxDecoration(
                  //     color: Color(0xffF1F3F8),
                  //     borderRadius: BorderRadius.all(Radius.circular(32))),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const ListDivider(),
            const SizedBox(
              height: 16,
            ),
            Text('Alert me',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 44,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: !theme.isDarkMode
                              ? colors.colorWhite
                              : const Color.fromARGB(255, 16, 16, 16))),
                  buttonStyleData: ButtonStyleData(
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          // border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(32)))),

                  isExpanded: true,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      14,
                      FontWeight.w500),

                  hint: Text(
                    alertValue,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  items: alterItems
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: alertValue,
                  onChanged: (value) {
                    setState(() {
                      alertValue = value!;
                    });
                    validatesetalret(value);
                  },
                  // buttonDecoration: const BoxDecoration(
                  //     color: Color(0xffF1F3F8),
                  //     borderRadius: BorderRadius.all(Radius.circular(32))),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const ListDivider(),
            const SizedBox(
              height: 16,
            ),
            Text('Enter Value',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 44,
              child: TextFormField(
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    15,
                    FontWeight.w500),
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    fillColor: theme.isDarkMode
                        ? const Color(0xffB5C0CF).withOpacity(.15)
                        : const Color(0xffF1F3F8),
                    filled: true,
                    hintText: "0",
                    hintStyle:
                        textStyle(const Color(0xff666666), 16, FontWeight.w600),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    labelStyle: textStyles.textFieldLabelStyle,
                    prefixIconColor: const Color(0xff586279),
                    prefixIcon: alertTypeVal == "Perc.Change"
                        ? const Icon(
                            Icons.percent_outlined,
                            size: 16,
                          )
                        : SvgPicture.asset(assets.ruppeIcon,
                            fit: BoxFit.scaleDown),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30)),
                    disabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(30))),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      errorText = "* Value is required";
                      return;
                    }
                    
                    // Try to parse the entered value
                    validatesetalret(value);
                   
                  });
                },
              ),
            ),
            if (errorText.isNotEmpty) ...[
              Text(errorText,
                  style: textStyle(colors.darkred, 10, FontWeight.w500)),
            ],
            const SizedBox(
              height: 16,
            ),
            const ListDivider(),
            const SizedBox(
              height: 16,
            ),
            Text('Remark',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 70,
              child: TextFormField(
                  textAlign: TextAlign.start,
                  maxLines: null,
                  expands: true,
                  controller: remark,
                  style: textStyle(
                      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                      15,
                      FontWeight.w500),
                  decoration: InputDecoration(
                      fillColor: theme.isDarkMode
                          ? const Color(0xffB5C0CF).withOpacity(.15)
                          : const Color(0xffF1F3F8),
                      filled: true,
                      hintText: "Remark",
                      hintStyle: textStyle(
                          const Color(0xff666666), 16, FontWeight.w600),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      labelStyle: textStyles.textFieldLabelStyle,
                      prefixIconColor: const Color(0xff586279),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15)),
                      disabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(15)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30)))),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 45,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    // ignore: deprecated_member_use
                    backgroundColor: errorText.isNotEmpty || valueCtrl.text.isEmpty
                        ? Colors.grey // Disabled color
                        : (theme.isDarkMode
                        ? colors.colorWhite
                            : colors.colorBlack),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: (errorText.isNotEmpty || valueCtrl.text.isEmpty)
                      ? null // Disable the button when there's an error or empty value
                      : () {
                    setState(() {
                            if (valueCtrl.text == "0") {
                              errorText = "Value cannot be 0";
                      } else {
                        errorText = "";
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                                  return StatefulBuilder(builder: (BuildContext
                                                            context,
                                                        StateSetter
                                                            setDialogState) {
                            return AlertDialog(
                              backgroundColor: theme.isDarkMode
                                  ? const Color.fromARGB(255, 18, 18, 18)
                                  : colors.colorWhite,
                              titleTextStyle: textStyles.appBarTitleTxt
                                  .copyWith(
                                      color: theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack),
                              contentTextStyle: textStyles.menuTxt.copyWith(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack),
                              titlePadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(14))),
                              scrollable: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              insetPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              // ignore: prefer_const_constructors
                              title: Text(
                                "Confirmation Alert",
                              ),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Alert me when $alertTypeVal of ${widget.wlvalue.tsym} is $alertValue ${valueCtrl.text}")
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel",
                                        style: textStyles.textBtn.copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorLightBlue
                                                : colors.colorBlue))),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        backgroundColor: theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        )),
                                            onPressed: _handlesetalert ? null : () async {
                                              setDialogState(
                                                                          () {
                                                                        _handlesetalert =
                                                                            true;
                                                                      });
                                      await ref
                                          .read(marketWatchProvider)
                                          .fetchSetAlert(
                                              widget.wlvalue.exch,
                                              widget.wlvalue.tsym,
                                              valueCtrl.text,
                                              alertValue == "Above" &&
                                                      alertTypeVal == "LTP"
                                                  ? "LTP_A"
                                                  : alertValue == "Below" &&
                                                          alertTypeVal == "LTP"
                                                      ? "LTP_B"
                                                      : alertValue == "Above" &&
                                                              alertTypeVal ==
                                                                  "Perc.Change"
                                                          ? "CH_PER_A"
                                                          : "CH_PER_B",
                                              context,
                                              scripInfo
                                                  .alertPendingModel!.length,
                                              "${widget.depthdata.lp}",
                                              remark.text);
                                    if (mounted) {
                                                                        setDialogState(
                                                                            () {
                                                                          _handlesetalert =
                                                                              false;
                                                                        });
                                                                      }
                                    
                                    },
                                    child: Text("Ok",
                                        style: textStyles.btnText.copyWith(
                                            color: !theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)))
                              ],
                            );
                                                            }
                                  );
                          },
                        );
                      }
                    });
                  },
                  child: Text(
                    'Set my alert',
                    style: GoogleFonts.inter(
                        letterSpacing: 0.28,
                        fontSize: 14,
                        color: !theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        fontWeight: FontWeight.w600),
                  )),
            )
          ],
        ),
      );
    });
  }

  
}
