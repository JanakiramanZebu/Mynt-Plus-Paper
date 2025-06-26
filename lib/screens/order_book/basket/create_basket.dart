import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/order_provider.dart';
import '../../../locator/locator.dart';
import '../../../locator/preference.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/list_divider.dart';

class CreateBasket extends ConsumerStatefulWidget {
  const CreateBasket({super.key});

  @override
  ConsumerState<CreateBasket> createState() => _CreateBasketState();
}

class _CreateBasketState extends ConsumerState<CreateBasket> {
  final Preferences pref = locator<Preferences>();
  TextEditingController textCtrl = TextEditingController();
  String? errorText;
  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final basket = ref.read(orderProvider);

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
              TextWidget.titleText(text: 'Create Basket',theme: theme.isDarkMode,fw: 1),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded),
              color:
                  theme.isDarkMode ? const Color(0xffBDBDBD) : colors.colorGrey)
        ]),
        content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              const ListDivider(),
              const SizedBox(height: 14),
              TextFormField(
                  controller: textCtrl,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp("[π£•₹€℅™∆√¶÷℅/]"))
                  ],
                  style: textStyles.textFieldLabelStyle.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlue),
                  decoration: InputDecoration(
                      fillColor: theme.isDarkMode
                          ? colors.darkGrey
                          : const Color(0xffF1F3F8),
                      filled: true,
                      hintText: "Enter basket name",
                      hintStyle: TextWidget.textStyle(color: Colors.grey,fontSize: 12,fw: 00,theme: false),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      errorText: errorText,
                      errorStyle:
                         TextWidget.textStyle(color: colors.darkred,fontSize: 10,fw: 1,theme: false),
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
                        errorText = "Please enter basket name";
                      }
                    });
                  })
            ])),
        actions: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  onPressed: () {
                    List<String> bskt = [];
                    setState(() {
                      if (textCtrl.text.trim().isEmpty) {
                        errorText = "Please enter basket name";
                      } else {
                        List listofBasket =
                       pref.bsktList!.isEmpty?[]:     jsonDecode("${pref.bsktList?? []}");

                        if (listofBasket.isNotEmpty) {
                          for (var element in listofBasket) {
                            bskt.add(
                                element['bsketName'].toString().toLowerCase());
                          }

                          if (bskt
                              .contains(textCtrl.text.trim().toLowerCase())) {
                            errorText = "Basket name already exist";
                          } else {
                            basket.createBasketOrder(
                                textCtrl.text.trim(), context);
                          }
                        } else {
                          basket.createBasketOrder(
                              textCtrl.text.trim(), context);
                        }
                      }
                    });
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
                  child: TextWidget.subText(text: "Create",theme: false,color: !theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,fw: 0)))
        ]);
  }
}
