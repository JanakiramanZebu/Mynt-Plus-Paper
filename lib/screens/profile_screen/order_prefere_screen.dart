import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';

import '../../api/core/api_core.dart';
import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../provider/shocase_provider.dart';
import '../../res/res.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/enums.dart';
import '../../sharedWidget/snack_bar.dart';

class OrderPreference extends StatefulWidget {
  const OrderPreference({super.key});

  @override
  State<OrderPreference> createState() => _OrderPreference();
}

class _OrderPreference extends State<OrderPreference> {
  Map<String, dynamic> localdata = {};
  String priceType = "Limit";
  String orderType = "Intraday";
  String validity = "DAY";
  List orderTypes = ["Intraday", 'Delivery', "Cover", "Bracket"];
  List priceTypes = [];
  List<String> validityTypes = ["DAY", "IOC"];
  TextEditingController mktProtCtrl = TextEditingController(text: "1");
  TextEditingController qtyCtrl = TextEditingController(text: "1");
  final Preferences pref = locator<Preferences>();
  int multiplayer = 0;

  OrdQtyPref QtyPrefer = OrdQtyPref.mktqty;

  @override
  void initState() {
    String getlocal = "";
    if (pref.showOrderpref != null) {
      getlocal = pref.showOrderpref!;
    }

    if (getlocal != "") {
      localdata = jsonDecode(getlocal);
      priceType = localdata['prc'];
      orderType = localdata['prd'];
      validity = localdata['validity'];
      QtyPrefer =
          localdata['qtypref'] == 'lot' ? OrdQtyPref.mktlot : OrdQtyPref.mktqty;
      qtyCtrl = TextEditingController(text: "${localdata['qty']}");
      mktProtCtrl = TextEditingController(text: "${localdata['mrkprot']}");
    }
    priceTypes = [
      {
        "type": "Limit",
        "key": context.read(showcaseProvide).limitprctype,
        "case": "Click here to set your order type to Limit."
      },
      {
        "type": "Market",
        "key": context.read(showcaseProvide).marketprctype,
        "case": "Click here to set your order type to Market."
      },
      {
        "type": "SL Limit",
        "key": context.read(showcaseProvide).sllimitprctype,
        "case": "Click here to set your order type to SL Limit."
      },
      {
        "type": "SL MKT",
        "key": context.read(showcaseProvide).sllimktprctype,
        "case": "Click here to set your order type to SL MKT."
      },
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = context.read(themeProvider);

      return Scaffold(
        appBar: AppBar(
          leadingWidth: 41,
          titleSpacing: 6,
          centerTitle: false,
          leading: const CustomBackBtn(),
          elevation: 0.2,
          title: Text('Order Preference',
              style: textStyle(
                  theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                  14,
                  FontWeight.w600)),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: headerTitleText("Product type", theme)),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    orderType = orderTypes[index];
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                    backgroundColor: !theme.isDarkMode
                                        ? orderType != orderTypes[index]
                                            ? const Color(0xffF1F3F8)
                                            : colors.colorBlack
                                        : orderType != orderTypes[index]
                                            ? colors.darkGrey
                                            : colors.colorbluegrey,
                                    shape: const StadiumBorder()),
                                child: Text(orderTypes[index] == "Delivery" ? "Delivery / Carry" : orderTypes[index],
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? orderType != orderTypes[index]
                                                ? const Color(0xff666666)
                                                : colors.colorWhite
                                            : orderType != orderTypes[index]
                                                ? const Color(0xff666666)
                                                : colors.colorBlack,
                                        14,
                                        orderType == orderTypes[index]
                                            ? FontWeight.w600
                                            : FontWeight.w500)));
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 8);
                          },
                          itemCount: orderTypes.length))),
              const SizedBox(height: 6),
              Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: headerTitleText("Order type", theme)),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    priceType = priceTypes[index]['type'];
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                    backgroundColor: !theme.isDarkMode
                                        ? priceType != priceTypes[index]['type']
                                            ? const Color(0xffF1F3F8)
                                            : colors.colorBlack
                                        : priceType != priceTypes[index]['type']
                                            ? colors.darkGrey
                                            : colors.colorbluegrey,
                                    shape: const StadiumBorder()),
                                child: Text(priceTypes[index]['type'],
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? priceType !=
                                                    priceTypes[index]['type']
                                                ? const Color(0xff666666)
                                                : colors.colorWhite
                                            : priceType !=
                                                    priceTypes[index]['type']
                                                ? const Color(0xff666666)
                                                : colors.colorBlack,
                                        14,
                                        priceType == priceTypes[index]['type']
                                            ? FontWeight.w600
                                            : FontWeight.w500)));
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 8);
                          },
                          itemCount: priceTypes.length))),
              const SizedBox(height: 8),
              Padding(
                  padding: const EdgeInsets.only(left: 16, top: 16),
                  child: headerTitleText("Validity", theme)),
              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    validity = validityTypes[index];
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                    backgroundColor: !theme.isDarkMode
                                        ? validity != validityTypes[index]
                                            ? const Color(0xffF1F3F8)
                                            : colors.colorBlack
                                        : validity != validityTypes[index]
                                            ? colors.darkGrey
                                            : colors.colorbluegrey,
                                    shape: const StadiumBorder()),
                                child: Text(validityTypes[index],
                                    style: textStyle(
                                        !theme.isDarkMode
                                            ? validity != validityTypes[index]
                                                ? const Color(0xff666666)
                                                : colors.colorWhite
                                            : validity != validityTypes[index]
                                                ? const Color(0xff666666)
                                                : colors.colorBlack,
                                        14,
                                        validity == validityTypes[index]
                                            ? FontWeight.w600
                                            : FontWeight.w500)));
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 8);
                          },
                          itemCount: validityTypes.length))),
              const SizedBox(height: 24),
              Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 0),
                  child: headerTitleText("Quantity preference", theme)),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Radio<OrdQtyPref>(
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return const Color(0xff666666);
                      }
                      return theme.isDarkMode
                          ? colors.colorWhite
                          : const Color(0xff666666);
                    }),
                    activeColor: theme.isDarkMode
                        ? colors.colorWhite
                        : const Color(0xff666666),
                    value: OrdQtyPref.mktqty,
                    groupValue: QtyPrefer,
                    onChanged: (OrdQtyPref? value) {
                      setState(() {
                        QtyPrefer = value!;
                        qtyCtrl.text = "1";
                      });
                    }),
                Text('Minimum Qty',
                    style: textStyle(
                        theme.isDarkMode
                            ? Color(QtyPrefer == OrdQtyPref.mktqty
                                ? 0xffffffff
                                : 0xff666666)
                            : Color(QtyPrefer == OrdQtyPref.mktqty
                                ? 0xff3E4763
                                : 0xff666666),
                        14,
                        FontWeight.w500)),
                Radio<OrdQtyPref>(
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                        (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return const Color(0xff666666);
                      }
                      return theme.isDarkMode
                          ? colors.colorWhite
                          : const Color(0xff666666);
                    }),
                    activeColor: theme.isDarkMode
                        ? colors.colorWhite
                        : const Color(0xff666666),
                    value: OrdQtyPref.mktlot,
                    groupValue: QtyPrefer,
                    onChanged: (OrdQtyPref? value) {
                      setState(() {
                        QtyPrefer = value!;
                      });
                    }),
                Text("No.of Market Lots",
                    style: textStyle(
                        theme.isDarkMode
                            ? Color(QtyPrefer == OrdQtyPref.mktqty
                                ? 0xffffffff
                                : 0xff666666)
                            : Color(QtyPrefer == OrdQtyPref.mktqty
                                ? 0xff3E4763
                                : 0xff666666),
                        14,
                        FontWeight.w500))
              ]),

              //////////////////////////
              if (QtyPrefer == OrdQtyPref.mktlot) ...[
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 40,
                    child: Row(children: [
                      Expanded(
                          child: CustomTextFormField(
                              fillColor: theme.isDarkMode
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              hintText: qtyCtrl.text,
                              hintStyle: textStyle(
                                  const Color(0xff666666), 15, FontWeight.w400),
                              inputFormate: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w600),
                              textCtrl: qtyCtrl,
                              textAlign: TextAlign.start,
                              onChanged: (value) {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();

                                if (value.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      warningMessage(
                                          context, "Quantity cannot be empty"));
                                } else {
                                  String newValue =
                                      value.replaceAll(RegExp(r'[^0-9]'), '');
                                  if (newValue != value) {
                                    setState(() {
                                      qtyCtrl.text = newValue;
                                      qtyCtrl.selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: newValue.length));
                                    });
                                  }
                                }
                              }))
                    ])),
                const SizedBox(height: 14),
              ],
              //////////////////////////

              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 12),
                  child: headerTitleText("Market Protection%", theme)),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 40,
                  child: Row(children: [
                    Expanded(
                        child: CustomTextFormField(
                            fillColor: theme.isDarkMode
                                ? colors.darkGrey
                                : const Color(0xffF1F3F8),
                            inputFormate: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) {
                              setState(() {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                if (value.isNotEmpty) {
                                  if (int.parse(value) > 20) {
                                    mktProtCtrl.text = "20";
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        warningMessage(context,
                                            "can't enter greater than 20% of Market Protection"));
                                  } else if (int.parse(value) < 1) {
                                    mktProtCtrl.text = "1";
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        warningMessage(context,
                                            "can't enter less than 1% of Market Protection"));
                                  }
                                }
                              });
                            },
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                            textCtrl: mktProtCtrl,
                            prefixIcon: Container(
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: theme.isDarkMode
                                      ? const Color(0xff555555)
                                      : colors.colorWhite),
                              child: SvgPicture.asset(
                                  color: theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorGrey,
                                  assets.precentIcon,
                                  fit: BoxFit.scaleDown),
                            ),
                            textAlign: TextAlign.start))
                  ])),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            backgroundColor: theme.isDarkMode
                                ? colors.colorbluegrey
                                : colors.colorBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            )),
                        onPressed: () async {
                          if (mktProtCtrl.text.isEmpty ||
                              int.parse(mktProtCtrl.text) > 20 ||
                              int.parse(mktProtCtrl.text) < 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(context,
                                    "Market Protection between 1% to 20%"));
                          } else if ((QtyPrefer == OrdQtyPref.mktlot) &&
                              qtyCtrl.text == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(
                                    context, "Quantity can not be 0 or empty"));
                          } else {
                            await setPrefOrderPrefer(context);
                          }
                        },
                        child: Text("Save",
                            textAlign: TextAlign.center,
                            style: textStyle(
                                !theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)))))),
      );
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }

  Text headerTitleText(String text, ThemesProvider theme) {
    return Text(text,
        style: textStyle(
            theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
            14,
            FontWeight.w500));
  }

  Future<void> setPrefOrderPrefer(BuildContext context) async {
    Map<String, dynamic> local = {
      "prc": priceType,
      "prd": orderType,
      "qtypref": QtyPrefer == OrdQtyPref.mktlot ? 'lot' : ' qty',
      "qty": qtyCtrl.text,
      "validity": validity,
      "mrkprot": mktProtCtrl.text,
    };
    String jsonString = jsonEncode(local);
    await pref.setOrderprefer("ord_prf_${pref.clientId}", jsonString);
    ScaffoldMessenger.of(context).showSnackBar(
        successMessage(context, "Order Preference hav been saved"));
    await pref.init();
  }
}
