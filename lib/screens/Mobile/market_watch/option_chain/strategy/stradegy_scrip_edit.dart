import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../models/marketwatch_model/opt_chain_model.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_exch_badge.dart';
import '../../../../../sharedWidget/custom_switch_btn.dart';
import '../../../../../sharedWidget/functions.dart';
import '../../../../../sharedWidget/list_divider.dart';

class OptionStrategyEdit extends ConsumerStatefulWidget {
  final OptionValues scripData;
  const OptionStrategyEdit({super.key, required this.scripData});

  @override
  ConsumerState<OptionStrategyEdit> createState() => _OptionStrategyEditState();
}

class _OptionStrategyEditState extends ConsumerState<OptionStrategyEdit> {
  TextEditingController textCtrl = TextEditingController();
  String? errorText;

  bool? isBuy;
  @override
  void initState() {
    textCtrl.text = "${widget.scripData.ls}";

    isBuy = widget.scripData.transType == "B";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    return AlertDialog(
        backgroundColor: theme.isDarkMode
            ? const Color.fromARGB(255, 18, 18, 18)
            : colors.colorWhite,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
        scrollable: true,
        actionsPadding:
            const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        titlePadding: const EdgeInsets.only(left: 16),
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
         

                    TextWidget.titleText(
                      text: 'Modify Scrip',
                    
                      theme: theme.isDarkMode,
                      fw: 1),
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close_rounded),
            color:
                theme.isDarkMode ? const Color(0xffBDBDBD) : colors.colorGrey,
          )
        ]),
        content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const ListDivider(),
              const SizedBox(height: 14),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              

                    TextWidget.titleText(
                      text:"${widget.scripData.symbol!} " ,
                     textOverflow: TextOverflow.ellipsis,
                     maxLines: 1,
                      theme: theme.isDarkMode,
                      fw: 1),
                if (widget.scripData.option!.isNotEmpty)
                 


                        TextWidget.subText(
                      text: widget.scripData.option!,
                      color:Color(0xff666666) ,
                      textOverflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      theme: theme.isDarkMode,
                      fw: 1),
                if (widget.scripData.expDate!.isNotEmpty)
                  
                           TextWidget.subText(
                      text:" ${widget.scripData.expDate} ",
                   
                      theme: theme.isDarkMode,
                      fw: 1),
                CustomExchBadge(exch: "${widget.scripData.exch}"),
              ]),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                       

                                 TextWidget.titleText(
                      text:"₹${widget.scripData.lp} " ,
                  
                      theme: theme.isDarkMode,
                      fw: 1),
                        

                         TextWidget.paraText(
                      text:  " (${widget.scripData.perChange ?? 0.00}%)",
                      color: widget.scripData.perChange!.startsWith("-")
                                  ? colors.darkred
                                  : colors.ltpgreen ,
                      theme: theme.isDarkMode,
                      fw: 1),
                      ],
                    ),
                    Row(children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              isBuy = true;
                            });
                          },
                          child: SvgPicture.asset(assets.buyIcon)),
                      const SizedBox(width: 6),
                      CustomSwitch(
                          onChanged: (bool value) {
                            setState(() {
                              isBuy = value;
                            });
                          },
                          value: isBuy!),
                      const SizedBox(width: 6),
                      InkWell(
                          onTap: () {
                            setState(() {
                              isBuy = false;
                            });
                          },
                          child: SvgPicture.asset(assets.sellIcon))
                    ])
                  ]),
              const SizedBox(height: 8),
             

                       TextWidget.subText(
                      text:"Lot size" ,
                  
                      theme: theme.isDarkMode,
                      fw: 0),
              const SizedBox(height: 8),
              TextFormField(
                  controller: textCtrl,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                   style: TextWidget.textStyle(
                                    fontSize: 16,
                                    color: theme.isDarkMode
                                        ? colors.textPrimaryDark
                                        : colors.textPrimaryLight,
                                    theme: theme.isDarkMode,
                                    fw: 0,
                                  ),

                  decoration: InputDecoration(
                      fillColor: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffF1F3F8),
                      filled: true,
                      hintText: "Enter lot size",
                      hintStyle: TextWidget.textStyle(
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                     color: (theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight).withOpacity(0.4),
                                    fw: 0,
                                    ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      errorText: errorText,
                      errorStyle:
                        
                            TextWidget.textStyle(
                 fontSize: 10 , color: colors.darkred, theme: theme.isDarkMode , fw: 1 ),	
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50)),
                      disabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(50))),
                  onChanged: (value) {
                    setState(() {
                      if (textCtrl.text.trim().isNotEmpty) {
                        errorText = null;
                      } else {
                        errorText = "Please enter lotm size";
                      }
                    });
                  })
            ])),
        actions: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      widget.scripData.transType = isBuy! ? "B" : "S";

                      widget.scripData.ls = textCtrl.text;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: theme.isDarkMode
                        ? colors.colorbluegrey
                        : colors.colorBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: 
                              
                              
                               TextWidget.subText(
                      text: "Modify",
                      color:  !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                      theme: theme.isDarkMode,
                      fw: 0),
                              
                              
                              ))
        ]);
  }
}
