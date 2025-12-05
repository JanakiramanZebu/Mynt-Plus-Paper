import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../models/ipo_model/ipo_details_model.dart';
import '../../../../models/ipo_model/ipo_mainstream_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/ipo_error_widget.dart';
import '../../../../sharedWidget/snack_bar.dart';

class ApplyIpoScreen extends ConsumerStatefulWidget {
  final MainIPO mainstream;
  const ApplyIpoScreen({
    super.key,
    required this.mainstream,
  });

  @override
  ConsumerState<ApplyIpoScreen> createState() => _ApplyIpoScreenState();
}

class _ApplyIpoScreenState extends ConsumerState<ApplyIpoScreen> {
  bool ischecked = false;
  String upierrortext = "Please enter the UPI Id";
  int required = 0;

  List<int> stringList = [];
  int? maxValue;

  List<IpoDetails> addIpo = [];
  @override
  void initState() {
    setState(() {
      addNewItem();
      maxValue = mininv(double.parse(widget.mainstream.minPrice!).toDouble(),
              int.parse(widget.mainstream.minBidQuantity!).toInt())
          .toInt();
    });
    super.initState();
  }

  void addNewItem() {
    setState(() {
      addIpo.add(IpoDetails(
          qualitytext: "${widget.mainstream.lotSize}",
          bidprice: "${double.parse(widget.mainstream.minPrice!).toInt()}",
          lotsize: int.parse("${widget.mainstream.lotSize}"),
          requriedprice: mininv(
                  double.parse(widget.mainstream.minPrice!).toDouble(),
                  int.parse(widget.mainstream.minBidQuantity!).toInt())
              .toInt(),
          isChecked: false));
    });
  }

  removeItem(int index) {
    setState(() {
      addIpo.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer(
        builder: (context, ref, child) {
          final ipo = ref.watch(ipoProvide);
          final theme = ref.watch(themeProvider);
          final upiid = ref.watch(transcationProvider);
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
                title: Text("IPO Order",
                    style: textStyles.appBarTitleTxt.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack)),
              ),
              body: ListView(
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
                                  : Colors.transparent)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("${widget.mainstream.name}",
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
                                child: Text("${widget.mainstream.symbol}",
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
                                      "₹${double.parse(widget.mainstream.minPrice!).toInt()}- ₹${double.parse(widget.mainstream.maxPrice!).toInt()}",
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
                                  Text("${widget.mainstream.minBidQuantity}",
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
                                      formatInCrore(
                                        double.parse(
                                                widget.mainstream.issueSize!)
                                            .toInt(),
                                      ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text('Category',
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600)),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(
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
                                  ? colors.darkGrey
                                  : const Color(0xffF1F3F8),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(32)))),
                      isExpanded: true,
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          13,
                          FontWeight.w500),
                      hint: Text(ipo.ipoCategoryvalue,
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              13,
                              FontWeight.w500)),
                      items: ipo.loading
                          ? null
                          : ipo.addDividerSubCategory(ipo.ipoCategory),
                      value: ipo.ipoCategoryvalue,
                      onChanged: (value) async {
                        ipo.chngCategoryType("$value");
                        ipo.categoryOnChange(addIpo,
                            ipo.maxUPIAmt, ipo.isMainIPOPlaceOrderBtnActive,
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
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Bid - 0${index + 1}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          14,
                                          FontWeight.w600)),
                                  index > 0
                                      ? InkWell(
                                          splashFactory: InkSparkle
                                              .constantTurbulenceSeedSplashFactory,
                                          onTap: ipo.loading
                                              ? null
                                              : () {
                                                  removeItem(index);
                                                },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                SvgPicture.asset(
                                                  assets.trash,
                                                  color: colors.darkred,
                                                ),
                                                const SizedBox(width: 5),
                                                Text("Delete",
                                                    style: textStyle(
                                                        colors.darkred,
                                                        12,
                                                        FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container()
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            readOnly:
                                                ipo.loading ? true : false,
                                            textAlign: TextAlign.center,
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
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                disabledBorder:
                                                    InputBorder.none,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                contentPadding:
                                                    const EdgeInsets.all(13),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                suffixIcon: InkWell(
                                                  onTap: ipo.loading
                                                      ? null
                                                      : () {
                                                          ipo.qualityplusefunction(
                                                              addIpo[index],
                                                              ischecked,
                                                              ipo,
                                                              widget
                                                                  .mainstream,"");
                                                          setState(() {
                                                            maxValue = addIpo
                                                                .map((map) => map
                                                                    .requriedprice)
                                                                .reduce((a,
                                                                        b) =>
                                                                    a > b
                                                                        ? a
                                                                        : b);
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
                                                          addIpo[index]
                                                              .qualitytext
                                                      ? null
                                                      : ipo.loading
                                                          ? null
                                                          : () {
                                                              ipo.quantityminusfunction(
                                                                  addIpo[index],
                                                                  ischecked,
                                                                  ipo,
                                                                  widget
                                                                      .mainstream,"");
                                                              setState(() {
                                                                maxValue = addIpo
                                                                    .map((map) => map
                                                                        .requriedprice)
                                                                    .reduce((a,
                                                                            b) =>
                                                                        a > b
                                                                            ? a
                                                                            : b);
                                                              });
                                                            },
                                                  child: SvgPicture.asset(
                                                      theme.isDarkMode
                                                          ? assets.darkCMinus
                                                          : assets.minusIcon,
                                                      fit: BoxFit.scaleDown),
                                                )),
                                            onChanged: (value) {
                                              ipo.quantityOnchange(
                                                  addIpo[index],
                                                  ischecked,
                                                  ipo,
                                                  value,
                                                  widget.mainstream,"");
                                              setState(() {
                                                if (addIpo[index]
                                                        .qualityController
                                                        .text
                                                        .isEmpty ||
                                                    addIpo[index]
                                                            .qualityController
                                                            .text ==
                                                        "0") {
                                                  ischecked = false;
                                                } else if ((int.parse(
                                                        addIpo[index]
                                                            .qualityController
                                                            .text)) <
                                                    int.parse(widget.mainstream
                                                            .minBidQuantity
                                                            .toString())
                                                        .toInt()) {
                                                  addIpo[index]
                                                          .qualityerrortext =
                                                      "Minimum Bid quantity is ${widget.mainstream.minBidQuantity.toString()} only ";
                                                  ischecked = false;
                                                }

                                                maxValue = addIpo
                                                    .map((map) =>
                                                        map.requriedprice)
                                                    .reduce((a, b) =>
                                                        a > b ? a : b);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Bid Price",
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
                                            readOnly: ipo.loading
                                                ? true
                                                : addIpo[index].isChecked ==
                                                        true
                                                    ? true
                                                    : false,
                                            controller: addIpo[index]
                                                .bidpricecontroller,
                                            decoration: InputDecoration(
                                                fillColor: theme.isDarkMode
                                                    ? colors.darkGrey
                                                    : const Color(0xffF1F3F8),
                                                filled: true,
                                                labelStyle: textStyle(
                                                    const Color(0xff000000),
                                                    14,
                                                    FontWeight.w600),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                disabledBorder:
                                                    InputBorder.none,
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                        borderSide:
                                                            BorderSide.none,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(30)),
                                                contentPadding:
                                                    const EdgeInsets.all(13),
                                                border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30)),
                                                prefixIcon: SvgPicture.asset(
                                                  assets.rupee,
                                                  fit: BoxFit.values[5],
                                                ),
                                                prefixIconConstraints:
                                                    const BoxConstraints(
                                                  minWidth: 30,
                                                )),
                                            onChanged: (value) {
                                              ipo.bidpricefunction(
                                                  addIpo[index],
                                                  widget.mainstream,
                                                  value,
                                                  ischecked);
                                              setState(() {
                                                if (addIpo[index]
                                                        .bidpricecontroller
                                                        .text
                                                        .isEmpty ||
                                                    addIpo[index]
                                                            .bidpricecontroller
                                                            .text ==
                                                        "0") {
                                                  addIpo[index].requriedprice =
                                                      0;
                                                  ischecked = false;
                                                } else if ((int.parse(addIpo[index]
                                                            .bidpricecontroller
                                                            .text)) >
                                                        double.parse(widget
                                                                .mainstream
                                                                .maxPrice
                                                                .toString())
                                                            .toInt() ||
                                                    (int.parse(addIpo[index]
                                                            .bidpricecontroller
                                                            .text)) <
                                                        double.parse(
                                                                widget.mainstream.minPrice.toString())
                                                            .toInt()) {
                                                  ischecked = false;
                                                }
                                                maxValue = addIpo
                                                    .map((map) =>
                                                        map.requriedprice)
                                                    .reduce((a, b) =>
                                                        a > b ? a : b);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (addIpo[index]
                                  .qualityerrortext
                                  .isNotEmpty) ...[
                                const SizedBox(
                                  height: 6,
                                ),
                                TextWidget.captionText(
                                  theme: false,
                                  text: addIpo[index].qualityerrortext,
                                  color: colors.error,
                                  fw: 3,
                                )
                              ],
                              if (addIpo[index].biderrortext.isNotEmpty) ...[
                                const SizedBox(
                                  height: 6,
                                ),
                                TextWidget.captionText(
                                  theme: false,
                                  text: addIpo[index].biderrortext,
                                  color: colors.error,
                                  fw: 3,
                                )
                              ],
                              Row(
                                children: [
                                  IconButton(
                                      splashRadius: 20,
                                      onPressed: ipo.loading
                                          ? null
                                          : () {
                                              ipo.cutoffprice(
                                                  addIpo[index],
                                                  widget.mainstream);
                                              FocusScope.of(context).unfocus();
                                              maxValue = addIpo
                                                  .map((map) =>
                                                      map.requriedprice)
                                                  .reduce(
                                                      (a, b) => a > b ? a : b);
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
                  addIpo.length == 3
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          width: MediaQuery.of(context).size.width,
                          child: OutlinedButton.icon(
                            onPressed: ipo.loading
                                ? null
                                : () {
                                    addNewItem();
                                  },
                            icon: SvgPicture.asset(
                              assets.add,
                              color: theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlue,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: theme.isDarkMode
                                      ? colors.colorGrey
                                      : colors.colorBlue),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(60))),
                            ),
                            label: Text("Add another bid",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlue,
                                    14,
                                    FontWeight.w600)),
                          ),
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
                      readOnly: ipo.loading ? true : false,
                      controller: upiid.upiid,
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
                          upiid.upiid.text = value;
                          if (upiid.upiid.text.isEmpty) {
                            upierrortext = "* UPI ID cannot be empty";
                            ischecked = false;
                          } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                              .hasMatch(upiid.upiid.text = value)) {
                            upierrortext = 'Invalid UPI ID format';
                            ischecked = false;
                          } else {
                            upierrortext = '';
                          }
                        });
                      },
                    ),
                  ),
                  if (upiid.upiid.text.isEmpty ||
                      !RegExp(r'^[\w.-]+@[\w]+$')
                          .hasMatch(upiid.upiid.text)) ...[
                    const SizedBox(
                      height: 6,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextWidget.captionText(
                        theme: false,
                        text: upierrortext,
                        color: colors.error,
                        fw: 3,
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
                                      for(final bid in addIpo){
                                          if (bid.requriedprice >
                                          ipo.maxUPIAmt) {
                                        warningMessage(
                                                context,
                                                "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ");

                                        ischecked = false;
                                      } else if (bid
                                              .bidpricecontroller
                                              .text
                                              .isEmpty ||
                                          bid
                                                  .bidpricecontroller
                                                  .text ==
                                              "0") {
                                        warningMessage(
                                                context,
                                                bid
                                                            .bidpricecontroller
                                                            .text ==
                                                        "0"
                                                    ? "*Bid Price Value cannot be 0"
                                                    : "*Bid Price Value is required");

                                        ischecked = false;
                                      } else if ((int.parse(bid.bidpricecontroller.text.toString())) >
                                              double.parse(widget.mainstream.maxPrice.toString())
                                                  .toInt() ||
                                          (int.parse(bid.bidpricecontroller.text)) <
                                              double.parse(widget.mainstream.minPrice.toString())
                                                  .toInt()) {
                                        warningMessage(
                                                context,
                                                "Your bid price ranges between ₹${double.parse(widget.mainstream.minPrice!).toInt()}-₹${double.parse(widget.mainstream.maxPrice!).toInt()}");
                                        ischecked = false;
                                      } else if (bid
                                              .qualityController
                                              .text
                                              .isEmpty ||
                                          bid.qualityController.text ==
                                              "0") {
                                        warningMessage(
                                                context,
                                                bid
                                                            .qualityController
                                                            .text ==
                                                        "0"
                                                    ? '* Quantity cannot be 0'
                                                    : '* Quantity cannot be empty');
                                        ischecked = false;
                                      } else if ((int.parse(bid.qualityController.text)) <
                                          int.parse(widget.mainstream.minBidQuantity.toString())
                                              .toInt()) {
                                        warningMessage(
                                                context,
                                                "Minimum Bid quantity is ${widget.mainstream.minBidQuantity.toString()} only ");
                                        ischecked = false;
                                      } else if (upiid.upiid.text.isEmpty) {
                                        warningMessage(
                                                context,
                                                "UPI ID cannot be empty");
                                        ischecked = false;
                                      } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                                          .hasMatch(upiid.upiid.text)) {
                                        ischecked = false;
                                      }
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
                              style: textStyle(const Color(0xff666666), 12,
                                  FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  if (ischecked == false) ...[
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 16, top: 8, bottom: 10),
                      child: Text("You Must Agree To Invest",
                          style:
                              textStyle(colors.darkred, 13, FontWeight.w500)),
                    ),
                  ],
                  const SizedBox(height: 86)
                ],
              ),
              bottomSheet: BottomAppBar(
                  elevation: .14,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(color: colors.darkColorDivider))),
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
                      trailing: SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: ischecked == true
                              ? () {
                                  if (addIpo[addIpo.length - 1].requriedprice >
                                      ipo.maxUPIAmt) {
                                        warningMessage(context,
                                            "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ");

                                    ischecked = false;
                                  } else if (addIpo[addIpo.length - 1]
                                          .bidpricecontroller
                                          .text
                                          .isEmpty ||
                                      addIpo[addIpo.length - 1]
                                              .bidpricecontroller
                                              .text ==
                                          "0") {
                                        warningMessage(
                                            context,
                                            addIpo[addIpo.length - 1]
                                                        .bidpricecontroller
                                                        .text ==
                                                    "0"
                                                ? "Bid Price Value cannot be 0"
                                                : "*Bid Price Value is required");
                                  } else if (addIpo[addIpo.length - 1]
                                          .qualityController
                                          .text
                                          .isEmpty ||
                                      addIpo[addIpo.length - 1]
                                              .qualityController
                                              .text ==
                                          "0") {
                                        warningMessage(
                                            context,
                                            addIpo[addIpo.length - 1]
                                                        .qualityController
                                                        .text ==
                                                    "0"
                                                ? '* Quantity cannot be 0'
                                                : '* Quantity cannot be empty');
                                  } else if (upiid.upiid.text.isEmpty) {
                                        warningMessage(context,
                                            '* UPI ID cannot be empty');
                                  } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                                      .hasMatch(upiid.upiid.text)) {
                                        warningMessage(
                                            context, 'Invalid UPI ID format');
                                  } else {
                                    ipoplaceorder(upiid, ipo);
                                  }
                                }
                              : () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
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
                          child: ipo.loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Color(0xff666666)),
                                )
                              : Text("Continue",
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
                      ),
                    ),
                  )

                  // Container(
                  //     width: MediaQuery.of(context).size.width,
                  //     height: 55,
                  //     decoration: BoxDecoration(
                  //         color: colors.colorWhite,
                  //         border: Border(
                  //             top: BorderSide(color: colors.colorDivider))),
                  //     child: Center(
                  //         child: Text(
                  //       "! MARKET IS CLOSED",
                  //       style: textStyle(
                  //           colors.colorBlack, 16, FontWeight.w600),
                  //     )),
                  //   )
                  ));
        },
      ),
    );
  }

  ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    MenuData menudata = MenuData(
      flow: "now",
      type: widget.mainstream.type.toString(),
      symbol: widget.mainstream.symbol.toString(),
      category: ipo.ipoCategoryvalue == "Individual" || ipo.ipoCategoryvalue == "HNI"
          ? "IND"
          : ipo.ipoCategoryvalue == "Employee"
              ? "EMP"
              : ipo.ipoCategoryvalue == "Shareholder"
                  ? "SHA"
                  : ipo.ipoCategoryvalue == "Policyholder"
                      ? "POL"
                      : "",
      name: widget.mainstream.name.toString(),
      applicationNumber: '',
      respBid: [BidReference(bidReferenceNumber: '')],
    );
    final String iposupiid = upiid.upiid.text;
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
    await ref.read(ipoProvide).fetchupiidvalidation(
        context, upiid.upiid.text, "343245", menudata, iposbids, iposupiid);
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}
