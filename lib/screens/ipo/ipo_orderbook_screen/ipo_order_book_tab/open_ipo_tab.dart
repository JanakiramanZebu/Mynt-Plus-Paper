import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class IpoOpenOrder extends ConsumerWidget {
  // final IPOProvider ipo;
  const IpoOpenOrder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final ipo = ref.watch(ipoProvide);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (ipo.openorder!.length > 4)
          // Container(
          //   alignment: Alignment.centerRight,
          //   width: MediaQuery.of(context).size.width,
          //   padding: const EdgeInsets.symmetric(vertical: 8),
          //   decoration: BoxDecoration(
          //       border: Border(
          //           bottom: BorderSide(
          //               color: theme.isDarkMode
          //                   ? colors.darkGrey
          //                   : const Color(0xffF1F3F8),
          //               width: 6))),
          //   child: InkWell(
          //     onTap: () {
          //       // ipo.showOpenSearch(true);
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.only(right: 12, left: 10),
          //       child: SvgPicture.asset(assets.searchIcon,
          //           width: 19,
          //           color: theme.isDarkMode
          //               ? Color(0xffBDBDBD)
          //               : colors.colorGrey),
          //     ),
          //   ),
          // ),
          if (ipo.showSearch)
            Container(
              height: 62,
              padding: const EdgeInsets.only(left: 16, top: 8),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          width: 6))),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: ipo.openOrderController,
                      style: textStyle(
                          theme.isDarkMode
                              ? colors.colorWhite
                              : colors.colorBlack,
                          16,
                          FontWeight.w600),
                      decoration: InputDecoration(
                          fillColor: theme.isDarkMode
                              ? colors.darkGrey
                              : const Color(0xffF1F3F8),
                          filled: true,
                          hintStyle: GoogleFonts.inter(
                              textStyle: textStyle(const Color(0xff69758F), 15,
                                  FontWeight.w500)),
                          prefixIconColor: const Color(0xff586279),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SvgPicture.asset(assets.searchIcon,
                                color: const Color(0xff586279),
                                fit: BoxFit.contain,
                                width: 20),
                          ),
                          suffixIcon: InkWell(
                            onTap: () async {
                              ipo.clearopenoreder();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: SvgPicture.asset(assets.removeIcon,
                                  fit: BoxFit.scaleDown, width: 20),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20)),
                          disabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20)),
                          hintText: "Search Ipo",
                          contentPadding: const EdgeInsets.only(top: 20),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(20))),
                      onChanged: (value) async {
                        ipo.openOrderSearch(value, context);
                      },
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        ipo.showOpenSearch(false);
                        ipo.getipoorderbookmodel(false);
                      },
                      child: Text("Close",
                          style: textStyles.textBtn.copyWith(
                              color: theme.isDarkMode
                                  ? colors.colorLightBlue
                                  : colors.colorBlue)))
                ],
              ),
            ),
          ipo.iposearch!.isEmpty
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ipo.openorder!.length,
                  itemBuilder: (context, index) {
                    List<String> stringList = [];
                    List<String> bidqty = [];
                    for (var i = 0;
                        i < ipo.openorder![index].bidDetail!.length;
                        i++) {
                      stringList.add(ipo.openorder![index].type == "BSE"
                          ? (double.parse(ipo
                                      .openorder![index].bidDetail![i].rate!) *
                                  double.parse(ipo.openorder![index]
                                      .bidDetail![i].quantity!))
                              .toString()
                          : ipo.openorder![index].bidDetail![i].amount
                              .toString());
                      bidqty.add(ipo.openorder![index].bidDetail![i].quantity
                          .toString());
                    }
                    String maxValue = stringList
                        .reduce((curr, next) =>
                            double.parse(curr) > double.parse(next)
                                ? curr
                                : next)
                        .toString();
                    String bidmaxvalue = bidqty
                        .reduce((curr, next) =>
                            double.parse(curr) > double.parse(next)
                                ? curr
                                : next)
                        .toString();
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.ipoopendetailsscreen,
                            arguments: ipo.openorder![index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                      ipo.openorder![index].companyName
                                          .toString(),
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                // const SizedBox(
                                //   height: 8,
                                // ),

                                Text(
                                  // ipo.openorder![index].type == "BSE"
                                  //     ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(maxValue))}"
                                  // :
                                  "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(maxValue))}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),

                                // SvgPicture.asset(assets.rightArrowIcon)
                              ],
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                            //   child: Divider(
                            //     height: 0,
                            //       color: theme.isDarkMode
                            //           ? colors.darkColorDivider
                            //           : const Color(0xffECEDEE),
                            //       thickness: 1.2),
                            // ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ipo.openorder![index].responseDatetime
                                                  .toString() ==
                                              ""
                                          ? "----"
                                          : ipodateres(ipo.openorder![index]
                                              .responseDatetime
                                              .toString()),
                                      style: textStyle(const Color(0xff666666),
                                          12, FontWeight.w600),
                                    ),
                                    // const SizedBox(
                                    //   height: 2,
                                    // ),
                                    // Text(
                                    //   "Bid Date & time",
                                    //   style: textStyle(colors.colorGrey, 12,
                                    //       FontWeight.w500),
                                    // )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(ipo.openorder![index]
                                                    .reponseStatus ==
                                                "new success"
                                            ? "assets/icon/success.svg"
                                            : "assets/icon/pendingicon.svg"),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          ipo.openorder![index].reponseStatus ==
                                                  "new success"
                                              ? "Success"
                                              : "Pending",
                                          style: textStyle(
                                              theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack,
                                              14,
                                              FontWeight.w600),
                                        ),
                                      ],
                                    )

                                    // const SizedBox(
                                    //   height: 2,
                                    // ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider(
                      height: 0,
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                    );
                  },
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ipo.iposearch!.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                            context, Routes.ipoopendetailsscreen,
                            arguments: ipo.iposearch![index]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                      ipo.iposearch![index].companyName
                                          .toString(),
                                      style: textStyles.scripNameTxtStyle
                                          .copyWith(
                                              color: theme.isDarkMode
                                                  ? colors.colorWhite
                                                  : colors.colorBlack),
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(
                                  ipo.iposearch![index].type == "BSE"
                                      ? "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(ipo.iposearch![index].bidDetail![0].rate!) * double.parse(ipo.iposearch![index].bidDetail![0].quantity!)).toString()}"
                                      : "₹${getFormatter(noDecimal: true, v4d: false, value: double.parse(ipo.iposearch![index].bidDetail![0].amount.toString()))}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                              ],
                            ),

                            SizedBox(
                              height: 16,
                            ),
                            //     Padding(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 0, vertical: 16),
                            //       child: Divider(
                            //           height: 0,
                            //           color: theme.isDarkMode
                            // ? colors.darkColorDivider
                            // : colors.colorDivider,),
                            //     ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ipo.iposearch![index].responseDatetime
                                              .toString() ==
                                          ""
                                      ? "----"
                                      : ipodateres(ipo.iposearch![index]
                                          .responseDatetime
                                          .toString()),
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),


                                Row(
                                  children: [
                                
                                     SvgPicture.asset(ipo.iposearch![index]
                                            .reponseStatus ==
                                        "new success"
                                    ? "assets/icon/success.svg"
                                    : "assets/icon/pendingicon.svg"),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  ipo.iposearch![index].reponseStatus ==
                                          "new success"
                                      ? "Success"
                                      : "Pending",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      color: theme.isDarkMode
                          ? colors.darkColorDivider
                          : colors.colorDivider,
                    );
                  },
                )
        ],
      ),
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
