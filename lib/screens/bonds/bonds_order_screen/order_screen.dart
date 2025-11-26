import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mynt_plus/models/bonds_model/all_bonds_list_model.dart';
import 'package:mynt_plus/models/bonds_model/bonds_place_order_details_model.dart';
import 'package:mynt_plus/provider/bonds_provider.dart';
import 'package:mynt_plus/sharedWidget/custom_exch_badge.dart';
import '../../../provider/thems.dart';
import '../../../res/global_state_text.dart';
import '../../../res/res.dart';
import '../../../sharedWidget/ipo_error_widget.dart';

class ApplyBondsScreen extends ConsumerStatefulWidget {
  final BondsList bondInfo;
  const ApplyBondsScreen({
    required this.bondInfo,
    super.key,
  });

  @override
  ConsumerState<ApplyBondsScreen> createState() => _ApplyBondsScreenState();
}

class _ApplyBondsScreenState extends ConsumerState<ApplyBondsScreen> {
  // bool ischecked = true;
  // String upierrortext = "Please enter the UPI Id";
  // int required = 0;
  late TextEditingController quantityController;
  late TextEditingController bidpricecontroller;
  // List<int> stringList = [];
  // int? maxValue;
  // String selectedChip = "Individual";
  late BondDetails bondDetails;
  @override
  void initState() {
    setState(() {
      bondDetails = BondDetails(
          quantitytext:
              "${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!).toInt()).toInt()}",
          bidprice: "${double.parse(widget.bondInfo.cutoffPrice!).toInt()}",
          lotsize: (int.parse(widget.bondInfo.lotSize!) /
                  double.parse(widget.bondInfo.faceValue!))
              .toInt(),
          minrequriedprice:
              (double.parse(widget.bondInfo.cutoffPrice!).toInt() *
                      (int.parse(widget.bondInfo.minBidQuantity!) /
                          double.parse(widget.bondInfo.faceValue!)))
                  .toInt(),
          maxrequriedprice:
              (double.parse(widget.bondInfo.cutoffPrice!).toInt() *
                      (int.parse(widget.bondInfo.maxQuantity!) /
                          double.parse(widget.bondInfo.faceValue!)))
                  .toInt());

      // addNewItem();

      // maxValue = mininv(double.parse(widget.bondInfo.minPrice!).toDouble(),
      //         int.parse(widget.bondInfo.minBidQuantity!).toInt())
      //     .toInt();
    });
    super.initState();
  }

  // void addNewItem() {
  //   setState(() {
  //     addIpo.add(IpoDetails(
  //         qualitytext: "${widget.bondInfo.lotSize}",
  //         bidprice: "${double.parse(widget.bondInfo.minPrice!).toInt()}",
  //         lotsize: int.parse("${widget.bondInfo.lotSize}"),
  //         requriedprice: mininv(
  //                 double.parse(widget.bondInfo.minPrice!).toDouble(),
  //                 int.parse(widget.bondInfo.minBidQuantity!).toInt())
  //             .toInt(),
  //         isChecked: false));
  //   });
  // }

  // removeItem(int index) {
  //   setState(() {
  //     addIpo.removeAt(index);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer(
        builder: (context, ref, child) {
          final bonds = ref.watch(bondsProvider);
          final theme = ref.watch(themeProvider);
          // final upiid = ref.watch(transcationProvider);
          // if (selectedChip == null && chips.isNotEmpty) {
          //   selectedChip = chips[0]; // Set first item as default
          // }
          // if (ipo.checkForErrorsInSMEPlaceOrder(addIpo)) {
          //   ipo.setisMainIPOPlaceOrderBtnActiveValue = true;
          // }
          //  ipo.setMainIPOPlaceOrderRequiredMaxPrice = addIpo;

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
                    child: Text("${widget.bondInfo.name}",
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
                          CustomExchBadge(exch: widget.bondInfo.symbol!),
                          CustomExchBadge(exch: widget.bondInfo.isin!)
                        ],
                      )),
                ),
              ),
              body: 
              SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      color: Color(0xFFFCEFD4),
                      height: 30,
                      child: Center(
                        child: Text(
                            "Bond window is open from ${widget.bondInfo.dailyStartTime} till ${widget.bondInfo.dailyEndTime} on trading days.",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                10,
                                FontWeight.w600)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Units",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        14,
                                        FontWeight.w600)),
                                const SizedBox(width: 8),
                                Text(
                                    "(${(int.parse(widget.bondInfo.minBidQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()} - ${(int.parse(widget.bondInfo.maxQuantity!) / double.parse(widget.bondInfo.faceValue!)).toInt()})",
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
                                readOnly: bonds.loading ? true : false,
                                textAlign: TextAlign.center,
                                style: textStyle(
                                    theme.isDarkMode
                                        ? colors.colorWhite
                                        : colors.colorBlack,
                                    14,
                                    FontWeight.w600),
                                keyboardType: TextInputType.number,
                                controller: bondDetails.quantityController,
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
                                  suffixIcon: InkWell(
                                    onTap: bonds.loading
                                        ? null
                                        : () {
                                            bonds.addQuantity(bondDetails);
                                            // setState(() {
                                            //   bonds.setMainIPOPlaceOrderRequiredMaxPrice =
                                            //       bondDetails;

                                            // });
                                          },
                                    child: SvgPicture.asset(
                                        theme.isDarkMode
                                            ? assets.darkAdd
                                            : assets.addIcon,
                                        fit: BoxFit.scaleDown),
                                  ),
                                  prefixIcon: InkWell(
                                    onTap:
                                        bondDetails.quantityController.text ==
                                                bondDetails.quantitytext
                                            ? null
                                            : bonds.loading
                                                ? null
                                                : () {
                                                    bonds.substractQuantity(
                                                        bondDetails);
                                                    // setState(() {
                                                    //   ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                                    //       addIpo;
                                                    //   // maxValue = addIpo
                                                    //   //     .map((map) => map
                                                    //   //         .requriedprice)
                                                    //   //     .reduce((a,
                                                    //   //             b) =>
                                                    //   //         a > b
                                                    //   //             ? a
                                                    //   //             : b);
                                                    // });
                                                  },
                                    child: SvgPicture.asset(
                                        theme.isDarkMode
                                            ? assets.darkCMinus
                                            : assets.minusIcon,
                                        fit: BoxFit.scaleDown),
                                  ),
                                ),
                                onChanged: (value) {
                                  bonds.quantityOnchange(bondDetails, value);
                                  // setState(() {
                                  //   ipo.setMainIPOPlaceOrderRequiredMaxPrice =
                                  //       addIpo;
                                  // });
                                },
                              ),
                            ),
                            if (bondDetails.quantityerrortext.isNotEmpty) ...[
                              const SizedBox(
                                height: 6,
                              ),
                              TextWidget.captionText(
                                theme: false,
                                text: bondDetails.quantityerrortext,
                                color: colors.error,
                                fw: 3,
                              )
                            ],
                            if (bondDetails.biderrortext.isNotEmpty) ...[
                              const SizedBox(
                                height: 6,
                              ),
                              TextWidget.captionText(
                                theme: false,
                                text: bondDetails.biderrortext,
                                color: colors.error,
                                fw: 3,
                              )
                            ],
                          ]),
                    ),
                    const SizedBox(height: 86)
                  ],
                ),
              ),
              bottomSheet: BottomAppBar(
                elevation: .14,
                child: ListTile(
                  title: Text("₹ ${bondDetails.minrequriedprice.toString()}",
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
                    onPressed: bonds.isBondPlaceOrderBtnActive ? () {} : () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(145, 37),
                      backgroundColor: !theme.isDarkMode
                          ? bonds.isBondPlaceOrderBtnActive == false
                              ? const Color(0xfff5f5f5)
                              : colors.colorBlack
                          : bonds.isBondPlaceOrderBtnActive == false
                              ? colors.darkGrey
                              : colors.colorbluegrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text("Continue",
                        style: textStyle(
                            !theme.isDarkMode
                                ? bonds.isBondPlaceOrderBtnActive == false
                                    ? const Color(0xff999999)
                                    : colors.colorWhite
                                : bonds.isBondPlaceOrderBtnActive == false
                                    ? colors.darkGrey
                                    : colors.colorBlack,
                            14,
                            FontWeight.w500)),
                  ),
                ),
              ));
        },
      ),
    );
  }

  ipoplaceorder(BondDetails bondDetails) async {
    await ref.read(bondsProvider).validateClientLedgertoPlaceOrder(context);
  }
}

TextStyle textStyle(Color color, double fontSize, fWeight) {
  return TextStyle(
    fontWeight: fWeight,
    color: color,
    fontSize: fontSize,
  );
}
