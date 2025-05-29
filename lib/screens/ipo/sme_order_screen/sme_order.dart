// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/screens/ipo/mainstream_order_screen/orderscreenbottompage.dart';
import '../../../models/ipo_model/ipo_details_model.dart';
import '../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../models/ipo_model/ipo_sme_model.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/ipo_error_widget.dart';
import '../../../sharedWidget/snack_bar.dart';

class SMEApplyIpoScreen extends ConsumerStatefulWidget {
  final SMEIPO smeipo;
  const SMEApplyIpoScreen({
    super.key,
    required this.smeipo,
  });

  @override
  ConsumerState<SMEApplyIpoScreen> createState() => _SMEApplyIpoScreenState();
}

class _SMEApplyIpoScreenState extends ConsumerState<SMEApplyIpoScreen> {
  // bool ischecked = false;
  String upierrortext = "";

  // List<int> requriedpriceList = [];
  // int? maxValue;
  String selectedChip = "Individual";
  List<IpoDetails> addIpo = [];
  @override
  void initState() {
    setState(() {
      addNewItem();
      // maxValue = mininv(double.parse(widget.smeipo.minPrice!).toDouble(),
      //         int.parse(widget.smeipo.minBidQuantity!).toInt())
      //     .toInt();
    });
    super.initState();
  }

  void addNewItem() {
    setState(() {
      addIpo.add(IpoDetails(
          qualitytext: "${widget.smeipo.lotSize}",
          bidprice: "${double.parse(widget.smeipo.minPrice!).toInt()}",
          lotsize: int.parse("${widget.smeipo.lotSize}"),
          requriedprice: mininv(
                  double.parse(widget.smeipo.minPrice!).toDouble(),
                  int.parse(widget.smeipo.minBidQuantity!).toInt())
              .toInt(),
          isChecked: false));
      // ref.read(ipoProvide).viewupiid.text.isEmpty
      //     ? upierrortext = "Please enter the UPI ID"
      //     : upierrortext = "";
    });
  }

  void removeItem(int index) {
    setState(() {
      addIpo.removeAt(index);
    });
  }

  // void printValues() {
  //   for (int i = 0; i < addIpo.length; i++) {
  //     print(
  //         "Text: ${addIpo[i].qualityController.text} Checkbox: ${addIpo[i].isChecked}, requried:${addIpo[i].requriedprice},bidprice:${addIpo[i].bidpricecontroller.text} value}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer(
        builder: (context, ref, child) {
          final ipo = ref.watch(ipoProvide);
          final upiid = ref.watch(transcationProvider);
          final theme = ref.watch(themeProvider);
          var chips =
              ipo.ipoCategory.map((e) => e['subCatCode']).toSet().toList();
          // selectedChip = chips.isNotEmpty ? chips[0] : null;
          // if (selectedChip == null && chips.isNotEmpty) {
          //   selectedChip = chips[0]; // Set first item as default
          // }
          if (ipo.checkForErrorsInSMEPlaceOrder(addIpo)) {
            ipo.setisSMEPlaceOrderBtnActiveValue = true;
          }
          ipo.setsmePlaceOrderRequiredMaxPrice = addIpo;

          return Scaffold(
              appBar: AppBar(
                elevation: .2,
                centerTitle: false,
                // leadingWidth: 40,
                titleSpacing: -8,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: theme.isDarkMode
                            ? const Color(0xffBDBDBD)
                            : colors.colorGrey,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                backgroundColor:
                    theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                shadowColor: const Color(0xffECEFF3),
                title: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Text(
  widget.smeipo.name!
     ,
  style: textStyle(
      theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
      16,
      FontWeight.w600),
  softWrap: true,
  overflow: TextOverflow.ellipsis
),

                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                                color: widget.smeipo.key == "SME"
                                    ? theme.isDarkMode
                                        ? colors.colorGrey.withOpacity(.3)
                                        : const Color.fromARGB(
                                            255, 243, 242, 174)
                                    : theme.isDarkMode
                                        ? colors.colorGrey.withOpacity(.1)
                                        : const Color.fromARGB(255, 251, 215,
                                            148), //(0xffF1F3F8),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text("${widget.smeipo.key}",
                                style: textStyle(const Color(0xff666666), 10,
                                    FontWeight.w500))),
                      )
                    ],
                  ),
                ),
              ),
              body: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
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
                  //       //   title: Text("${widget.smeipo.name}",
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
                  //       //         child: Text("${widget.smeipo.symbol}",
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
                  //                     "₹${double.parse(widget.smeipo.minPrice!).toInt()}- ₹${double.parse(widget.smeipo.maxPrice!).toInt()}",
                  //                     style: textStyle(
                  //                         theme.isDarkMode
                  //                             ? colors.colorWhite
                  //                             : colors.colorBlack,
                  //                         15,
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
                  //                 Text("${widget.smeipo.minBidQuantity}",
                  //                     style: textStyle(
                  //                         theme.isDarkMode
                  //                             ? colors.colorWhite
                  //                             : colors.colorBlack,
                  //                         15,
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
                  //                         double.parse(widget.smeipo.issueSize!)
                  //                             .toInt()),
                  //                     style: textStyle(
                  //                         theme.isDarkMode
                  //                             ? colors.colorWhite
                  //                             : colors.colorBlack,
                  //                         15,
                  //                         FontWeight.w500)),
                  //                 // Text("IPO Size",
                  //                 //     style: textStyle(const Color(0xff666666),
                  //                 //         12, FontWeight.w500)),
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
                          "IPO window is open from ${widget.smeipo.dailyStartTime} till ${widget.smeipo.dailyEndTime} on trading days.",
                          style: textStyle(
                              theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              10,
                              FontWeight.w600)),
                    ),
                  ),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 16, vertical: 10),
                  //   child: Text('Category',
                  //       style: textStyle(
                  //           theme.isDarkMode
                  //               ? colors.colorWhite
                  //               : colors.colorBlack,
                  //           14,
                  //           FontWeight.w600)),
                  // ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  selectedChip = isSelected
                                      ? chip
                                      : selectedChip; // Update selected chip

                                  if (ipo
                                      .checkForErrorsInSMEPlaceOrder(addIpo)) {
                                    ipo.setisSMEPlaceOrderBtnActiveValue = true;
                                  } else {
                                    ipo.setisSMEPlaceOrderBtnActiveValue =
                                        false;
                                  }
                                });
                                ipo.chngCategoryType("$chip");
                                await ipo.categoryOnChange(
                                    addIpo,
                                    ipo.maxUPIAmt,
                                    ipo.isSMEPlaceOrderBtnActive,
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
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
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
                  //     hint: Text(ipo.ipoCategorys,
                  //         style: textStyle(
                  //             colors.colorBlack, 13, FontWeight.w500)),
                  //     items: ipo.loading
                  //         ? null
                  //         : ipo.addDividerSubCategory(
                  //             ipo.ipoCategory.toSet().toList()),
                  //     value: ipo.ipoCategoryvalue,
                  //     onChanged: (value) async {
                  //       ipo.chngCategoryType("$value");
                  //       ipo.categoryOnChange(addIpo[addIpo.length - 1],
                  //           ipo.maxUPIAmt, ipo.isSMEPlaceOrderBtnActive);
                  //     },
                  //   )),
                  // ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addIpo.length,
                    itemBuilder: (context, index) {
                      // for (var i = 0; i < addIpo.length; i++) {
                      //   requriedpriceList.add(addIpo[index].requriedprice);
                      // }
                      ipo.setsmePlaceOrderRequiredMaxPrice = addIpo;
                      // maxValue = requriedpriceList.reduce((curr, next) =>
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
                                            padding: const EdgeInsets.all(0),
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
                                height: 8,
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
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 44,
                                          child: TextFormField(
                                            readOnly:
                                                ipo.loading ? true : false,
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
                                                          ipo.smequalityplusefunction(
                                                              addIpo[index],
                                                              ipo.isSMEPlaceOrderBtnActive,
                                                              widget.smeipo,
                                                              ipo.maxUPIAmt,
                                                              selectedChip);
                                                          setState(() {
                                                            ipo.setsmePlaceOrderRequiredMaxPrice =
                                                                addIpo;
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
                                                              ipo.smequantityminusfunction(
                                                                  addIpo[index],
                                                                  ipo.isSMEPlaceOrderBtnActive,
                                                                  widget.smeipo,
                                                                  ipo.maxUPIAmt,
                                                                  selectedChip);
                                                              setState(() {
                                                                ipo.setsmePlaceOrderRequiredMaxPrice =
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
                                              ipo.smequantityOnchange(
                                                  value,
                                                  addIpo[index],
                                                  widget.smeipo,
                                                  ipo.isSMEPlaceOrderBtnActive,
                                                  ipo.maxUPIAmt,
                                                  selectedChip);
                                              setState(() {
                                                ipo.setsmePlaceOrderRequiredMaxPrice =
                                                    addIpo;
                                                // maxValue = addIpo
                                                //     .map((map) =>
                                                //         map.requriedprice)
                                                //     .reduce((a, b) =>
                                                //         a > b ? a : b);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const SizedBox(height: 8),
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
                                              : addIpo[index].isChecked == true
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
                                                      BorderRadius.circular(
                                                          30)),
                                              disabledBorder: InputBorder.none,
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
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
                                            ipo.smebidpriceOnChange(
                                                value,
                                                addIpo[index],
                                                ipo.isSMEPlaceOrderBtnActive,
                                                widget.smeipo);
                                            setState(() {
                                              // if (addIpo[index]
                                              //         .bidpricecontroller
                                              //         .text
                                              //         .isEmpty ||
                                              //     addIpo[index]
                                              //             .bidpricecontroller
                                              //             .text ==
                                              //         "0") {
                                              //   addIpo[index].requriedprice = 0;
                                              //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                                              // } else if ((int.parse(addIpo[index]
                                              //             .bidpricecontroller
                                              //             .text)) >
                                              //         double.parse(widget.smeipo.maxPrice
                                              //                 .toString())
                                              //             .toInt() ||
                                              //     (int.parse(addIpo[index]
                                              //             .bidpricecontroller
                                              //             .text)) <
                                              //         double.parse(widget
                                              //                 .smeipo.minPrice
                                              //                 .toString())
                                              //             .toInt()) {
                                              //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                                              // }

                                              // maxValue = addIpo
                                              //     .map((map) =>
                                              //         map.requriedprice)
                                              //     .reduce(
                                              //         (a, b) => a > b ? a : b);

                                              ipo.setsmePlaceOrderRequiredMaxPrice =
                                                  addIpo;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ))
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
                                            ipo.smecutoffprice(
                                              addIpo[index],
                                              widget.smeipo,
                                            );
                                            // maxValue = addIpo
                                            //     .map((map) =>
                                            //         map.requriedprice)
                                            //     .reduce(
                                            //         (a, b) => a > b ? a : b);
                                            ipo.setsmePlaceOrderRequiredMaxPrice =
                                                addIpo;
                                            FocusScope.of(context).unfocus();
                                          },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(theme.isDarkMode
                                            ? addIpo[index].isChecked
                                                ? assets.darkCheckedboxIcon
                                                : assets.darkCheckboxIcon
                                            : addIpo[index].isChecked
                                                ? assets.checkedbox
                                                : assets.checkbox),
                                        const SizedBox(width: 8),
                                        Text("Cut-off price",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w600)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              if (addIpo[index]
                                  .qualityerrortext
                                  .isNotEmpty) ...[
                                IpoErrorBadge(
                                  errorName: addIpo[index].qualityerrortext,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                              if (addIpo[index].biderrortext.isNotEmpty) ...[
                                IpoErrorBadge(
                                  errorName: addIpo[index].biderrortext,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
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
                                        ipo.isSMEPlaceOrderBtnActive,
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
                            label: Text("Add another",
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlue,
                                    14,
                                    FontWeight.w600)),
                          ),
                        ),
                  const SizedBox(height: 8),
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
                  //     controller: ipo.viewupiid,
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
                  //         ipo.viewupiid.text = value;
                  //         if (ipo.viewupiid.text.isEmpty) {
                  //           upierrortext = "* UPI ID cannot be empty";
                  //           ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //         } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                  //             .hasMatch(ipo.viewupiid.text = value)) {
                  //           upierrortext = 'Invalid UPI ID format';
                  //           ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //         } else {
                  //           upierrortext = '';
                  //           ipo.setisSMEPlaceOrderBtnActiveValue = true;
                  //         }
                  //       });
                  //     },
                  //   ),
                  // ),
                  // if (ipo.viewupiid.text.isEmpty ||
                  //     !RegExp(r'^[\w.-]+@[\w]+$')
                  //         .hasMatch(ipo.viewupiid.text)) ...[
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
                  //                     // ischecked=!ischecked;

                  //                     if (ipo.checkForErrorsInSMEPlaceOrder(
                  //                         addIpo)) {
                  //                       ipo.setisSMEPlaceOrderBtnActiveValue =
                  //                           true;
                  //                       // ischecked=true;
                  //                     }
                  //                     // else if(!ischecked){
                  //                     //     ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // }
                  //                     else {
                  //                       ScaffoldMessenger.of(context)
                  //                           .showSnackBar(warningMessage(
                  //                               context,
                  //                               "can't able place Order with current selected combination of Bids"));
                  //                       ischecked = false;
                  //                       ipo.setisSMEPlaceOrderBtnActiveValue =
                  //                           false;
                  //                     }

                  //                     // ipo.setisSMEPlaceOrderBtnActiveValue = !;
                  //                     // for(final bid in addIpo){
                  //                     //   if (bid.requriedprice >
                  //                     //     ipo.maxUPIAmt) {
                  //                     //   bid.qualityerrortext =
                  //                     //       "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only ";
                  //                     //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // } else if (bid
                  //                     //         .bidpricecontroller
                  //                     //         .text
                  //                     //         .isEmpty ||
                  //                     //     bid.bidpricecontroller.text ==
                  //                     //         "0") {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           bid.bidpricecontroller
                  //                     //                       .text ==
                  //                     //                   "0"
                  //                     //               ? "*Bid Price Value cannot be 0"
                  //                     //               : "*Bid Price Value is required"));
                  //                     //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // } else if ((int.parse(bid.bidpricecontroller.text)) > double.parse(widget.smeipo.maxPrice.toString()).toInt() ||
                  //                     //     (int.parse(bid.bidpricecontroller.text)) <
                  //                     //         double.parse(widget.smeipo.minPrice.toString())
                  //                     //             .toInt()) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Your bid price ranges between ₹${double.parse(widget.smeipo.minPrice!).toInt()}-₹${double.parse(widget.smeipo.maxPrice!).toInt()}"));
                  //                     //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // } else if ((int.parse(bid.qualityController.text)) <
                  //                     //     int.parse(widget.smeipo.minBidQuantity.toString())
                  //                     //         .toInt()) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "Minimum Bid quantity is ${widget.smeipo.minBidQuantity.toString()} only "));
                  //                     //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // }
                  //                     // else if (bid
                  //                     //         .qualityController
                  //                     //         .text
                  //                     //         .isEmpty ||
                  //                     //     bid.qualityController.text ==
                  //                     //         "0") {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           bid.qualityController
                  //                     //                       .text ==
                  //                     //                   "0"
                  //                     //               ? '* Quantity cannot be 0'
                  //                     //               : '* Quantity cannot be empty'));
                  //                     //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // }
                  //                     //  else if (upiid.upiid.text.isEmpty) {
                  //                     //   ScaffoldMessenger.of(context)
                  //                     //       .showSnackBar(warningMessage(
                  //                     //           context,
                  //                     //           "UPI ID cannot be empty"));
                  //                     //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // } else if (!RegExp(r'^[\w.-]+@[\w]+$').hasMatch(upiid.upiid.text)) {
                  //                     //   ipo.setisSMEPlaceOrderBtnActiveValue = false;
                  //                     // }
                  //                     // }
                  //                   });
                  //                 },
                  //           icon: SvgPicture.asset(theme.isDarkMode
                  //               ? ipo.isSMEPlaceOrderBtnActive
                  //                   ? assets.darkCheckedboxIcon
                  //                   : assets.darkCheckboxIcon
                  //               : ipo.isSMEPlaceOrderBtnActive
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
                  // if (ipo.isSMEPlaceOrderBtnActive == false) ...[
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
                    title: Text("₹${ipo.smePlaceOrderRequiredMaxPrice}",
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
                      onPressed: ipo.isSMEPlaceOrderBtnActive
                          ? () {
                              if (addIpo[addIpo.length - 1].requriedprice >
                                  ipo.maxUPIAmt) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    warningMessage(context,
                                        "Maximum investment upto ₹${double.parse(ipo.maxUPIAmt.toString()).toInt()} only "));
                                ipo.setisSMEPlaceOrderBtnActiveValue = false;
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
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //       warningMessage(
                              //           context, '* UPI ID cannot be empty'));
                              // } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                              //     .hasMatch(upiid.upiid.text)) {
                              //   ScaffoldMessenger.of(context).showSnackBar(
                              //       warningMessage(
                              //           context, 'Invalid UPI ID format'));
                              // }
                              else {
                                // ipoplaceorder(upiid, ipo);

                                if (ipo.checkForErrorsInSMEPlaceOrder(addIpo)) {
                                  ipo.setisSMEPlaceOrderBtnActiveValue = true;

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
                                        mainstream: widget.smeipo,
                                        addIpo: addIpo,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      warningMessage(context,
                                          "can't able place Order with current selected combination of Bids"));
                                  // ischecked = false;
                                  ipo.setisSMEPlaceOrderBtnActiveValue = false;
                                }
                              }
                            }
                          : () {},
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(155, 40),
                        backgroundColor: !theme.isDarkMode
                            ? ipo.isSMEPlaceOrderBtnActive == false
                                ? const Color(0xfff5f5f5)
                                : colors.colorBlack
                            : ipo.isSMEPlaceOrderBtnActive == false
                                ? colors.darkGrey
                                : colors.colorbluegrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text("Continue",
                          style: textStyle(
                              !theme.isDarkMode
                                  ? ipo.isSMEPlaceOrderBtnActive == false
                                      ? const Color(0xff999999)
                                      : colors.colorWhite
                                  : ipo.isSMEPlaceOrderBtnActive == false
                                      ? colors.darkGrey
                                      : colors.colorBlack,
                              14,
                              FontWeight.w500)),
                    ),
                  )));
        },
      ),
    );
  }

  ipoplaceorder(TranctionProvider upiid, IPOProvider ipo) async {
    MenuData menudata = MenuData(
      flow: "now",
      type: widget.smeipo.type.toString(),
      symbol: widget.smeipo.symbol.toString(),
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
      name: widget.smeipo.name.toString(),
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
    // print( "IPO PLACE ORDERS :: ${upiid.upiid.text} ,${inspect(menudata)} ,${inspect(iposbids)} ,${iposupiid}");
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
