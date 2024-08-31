import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_book_model/sip_order_book.dart';
import '../../provider/sip_order_provider.dart';
import '../../provider/thems.dart';
import '../../res/res.dart';
import '../../sharedWidget/custom_back_btn.dart';
import '../../sharedWidget/custom_exch_badge.dart';
import '../../sharedWidget/functions.dart';
import '../../sharedWidget/snack_bar.dart';
import 'sip_cancel_alert.dart';
import 'sip_modify_alert.dart';

class SipOrderDetails extends StatefulWidget {
  final SipDetails sipdetails;
  const SipOrderDetails({super.key, required this.sipdetails});

  @override
  State<SipOrderDetails> createState() => _SipOrderDetailsState();
}

class _SipOrderDetailsState extends State<SipOrderDetails> {
  String selectedValue = "";
  int lotSize = 0;
  List<String> dropdownItems = ['Daily', 'Weekly', 'Fortnightly', 'Monthly'];
  TextEditingController sipqtyctrl = TextEditingController();
  @override
  void initState() {
    context.read(siprovider).modifysipdate.text =
        duedateformate(value: "${widget.sipdetails.startDate}");
    selectedValue = widget.sipdetails.frequency == "0"
        ? "Daily"
        : widget.sipdetails.frequency == "1"
            ? "Weekly"
            : widget.sipdetails.frequency == "2"
                ? "Fortnightly"
                : "Monthly";
    context.read(siprovider).numberofSips.text =
        widget.sipdetails.endPeriod.toString();
    lotSize = 1;
    sipqtyctrl =
        TextEditingController(text: "${widget.sipdetails.scrips![0].qty ?? 0}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final theme = watch(themeProvider);
      final sip = watch(siprovider);
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            leadingWidth: 41,
            titleSpacing: 6,
            leading: const CustomBackBtn(),
            elevation: 0.3,
            title: Text('SIP',
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600)),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: theme.isDarkMode
                          ? colors.colorbluegrey
                          : colors.colorBlack,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                  onPressed: () async {
                    if (sipqtyctrl.text.isEmpty || sipqtyctrl.text == "0") {
                      ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                          context,
                          sipqtyctrl.text.isEmpty
                              ? "Quantity can not be empty"
                              : "Quantity can not be 0"));
                    } else if (sip.numberofSips.text.isEmpty ||
                        sip.numberofSips.text == "0") {
                      ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                          context,
                          sip.numberofSips.text.isEmpty
                              ? "Number of SIP can not be empty"
                              : "Number of SIP can not be 0"));
                    } else {
                      // modifysipOrder(sip, sipqtyctrl, widget.sipdetails);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SipModifyAlert(
                                sips: sip,
                                sipqtyctrl: sipqtyctrl,
                                sipdetails: widget.sipdetails,
                                value: selectedValue,
                                themes: theme);
                          });
                    }
                  },
                  child: sip.loading
                      ? const SizedBox(
                          width: 18,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xff666666)),
                        )
                      : Text("Modify",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorBlack
                                  : colors.colorWhite,
                              14,
                              FontWeight.w600)),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    backgroundColor: const Color(0xffDF2525),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SipCancelAlert(
                          sipdetails: widget.sipdetails,
                        );
                      });
                },
                child: Text("Cancel",
                    style: textStyle(
                        const Color(0XFFFFFFFF), 14, FontWeight.w600)),
              ))
            ]),
          ),
          body: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                color: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                width: 4))),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${widget.sipdetails.sipName} ",
                                    overflow: TextOverflow.ellipsis,
                                    style: textStyles.scripNameTxtStyle
                                        .copyWith(
                                            color: theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack)),
                                Row(
                                  children: [
                                    Text("LTP: ",
                                        style: textStyle(
                                            const Color(0xff5E6B7D),
                                            13,
                                            FontWeight.w600)),
                                    Text(
                                        "₹${widget.sipdetails.scrips![0].ltp ?? widget.sipdetails.scrips![0].close ?? 0.00}",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w500)),
                                  ],
                                )
                              ]),
                          const SizedBox(height: 4),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomExchBadge(
                                    exch:
                                        "${widget.sipdetails.scrips![0].exch}"),
                                Text(
                                    " (${widget.sipdetails.scrips![0].perChange ?? 0.00}%)",
                                    style: textStyle(
                                        widget.sipdetails.scrips![0].perChange!
                                                .startsWith("-")
                                            ? colors.darkred
                                            : widget.sipdetails.scrips![0]
                                                        .perChange ==
                                                    "0.00"
                                                ? colors.ltpgrey
                                                : colors.ltpgreen,
                                        12,
                                        FontWeight.w500))
                              ]),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Details",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              15,
                              FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  alertData(
                      "SIP ID", "${widget.sipdetails.internal!.sipId}", theme),
                  alertData(
                      "Registered On",
                      sipformatDateTime(value: "${widget.sipdetails.regDate}"),
                      theme),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Modify SIP date",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        SizedBox(
                          width: 150,
                          height: 40,
                          child: TextFormField(
                            controller: sip.modifysipdate,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.calendar_month_rounded,
                                  color: colors.colorGrey,
                                ),
                                fillColor: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                filled: true,
                                hintText: "0",
                                hintStyle: textStyle(const Color(0xff999999),
                                    14, FontWeight.w600),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                prefixIconColor: const Color(0xff586279),
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
                            readOnly: true,
                            onTap: () {
                              sip.providedate(context, theme, "1");
                            },
                            onChanged: (value) {
                              sip.providedate(context, theme, "1");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Modify Frequency",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        SizedBox(
                          width: 150,
                          height: 44,
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                            dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: !theme.isDarkMode
                                        ? colors.colorWhite
                                        : const Color.fromARGB(
                                            255, 16, 16, 16))),
                            buttonStyleData: ButtonStyleData(
                                height: 40,
                                width: 124,
                                decoration: BoxDecoration(
                                    color: theme.isDarkMode
                                        ? const Color(0xffB5C0CF)
                                            .withOpacity(.1)
                                        : const Color(0xffF1F3F8),
                                    // border: Border.all(color: Colors.grey),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(32)))),
                            isExpanded: true,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500),
                            items: dropdownItems
                                .map<DropdownMenuItem<String>>((item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(item.toString()),
                                ),
                              );
                            }).toList(),
                            value: selectedValue,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value.toString();
                              });
                            },
                          )),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(" Modify Number of SIPs",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        SizedBox(
                          width: 150,
                          height: 44,
                          child: TextFormField(
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500),
                            keyboardType: TextInputType.number,
                            controller: sip.numberofSips,
                            decoration: InputDecoration(
                                fillColor: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30)),
                                disabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30))),
                            onChanged: (value) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              if (value.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    warningMessage(context,
                                        "The minimum number of this SIP is one."));
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Modify Quantity",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500)),
                        SizedBox(
                          width: 150,
                          height: 44,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            controller: sipqtyctrl,
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w500),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                fillColor: theme.isDarkMode
                                    ? colors.darkGrey
                                    : const Color(0xffF1F3F8),
                                prefixIcon: Theme(
                                  data: ThemeData(
                                      splashColor: Colors.transparent,
                                      splashFactory: NoSplash.splashFactory),
                                  child: InkWell(
                                    onLongPress: () {
                                      setState(() {
                                        if (sipqtyctrl.text.isNotEmpty) {
                                          if (int.parse(sipqtyctrl.text) >
                                              lotSize) {
                                            sipqtyctrl.text =
                                                (int.parse(sipqtyctrl.text) -
                                                        lotSize)
                                                    .toString();
                                          }
                                        } else {
                                          sipqtyctrl.text = "$lotSize";
                                        }
                                      });
                                    },
                                    onTap: () {
                                      setState(() {
                                        if (sipqtyctrl.text.isNotEmpty) {
                                          if (int.parse(sipqtyctrl.text) >
                                              lotSize) {
                                            sipqtyctrl.text =
                                                (int.parse(sipqtyctrl.text) -
                                                        lotSize)
                                                    .toString();
                                          }
                                        } else {
                                          sipqtyctrl.text = "$lotSize";
                                        }
                                      });
                                    },
                                    child: SvgPicture.asset(
                                        theme.isDarkMode
                                            ? assets.darkCMinus
                                            : assets.minusIcon,
                                        fit: BoxFit.scaleDown),
                                  ),
                                ),
                                suffixIcon: Theme(
                                  data: ThemeData(
                                      splashColor: Colors.transparent,
                                      splashFactory: NoSplash.splashFactory),
                                  child: InkWell(
                                    onLongPress: () {
                                      setState(() {
                                        if (sipqtyctrl.text.isNotEmpty) {
                                          sipqtyctrl.text =
                                              (int.parse(sipqtyctrl.text) +
                                                      lotSize)
                                                  .toString();
                                        } else {
                                          sipqtyctrl.text = "$lotSize";
                                        }
                                      });
                                    },
                                    onTap: () {
                                      setState(() {
                                        if (sipqtyctrl.text.isNotEmpty) {
                                          sipqtyctrl.text =
                                              (int.parse(sipqtyctrl.text) +
                                                      lotSize)
                                                  .toString();
                                        } else {
                                          sipqtyctrl.text = "$lotSize";
                                        }
                                      });
                                    },
                                    child: SvgPicture.asset(
                                        theme.isDarkMode
                                            ? assets.darkAdd
                                            : assets.addIcon,
                                        fit: BoxFit.scaleDown),
                                  ),
                                ),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30)),
                                disabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(30))),
                            onTap: () {},
                            onChanged: (value) {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              if (value.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    warningMessage(context,
                                        "The minimum quantity of this stock is one."));
                              }
                              setState(() {
                                // double inputValue =
                                //     double.tryParse(value) ?? 0.00;

                                // double ltpsip =
                                //     double.parse("${widget.orderArg.ltp}");
                                // resultsip = inputValue * ltpsip;
                                // sipLtpctrl.text = resultsip.toStringAsFixed(2);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      );
    });
  }

  Padding alertData(
    String title1,
    String value,
    ThemesProvider theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title1,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
            Text(value,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w500)),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider)
      ]),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
