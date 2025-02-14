// ignore_for_file: deprecated_member_use

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../models/ipo_model/ipo_details_model.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/ipo_error_widget.dart';
import '../../../../sharedWidget/snack_bar.dart';

class ModifyIpoOrderScreen extends StatefulWidget {
  final IpoOrderBookModel modifyipoorder;

  const ModifyIpoOrderScreen({
    super.key,
    required this.modifyipoorder,
  });

  @override
  State<ModifyIpoOrderScreen> createState() => _ModifyIpoOrderScreenState();
}

class _ModifyIpoOrderScreenState extends State<ModifyIpoOrderScreen> {
  bool ischecked = false;
  String alertValue = "";
  String upierrortext = "";
  int bidbrice = 0;

  List<int> stringList = [];
  int? maxValue;

  List<IpoDetails> addIpo = [];
  final RegExp emailExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  @override
  void initState() {
    setState(() {
      addNewItem();
      maxValue = mininv(
              double.parse(widget.modifyipoorder.minprice!).toDouble(),
              int.parse(widget.modifyipoorder.minbidquantity!).toInt())
          .toInt();
    });
    super.initState();
  }

  addNewItem() {
    setState(() {
      for (int i = 0; i < widget.modifyipoorder.bidDetail!.length; i++) {
        addIpo.add(IpoDetails(
            qualitytext: "${widget.modifyipoorder.lotsize}",
            bidprice:
                "${double.parse(widget.modifyipoorder.bidDetail![i].atCutOff == true ? widget.modifyipoorder.maxprice! : widget.modifyipoorder.minprice!).toInt()}",
            lotsize: int.parse("${widget.modifyipoorder.lotsize}"),
            requriedprice: mininv(
                    double.parse(widget.modifyipoorder.minprice!).toDouble(),
                    int.parse(widget.modifyipoorder.minbidquantity!).toInt())
                .toInt(),
            isChecked: widget.modifyipoorder.bidDetail![i].atCutOff == null
                ? false
                : widget.modifyipoorder.bidDetail![i].atCutOff as bool));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final ipo = watch(ipoProvide);
        final upiid = watch(transcationProvider);
        final theme = watch(themeProvider);
        return Scaffold(
         
            appBar: AppBar(
              elevation: .2,
              centerTitle: false,
              leadingWidth: 41,
              titleSpacing: 6,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: SvgPicture.asset(
                    assets.backArrow,
                    color: theme.isDarkMode
                        ? colors.colorWhite
                        : colors.colorBlack,
                  ),
                ),
              ),
              backgroundColor:
                  theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              shadowColor: const Color(0xffECEFF3),
              title: Text("Modify IPO",
                  style: textStyles.appBarTitleTxt.copyWith(
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack)),
            ),
            body: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: theme.isDarkMode
                          ? colors.colorBlack
                          : const Color(0xffF1F3F8),
                      border: Border(
                          bottom: BorderSide(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : Colors.transparent))),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("${widget.modifyipoorder.companyName}",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                15,
                                FontWeight.w600)),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? colors.colorGrey.withOpacity(.1)
                                      : colors.colorWhite,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text("${widget.modifyipoorder.symbol}",
                                  style: textStyle(const Color(0xff666666), 9,
                                      FontWeight.w500)),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                  color: theme.isDarkMode
                                      ? colors.colorGrey.withOpacity(.1)
                                      : colors.colorWhite,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text("IPO",
                                  style: textStyle(const Color(0xff666666), 9,
                                      FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 6, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "₹${double.parse(widget.modifyipoorder.minprice!).toInt()}- ₹${double.parse(widget.modifyipoorder.maxprice!).toInt()}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w500)),
                                Text("Price Range",
                                    style: textStyle(const Color(0xff666666),
                                        12, FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${widget.modifyipoorder.minbidquantity}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w500)),
                                Text("Min.Qty",
                                    style: textStyle(const Color(0xff666666),
                                        12, FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    formatInCrore(double.parse(
                                            widget.modifyipoorder.issuesize!)
                                        .toInt()),
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w500)),
                                Text("IPO Size",
                                    style: textStyle(const Color(0xff666666),
                                        12, FontWeight.w500)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
               
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text('Category',
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton2(
                    dropdownStyleData: DropdownStyleData(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: !theme.isDarkMode
                                ? colors.colorWhite
                                : const Color.fromARGB(255, 16, 16, 16))),
                    menuItemStyleData: MenuItemStyleData(
                        customHeights:
                            ipo.getCustomItemsHeight(ipo.ipoCategory)),
                    buttonStyleData: ButtonStyleData(
                        height: 40,
                        width: 124,
                        decoration: BoxDecoration(
                            color: theme.isDarkMode
                                ? const Color(0xffB5C0CF).withOpacity(.1)
                                : const Color(0xffF1F3F8),
                            // border: Border.all(color: Colors.grey),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32)))),
                    isExpanded: true,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        13,
                        FontWeight.w500),
                    hint: Text(ipo.ipoCategorys,
                        style:
                            textStyle(colors.colorBlack, 13, FontWeight.w500)),
                    items: ipo.addDividerSubCategory(
                        ipo.ipoCategory.toSet().toList()),
                    value: ipo.ipoCategoryvalue,
                    onChanged: (value) async {
                      ipo.chngCategoryType("$value");
                      ipo.categoryOnChange(
                          addIpo, ipo.maxUPIAmt, ipo.isMainIPOPlaceOrderBtnActive,
                                    "");
                    },
                  )),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addIpo.length,
                  itemBuilder: (context, index) {
                    for (var i = 0; i < addIpo.length; i++) {
                      stringList.add(addIpo[index].requriedprice);
                    }

                    maxValue = stringList.reduce((curr, next) =>
                        int.parse(curr.toString()) >
                                double.parse(next.toString())
                            ? curr
                            : next);
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Text("Bid - 0${index + 1}",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600)),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Quantity",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w600)),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 44,
                                      child: TextFormField(
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? colors.colorWhite
                                                : colors.colorBlack,
                                            14,
                                            FontWeight.w600),
                                        keyboardType: TextInputType.number,
                                        controller:
                                            addIpo[index].qualityController,
                                        decoration: InputDecoration(
                                            fillColor: theme.isDarkMode
                                                ? colors.darkGrey
                                                : const Color(0xffF1F3F8),
                                            filled: true,
                                            labelStyle: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            disabledBorder: InputBorder.none,
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            contentPadding:
                                                const EdgeInsets.all(13),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (addIpo[index]
                                                      .qualityController
                                                      .text
                                                      .isNotEmpty) {
                                                    addIpo[index]
                                                        .qualityController
                                                        .text = (int.parse(addIpo[
                                                                    index]
                                                                .qualityController
                                                                .text) +
                                                            addIpo[index]
                                                                .lotsize)
                                                        .toString();
                                                    addIpo[index].isChecked == true
                                                        ? addIpo[index]
                                                                .requriedprice =
                                                            double.parse(widget.modifyipoorder.maxprice!)
                                                                    .toInt() *
                                                                (int.parse(addIpo[index]
                                                                    .qualityController
                                                                    .text))
                                                        : addIpo[index]
                                                                .requriedprice =
                                                            double.parse(widget.modifyipoorder.minprice!)
                                                                    .toInt() *
                                                                (int.parse(
                                                                    addIpo[index]
                                                                        .qualityController
                                                                        .text));
                                                  }
                                                  if (addIpo[index]
                                                          .qualityController
                                                          .text
                                                          .isEmpty ||
                                                      addIpo[index]
                                                              .qualityController
                                                              .text ==
                                                          "0") {
                                                    addIpo[index]
                                                        .qualityerrortext = addIpo[
                                                                index]
                                                            .qualityController
                                                            .text
                                                            .isEmpty
                                                        ? "* Value is required"
                                                        : "Value cannot be 0";
                                                  } else if (addIpo[index]
                                                          .requriedprice >
                                                      ipo.maxUPIAmt) {
                                                    addIpo[index]
                                                            .qualityerrortext =
                                                        "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
                                                    ischecked = false;
                                                  } else {
                                                    addIpo[index]
                                                        .qualityerrortext = "";
                                                  }
                                                  maxValue = addIpo
                                                      .map((map) =>
                                                          map.requriedprice)
                                                      .reduce((a, b) =>
                                                          a > b ? a : b);
                                                });
                                              },
                                              child: SvgPicture.asset(
                                                  theme.isDarkMode
                                                      ? assets.darkAdd
                                                      : assets.addIcon,
                                                  fit: BoxFit.scaleDown),
                                            ),
                                            prefixIcon: InkWell(
                                              onTap: addIpo[index]
                                                          .qualityController
                                                          .text ==
                                                      addIpo[index].qualitytext
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        if (addIpo[index]
                                                            .qualityController
                                                            .text
                                                            .isNotEmpty) {
                                                          addIpo[index]
                                                              .qualityController
                                                              .text = (int.parse(addIpo[
                                                                          index]
                                                                      .qualityController
                                                                      .text) -
                                                                  addIpo[index]
                                                                      .lotsize)
                                                              .toString();
                                                          addIpo[index].isChecked ==
                                                                  true
                                                              ? addIpo[index]
                                                                  .requriedprice = double.parse(widget.modifyipoorder.maxprice!)
                                                                      .toInt() *
                                                                  (int.parse(
                                                                      addIpo[index]
                                                                          .qualityController
                                                                          .text))
                                                              : addIpo[index]
                                                                  .requriedprice = double.parse(widget.modifyipoorder.minprice!)
                                                                      .toInt() *
                                                                  (int.parse(addIpo[index]
                                                                      .qualityController
                                                                      .text));
                                                        }
                                                        if (addIpo[index]
                                                                .qualityController
                                                                .text
                                                                .isEmpty ||
                                                            addIpo[index]
                                                                    .qualityController
                                                                    .text ==
                                                                "0") {
                                                          addIpo[index]
                                                              .qualityerrortext = addIpo[
                                                                      index]
                                                                  .qualityController
                                                                  .text
                                                                  .isEmpty
                                                              ? "* Value is required"
                                                              : "Value cannot be 0";
                                                        } else if (addIpo[index]
                                                                .requriedprice >
                                                            ipo.maxUPIAmt) {
                                                          addIpo[index]
                                                                  .qualityerrortext =
                                                              "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
                                                          ischecked = false;
                                                        } else {
                                                          addIpo[index]
                                                              .qualityerrortext = "";
                                                        }
                                                        maxValue = addIpo
                                                            .map((map) => map
                                                                .requriedprice)
                                                            .reduce((a, b) =>
                                                                a > b ? a : b);
                                                      });
                                                    },
                                              child: SvgPicture.asset(
                                                  theme.isDarkMode
                                                      ? assets.darkCMinus
                                                      : assets.minusIcon,
                                                  fit: BoxFit.scaleDown),
                                            )),
                                        onChanged: (value) {
                                          setState(() {
                                            addIpo[index]
                                                .qualityController
                                                .text = value;
                                            addIpo[index]
                                                    .qualityController
                                                    .text
                                                    .isEmpty
                                                ? addIpo[index].requriedprice =
                                                    0
                                                : addIpo[index]
                                                    .requriedprice = (int.parse(
                                                            addIpo[index]
                                                                .qualityController
                                                                .text) *
                                                        int.parse(addIpo[index]
                                                            .bidpricecontroller
                                                            .text))
                                                    .toInt();
                                            addIpo[index].isChecked == true
                                                ? addIpo[index]
                                                        .qualityController
                                                        .text
                                                        .isEmpty
                                                    ? addIpo[index]
                                                        .qualityController
                                                        .text = ""
                                                    : addIpo[index].requriedprice =
                                                        double.parse(widget.modifyipoorder.maxprice!)
                                                                .toInt() *
                                                            (int.parse(addIpo[index]
                                                                .qualityController
                                                                .text))
                                                : addIpo[index]
                                                        .qualityController
                                                        .text
                                                        .isEmpty
                                                    ? addIpo[index]
                                                        .qualityController
                                                        .text = ""
                                                    : addIpo[index].requriedprice =
                                                        double.parse(widget.modifyipoorder.minprice!)
                                                                .toInt() *
                                                            (int.parse(addIpo[index]
                                                                .qualityController
                                                                .text));
                                            if (addIpo[index]
                                                    .qualityController
                                                    .text
                                                    .isEmpty ||
                                                addIpo[index]
                                                        .qualityController
                                                        .text ==
                                                    "0") {
                                              addIpo[index].qualityerrortext =
                                                  addIpo[index]
                                                          .qualityController
                                                          .text
                                                          .isEmpty
                                                      ? "* Value is required"
                                                      : "Value cannot be 0";
                                              addIpo[index].requriedprice = 0;
                                              ischecked = false;
                                            } else if (addIpo[index]
                                                    .requriedprice >
                                                ipo.maxUPIAmt) {
                                              addIpo[index].qualityerrortext =
                                                  "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
                                              ischecked = false;
                                            } else if ((int.parse(addIpo[index]
                                                    .qualityController
                                                    .text)) <
                                                int.parse(widget.modifyipoorder
                                                        .minbidquantity
                                                        .toString())
                                                    .toInt()) {
                                              addIpo[index].qualityerrortext =
                                                  "Minimum Bid quantity is ₹${widget.modifyipoorder.minbidquantity.toString()} only ";
                                              ischecked = false;
                                            } else {
                                              addIpo[index].qualityerrortext =
                                                  "";
                                            }
                                            maxValue = addIpo
                                                .map((map) => map.requriedprice)
                                                .reduce(
                                                    (a, b) => a > b ? a : b);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Bid Price",
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? addIpo[index].isChecked ==
                                                        true
                                                    ? colors.colorGrey
                                                    : colors.colorWhite
                                                : addIpo[index].isChecked ==
                                                        true
                                                    ? colors.colorGrey
                                                    : colors.colorBlack,
                                            14,
                                            FontWeight.w600)),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      height: 44,
                                      child: TextFormField(
                                        style: textStyle(
                                            theme.isDarkMode
                                                ? addIpo[index].isChecked ==
                                                        true
                                                    ? colors.colorGrey
                                                    : colors.colorWhite
                                                : addIpo[index].isChecked ==
                                                        true
                                                    ? colors.colorGrey
                                                    : colors.colorBlack,
                                            14,
                                            FontWeight.w600),
                                        keyboardType: TextInputType.number,
                                        readOnly:
                                            addIpo[index].isChecked == true
                                                ? true
                                                : false,
                                        controller:
                                            addIpo[index].bidpricecontroller,
                                        decoration: InputDecoration(
                                            fillColor: theme.isDarkMode
                                                ? colors.darkGrey
                                                : const Color(0xffF1F3F8),
                                            filled: true,
                                            labelStyle: textStyle(
                                                const Color(0xff000000),
                                                14,
                                                FontWeight.w600),
                                            enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            disabledBorder: InputBorder.none,
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            contentPadding:
                                                const EdgeInsets.all(13),
                                            border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            prefixIcon: SvgPicture.asset(
                                              assets.rupee,
                                              fit: BoxFit.values[5],
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                              minWidth: 30,
                                            )),
                                        onChanged: (value) {
                                          setState(() {
                                            if (addIpo[index]
                                                    .bidpricecontroller
                                                    .text
                                                    .isEmpty ||
                                                addIpo[index].bidpricecontroller.text ==
                                                    "0") {
                                              addIpo[index].biderrortext =
                                                  addIpo[index]
                                                          .bidpricecontroller
                                                          .text
                                                          .isEmpty
                                                      ? "* Value is required"
                                                      : "Value cannot be 0";
                                              ischecked = false;
                                            } else if ((int.parse(addIpo[index]
                                                        .bidpricecontroller
                                                        .text)) >
                                                    double.parse(widget
                                                            .modifyipoorder
                                                            .maxprice
                                                            .toString())
                                                        .toInt() ||
                                                (int.parse(addIpo[index]
                                                        .bidpricecontroller
                                                        .text)) <
                                                    double.parse(widget
                                                            .modifyipoorder
                                                            .minprice
                                                            .toString())
                                                        .toInt()) {
                                              addIpo[index].biderrortext =
                                                  "Your bid price ranges lesser than ₹${double.parse(widget.modifyipoorder.minprice!).toInt()} ₹${double.parse(widget.modifyipoorder.maxprice!).toInt()}";
                                              ischecked = false;
                                            } else {
                                              addIpo[index].biderrortext = "";
                                            }
                                            maxValue = addIpo
                                                .map((map) => map.requriedprice)
                                                .reduce(
                                                    (a, b) => a > b ? a : b);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            if (addIpo[index].qualityerrortext.isNotEmpty) ...[
                              const SizedBox(
                                height: 6,
                              ),
                              IpoErrorBadge(
                                errorName: addIpo[index].qualityerrortext,
                              )
                            ],
                            if (addIpo[index].biderrortext.isNotEmpty) ...[
                              const SizedBox(
                                height: 6,
                              ),
                              IpoErrorBadge(
                                errorName: addIpo[index].biderrortext,
                              )
                            ],
                            Row(
                              children: [
                                IconButton(
                                    splashRadius: 20,
                                    onPressed: () {
                                      setState(() {
                                        addIpo[index].biderrortext = "";
                                        addIpo[index].isChecked =
                                            !addIpo[index].isChecked;
                                        addIpo[index].isChecked == true
                                            ? addIpo[index]
                                                    .bidpricecontroller
                                                    .text =
                                                ("${double.parse(widget.modifyipoorder.maxprice!).toInt()}")
                                            : addIpo[index]
                                                    .bidpricecontroller
                                                    .text =
                                                "${double.parse(widget.modifyipoorder.minprice!).toInt()}";
                                        addIpo[index].isChecked == true
                                            ? addIpo[index]
                                                    .qualityController
                                                    .text
                                                    .isEmpty
                                                ? addIpo[index]
                                                    .qualityController
                                                    .text = ""
                                                : addIpo[index].requriedprice =
                                                    double.parse(widget.modifyipoorder.maxprice!)
                                                            .toInt() *
                                                        (int.parse(addIpo[index]
                                                            .qualityController
                                                            .text))
                                            : addIpo[index]
                                                    .qualityController
                                                    .text
                                                    .isEmpty
                                                ? addIpo[index]
                                                    .qualityController
                                                    .text = ""
                                                : addIpo[index].requriedprice =
                                                    double.parse(widget.modifyipoorder.minprice!)
                                                            .toInt() *
                                                        (int.parse(addIpo[index]
                                                            .qualityController
                                                            .text));
                                        maxValue = addIpo
                                            .map((map) => map.requriedprice)
                                            .reduce((a, b) => a > b ? a : b);
                                        FocusScope.of(context).unfocus();
                                      });
                                    },
                                    icon: SvgPicture.asset(theme.isDarkMode
                                        ? addIpo[index].isChecked
                                            ? assets.darkCheckedboxIcon
                                            : assets.darkCheckboxIcon
                                        : addIpo[index].isChecked
                                            ? assets.checkedbox
                                            : assets.checkbox)),
                                Text("Cut-off price",
                                    style: textStyle(const Color(0xff666666),
                                        13, FontWeight.w600)),
                              ],
                            ),
                          ]),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text("UPI ID (Virtual payment adress)",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          14,
                          FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 44,
                  child: TextFormField(
                    controller: ipo.viewupiid,
                    style: textStyle(
                        theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack,
                        14,
                        FontWeight.w600),
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
                      contentPadding: const EdgeInsets.all(13),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        ipo.viewupiid.text = value;
                        if (ipo.viewupiid.text.isEmpty) {
                          upierrortext = "* UPI ID cannot be empty";
                          ischecked = false;
                        } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                            .hasMatch(ipo.viewupiid.text = value)) {
                          upierrortext = 'Invalid UPI ID format';
                          ischecked = false;
                        } else {
                          upierrortext = '';
                          ischecked = true;
                        }
                      });
                    },
                  ),
                ),
                if (ipo.viewupiid.text.isEmpty ||
                    !RegExp(r'^[\w.-]+@[\w]+$')
                        .hasMatch(ipo.viewupiid.text)) ...[
                  const SizedBox(
                    height: 6,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: IpoErrorBadge(
                      errorName: upierrortext,
                    ),
                  )
                ],
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      IconButton(
                          splashRadius: 20,
                          onPressed: ipo.loading
                              ? null
                              : () {
                                  setState(() {
                                    ischecked = !ischecked;
                                    if (addIpo[addIpo.length - 1].requriedprice >
                                        ipo.maxUPIAmt) {
                                      addIpo[addIpo.length - 1]
                                              .qualityerrortext =
                                          "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
                                      ischecked = false;
                                    } else if (addIpo[addIpo.length - 1]
                                            .bidpricecontroller
                                            .text
                                            .isEmpty ||
                                        addIpo[addIpo.length - 1].bidpricecontroller.text ==
                                            "0") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(warningMessage(
                                              context,
                                              addIpo[addIpo.length - 1]
                                                          .bidpricecontroller
                                                          .text ==
                                                      "0"
                                                  ? "*Bid Price Value cannot be 0"
                                                  : "*Bid Price Value is required"));
                                      ischecked = false;
                                    } else if ((int.parse(addIpo[addIpo.length - 1].bidpricecontroller.text)) > double.parse(widget.modifyipoorder.maxprice.toString()).toInt() ||
                                        (int.parse(addIpo[addIpo.length - 1].bidpricecontroller.text)) <
                                            double.parse(widget.modifyipoorder.minprice.toString())
                                                .toInt()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(warningMessage(context,
                                              "Your bid price ranges between ₹${double.parse(widget.modifyipoorder.minprice!).toInt()}-₹${double.parse(widget.modifyipoorder.maxprice!).toInt()}"));
                                      ischecked = false;
                                    } else if ((int.parse(addIpo[addIpo.length - 1].qualityController.text)) <
                                        int.parse(widget.modifyipoorder.minbidquantity.toString())
                                            .toInt()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(warningMessage(context,
                                              "Minimum Bid quantity is ₹${widget.modifyipoorder.minbidquantity.toString()} only "));
                                      ischecked = false;
                                    } else if (addIpo[addIpo.length - 1]
                                            .qualityController
                                            .text
                                            .isEmpty ||
                                        addIpo[addIpo.length - 1].qualityController.text ==
                                            "0") {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(warningMessage(
                                              context,
                                              addIpo[addIpo.length - 1]
                                                          .qualityController
                                                          .text ==
                                                      "0"
                                                  ? '* Quantity cannot be 0'
                                                  : '* Quantity cannot be empty'));
                                      ischecked = false;
                                    } else if ((int.parse(addIpo[addIpo.length - 1].bidpricecontroller.text).toInt()) >
                                            double.parse(widget.modifyipoorder.maxprice.toString())
                                                .toInt() ||
                                        (int.parse(addIpo[addIpo.length - 1].bidpricecontroller.text).toInt()) <
                                            double.parse(widget.modifyipoorder.minprice.toString()).toInt()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(warningMessage(context,
                                              "Your bid price ranges between ₹${double.parse(widget.modifyipoorder.minprice!).toInt()} ₹${double.parse(widget.modifyipoorder.maxprice!).toInt()}"));

                                      ischecked = false;
                                    } else if (ipo.viewupiid.text.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(warningMessage(context,
                                              "UPI ID cannot be empty"));
                                      ischecked = false;
                                    } else if (!RegExp(r'^[\w.-]+@[\w]+$').hasMatch(ipo.viewupiid.text)) {
                                      ischecked = false;
                                    }
                                  });
                                },
                          icon: SvgPicture.asset(theme.isDarkMode
                              ? ischecked
                                  ? assets.darkCheckedboxIcon
                                  : assets.darkCheckboxIcon
                              : ischecked
                                  ? assets.checkedbox
                                  : assets.checkbox)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            "I hereby undertake that I have read the Red Herring Prospectus and I am eligible bidder as per the applicable provisions of SEBI (Issue of Capital & Disclosure Agreement, 2009) regulations",
                            style: textStyle(
                                const Color(0xff666666), 12, FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                if (ischecked == false) ...[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 8, bottom: 10),
                    child: Text("You Must Agree To Invest",
                        style: textStyle(colors.darkred, 13, FontWeight.w500)),
                  ),
                ],
                const SizedBox(height: 86)
              ],
            ),
            bottomSheet: BottomAppBar(
                elevation: .14,
                child: ListTile(
                  title: Text("₹$maxValue",
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          16,
                          FontWeight.w600)),
                  subtitle: Text("Total Investment",
                      style: textStyle(
                          const Color(0xff666666), 13, FontWeight.w500)),
                  trailing: ElevatedButton(
                    onPressed: ischecked == true
                        ? () {
                            if (addIpo[addIpo.length - 1].requriedprice >
                                ipo.maxUPIAmt) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  warningMessage(context,
                                      "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only "));
                              ischecked = false;
                            } else if (addIpo[addIpo.length - 1]
                                    .bidpricecontroller
                                    .text
                                    .isEmpty ||
                                addIpo[addIpo.length - 1]
                                        .bidpricecontroller
                                        .text ==
                                    "0") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  warningMessage(
                                      context,
                                      addIpo[addIpo.length - 1]
                                                  .bidpricecontroller
                                                  .text ==
                                              "0"
                                          ? "Bid Price Value cannot be 0"
                                          : "*Bid Price Value is required"));
                            } else if (addIpo[addIpo.length - 1]
                                    .qualityController
                                    .text
                                    .isEmpty ||
                                addIpo[addIpo.length - 1]
                                        .qualityController
                                        .text ==
                                    "0") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  warningMessage(
                                      context,
                                      addIpo[addIpo.length - 1]
                                                  .qualityController
                                                  .text ==
                                              "0"
                                          ? '* Quantity cannot be 0'
                                          : '* Quantity cannot be empty'));
                            } else if (ipo.viewupiid.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  warningMessage(
                                      context, '* UPI ID cannot be empty'));
                            } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                                .hasMatch(ipo.viewupiid.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  warningMessage(
                                      context, 'Invalid UPI ID format'));
                            } else {
                              ipoplaceorder(upiid, ipo);
                            }
                          }
                        : () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !theme.isDarkMode
                          ? ischecked == false
                              ? const Color(0xfff5f5f5)
                              : colors.colorBlack
                          : ischecked == false
                              ? colors.darkGrey
                              : colors.colorbluegrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text("Continue",
                        style: textStyle(
                            !theme.isDarkMode
                                ? ischecked == false
                                    ? const Color(0xff999999)
                                    : colors.colorWhite
                                : ischecked == false
                                    ? colors.darkGrey
                                    : colors.colorBlack,
                            14,
                            FontWeight.w500)),
                  ),
                )));
      },
    );
  }

  ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    MenuData menudata = MenuData(
      flow: "mod",
      type: widget.modifyipoorder.type.toString(),
      symbol: widget.modifyipoorder.symbol.toString(),
      category: ipo.ipoCategoryvalue == "Individual" || ipo.ipoCategoryvalue == "HNI"
          ? "IND"
          : ipo.ipoCategoryvalue == "Employee"
              ? "EMP"
              : ipo.ipoCategoryvalue == "Shareholder"
                  ? "SHA"
                  : ipo.ipoCategoryvalue == "Policyholder"
                      ? "POL"
                      : "",
      name: widget.modifyipoorder.companyName.toString(),
      applicationNumber: "${widget.modifyipoorder.applicationNumber}",
      respBid: [
        BidReference(
            bidReferenceNumber: "${widget.modifyipoorder.bidReferenceNumber}")
      ],
    );
    final String iposupiid = ipo.viewupiid.text;
    List<IposBid> iposbids = [];
    for (int i = 0; i < addIpo.length; i++) {
      iposbids.add(IposBid(
          bitis: true,
          qty: int.parse(addIpo[i].qualityController.text).toInt(),
          cutoff: addIpo[i].isChecked,
          price: double.parse(addIpo[i].bidpricecontroller.text).toDouble(),
          total: addIpo[i].requriedprice.toDouble()));
    }
    // for (int i = 0; i < iposbids.length; i++) {
    //   print(
    //       "Text: ${iposbids[i].bitis} Checkbox: ${iposbids[i].qty}, requried:${iposbids[i].cutoff},bidprice:${iposbids[i].price} value Total: ${iposbids[i].total}");
    // }
    await context.read(ipoProvide).fetchupiidvalidation(
        context, ipo.viewupiid.text, "343245", menudata, iposbids, iposupiid);
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}
