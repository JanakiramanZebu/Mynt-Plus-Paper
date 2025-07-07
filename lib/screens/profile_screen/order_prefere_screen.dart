import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/auth_provider.dart';
import 'package:mynt_plus/provider/thems.dart';

import '../../locator/locator.dart';
import '../../locator/preference.dart';
import '../../models/marketwatch_model/scrip_info.dart';
import '../../models/order_book_model/order_book_model.dart';
import '../../provider/shocase_provider.dart';
import '../../res/global_state_text.dart';
import '../../res/res.dart';
import '../../routes/route_names.dart';
import '../../sharedWidget/cust_text_formfield.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/enums.dart';
import '../../sharedWidget/snack_bar.dart';

class OrderPreference extends ConsumerStatefulWidget {
  final OrderScreenArgs? orderArg;
  final ScripInfoModel? scripInfo;
  final String? isRollback;
  const OrderPreference(
      {super.key, this.scripInfo, this.orderArg, this.isRollback});

  @override
  ConsumerState<OrderPreference> createState() => _OrderPreference();
}

class _OrderPreference extends ConsumerState<OrderPreference> {
  Map localdata = {};
  String priceType = "Limit";
  String expriceType = "Market";
  String orderType = "Intraday";
  String validity = "DAY";
  List orderTypes = ["Intraday", 'Delivery', "Cover", "Bracket"];
  List priceTypes = [];
  List expriceTypes = [];

  List<String> validityTypes = ["DAY", "IOC"];
  TextEditingController mktProtCtrl = TextEditingController(text: "1");
  TextEditingController qtyCtrl = TextEditingController(text: "1");
  final Preferences pref = locator<Preferences>();
  int multiplayer = 0;

  bool gobackOP = false;

  OrdQtyPref QtyPrefer = OrdQtyPref.mktqty;

  @override
  void initState() {
    super.initState();
    gobackOP = widget.isRollback == "yes" ? true : false;
    localdata = ref.read(authProvider).savedOrderPreference;

    if (localdata.isNotEmpty) {
      priceType = localdata['prc'];
      orderType = localdata['prd'];
      validity = localdata['validity'];
      QtyPrefer =
          localdata['qtypref'] == 'lot' ? OrdQtyPref.mktlot : OrdQtyPref.mktqty;
      qtyCtrl = TextEditingController(text: "${localdata['qty']}");
      mktProtCtrl = TextEditingController(text: "${localdata['mrkprot']}");
    }

    // Initialize priceTypes and expriceTypes arrays
    final showcaseProvider = ref.read(showcaseProvide);

    priceTypes = [
      {
        "type": "Limit",
        "key": showcaseProvider.limitprctype,
        "case": "Click here to set your order type to Limit."
      },
      {
        "type": "Market",
        "key": showcaseProvider.marketprctype,
        "case": "Click here to set your order type to Market."
      },
      {
        "type": "SL Limit",
        "key": showcaseProvider.sllimitprctype,
        "case": "Click here to set your order type to SL Limit."
      },
      {
        "type": "SL MKT",
        "key": showcaseProvider.sllimktprctype,
        "case": "Click here to set your order type to SL MKT."
      },
    ];

    expriceTypes = [
      {
        "type": "Limit",
        "key": showcaseProvider.limitprctype,
        "case": "Click here to set your order type to Limit."
      },
      {
        "type": "Market",
        "key": showcaseProvider.marketprctype,
        "case": "Click here to set your order type to Market."
      },
    ];

    expriceType = ["Limit", "Market"].contains(localdata['expos'])
        ? localdata['expos']
        : 'Market';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 41,
        titleSpacing: 6,
        centerTitle: false,
        leading: gobackOP
            ? InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, Routes.placeOrderScreen,
                      arguments: {
                        "orderArg": widget.orderArg,
                        "scripInfo": widget.scripInfo,
                        "isBskt": ""
                      });
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: SvgPicture.asset(assets.backArrow,
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack)))
            : const CustomBackBtn(),
        elevation: 0.2,
        title: TextWidget.titleText(
          text: 'Order Preference',
          theme: false,
          color: theme.isDarkMode
              ? colors.textPrimaryDark
              : colors.textPrimaryLight,
          fw: 1,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: headerTitleText("Product type", theme)),
                  const SizedBox(height: 16),
                  Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                          height: 38,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        orderType = orderTypes[index];
                                      });
                                      FocusScope.of(context).unfocus();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                      backgroundColor: !theme.isDarkMode
                                          ? orderType == orderTypes[index]
                                              ? Color(0xffF1F3F8)
                                              : Colors.transparent
                                          : orderType == orderTypes[index]
                                              ? colors.colorbluegrey
                                              : Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: orderType == orderTypes[index]
                                          ? BorderSide(
                                              color: colors.primaryLight,
                                              width: 1,
                                            )
                                          : BorderSide.none,
                                      ),
                                    ),
                                    child: Text(
                                        orderTypes[index] == "Delivery"
                                            ? "Delivery / Carry"
                                            : orderTypes[index],
                                        style: TextWidget.textStyle(
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                            fontSize: 14,
                                            theme: theme.isDarkMode,
                                            fw: orderType == orderTypes[index] ? 0 : null)));
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(width: 8);
                              },
                              itemCount: orderTypes.length))),
                  // const SizedBox(height: 0),
                  Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: headerTitleText("Order type", theme)),
                  const SizedBox(height: 16),
                  Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                          height: 38,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        priceType = priceTypes[index]['type'];
                                      });
                                      FocusScope.of(context).unfocus();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                      backgroundColor: !theme.isDarkMode
                                          ? priceType == priceTypes[index]['type']
                                              ? Color(0xffF1F3F8)
                                              : Colors.transparent
                                          : priceType == priceTypes[index]['type']
                                              ? colors.colorbluegrey
                                              : Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: priceType == priceTypes[index]['type']
                                          ? BorderSide(
                                              color: colors.primaryLight,
                                              width: 1,
                                            )
                                          : BorderSide.none,
                                      ),
                                    ),
                                    child: Text(priceTypes[index]['type'],
                                        style: TextWidget.textStyle(
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                            fontSize: 14,
                                            theme: theme.isDarkMode,
                                            fw: priceType == priceTypes[index]['type'] ? 0 : null)));
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(width: 8);
                              },
                              itemCount: priceTypes.length))),
                
                  Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: headerTitleText("Validity", theme),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final isSelected = validity == validityTypes[index];
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        validity = validityTypes[index];
                      });
                      FocusScope.of(context).unfocus();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: !theme.isDarkMode
                          ? isSelected
                              ? Color(0xffF1F3F8)
                              : Colors.transparent
                          : isSelected
                              ? colors.colorbluegrey
                              : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: isSelected
                          ? BorderSide(
                              color: colors.primaryLight,
                              width: 1,
                            )
                          : BorderSide.none,
                      ),
                    ),
                    child: Text(
                      validityTypes[index],
                      style: TextWidget.textStyle(
                        color: theme.isDarkMode
                            ? colors.textPrimaryDark
                            : colors.textPrimaryLight,
                        fontSize: 14,
                        theme: theme.isDarkMode,
                        fw: isSelected ? 0 : null,
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemCount: validityTypes.length,
              ),
            ),
          ),
        ],
      ),
    ),
    Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only( top: 16, bottom: 8),
            child: headerTitleText("Market Protection%", theme),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              height: 40,
              child: Row(
                children: [
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
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          if (value.isNotEmpty) {
                            int parsed = int.tryParse(value) ?? 1;
                            if (parsed > 20) {
                              mktProtCtrl.text = "20";
                              ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(context,
                                    "Can't enter greater than 20% of Market Protection"),
                              );
                            } else if (parsed < 1) {
                              mktProtCtrl.text = "1";
                              ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(context,
                                    "can't enter less than 1% of Market Protection"),
                              );
                            }
                          }
                        });
                      },
                      style: TextWidget.textStyle(
                        color: theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
                        fontSize: 14,
                        theme: theme.isDarkMode,
                        
                      ),
                      textCtrl: mktProtCtrl,
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: theme.isDarkMode
                              ? const Color(0xff555555)
                              : colors.colorWhite,
                        ),
                        child: SvgPicture.asset(
                          assets.precentIcon,
                          color: theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorGrey,
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

                  const SizedBox(height: 16),
                  Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 0),
                      child: headerTitleText("Quantity preference", theme)),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Radio<OrdQtyPref>(
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return const Color(0xff666666);
                          }
                          return theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight;
                        }),
                        activeColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        value: OrdQtyPref.mktqty,
                        groupValue: QtyPrefer,
                        onChanged: (OrdQtyPref? value) {
                          setState(() {
                            QtyPrefer = value!;
                            qtyCtrl.text = "1";
                          });
                        }),
                          TextWidget.subText(
                      text: 'Minimum Qty',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? Color(QtyPrefer == OrdQtyPref.mktqty
                              ? 0xffffffff
                              : 0xff666666)
                          : Color(QtyPrefer == OrdQtyPref.mktqty
                              ? 0xff3E4763
                              : 0xff666666),
                     
                    ),
                     
                    Radio<OrdQtyPref>(
                        fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return const Color(0xff666666);
                          }
                          return theme.isDarkMode
                              ? colors.primaryDark
                              : colors.primaryLight;
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
                    TextWidget.subText(
                      text: 'No.of Market Lots',
                      theme: theme.isDarkMode,
                      color: theme.isDarkMode
                          ? Color(QtyPrefer == OrdQtyPref.mktqty
                              ? 0xffffffff
                              : 0xff666666)
                          : Color(QtyPrefer == OrdQtyPref.mktqty
                              ? 0xff3E4763
                              : 0xff666666),
                     
                    ),
                  ]),
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
                                  hintStyle: TextWidget.textStyle(
                                      color: colors.textSecondaryLight,
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                      ),
                                  inputFormate: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  style: TextWidget.textStyle(
                                      color: theme.isDarkMode
                                          ? colors.textPrimaryDark
                                          : colors.textPrimaryLight,
                                      fontSize: 14,
                                      theme: theme.isDarkMode,
                                      ),
                                  textCtrl: qtyCtrl,
                                  textAlign: TextAlign.start,
                                  onChanged: (value) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();

                                    if (value.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(warningMessage(context,
                                              "Quantity cannot be empty"));
                                    } else {
                                      String newValue = value.replaceAll(
                                          RegExp(r'[^0-9]'), '');
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
                  ],
                  Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: headerTitleText(
                          "Position exit ${expriceType}", theme)),
                  const SizedBox(height: 16),
                  Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SizedBox(
                          height: 38,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return TextButton(
                                    onPressed: () {
                                      setState(() {
                                        expriceType =
                                            expriceTypes[index]['type'];
                                      });
                                      FocusScope.of(context).unfocus();
                                    },
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                      backgroundColor: !theme.isDarkMode
                                          ? expriceType == expriceTypes[index]['type']
                                              ? Color(0xffF1F3F8)
                                              : Colors.transparent
                                          : expriceType == expriceTypes[index]['type']
                                              ? colors.colorbluegrey
                                              : Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        side: expriceType == expriceTypes[index]['type']
                                          ? BorderSide(
                                              color: colors.primaryLight,
                                              width: 1,
                                            )
                                          : BorderSide.none,
                                      ),
                                    ),
                                    child: Text(expriceTypes[index]['type'],
                                        style: TextWidget.textStyle(
                                            color: theme.isDarkMode
                                                ? colors.textPrimaryDark
                                                : colors.textPrimaryLight,
                                            fontSize: 14,
                                            theme: theme.isDarkMode,
                                            fw: expriceType == expriceTypes[index]['type'] ? 0 : null)));
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(width: 8);
                              },
                              itemCount: expriceTypes.length))),
                  
                ],
              ),
            ),
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        backgroundColor: theme.isDarkMode
                            ? colors.primaryDark
                            : colors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
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
                    child: TextWidget.subText(
                      text: "Save",
                      theme: false,
                      color:  colors.colorWhite,
                      fw: 2,
                      align: TextAlign.center,
                    )),
              ))
        ],
      ),
    );
  }

  Widget headerTitleText(String text, ThemesProvider theme) {
    return TextWidget.subText(
      text: text,
      theme: false,
      color:
          theme.isDarkMode ? colors.textPrimaryDark : colors.textPrimaryLight,
      fw: null,
    );
  }

  Future<void> setPrefOrderPrefer(BuildContext context) async {
    Map local = {
      "clientid": pref.clientId,
      "metadata": {
        "prc": priceType,
        "prd": orderType,
        "qtypref": QtyPrefer == OrdQtyPref.mktlot ? 'lot' : 'qty',
        "qty": qtyCtrl.text,
        "validity": validity,
        "mrkprot": mktProtCtrl.text,
        "expos": expriceType
      },
      "source": "MOB"
    };

    final authProv = ref.read(authProvider);
    await authProv.getPrefOrderPrefer(local, true, context);

    ScaffoldMessenger.of(context).showSnackBar(
        successMessage(context, "Order Preference hav been saved"));
    await authProv.setPrefOrderPrefer(context);
    Navigator.pop(context);
    if (gobackOP) {
      Navigator.pushNamed(context, Routes.placeOrderScreen, arguments: {
        "orderArg": widget.orderArg,
        "scripInfo": widget.scripInfo,
        "isBskt": ""
      });
    }
  }
}
