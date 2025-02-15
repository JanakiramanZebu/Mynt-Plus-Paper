import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/screens/ipo/mainstream_order_screen/orderscreenbottompage.dart';
import '../../../models/ipo_model/ipo_details_model.dart';
import '../../../models/ipo_model/ipo_mainstream_model.dart';
import '../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/ipo_error_widget.dart';
import '../../../sharedWidget/snack_bar.dart';

class ApplyIpoScreen extends StatefulWidget {
  final MainIPO mainstream;
  const ApplyIpoScreen({
    super.key,
    required this.mainstream,
  });

  @override
  State<ApplyIpoScreen> createState() => _ApplyIpoScreenState();
}

class _ApplyIpoScreenState extends State<ApplyIpoScreen> {
  // bool ischecked = true;
  String upierrortext = "Please enter the UPI Id";
  // int required = 0;

  // List<int> stringList = [];
  // int? maxValue;
  String selectedChip = "Individual";
  List<IpoDetails> addIpo = [];
  @override
  void initState() {
    setState(() {
      addNewItem();

      // maxValue = mininv(double.parse(widget.mainstream.minPrice!).toDouble(),
      //         int.parse(widget.mainstream.minBidQuantity!).toInt())
      //     .toInt();
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
        builder: (context, watch, child) {
          final ipo = watch(ipoProvide);
          final theme = watch(themeProvider);
          // final upiid = watch(transcationProvider);
          var chips =
              ipo.ipoCategory.map((e) => e['subCatCode']).toSet().toList();
          // if (selectedChip == null && chips.isNotEmpty) {
          //   selectedChip = chips[0]; // Set first item as default
          // }
          if (ipo.checkForErrorsInSMEPlaceOrder(addIpo)) {
            ipo.setisMainIPOPlaceOrderBtnActiveValue = true;
          }
           ipo.setMainIPOPlaceOrderRequiredMaxPrice = addIpo;

          return Scaffold(
              appBar: AppBar(
                elevation: .2,
                centerTitle: false,
                leadingWidth: 38,
                titleSpacing: 1,
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
                title: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 10),
                    child: Text("${widget.mainstream.name}",
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            15,
                            FontWeight.w600)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: widget.mainstream.key == "SME"
                                    ? theme.isDarkMode
                                        ? colors.colorGrey.withOpacity(.1)
                                        : const Color.fromARGB(
                                            255, 243, 242, 174)
                                    : theme.isDarkMode
                                        ? colors.colorGrey.withOpacity(.1)
                                        : const Color.fromARGB(
                                            255, 251, 215, 148), //(0xffF1F3F8),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text("${widget.mainstream.key}",
                                style: textStyle(const Color(0xff666666), 9,
                                    FontWeight.w500))),
                        const SizedBox(
                          width: 5,
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: theme.isDarkMode
                                    ? const Color(0xffECF8F1).withOpacity(.3)
                                    : const Color(0xffECF8F1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text("Open",
                                style: textStyle(
                                    Color(0xff43A833), 11, FontWeight.w500))),
                      ],
                    ),
                  ),
                ),
              ),
              body: ListView(
                children: [
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: theme.isDarkMode
                  //         ? colors.colorBlack
                  //         : const Color(0xffF1F3F8),
                  //     border: Border(
                  //         bottom: BorderSide(
                  //             color: theme.isDarkMode
                  //                 ? colors.darkColorDivider
                  //                 : Colors.transparent)),
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       // ListTile(
                  //       //   title: Text("${widget.mainstream.name}",
                  //       //       style: textStyle(
                  //       //           theme.isDarkMode
                  //       //               ? colors.colorWhite
                  //       //               : colors.colorBlack,
                  //       //           15,
                  //       //           FontWeight.w600)),
                  //       //   subtitle: Row(
                  //       //     children: [
                  //       //       Container(
                  //       //         padding: const EdgeInsets.symmetric(
                  //       //             horizontal: 6, vertical: 3),
                  //       //         decoration: BoxDecoration(
                  //       //             color: theme.isDarkMode
                  //       //                 ? colors.colorGrey.withOpacity(.1)
                  //       //                 : colors.colorWhite,
                  //       //             borderRadius: BorderRadius.circular(4)),
                  //       //         child: Text("${widget.mainstream.symbol}",
                  //       //             style: textStyle(const Color(0xff666666), 9,
                  //       //                 FontWeight.w500)),
                  //       //       ),
                  //       //       const SizedBox(
                  //       //         width: 8,
                  //       //       ),
                  //       //       Container(
                  //       //         padding: const EdgeInsets.symmetric(
                  //       //             horizontal: 6, vertical: 3),
                  //       //         decoration: BoxDecoration(
                  //       //             color: theme.isDarkMode
                  //       //                 ? colors.colorGrey.withOpacity(.1)
                  //       //                 : colors.colorWhite,
                  //       //             borderRadius: BorderRadius.circular(4)),
                  //       //         child: Text("IPO",
                  //       //             style: textStyle(const Color(0xff666666), 9,
                  //       //                 FontWeight.w500)),
                  //       //       ),
                  //       //     ],
                  //       //   ),
                  //       // ),
                  //       Padding(
                  //         padding: const EdgeInsets.fromLTRB(16.0, 20, 16, 20),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text("Price Range",
                  //                     style: textStyle(const Color(0xff666666),
                  //                         12, FontWeight.w500)),
                  //                 const SizedBox(
                  //                   height: 5,
                  //                 ),
                  //                 Text(
                  //                     "₹${double.parse(widget.mainstream.minPrice!).toInt()}- ₹${double.parse(widget.mainstream.maxPrice!).toInt()}",
                  //                     style: textStyle(
                  //                         theme.isDarkMode
                  //                             ? colors.colorWhite
                  //                             : colors.colorBlack,
                  //                         14,
                  //                         FontWeight.w500)),
                  //                 // Text("Price Range",
                  //                 //     style: textStyle(const Color(0xff666666),
                  //                 //         12, FontWeight.w500)),
                  //               ],
                  //             ),
                  //             Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text("Min.Qty",
                  //                     style: textStyle(const Color(0xff666666),
                  //                         12, FontWeight.w500)),
                  //                 const SizedBox(
                  //                   height: 5,
                  //                 ),
                  //                 Text("${widget.mainstream.minBidQuantity}",
                  //                     style: textStyle(
                  //                         theme.isDarkMode
                  //                             ? colors.colorWhite
                  //                             : colors.colorBlack,
                  //                         14,
                  //                         FontWeight.w500)),
                  //                 // Text("Min.Qty",
                  //                 //     style: textStyle(const Color(0xff666666),
                  //                 //         12, FontWeight.w500)),
                  //               ],
                  //             ),
                  //             Column(
                  //               crossAxisAlignment: CrossAxisAlignment.start,
                  //               children: [
                  //                 Text("IPO Size",
                  //                     style: textStyle(const Color(0xff666666),
                  //                         12, FontWeight.w500)),
                  //                 const SizedBox(
                  //                   height: 5,
                  //                 ),
                  //                 Text(
                  //                     formatInCrore(
                  //                       double.parse(
                  //                               widget.mainstream.issueSize!)
                  //                           .toInt(),
                  //                     ),
                  //                     style: textStyle(
                  //                         theme.isDarkMode
                  //                             ? colors.colorWhite
                  //                             : colors.colorBlack,
                  //                         14,
                  //                         FontWeight.w500)),
                  //               ],
                  //             )
                  //           ],
                  //         ),
                  //       )

                  //     ],
                  //   ),
                  // ),
                  Container(
                    color: Color(0xFFFCEFD4),
                    height: 30,
                    child: Center(
                      child: Text(
                          "IPO window is open from ${widget.mainstream.dailyStartTime} till ${widget.mainstream.dailyEndTime} on trading days.",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              10,
                              FontWeight.w600)),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12), // Added `const` for better performance
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: chips.map((chip) {
                            return ChoiceChip(
                              label: Text(
                                chip,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: theme.isDarkMode
                                      ? Color(selectedChip == chip
                                          ? 0xff000000
                                          : 0xffffffff)
                                      : Color(selectedChip == chip
                                          ? 0xffffffff
                                          : 0xff000000),
                                ),
                              ),
                              shape: const StadiumBorder(),
                              backgroundColor: theme.isDarkMode
                                  ? selectedChip == chip
                                      ? colors.colorbluegrey
                                      : const Color(0xffB5C0CF).withOpacity(.15)
                                  : selectedChip == chip
                                      ? const Color(0xff000000)
                                      : const Color(0xffF1F3F8),
                              selectedColor: theme.isDarkMode
                                  ? const Color(0xffF1F3F8)
                                  : const Color(
                                      0xff000000), // Color when selected
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 2.0),
                              side: BorderSide.none,
                              selected:
                                  selectedChip == chip, // Mark selected chip
                              onSelected: (isSelected) async {
                                setState(() {
                                  selectedChip =
                                      isSelected ? chip : selectedChip;

                                  if (ipo
                                      .checkForErrorsInSMEPlaceOrder(addIpo)) {
                                    ipo.setisMainIPOPlaceOrderBtnActiveValue =
                                        true;
                                  } else {
                                    ipo.setisMainIPOPlaceOrderBtnActiveValue =
                                        false;
                                  }
                                });

                                ipo.chngCategoryType("$chip");
                                await ipo.categoryOnChange(
                                    addIpo,
                                    ipo.maxUPIAmt,
                                    ipo.isMainIPOPlaceOrderBtnActive,
                                    selectedChip);
                              },
                            );
                          }).toList(),
                        ),
                        // const SizedBox(height: 10),
                        // Text(
                        //   "Selected: ${selectedChip ?? 'None'}",
                        //   style: const TextStyle(
                        //       fontSize: 16, fontWeight: FontWeight.bold),
                        // ),
                      ],
                    ),
                  ),

                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   margin: const EdgeInsets.symmetric(
                  //     horizontal: 16,
                  //   ),
                  //   child: DropdownButtonHideUnderline(
                  //       child: DropdownButton2(
                  //     dropdownStyleData: DropdownStyleData(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: !theme.isDarkMode
                  //                 ? colors.colorWhite
                  //                 : const Color.fromARGB(255, 16, 16, 16))),
                  //     menuItemStyleData: MenuItemStyleData(
                  //         customHeights:
                  //             ipo.getCustomItemsHeight(ipo.ipoCategory)),
                  //     buttonStyleData: ButtonStyleData(
                  //         height: 40,
                  //         width: 124,
                  //         decoration: BoxDecoration(
                  //             color: theme.isDarkMode
                  //                 ? colors.darkGrey
                  //                 : const Color(0xffF1F3F8),
                  //             borderRadius:
                  //                 const BorderRadius.all(Radius.circular(32)))),
                  //     isExpanded: true,
                  //     style: textStyle(
                  //         theme.isDarkMode
                  //             ? colors.colorWhite
                  //             : colors.colorBlack,
                  //         13,
                  //         FontWeight.w500),
                  //     hint: Text(ipo.ipoCategoryvalue,
                  //         style: textStyle(
                  //             theme.isDarkMode
                  //                 ? colors.colorWhite
                  //                 : colors.colorBlack,
                  //             13,
                  //             FontWeight.w500)),
                  //     items: ipo.loading
                  //         ? null
                  //         : ipo.addDividerSubCategory(ipo.ipoCategory),
                  //     value: ipo.ipoCategoryvalue,
                  //     onChanged: (value) async {
                  //       ipo.chngCategoryType("$value");
                  //       ipo.categoryOnChange(addIpo[addIpo.length - 1],
                  //           ipo.maxUPIAmt, ipo.isMainIPOPlaceOrderBtnActive);
                  //     },
                  //   )),
                  // ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addIpo.length,
                    itemBuilder: (context, index) {
                      // for (var i = 0; i < addIpo.length; i++) {
                      //   stringList.add(addIpo[index].requriedprice);
                      // }
                      ipo.setMainIPOPlaceOrderRequiredMaxPrice = addIpo;
                      // maxValue = stringList.reduce((curr, next) =>
                      //     int.parse(curr.toString()) >
                      //             double.parse(next.toString())
                      //         ? curr
                      //         : next);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 0,
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
                                                              ipo.isMainIPOPlaceOrderBtnActive,
                                                              ipo,
                                                              widget.mainstream,selectedChip);
                                                          setState(() {
                                                            ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                                                addIpo;
                                                            // maxValue = addIpo
                                                            //     .map((map) => map
                                                            //         .requriedprice)
                                                            //     .reduce((a,
                                                            //             b) =>
                                                            //         a > b
                                                            //             ? a
                                                            //             : b);
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
                                                                  ipo
                                                                      .isMainIPOPlaceOrderBtnActive,
                                                                  ipo,
                                                                  widget
                                                                      .mainstream,selectedChip);
                                                              setState(() {
                                                                ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                                                    addIpo;
                                                                // maxValue = addIpo
                                                                //     .map((map) => map
                                                                //         .requriedprice)
                                                                //     .reduce((a,
                                                                //             b) =>
                                                                //         a > b
                                                                //             ? a
                                                                //             : b);
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
                                                  ipo.isMainIPOPlaceOrderBtnActive,
                                                  ipo,
                                                  value,
                                                  widget.mainstream,selectedChip);
                                              setState(() {
                                                // if (addIpo[index]
                                                //         .qualityController
                                                //         .text
                                                //         .isEmpty ||
                                                //     addIpo[index]
                                                //             .qualityController
                                                //             .text ==
                                                //         "0") {
                                                //   ischecked = false;
                                                // } else if ((int.parse(
                                                //         addIpo[index]
                                                //             .qualityController
                                                //             .text)) <
                                                //     int.parse(widget.mainstream
                                                //             .minBidQuantity
                                                //             .toString())
                                                //         .toInt()) {
                                                //   addIpo[index]
                                                //           .qualityerrortext =
                                                //       "Minimum Bid quantity is ${widget.mainstream.minBidQuantity.toString()} only ";
                                                //   ischecked = false;
                                                // }

                                                // maxValue = addIpo
                                                //     .map((map) =>
                                                //         map.requriedprice)
                                                //     .reduce((a, b) =>
                                                //         a > b ? a : b);
                                                ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                                    addIpo;
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
                                        Row(
                                          children: [
                                            Text("Bid Price ",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    14,
                                                    FontWeight.w600)),
                                            Text(
                                                "(${double.parse(widget.mainstream.minPrice!).toInt()}- ${double.parse(widget.mainstream.maxPrice!).toInt()})",
                                                style: textStyle(
                                                    theme.isDarkMode
                                                        ? colors.colorWhite
                                                        : colors.colorBlack,
                                                    10,
                                                    FontWeight.w600)),
                                          ],
                                        ),
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
                                                prefixIcon: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.white,
                                                          shape:
                                                              BoxShape.circle),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: SvgPicture.asset(
                                                      assets.rupee,
                                                      fit: BoxFit.values[5],
                                                    ),
                                                  ),
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
                                                  ipo.isMainIPOPlaceOrderBtnActive);
                                              setState(() {
                                                // if (addIpo[index]
                                                //         .bidpricecontroller
                                                //         .text
                                                //         .isEmpty ||
                                                //     addIpo[index]
                                                //             .bidpricecontroller
                                                //             .text ==
                                                //         "0") {
                                                //   addIpo[index].requriedprice =
                                                //       0;
                                                //   ischecked = false;
                                                // } else if ((int.parse(addIpo[index]
                                                //             .bidpricecontroller
                                                //             .text)) >
                                                //         double.parse(widget
                                                //                 .mainstream
                                                //                 .maxPrice
                                                //                 .toString())
                                                //             .toInt() ||
                                                //     (int.parse(addIpo[index]
                                                //             .bidpricecontroller
                                                //             .text)) <
                                                //         double.parse(
                                                //                 widget.mainstream.minPrice.toString())
                                                //             .toInt()) {
                                                //   ischecked = false;
                                                // }
                                                // maxValue = addIpo
                                                //     .map((map) =>
                                                //         map.requriedprice)
                                                //     .reduce((a, b) =>
                                                //         a > b ? a : b);

                                                ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                                    addIpo;
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 55, vertical: 20)),
                                  InkWell(
                                      onTap: ipo.loading
                                          ? null
                                          : () {
                                              ipo.cutoffprice(addIpo[index],
                                                  widget.mainstream);
                                              FocusScope.of(context).unfocus();
                                              ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                                  addIpo;
                                              // maxValue = addIpo
                                              //     .map((map) =>
                                              //         map.requriedprice)
                                              //     .reduce(
                                              //         (a, b) => a > b ? a : b);
                                            },
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            theme.isDarkMode
                                                ? addIpo[index].isChecked
                                                    ? assets.darkCheckedboxIcon
                                                    : assets.darkCheckboxIcon
                                                : addIpo[index].isChecked
                                                    ? assets.checkedbox
                                                    : assets.checkbox,
                                          ),
                                          const SizedBox(
                                              width:
                                                  8), // Space between icon and text
                                          Text(
                                            "Cut-off price",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w600),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                              if (addIpo[index]
                                  .qualityerrortext
                                  .isNotEmpty) ...[
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
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Padding(
                              //         padding: EdgeInsets.symmetric(
                              //             horizontal: 55, vertical: 20)),
                              //     InkWell(
                              //         onTap: ipo.loading
                              //             ? null
                              //             : () {
                              //                 ipo.cutoffprice(addIpo[index],
                              //                     widget.mainstream);
                              //                 FocusScope.of(context).unfocus();
                              //                 ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                              //                     addIpo;
                              //                 // maxValue = addIpo
                              //                 //     .map((map) =>
                              //                 //         map.requriedprice)
                              //                 //     .reduce(
                              //                 //         (a, b) => a > b ? a : b);
                              //               },
                              //         child: Row(
                              //           children: [
                              //             SvgPicture.asset(
                              //               theme.isDarkMode
                              //                   ? addIpo[index].isChecked
                              //                       ? assets.darkCheckedboxIcon
                              //                       : assets.darkCheckboxIcon
                              //                   : addIpo[index].isChecked
                              //                       ? assets.checkedbox
                              //                       : assets.checkbox,
                              //             ),
                              //             const SizedBox(
                              //                 width:
                              //                     8), // Space between icon and text
                              //             Text(
                              //               "Cut-off price",
                              //               style: textStyle(
                              //                   const Color(0xff666666),
                              //                   13,
                              //                   FontWeight.w600),
                              //             ),
                              //           ],
                              //         ))
                              //   ],
                              // ),
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
                                    ipo.categoryOnChange(
                                    addIpo,
                                    ipo.maxUPIAmt,
                                    ipo.isMainIPOPlaceOrderBtnActive,
                                    selectedChip);
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
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 16),
                  //   child: Text("UPI ID (Virtual payment adress)",
                  //       style: textStyle(
                  //           theme.isDarkMode
                  //               ? colors.colorWhite
                  //               : colors.colorBlack,
                  //           14,
                  //           FontWeight.w600)),
                  // ),
                  // const SizedBox(height: 10),
                  // Container(
                  //   margin: const EdgeInsets.symmetric(horizontal: 16),
                  //   height: 44,
                  //   child: TextFormField(
                  //     readOnly: ipo.loading ? true : false,
                  //     controller: upiid.upiid,
                  //     style: textStyle(
                  //         theme.isDarkMode
                  //             ? colors.colorWhite
                  //             : colors.colorBlack,
                  //         14,
                  //         FontWeight.w600),
                  //     decoration: InputDecoration(
                  //       fillColor: theme.isDarkMode
                  //           ? colors.darkGrey
                  //           : const Color(0xffF1F3F8),
                  //       filled: true,
                  //       enabledBorder: OutlineInputBorder(
                  //           borderSide: BorderSide.none,
                  //           borderRadius: BorderRadius.circular(30)),
                  //       disabledBorder: InputBorder.none,
                  //       focusedBorder: OutlineInputBorder(
                  //           borderSide: BorderSide.none,
                  //           borderRadius: BorderRadius.circular(30)),
                  //       contentPadding: const EdgeInsets.all(13),
                  //       border: OutlineInputBorder(
                  //           borderSide: BorderSide.none,
                  //           borderRadius: BorderRadius.circular(30)),
                  //     ),
                  //     onChanged: (value) {
                  //       setState(() {
                  //         upiid.upiid.text = value;
                  //         if (upiid.upiid.text.isEmpty) {
                  //           upierrortext = "* UPI ID cannot be empty";
                  //           ipo.setisMainIPOPlaceOrderBtnActiveValue = false;
                  //         } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                  //             .hasMatch(upiid.upiid.text = value)) {
                  //           upierrortext = 'Invalid UPI ID format';
                  //           ipo.setisMainIPOPlaceOrderBtnActiveValue = false;
                  //         } else {
                  //           upierrortext = '';
                  //           ipo.setisMainIPOPlaceOrderBtnActiveValue = true;
                  //         }
                  //       });
                  //     },
                  //   ),
                  // ),
                  // if (upiid.upiid.text.isEmpty ||
                  //     !RegExp(r'^[\w.-]+@[\w]+$')
                  //         .hasMatch(upiid.upiid.text)) ...[
                  //   const SizedBox(
                  //     height: 6,
                  //   ),
                  //   Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 16),
                  //     child: IpoErrorBadge(
                  //       errorName: upierrortext,
                  //     ),
                  //   )
                  // ],
                  // const SizedBox(height: 20),

                  // Padding(
                  //   padding: const EdgeInsets.only(right: 12),
                  //   child: Row(
                  //     children: [
                  //       IconButton(
                  //           splashRadius: 20,
                  //           onPressed: ipo.loading
                  //               ? null
                  //               : () {
                  //                   setState(() {
                  //                     // ischecked = !ischecked;
                  //                     if (ipo.checkForErrorsInSMEPlaceOrder(
                  //                         addIpo)) {
                  //                       ipo.setisMainIPOPlaceOrderBtnActiveValue =
                  //                           true;
                  //                     } else {
                  //                       ScaffoldMessenger.of(context)
                  //                           .showSnackBar(warningMessage(
                  //                               context,
                  //                               "can't able place Order with current selected combination of Bids"));
                  //                       ischecked = false;
                  //                       ipo.setisMainIPOPlaceOrderBtnActiveValue =
                  //                           false;
                  //                     }

                  //                     // for(final bid in addIpo){
                  //                     //     if (bid.requriedprice >
                  //                     //     ipo.maxUPIAmt) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only "));

                  //                     //   ischecked = false;
                  //                     // } else if (bid
                  //                     //         .bidpricecontroller
                  //                     //         .text
                  //                     //         .isEmpty ||
                  //                     //     bid
                  //                     //             .bidpricecontroller
                  //                     //             .text ==
                  //                     //         "0") {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           bid
                  //                     //                       .bidpricecontroller
                  //                     //                       .text ==
                  //                     //                   "0"
                  //                     //               ? "*Bid Price Value cannot be 0"
                  //                     //               : "*Bid Price Value is required"));

                  //                     //   ischecked = false;
                  //                     // } else if ((int.parse(bid.bidpricecontroller.text.toString())) >
                  //                     //         double.parse(widget.mainstream.maxPrice.toString())
                  //                     //             .toInt() ||
                  //                     //     (int.parse(bid.bidpricecontroller.text)) <
                  //                     //         double.parse(widget.mainstream.minPrice.toString())
                  //                     //             .toInt()) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Your bid price ranges between ₹${double.parse(widget.mainstream.minPrice!).toInt()}-₹${double.parse(widget.mainstream.maxPrice!).toInt()}"));
                  //                     //   ischecked = false;
                  //                     // } else if (bid
                  //                     //         .qualityController
                  //                     //         .text
                  //                     //         .isEmpty ||
                  //                     //     bid.qualityController.text ==
                  //                     //         "0") {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           bid
                  //                     //                       .qualityController
                  //                     //                       .text ==
                  //                     //                   "0"
                  //                     //               ? '* Quantity cannot be 0'
                  //                     //               : '* Quantity cannot be empty'));
                  //                     //   ischecked = false;
                  //                     // } else if ((int.parse(bid.qualityController.text)) <
                  //                     //     int.parse(widget.mainstream.minBidQuantity.toString())
                  //                     //         .toInt()) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Minimum Bid quantity is ${widget.mainstream.minBidQuantity.toString()} only "));
                  //                     //   ischecked = false;
                  //                     // } else if (upiid.upiid.text.isEmpty) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "UPI ID cannot be empty"));
                  //                     //   ischecked = false;
                  //                     // } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                  //                     //     .hasMatch(upiid.upiid.text)) {
                  //                     //   ischecked = false;
                  //                     // }
                  //                     // }
                  //                     // if (addIpo[addIpo.length - 1].requriedprice >
                  //                     //     ipo.maxUPIAmt) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only "));

                  //                     //   ischecked = false;
                  //                     // } else if (addIpo[addIpo.length - 1]
                  //                     //         .bidpricecontroller
                  //                     //         .text
                  //                     //         .isEmpty ||
                  //                     //     addIpo[addIpo.length - 1]
                  //                     //             .bidpricecontroller
                  //                     //             .text ==
                  //                     //         "0") {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           addIpo[addIpo.length - 1]
                  //                     //                       .bidpricecontroller
                  //                     //                       .text ==
                  //                     //                   "0"
                  //                     //               ? "*Bid Price Value cannot be 0"
                  //                     //               : "*Bid Price Value is required"));

                  //                     //   ischecked = false;
                  //                     // } else if ((int.parse(addIpo[addIpo.length - 1].bidpricecontroller.text.toString())) >
                  //                     //         double.parse(widget.mainstream.maxPrice.toString())
                  //                     //             .toInt() ||
                  //                     //     (int.parse(addIpo[addIpo.length - 1].bidpricecontroller.text)) <
                  //                     //         double.parse(widget.mainstream.minPrice.toString())
                  //                     //             .toInt()) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Your bid price ranges between ₹${double.parse(widget.mainstream.minPrice!).toInt()}-₹${double.parse(widget.mainstream.maxPrice!).toInt()}"));
                  //                     //   ischecked = false;
                  //                     // } else if (addIpo[addIpo.length - 1]
                  //                     //         .qualityController
                  //                     //         .text
                  //                     //         .isEmpty ||
                  //                     //     addIpo[addIpo.length - 1].qualityController.text ==
                  //                     //         "0") {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           addIpo[addIpo.length - 1]
                  //                     //                       .qualityController
                  //                     //                       .text ==
                  //                     //                   "0"
                  //                     //               ? '* Quantity cannot be 0'
                  //                     //               : '* Quantity cannot be empty'));
                  //                     //   ischecked = false;
                  //                     // } else if ((int.parse(addIpo[addIpo.length - 1].qualityController.text)) <
                  //                     //     int.parse(widget.mainstream.minBidQuantity.toString())
                  //                     //         .toInt()) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Minimum Bid quantity is ${widget.mainstream.minBidQuantity.toString()} only "));
                  //                     //   ischecked = false;
                  //                     // } else if (upiid.upiid.text.isEmpty) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "UPI ID cannot be empty"));
                  //                     //   ischecked = false;
                  //                     // } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                  //                     //     .hasMatch(upiid.upiid.text)) {
                  //                     //   ischecked = false;
                  //                     // }
                  //                   });
                  //                 },
                  //           icon: SvgPicture.asset(theme.isDarkMode
                  //               ? ipo.isMainIPOPlaceOrderBtnActive
                  //                   ? assets.darkCheckedboxIcon
                  //                   : assets.darkCheckboxIcon
                  //               : ipo.isMainIPOPlaceOrderBtnActive
                  //                   ? assets.checkedbox
                  //                   : assets.checkbox)),
                  //       const SizedBox(width: 10),
                  //       Expanded(
                  //         child: Text(
                  //             "I hereby undertake that I have read the Red Herring Prospectus and I am eligible bidder as per the applicable provisions of SEBI (Issue of Capital & Disclosure Agreement, 2009) regulations",
                  //             style: textStyle(const Color(0xff666666), 12,
                  //                 FontWeight.w600)),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // if (ipo.isMainIPOPlaceOrderBtnActive == false) ...[
                  //   Padding(
                  //     padding:
                  //         const EdgeInsets.only(left: 16, top: 8, bottom: 10),
                  //     child: Text("You Must Agree To Invest",
                  //         style:
                  //             textStyle(colors.darkred, 13, FontWeight.w500)),
                  //   ),
                  // ],
                  const SizedBox(height: 86)
                ],
              ),
              bottomSheet: BottomAppBar(
                elevation: .14,
                child: ListTile(
                  title: Text("₹ ${ipo.mainIPOPlaceOrderRequiredMaxPrice}",
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
                    onPressed: ipo.isMainIPOPlaceOrderBtnActive
                        ? () {
                            if (addIpo[addIpo.length - 1].requriedprice >
                                ipo.maxUPIAmt) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  warningMessage(context,
                                      "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only "));

                              ipo.setisMainIPOPlaceOrderBtnActiveValue = false;
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
                            }
                            // else if (upiid.upiid.text.isEmpty) {
                            //   ScaffoldMessenger.of(context)
                            //       .showSnackBar(warningMessage(
                            //           context,
                            //           '* UPI ID cannot be empty'));
                            // } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                            //     .hasMatch(upiid.upiid.text)) {
                            //   ScaffoldMessenger.of(context)
                            //       .showSnackBar(warningMessage(
                            //           context,
                            //           'Invalid UPI ID format'));
                            // }
                            else {
                              if (ipo.checkForErrorsInSMEPlaceOrder(addIpo)) {
                                ipo.setisMainIPOPlaceOrderBtnActiveValue = true;
                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  isDismissible: true,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(16))),
                                  context: context,
                                  builder: (context) => Container(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom,
                                    ),
                                    child: OrderScreenbottomPage(
                                      mainstream: widget.mainstream,
                                      addIpo: addIpo,
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    warningMessage(context,
                                        "can't able place Order with current selected combination of Bids"));
                                // ischecked = false;
                                ipo.setisMainIPOPlaceOrderBtnActiveValue =
                                    false;
                              }

                              // ipoplaceorder(upiid, ipo);
                              // _showBottomSheet(context, theme, ipo, upiid);
                            }
                          }
                        : () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(145, 37),
                      backgroundColor: !theme.isDarkMode
                          ? ipo.isMainIPOPlaceOrderBtnActive == false
                              ? const Color(0xfff5f5f5)
                              : colors.colorBlack
                          : ipo.isMainIPOPlaceOrderBtnActive == false
                              ? colors.darkGrey
                              : colors.colorbluegrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text("Continue",
                        style: textStyle(
                            !theme.isDarkMode
                                ? ipo.isMainIPOPlaceOrderBtnActive == false
                                    ? const Color(0xff999999)
                                    : colors.colorWhite
                                : ipo.isMainIPOPlaceOrderBtnActive == false
                                    ? colors.darkGrey
                                    : colors.colorBlack,
                            14,
                            FontWeight.w500)),
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
              );
        },
      ),
    );
  }

  // void _showBottomSheet(BuildContext context, theme, ipo, upiid) {
  //   TextEditingController _controller = TextEditingController();
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // IMPORTANT: Allows full-screen input handling
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           bottom: MediaQuery.of(context)
  //               .viewInsets
  //               .bottom, // Avoids keyboard overlap
  //         ),
  //         child: SingleChildScrollView(
  //           // Ensures proper scrolling when keyboard appears
  //           child: Container(
  //             padding: EdgeInsets.all(16),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   "Enter Your Text",
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //                 SizedBox(height: 10),

  //                 /// Text Input Field
  //                 TextField(
  //                   controller: _controller,
  //                   autofocus: true, // Ensures keyboard opens automatically
  //                   decoration: InputDecoration(
  //                     border: OutlineInputBorder(),
  //                     hintText: "Type something...",
  //                   ),
  //                 ),
  //                 SizedBox(height: 20),

  //                 /// Buttons Row (Cancel & Submit)
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       style: ElevatedButton.styleFrom(
  //                           backgroundColor: Colors.red),
  //                       child: Text("Cancel"),
  //                     ),
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         print("User Input: ${_controller.text}");
  //                         Navigator.pop(context);
  //                       },
  //                       child: Text("Submit"),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showBottomSheet(BuildContext context, ThemesProvider theme,
  //     IPOProvider ipo, TranctionProvider upiid) {
  //   TextEditingController _controller = TextEditingController();
  //   print(ipo.loading);
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allows proper keyboard handling
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: EdgeInsets.only(
  //           left: 0,
  //           right: 0,
  //           top: 16,
  //           bottom: MediaQuery.of(context).viewInsets.bottom + 16,
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.only(left: 16),
  //               // padding: null,
  //               child: Text("UPI ID (Virtual payment adress)",
  //                   style: textStyle(
  //                       theme.isDarkMode
  //                           ? colors.colorWhite
  //                           : colors.colorBlack,
  //                       14,
  //                       FontWeight.w600)),
  //             ),
  //             const SizedBox(
  //               height: 10,
  //             ),
  //             Container(
  //               margin: const EdgeInsets.symmetric(horizontal: 16),
  //               height: 44,
  //               child: TextFormField(
  //                 readOnly: ipo.loading ? true : false,
  //                 controller: upiid.upiid,
  //                 style: textStyle(
  //                     theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
  //                     14,
  //                     FontWeight.w600),
  //                 decoration: InputDecoration(
  //                   fillColor: theme.isDarkMode
  //                       ? colors.darkGrey
  //                       : const Color(0xffF1F3F8),
  //                   filled: true,
  //                   enabledBorder: OutlineInputBorder(
  //                       borderSide: BorderSide.none,
  //                       borderRadius: BorderRadius.circular(30)),
  //                   disabledBorder: InputBorder.none,
  //                   focusedBorder: OutlineInputBorder(
  //                       borderSide: BorderSide.none,
  //                       borderRadius: BorderRadius.circular(30)),
  //                   contentPadding: const EdgeInsets.all(13),
  //                   border: OutlineInputBorder(
  //                       borderSide: BorderSide.none,
  //                       borderRadius: BorderRadius.circular(30)),
  //                 ),
  //                 onChanged: (value) {
  //                   setState(() {
  //                     upiid.upiid.text = value;
  //                     if (upiid.upiid.text.isEmpty) {
  //                       upierrortext = "* UPI ID cannot be empty";
  //                       ipo.setisMainIPOPlaceOrderBtnActiveValue = false;
  //                     } else if (!RegExp(r'^[\w.-]+@[\w]+$')
  //                         .hasMatch(upiid.upiid.text = value)) {
  //                       upierrortext = 'Invalid UPI ID format';
  //                       ipo.setisMainIPOPlaceOrderBtnActiveValue = false;
  //                     } else {
  //                       upierrortext = '';
  //                       ipo.setisMainIPOPlaceOrderBtnActiveValue = true;
  //                     }
  //                   });
  //                 },
  //               ),
  //             ),
  //             if (upiid.upiid.text.isEmpty ||
  //                 !RegExp(r'^[\w.-]+@[\w]+$').hasMatch(upiid.upiid.text)) ...[
  //               const SizedBox(
  //                 height: 6,
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16),
  //                 child: IpoErrorBadge(
  //                   errorName: upierrortext,
  //                 ),
  //               ),
  //             ],

  //             const SizedBox(height: 20),

  //             Padding(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
  //               child: Row(
  //                 children: [
  //                   IconButton(
  //                       splashRadius: 20,
  //                       onPressed: ipo.loading
  //                           ? null
  //                           : () {
  //                               setState(() {
  //                                 // ischecked = !ischecked;
  //                                 if (ipo
  //                                     .checkForErrorsInSMEPlaceOrder(addIpo)) {
  //                                   ipo.setisMainIPOPlaceOrderBtnActiveValue =
  //                                       true;
  //                                 } else {
  //                                   ScaffoldMessenger.of(context).showSnackBar(
  //                                       warningMessage(context,
  //                                           "can't able place Order with current selected combination of Bids"));
  //                                   ischecked = false;
  //                                   ipo.setisMainIPOPlaceOrderBtnActiveValue =
  //                                       false;
  //                                 }
  //                               });
  //                             },
  //                       icon: SvgPicture.asset(theme.isDarkMode
  //                           ? ipo.isMainIPOPlaceOrderBtnActive
  //                               ? assets.darkCheckedboxIcon
  //                               : assets.darkCheckboxIcon
  //                           : ipo.isMainIPOPlaceOrderBtnActive
  //                               ? assets.checkedbox
  //                               : assets.checkbox)),
  //                   const SizedBox(width: 10),
  //                   const Expanded(
  //                     child: Text(
  //                       "I hereby undertake that I have read the Red Herring Prospectus and I am eligible bidder as per the applicable provisions of SEBI (Issue of Capital & Disclosure Agreement, 2009) regulations",
  //                       style: TextStyle(
  //                           color: Color(0xff666666),
  //                           fontSize: 13,
  //                           fontWeight: FontWeight.w600,
  //                           height: 1.3),
  //                       textAlign: TextAlign.justify,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),

  //             const SizedBox(height: 20),

  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                   minimumSize: const Size(double.infinity, 35),
  //                   elevation: 0,
  //                   backgroundColor: !theme.isDarkMode
  //                       ? ipo.isMainIPOPlaceOrderBtnActive == false
  //                           ? const Color(0xfff5f5f5)
  //                           : colors.colorBlack
  //                       : ipo.isMainIPOPlaceOrderBtnActive == false
  //                           ? colors.darkGrey
  //                           : colors.colorbluegrey,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(32),
  //                   ),
  //                 ),
  //                 onPressed: () {
  //                   if (upiid.upiid.text.isEmpty) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                         warningMessage(context, '* UPI ID cannot be empty'));
  //                   } else if (!RegExp(r'^[\w.-]+@[\w]+$')
  //                       .hasMatch(upiid.upiid.text)) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                         warningMessage(context, 'Invalid UPI ID format'));
  //                   } else {
  //                     ipoplaceorder(upiid, ipo);
  //                   }
  //                 },
  //                 child: ipo.loading
  //                     ? const SizedBox(
  //                         width: 18,
  //                         height: 20,
  //                         child: CircularProgressIndicator(
  //                             strokeWidth: 2, color: Color(0xff666666)),
  //                       )
  //                     : Text("Apply",
  //                         style: textStyle(
  //                             !theme.isDarkMode
  //                                 ? ipo.isMainIPOPlaceOrderBtnActive == false
  //                                     ? const Color(0xff999999)
  //                                     : colors.colorWhite
  //                                 : ipo.isMainIPOPlaceOrderBtnActive == false
  //                                     ? colors.darkGrey
  //                                     : colors.colorBlack,
  //                             14,
  //                             FontWeight.w500)),
  //               ),
  //             ),

  //             // /// Buttons

  //             // /// Slider (Shows when OK button is clicked)
  //             // if (_showSlider)
  //             //   Column(
  //             //     children: [
  //             //       SizedBox(height: 10),
  //             //       Text(
  //             //           "Adjust Value: ${_sliderValue.toStringAsFixed(2)}"),
  //             //       Slider(
  //             //         value: _sliderValue,
  //             //         min: 0,
  //             //         max: 1,
  //             //         divisions: 10,
  //             //         label: _sliderValue.toStringAsFixed(2),
  //             //         onChanged: (newValue) {
  //             //           setState(() {
  //             //             _sliderValue = newValue;
  //             //           });
  //             //         },
  //             //       ),
  //             //     ],
  //             //   ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showBottomSheet(BuildContext context, theme, ipo, upiid) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // Allows full-screen bottom sheet
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return DraggableScrollableSheet(
  //         expand: false,
  //         initialChildSize: 0.6, // Start at 40% of screen height
  //         minChildSize: 0.2,
  //         maxChildSize: 0.8, // Can be dragged up to 80%
  //         builder: (context, scrollController) {
  //           return Container(
  //             padding: EdgeInsets.symmetric(vertical: 20),
  //             child: ListView(
  //               controller: scrollController,
  //               children: [
  //                 Column(children: [
  //                   Column(
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets.only(left: 16),
  //                         // padding: null,
  //                         child: Text("UPI ID (Virtual payment adress)",
  //                             style: textStyle(
  //                                 theme.isDarkMode
  //                                     ? colors.colorWhite
  //                                     : colors.colorBlack,
  //                                 14,
  //                                 FontWeight.w600)),
  //                       ),
  //                       SizedBox(
  //                         height: 10,
  //                       ),
  //                       Container(
  //                         margin: const EdgeInsets.symmetric(horizontal: 16),
  //                         height: 44,
  //                         child: TextFormField(
  //                           readOnly: ipo.loading ? true : false,
  //                           controller: upiid.upiid,
  //                           style: textStyle(
  //                               theme.isDarkMode
  //                                   ? colors.colorWhite
  //                                   : colors.colorBlack,
  //                               14,
  //                               FontWeight.w600),
  //                           decoration: InputDecoration(
  //                             fillColor: theme.isDarkMode
  //                                 ? colors.darkGrey
  //                                 : const Color(0xffF1F3F8),
  //                             filled: true,
  //                             enabledBorder: OutlineInputBorder(
  //                                 borderSide: BorderSide.none,
  //                                 borderRadius: BorderRadius.circular(30)),
  //                             disabledBorder: InputBorder.none,
  //                             focusedBorder: OutlineInputBorder(
  //                                 borderSide: BorderSide.none,
  //                                 borderRadius: BorderRadius.circular(30)),
  //                             contentPadding: const EdgeInsets.all(13),
  //                             border: OutlineInputBorder(
  //                                 borderSide: BorderSide.none,
  //                                 borderRadius: BorderRadius.circular(30)),
  //                           ),
  //                           onChanged: (value) {
  //                             setState(() {
  //                               upiid.upiid.text = value;
  //                               if (upiid.upiid.text.isEmpty) {
  //                                 upierrortext = "* UPI ID cannot be empty";
  //                                 ipo.setisMainIPOPlaceOrderBtnActiveValue =
  //                                     false;
  //                               } else if (!RegExp(r'^[\w.-]+@[\w]+$')
  //                                   .hasMatch(upiid.upiid.text = value)) {
  //                                 upierrortext = 'Invalid UPI ID format';
  //                                 ipo.setisMainIPOPlaceOrderBtnActiveValue =
  //                                     false;
  //                               } else {
  //                                 upierrortext = '';
  //                                 ipo.setisMainIPOPlaceOrderBtnActiveValue =
  //                                     true;
  //                               }
  //                             });
  //                           },
  //                         ),
  //                       ),
  //                       if (upiid.upiid.text.isEmpty ||
  //                           !RegExp(r'^[\w.-]+@[\w]+$')
  //                               .hasMatch(upiid.upiid.text)) ...[
  //                         const SizedBox(
  //                           height: 6,
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.symmetric(horizontal: 16),
  //                           child: IpoErrorBadge(
  //                             errorName: upierrortext,
  //                           ),
  //                         ),
  //                       ],

  //                     ],
  //                   ),
  //                   ElevatedButton(onPressed: () {}, child: Text("text"))
  //                 ]),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    MenuData menudata = MenuData(
      flow: "now",
      type: widget.mainstream.type.toString(),
      symbol: widget.mainstream.symbol.toString(),
      category:
          ipo.ipoCategoryvalue == "Individual" || ipo.ipoCategoryvalue == "HNI"
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
    await context.read(ipoProvide).fetchupiidvalidation(
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
