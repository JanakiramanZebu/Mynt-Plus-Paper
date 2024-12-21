// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/sharedWidget/no_data_found.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../provider/transcation_provider.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';
import 'single_page.dart';

class MainSmeListCard extends StatelessWidget {
  const MainSmeListCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ipos = watch(ipoProvide);
      final mainstreamipo = watch(ipoProvide);
      final upi = watch(transcationProvider);
      final theme = watch(themeProvider);
      return mainstreamipo.mainsme.isEmpty
          ? const Padding(
              padding: EdgeInsets.only(top: 225),
              child: NoDataFound(),
            )
          : Column(children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      await ipos.getIpoSinglePage(
                          ipoName: "${mainstreamipo.mainsme[index].name}");
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
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: MainSmeSinglePage(
                                pricerange:"₹${double.parse(mainstreamipo.mainsme[index].minPrice!).toInt()}- ₹${double.parse(mainstreamipo.mainsme[index].maxPrice!).toInt()}",
                                  mininv:
                                      "₹${mininv(double.parse(mainstreamipo.mainsme[index].minPrice!).toDouble(), int.parse(mainstreamipo.mainsme[index].minBidQuantity!).toInt()).toInt()}",
                                  enddate:
                                      "${mainstreamipo.mainsme[index].biddingEndDate}",
                                  startdate:
                                      "${mainstreamipo.mainsme[index].biddingStartDate}",
                                  ipotype:
                                      "${mainstreamipo.mainsme[index].key}")));
                    },
                    child: Column(
                      children: [
                        ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                    "${mainstreamipo.mainsme[index].name}",
                                    style: textStyle(
                                        theme.isDarkMode
                                            ? colors.colorWhite
                                            : colors.colorBlack,
                                        15,
                                        FontWeight.w600)),
                              ),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: theme.isDarkMode
                                          ? colors.colorGrey.withOpacity(.1)
                                          : const Color(0xffF1F3F8),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                      "${mainstreamipo.mainsme[index].key}",
                                      style: textStyle(const Color(0xff666666),
                                          9, FontWeight.w500))),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: theme.isDarkMode
                                            ? colors.colorGrey.withOpacity(.1)
                                            : const Color(0xffF1F3F8),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                        "${mainstreamipo.mainsme[index].symbol}",
                                        style: textStyle(colors.colorGrey, 11,
                                            FontWeight.w500))),
                                const SizedBox(width: 10),
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: ipostartdate(
                                                    "${mainstreamipo.mainsme[index].biddingStartDate}",
                                                    "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                                "Open"
                                            ? theme.isDarkMode
                                                ? const Color(0xffECF8F1)
                                                    .withOpacity(.3)
                                                : const Color(0xffECF8F1)
                                            : theme.isDarkMode
                                                ? const Color(0xffFFF6E6)
                                                    .withOpacity(.3)
                                                : const Color(0xffFFF6E6),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Text(
                                        ipostartdate(
                                            "${mainstreamipo.mainsme[index].biddingStartDate}",
                                            "${mainstreamipo.mainsme[index].biddingEndDate}"),
                                        style: textStyle(
                                            Color(ipostartdate("${mainstreamipo.mainsme[index].biddingStartDate}", "${mainstreamipo.mainsme[index].biddingEndDate}") == "Open" ? 0xff43A833 : 0xffB37702),
                                            11,
                                            FontWeight.w500))),
                                const SizedBox(width: 10),
                                Text(
                                    "${mainstreamipo.mainsme[index].biddingStartDate!.substring(0, 2)}th - ${mainstreamipo.mainsme[index].biddingEndDate!.substring(5, 16)}",
                                    style: textStyle(const Color(0xff666666),
                                        13, FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                            color: theme.isDarkMode
                                ? colors.darkColorDivider
                                : colors.colorDivider),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 2, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Price Range",
                                      style: textStyle(const Color(0xff666666),
                                          13, FontWeight.w500)),
                                  Text(
                                      "₹${double.parse(mainstreamipo.mainsme[index].minPrice!).toInt()}- ₹${double.parse(mainstreamipo.mainsme[index].maxPrice!).toInt()}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          15,
                                          FontWeight.w500)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Min Qty",
                                      style: textStyle(const Color(0xff666666),
                                          13, FontWeight.w500)),
                                  Text(
                                      "${mainstreamipo.mainsme[index].minBidQuantity}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          15,
                                          FontWeight.w500)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Min Amount",
                                      style: textStyle(const Color(0xff666666),
                                          13, FontWeight.w500)),
                                  Text(
                                      "₹${mininv(double.parse(mainstreamipo.mainsme[index].minPrice!).toDouble(), int.parse(mainstreamipo.mainsme[index].minBidQuantity!).toInt()).toInt()}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          15,
                                          FontWeight.w500))
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: theme.isDarkMode
                                      ? colors.colorbluegrey
                                      : const Color(0xffF1F3F8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  )),
                              onPressed: () async {
                                await upi.fetchupiIdView(
                                    upi.bankdetails!.dATA![upi.indexss][1],
                                    upi.bankdetails!.dATA![upi.indexss][2]);
                                mainstreamipo.mainsme[index].key == "SME"
                                    ? await context
                                        .read(ipoProvide)
                                        .smeipocategory()
                                    : await context
                                        .read(ipoProvide)
                                        .mainipocategory();

                                mainstreamipo.mainsme[index].key == "SME"
                                    ? Navigator.pushNamed(
                                        context,
                                        Routes.smeapplyIPO,
                                        arguments: ipos.mainsme[index],
                                      )
                                    : Navigator.pushNamed(
                                        context, Routes.applyIPO,
                                        arguments: ipos.mainsme[index]);
                              },
                              child: ipos.loading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xff666666)),
                                    )
                                  : Text(
                                      ipostartdate(
                                                  "${mainstreamipo.mainsme[index].biddingStartDate}",
                                                  "${mainstreamipo.mainsme[index].biddingEndDate}") ==
                                              "Open"
                                          ? "Apply"
                                          : "Pre Apply",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorBlack
                                              : colors.colorBlue,
                                          13,
                                          FontWeight.w600),
                                    )),
                        )
                      ],
                    ),
                  );
                },
                itemCount: mainstreamipo.mainsme.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.only(top: 8),
                    color:
                        mainstreamipo.mainStreamIpoModel?.msg == "no IPO found"
                            ? Colors.transparent
                            : theme.isDarkMode
                                ? colors.darkColorDivider
                                : const Color(0xffF1F3F8),
                    height:
                        mainstreamipo.mainStreamIpoModel?.msg == "no IPO found"
                            ? 0
                            : 7,
                  );
                },
              ),
              Container(
                margin: EdgeInsets.only(top: 8),
                color: mainstreamipo.mainStreamIpoModel?.msg == "no IPO found"
                    ? Colors.transparent
                    : theme.isDarkMode
                        ? colors.darkColorDivider
                        : const Color(0xffF1F3F8),
                height: mainstreamipo.mainStreamIpoModel?.msg == "no IPO found"
                    ? 0
                    : 7,
              )
            ]);
    });
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
      fontWeight: fWeight,
      color: color,
      fontSize: fontSize,
    );
  }
}
