import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../models/ipo_model/ipo_details_model.dart';
import '../../../../models/ipo_model/ipo_mainstream_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../provider/fund_provider.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/snack_bar.dart';


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
  bool ischecked = false;
  String alertValue = "";
  String upierrortext = "";
  final int indvalue = 200000;
  final int empvalue = 500000;
  List<IpoDetails> addIpo = [];
  @override
  void initState() {
    setState(() {
      addNewItem();
    });
    super.initState();
  }

  void addNewItem() {
    setState(() {
      addIpo.add(IpoDetails(
          qualitytext: "${widget.mainstream.lotSize}",
          bidprice: "${widget.mainstream.minPrice!.toInt()}",
          lotsize: int.parse("${widget.mainstream.lotSize}"),
          requriedprice: mininv(widget.mainstream.minPrice!.toDouble(),
                  widget.mainstream.minBidQuantity!.toInt())
              .toInt(),
          isChecked: false));
    });
  }

  void removeItem(int index) {
    setState(() {
      addIpo.removeAt(index);
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final upiid = watch(fundProvider);
        final ipo = watch(ipoProvide);
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
                child: SvgPicture.asset(assets.backArrow),
              ),
            ),
            backgroundColor: colors.colorWhite,
            shadowColor: const Color(0xffECEFF3),
            title: Text("IPO Order", style: textStyles.appBarTitleTxt),
           
          ),
          body: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: const Color(0xffF1F3F8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text("${widget.mainstream.name}",
                          style: textStyle(
                              const Color(0xff000000), 15, FontWeight.w600)),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                                color: const Color(0xffffffff),
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
                                color: const Color(0xffffffff),
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
                              Text("${widget.mainstream.minBidQuantity}",
                                  style: textStyle(const Color(0xff000000), 14,
                                      FontWeight.w500)),
                              Text("Min.Qty",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "₹${widget.mainstream.minPrice!.toInt()}- ₹${widget.mainstream.maxPrice!.toInt()}",
                                  style: textStyle(const Color(0xff000000), 14,
                                      FontWeight.w500)),
                              Text("Price Range",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "₹${getFormatter(value: widget.mainstream.issueSize!.toDouble(), v4d: false, noDecimal: true)}",
                                  style: textStyle(const Color(0xff000000), 14,
                                      FontWeight.w500)),
                              Text("IPO Size",
                                  style: textStyle(const Color(0xff666666), 12,
                                      FontWeight.w500)),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: const Color(0xffFCEFD4),
                child: Text(
                    "IPO window is open from 10:00 AM till 05:00 PM on trading days.",
                    textAlign: TextAlign.start,
                    style: textStyle(
                        const Color(0xff666666), 11, FontWeight.w500)),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text('Category',
                    style: textStyle(
                        const Color(0xff000000), 14, FontWeight.w600)),
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
                          color: const Color(0xffFFFFFF))),
                  menuItemStyleData: MenuItemStyleData(
                      customHeights: ipo.getCustomItemsHeight(
                          ipo.ipoCategory )),
                  buttonStyleData: const ButtonStyleData(
                      height: 40,
                      width: 124,
                      decoration: BoxDecoration(
                          color: const Color(0xffF1F3F8),
                          // border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(32)))),
                  isExpanded: true,
                  style: textStyle(colors.colorBlack, 13, FontWeight.w500),
                  hint: Text(ipo.ipoCategoryvalue,
                      style: textStyle(colors.colorBlack, 13, FontWeight.w500)),
                  items: ipo
                      .addDividerSubCategory(ipo.ipoCategory ),
                  value: ipo.ipoCategoryvalue,
                  onChanged: (value) async {
                    ipo.chngPeersType("$value");
                    setState(() {
                      if (ipo.ipoCategoryvalue == "Individual"
                          ? addIpo[addIpo.length - 1].requriedprice > 200000
                          : addIpo[addIpo.length - 1].requriedprice > 500000) {
                        ischecked = false;
                        ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                            context,
                            ipo.ipoCategoryvalue == "Individual"
                                ? 'Maximum investment upto ₹2,00,000 only '
                                : 'Maximum investment upto ₹5,00,000 only '));
                      }
                      else {
                        addIpo[addIpo.length - 1].qualityerrortext = "";
                        ischecked = false;
                      }
                      
                    });
                  },
                )),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: addIpo.length,
                itemBuilder: (context, index) {
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Bid - 0${index + 1}",
                                  style: textStyle(const Color(0xff000000), 14,
                                      FontWeight.w600)),
                              index > 0
                                  ? TextButton.icon(
                                      onPressed: () {
                                        removeItem(index);
                                      },
                                      icon: SvgPicture.asset(assets.trash),
                                      label: Text("Delete",
                                          style: textStyle(
                                              const Color(0xffFD2E2E),
                                              12,
                                              FontWeight.w600)),
                                    )
                                  : Container()
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Quantity",
                              style: textStyle(const Color(0xff000000), 14,
                                  FontWeight.w600)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style: textStyle(
                                  const Color(0xff000000), 14, FontWeight.w600),
                              keyboardType: TextInputType.number,
                              controller: addIpo[index].qualityController,
                              decoration: InputDecoration(
                                  fillColor: const Color(0xffF1F3F8),
                                  filled: true,
                                  labelStyle: textStyle(const Color(0xff000000),
                                      14, FontWeight.w600),
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
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (addIpo[index]
                                            .qualityController
                                            .text
                                            .isNotEmpty) {
                                          addIpo[index].qualityController.text =
                                              (int.parse(addIpo[index]
                                                          .qualityController
                                                          .text) +
                                                      addIpo[index].lotsize)
                                                  .toString();
                                          addIpo[index].isChecked == true
                                              ? addIpo[index].requriedprice =
                                                  widget
                                                          .mainstream.maxPrice!
                                                          .toInt() *
                                                      (int.parse(addIpo[index]
                                                          .qualityController
                                                          .text))
                                              : addIpo[index]
                                                  .requriedprice = widget
                                                      .mainstream.minPrice!
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
                                          addIpo[index].qualityerrortext =
                                              addIpo[index]
                                                      .qualityController
                                                      .text
                                                      .isEmpty
                                                  ? "* Value is required"
                                                  : "Value cannot be 0";
                                        } else if (ipo
                                                    .ipoCategoryvalue ==
                                                "Individual"
                                            ? addIpo[index].requriedprice >
                                                200000
                                            : addIpo[index].requriedprice >
                                                 
                                                500000) {
                                          ipo.ipoCategoryvalue == "Individual"
                                              ? addIpo[index].qualityerrortext =
                                                  "Maximum investment upto 2,00,000 only "
                                              : addIpo[index].qualityerrortext =
                                                  "Maximum investment upto ₹5,00,000 only ";
                                          ischecked = false;
                                        } else {
                                          addIpo[index].qualityerrortext = "";
                                        }
                                      });
                                    },
                                    child: SvgPicture.asset(assets.addIcon,
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
                                                        addIpo[index].lotsize)
                                                    .toString();
                                                addIpo[index].isChecked == true
                                                    ? addIpo[index]
                                                        .requriedprice = widget
                                                            .mainstream
                                                            .maxPrice!
                                                            .toInt() *
                                                        (int.parse(addIpo[index]
                                                            .qualityController
                                                            .text))
                                                    : addIpo[index]
                                                        .requriedprice = widget
                                                            .mainstream
                                                            .minPrice!
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
                                                addIpo[index].qualityerrortext =
                                                    addIpo[index]
                                                            .qualityController
                                                            .text
                                                            .isEmpty
                                                        ? "* Value is required"
                                                        : "Value cannot be 0";
                                              } else if (ipo.ipoCategoryvalue ==
                                                      "Individual"
                                                  ? addIpo[index].requriedprice >
                                                      200000
                                                  : addIpo[index].requriedprice >
                                                      500000) {
                                                ipo.ipoCategoryvalue ==
                                                        "Individual"
                                                    ? addIpo[index]
                                                            .qualityerrortext =
                                                        "Maximum investment upto 2,00,000 only "
                                                    : addIpo[index]
                                                            .qualityerrortext =
                                                        "Maximum investment upto ₹5,00,000 only ";
                                                ischecked = false;
                                              } else {
                                                addIpo[index].qualityerrortext =
                                                    "";
                                              }
                                            });
                                          },
                                    child: SvgPicture.asset(assets.minusIcon,
                                        fit: BoxFit.scaleDown),
                                  )),
                              onChanged: (value) {
                                setState(() {
                                  addIpo[index].qualityController.text = value;
                                  addIpo[index].isChecked == true
                                      ? addIpo[index].requriedprice =
                                          widget.mainstream.maxPrice!.toInt() *
                                              (int.parse(addIpo[index]
                                                  .qualityController
                                                  .text))
                                      : addIpo[index].requriedprice =
                                          widget.mainstream.minPrice!.toInt() *
                                              (int.parse(addIpo[index]
                                                  .qualityController
                                                  .text));
                                  if (addIpo[index]
                                          .qualityController
                                          .text
                                          .isEmpty ||
                                      addIpo[index].qualityController.text ==
                                          "0") {
                                    addIpo[index].qualityerrortext =
                                        addIpo[index]
                                                .qualityController
                                                .text
                                                .isEmpty
                                            ? "* Value is required"
                                            : "Value cannot be 0";
                                  } else if (ipo.ipoCategoryvalue ==
                                          "Individual"
                                      ? addIpo[index].requriedprice >
                                          200000
                                      : addIpo[index].requriedprice >
                                          500000) {
                                    ipo.ipoCategoryvalue == "Individual"
                                        ? addIpo[index].qualityerrortext =
                                            "Maximum investment upto 2,00,000 only "
                                        : addIpo[index].qualityerrortext =
                                            "Maximum investment upto ₹5,00,000 only ";
                                    ischecked = false;
                                  } else {
                                    addIpo[index].qualityerrortext = "";
                                  }
                                });
                              },
                            ),
                          ),
                          if (addIpo[index].qualityerrortext.isNotEmpty) ...[
                            Text(addIpo[index].qualityerrortext,
                                style: textStyle(const Color(0xffFF1717), 10,
                                    FontWeight.w500)),
                          ],
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Bid Price",
                              style: textStyle(const Color(0xff000000), 14,
                                  FontWeight.w600)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 44,
                            child: TextFormField(
                              style: textStyle(
                                  addIpo[index].isChecked == true
                                      ? Color(0xff666666)
                                      : Color(0xff000000),
                                  14,
                                  FontWeight.w600),
                              keyboardType: TextInputType.number,
                              readOnly: addIpo[index].isChecked == true
                                  ? true
                                  : false,
                              controller: addIpo[index].bidpricecontroller,
                              decoration: InputDecoration(
                                  fillColor: const Color(0xffF1F3F8),
                                  filled: true,
                                  labelStyle: textStyle(const Color(0xff000000),
                                      14, FontWeight.w600),
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
                                  prefixIcon: SvgPicture.asset(
                                    assets.rupee,
                                    fit: BoxFit.values[5],
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 30,
                                  )),
                              onChanged: (value) {
                                setState(() {
                                  addIpo[index].bidpricecontroller.text = value;
                                  if (addIpo[index]
                                          .bidpricecontroller
                                          .text
                                          .isEmpty ||
                                      addIpo[index].bidpricecontroller.text ==
                                          "0") {
                                    addIpo[index].biderrortext = addIpo[index]
                                            .bidpricecontroller
                                            .text
                                            .isEmpty
                                        ? "* Value is required"
                                        : "Value cannot be 0";
                                  } else if ((int.parse(addIpo[index]
                                          .bidpricecontroller
                                          .text)) >
                                      int.parse(addIpo[index].bidprice)) {
                                    addIpo[index].bidpricecontroller.text =
                                        addIpo[index].bidprice;
                                  } else {
                                    addIpo[index].biderrortext = "";
                                  }
                                });
                              },
                            ),
                          ),
                          if (addIpo[index].biderrortext.isNotEmpty) ...[
                            Text(addIpo[index].biderrortext,
                                style: textStyle(const Color(0xffFF1717), 10,
                                    FontWeight.w500)),
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
                                              ("${widget.mainstream.maxPrice!.toInt()}")
                                          : addIpo[index]
                                                  .bidpricecontroller
                                                  .text =
                                              "${widget.mainstream.minPrice!.toInt()}";
                                      addIpo[index].isChecked == true
                                          ? addIpo[index].requriedprice = widget
                                                  .mainstream.maxPrice!
                                                  .toInt() *
                                              (int.parse(addIpo[index]
                                                  .qualityController
                                                  .text))
                                          : addIpo[index].requriedprice = widget
                                                  .mainstream.minPrice!
                                                  .toInt() *
                                              (int.parse(addIpo[index]
                                                  .qualityController
                                                  .text));
                                    });
                                  },
                                  icon: SvgPicture.asset(addIpo[index].isChecked
                                      ? assets.checkedbox
                                      : assets.checkbox)),
                              Text("Cut-off price",
                                  style: textStyle(const Color(0xff666666), 13,
                                      FontWeight.w600)),
                            ],
                          ),
                        ]),
                  );
                },
              ),
              const SizedBox(height: 12),
              addIpo.length == 3
                  ? Container()
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      width: MediaQuery.of(context).size.width,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          addNewItem();
                        },
                        icon: SvgPicture.asset(assets.add),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xff0037B7)),
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(60))),
                        ),
                        label: Text("Add another bid",
                            style: textStyle(
                                const Color(0xff0037B7), 14, FontWeight.w600)),
                      ),
                    ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text("UPI ID (Virtual payment adress)",
                    style: textStyle(
                        const Color(0xff000000), 14, FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 44,
                child: TextFormField(
                  controller: upiid.viewupiid,
                  decoration: InputDecoration(
                    fillColor: const Color(0xffF1F3F8),
                    filled: true,
                    labelStyle:
                        textStyle(const Color(0xff000000), 14, FontWeight.w600),
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
                      upiid.viewupiid.text = value;
                      if (upiid.viewupiid.text.isEmpty) {
                        upierrortext = "* UPI ID cannot be empty";
                      } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                          .hasMatch(upiid.viewupiid.text = value)) {
                        upierrortext = 'Invalid UPI ID format';
                      } else {
                        upierrortext = '';
                      }
                    });
                  },
                ),
              ),
              if (upiid.viewupiid.text.isEmpty ||
                  !RegExp(r'^[\w.-]+@[\w]+$')
                      .hasMatch(upiid.viewupiid.text)) ...[
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: Text(upierrortext,
                      style: textStyle(
                          const Color(0xffFF1717), 10, FontWeight.w500)),
                ),
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    IconButton(
                        splashRadius: 20,
                        onPressed: () {
                          setState(() {
                            ischecked = !ischecked;
                            if (ipo.ipoCategoryvalue == "Individual"
                                ? addIpo[addIpo.length - 1].requriedprice >
                                    200000
                                : addIpo[addIpo.length - 1].requriedprice >
                                    500000) {
                              ischecked = false;
                              ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                  context,
                                  ipo.ipoCategoryvalue == "Individual"
                                      ? 'Maximum investment upto ₹2,00,000 only '
                                      : 'Maximum investment upto ₹5,00,000 only '));
                            }
                          });
                        },
                        icon: SvgPicture.asset(
                            ischecked ? assets.checkedbox : assets.checkbox)),
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
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 10),
                  child: Text("You Must Agree To Invest",
                      style: textStyle(
                          const Color(0xffFF1717), 13, FontWeight.w500)),
                ),
              ],
              const SizedBox(height: 86)
            ],
          ),
          bottomSheet: BottomAppBar(
              elevation: .14,
              child: ListTile(
                title: Text(
                    "BID 0${addIpo.length} ₹${addIpo[addIpo.length - 1].requriedprice}",
                    style: textStyle(
                        const Color(0xff282B2F), 16, FontWeight.w600)),
                subtitle: Text("Total Investment",
                    style: textStyle(
                        const Color(0xff666666), 13, FontWeight.w500)),
                trailing: ElevatedButton(
                  onPressed: ischecked == true
                      ? () {
                          if (ipo.ipoCategoryvalue == "Individual"
                              ? addIpo[addIpo.length - 1].requriedprice > 200000
                              : addIpo[addIpo.length - 1].requriedprice >
                                  500000) {
                            ScaffoldMessenger.of(context).showSnackBar(warningMessage(
                                context,
                                ipo.ipoCategoryvalue == "Individual"
                                    ? 'Maximum investment upto ₹2,00,000 only '
                                    : 'Maximum investment upto ₹5,00,000 only '));
                          } else if (upiid.viewupiid.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(
                                    context, '* UPI ID cannot be empty'));
                          } else if (!RegExp(r'^[\w.-]+@[\w]+$')
                              .hasMatch(upiid.viewupiid.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                warningMessage(
                                    context, 'Invalid UPI ID format'));
                          } else {
                            ipoplaceorder(upiid);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Color(ischecked == false ? 0xffdddddd : 0xff000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text("Continue",
                      style: textStyle(
                          const Color(0xffffffff), 14, FontWeight.w500)),
                ),
              )),
        );
      },
    );
  }

  ipoplaceorder(FundProvider upiid) async {
    MenuData menudata = MenuData(
      flow: "now",
      type: widget.mainstream.type.toString(),
      symbol: widget.mainstream.symbol.toString(),
      category: widget.mainstream.issueType.toString(),
      name: widget.mainstream.name.toString(),
      applicationNumber: '',
      respBid: [BidReference(bidReferenceNumber: '')],
    );
    final String iposupiid = upiid.viewupiid.text;
    List<IposBid> iposbids = [];
    for (int i = 0; i < addIpo.length; i++) {
      iposbids.add(IposBid(
          bitis: true,
          qty: int.parse(addIpo[i].qualityController.text).toInt(),
          cutoff: addIpo[i].isChecked,
          price: double.parse(addIpo[i].bidpricecontroller.text).toDouble(),
          total: addIpo[i].requriedprice.toDouble()));
    }

    await context.read(ipoProvide).fetchupiidvalidation(
        context,
        upiid.viewupiid.text,
        "343245",
        menudata,
        iposbids,
        iposupiid);
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}
