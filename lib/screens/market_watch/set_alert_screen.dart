import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/marketwatch_model/get_quotes.dart';
import '../../provider/market_watch_provider.dart';
import '../../provider/thems.dart';
import '../../res/global_state_text.dart';
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
  final List<String> alertType = ["LTP"];
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

  validatesetalret(value) {
    try {
      if (value == null || value.isEmpty) {
        errorText = "* Value is required";
        return;
      }

      if (alertTypeVal == "LTP" && value.isNotEmpty) {
        double enteredValue = double.parse(value);
        double currentLtp = double.parse(widget.depthdata.lp ?? "0.0");

        // Format numbers to always show 2 decimal places
        String formattedLtp = currentLtp.toStringAsFixed(2);
        String formattedEnteredValue = enteredValue.toStringAsFixed(2);

        if (alertValue == "Above" && enteredValue <= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already above ₹$formattedEnteredValue";
        } else if (alertValue == "Below" && enteredValue >= currentLtp) {
          errorText =
              "The Current LTP (₹$formattedLtp) is already below ₹$formattedEnteredValue";
        } else {
          errorText = "";
        }
      }
      //  else if (alertTypeVal == "Perc.Change") {
      //   errorText = "";
      // }
       else {
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
      
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
            const SizedBox(height: 16),            
                    TextWidget.subText(
                      text: 'Type',                    
                      theme: theme.isDarkMode,
                      fw: 0),
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
                      height: 44,
                      padding: const EdgeInsets.only(left: 0, right: 16,),
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(32)))),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 20,
                  ),
                  isExpanded: true,
                  style:
                       TextWidget.textStyle(
                 fontSize: 14 ,  theme: theme.isDarkMode , fw: 0 ),	
                  hint: 
                  TextWidget.subText(
                      text: alertTypeVal,
                     textOverflow: TextOverflow.ellipsis,
                      theme: theme.isDarkMode,
                      fw: 0),
                  items: alertType
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                               padding: const EdgeInsets.only(left: 8,),
                              child: 

                              TextWidget.subText(
                      text: item,
                      textOverflow: TextOverflow.ellipsis,                      
                      theme: theme.isDarkMode,
                      fw: 0),
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
                     TextWidget.subText(
                      text: 'Alert me',          
                      theme: theme.isDarkMode,
                      fw: 0),
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
                      height: 44,
                      padding: const EdgeInsets.only(left: 0, right: 16,),
                      decoration: BoxDecoration(
                          color: theme.isDarkMode
                              ? const Color(0xffB5C0CF).withOpacity(.15)
                              : const Color(0xffF1F3F8),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(32)))),
                  iconStyleData: const IconStyleData(
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 20,
                  ),
                  isExpanded: true,
                  style:
                       TextWidget.textStyle(
                 fontSize: 14 ,  theme: theme.isDarkMode , fw: 0 ),		

                  hint: 
                  TextWidget.subText(
                      text:alertValue ,
                      textOverflow: TextOverflow.ellipsis,                     
                      theme: theme.isDarkMode,
                      fw: 0),
                  items: alterItems
                      .map((String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Padding(
                            padding: const EdgeInsets.only(left: 8,),
                              child: 
                            TextWidget.subText(
                      text: item,
                      textOverflow: TextOverflow.ellipsis,                  
                      theme: theme.isDarkMode,
                      fw: 0),
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
                    TextWidget.subText(
                      text: 'Enter Value',                      
                      theme: theme.isDarkMode,
                      fw: 0),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 44,
              child: TextFormField(
                style: 
                     TextWidget.textStyle(
                 fontSize: 14 ,  theme: theme.isDarkMode , fw: 0 ),	
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    fillColor: theme.isDarkMode
                        ? const Color(0xffB5C0CF).withOpacity(.15)
                        : const Color(0xffF1F3F8),
                    filled: true,
                    hintText: "0",
                    hintStyle:                  
                        TextWidget.textStyle(
                 fontSize: 16 , color: const Color(0xff666666), theme: theme.isDarkMode , fw: 1 ),	
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    labelStyle: TextWidget.textStyle(
                 fontSize: 14 , theme: theme.isDarkMode , fw: 1 )	,
                    prefixIconColor: const Color(0xff586279),
                    prefixIcon: /*alertTypeVal == "Perc.Change"
                        ? const Icon(
                            Icons.percent_outlined,
                            size: 16,
                          )
                        : */SvgPicture.asset(assets.ruppeIcon,
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
                  // Don't block the input operation, apply validation after the text change
                  Future.microtask(() {
                    if (mounted) {
                      setState(() {
                        // Handle validation
                        validatesetalret(value);
                      });
                    }
                  });
                },
              ),
            ),
            if (errorText.isNotEmpty) ...[
                      TextWidget.captionText(
                      text:errorText ,
                      color:colors.darkred ,
                      theme: theme.isDarkMode,
                      fw: 0),
            ],
            const SizedBox(
              height: 16,
            ),
            const ListDivider(),
            const SizedBox(
              height: 16,
            ),
                     TextWidget.subText(
                      text:'Remark' ,
                     
                      theme: theme.isDarkMode,
                      fw: 0),
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
                  style: 
                       TextWidget.textStyle(
                 fontSize: 14 ,  theme: theme.isDarkMode , fw: 0 ),	
                  decoration: InputDecoration(
                      fillColor: theme.isDarkMode
                          ? const Color(0xffB5C0CF).withOpacity(.15)
                          : const Color(0xffF1F3F8),
                      filled: true,
                      hintText: "Remark",
                      hintStyle: 
                           TextWidget.textStyle(
                 fontSize: 16 , color: const Color(0xff666666), theme: theme.isDarkMode , fw: 1 ),	
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      labelStyle:  TextWidget.textStyle(
                 fontSize: 14 ,  theme: theme.isDarkMode , fw: 1 ),	
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
                    backgroundColor:
                        errorText.isNotEmpty || valueCtrl.text.isEmpty
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
                                  return StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setDialogState) {
                                    return AlertDialog(
                                      backgroundColor: theme.isDarkMode
                                          ? const Color.fromARGB(
                                              255, 18, 18, 18)
                                          : colors.colorWhite,
                                      titleTextStyle:
                                                   TextWidget.textStyle(
                 fontSize: 14 ,  theme: theme.isDarkMode , fw: 1 ),	

                                                  
                                      contentTextStyle:
                                                   TextWidget.textStyle(
                 fontSize: 12 , theme: theme.isDarkMode , fw: 0 ),	
                                      titlePadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(14))),
                                      scrollable: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      insetPadding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      // ignore: prefer_const_constructors
                                      title:
                                      TextWidget.titleText(
                      text:"Confirmation Alert" ,                  
                      theme: theme.isDarkMode,
                      fw: 0),

                                      
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                           
                                                TextWidget.subText(
                      text: "Alert me when $alertTypeVal of ${widget.wlvalue.tsym} is $alertValue ${valueCtrl.text}",
                     
                      theme: theme.isDarkMode,
                      fw: 0),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: 
                                                                
                                                                TextWidget.paraText(
                      text: "Cancel",
                      color: theme.isDarkMode
                                                            ? colors
                                                                .colorLightBlue
                                                            : colors
                                                                .colorBlue,
                      theme: theme.isDarkMode,
                      fw: 0),
                                                                
                                                                ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                backgroundColor:
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                )),
                                            onPressed: _handlesetalert
                                                ? null
                                                : () async {
                                                    setDialogState(() {
                                                      _handlesetalert = true;
                                                    });
                                                    try {
                                                      await ref
                                                          .read(
                                                              marketWatchProvider)
                                                          .fetchSetAlert(
                                                              widget
                                                                  .wlvalue.exch,
                                                              widget
                                                                  .wlvalue.tsym,
                                                              valueCtrl.text,
                                                              alertValue ==
                                                                          "Above" &&
                                                                      alertTypeVal ==
                                                                          "LTP"
                                                                  ? "LTP_A"
                                                                  : alertValue ==
                                                                              "Below" &&
                                                                          alertTypeVal ==
                                                                              "LTP"
                                                                      ? "LTP_B"
                                                                      /*: alertValue == "Above" &&
                                                                              alertTypeVal ==
                                                                                  "Perc.Change"
                                                                          ? "CH_PER_A"
                                                                          : "CH_PER_B"*/
                                                                      : "LTP_B",
                                                              context,
                                                              scripInfo
                                                                  .alertPendingModel!
                                                                  .length,
                                                              "${widget.depthdata.lp}",
                                                              remark.text);
                                                    } finally {
                                                      if (mounted) {
                                                        setDialogState(() {
                                                          _handlesetalert =
                                                              false;
                                                        });
                                                      }
                                                    }
                                                  },
                                            child: _handlesetalert || scripInfo.loading ? const SizedBox(
                              width: 18,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xff666666)),
                            ) :  

                                                                TextWidget.paraText(
                      text: "Ok",
                      color: !theme.isDarkMode
                                                            ? colors.colorWhite
                                                            : colors
                                                                .colorBlack,
                      theme: theme.isDarkMode,
                      fw: 0),
                                                                
                                                                
                                                                )
                                      ],
                                    );
                                  });
                                },
                              );
                            }
                          });
                        },
                  child:                   
                  TextWidget.subText(
                      text: 'Set my alert',
                      letterSpacing:0.28 ,
                      color:!theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack ,
                      theme: theme.isDarkMode,
                      fw: 1),
                  
                  ),
                        )
          ],
        ),
      ),
    );
    }
    );
  }
}
