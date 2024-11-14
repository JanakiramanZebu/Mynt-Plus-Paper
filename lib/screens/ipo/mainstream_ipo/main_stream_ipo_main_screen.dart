// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../provider/fund_provider.dart';
import '../../../provider/iop_provider.dart';
import '../../../provider/thems.dart';
import '../../../res/res.dart';
import '../../../routes/route_names.dart';
import '../../../sharedWidget/functions.dart';
import '../../../sharedWidget/no_data_found.dart';

class MainStreamIpo extends StatefulWidget {
  const MainStreamIpo({super.key});

  @override
  State<MainStreamIpo> createState() => _MainStreamIpoState();
}

class _MainStreamIpoState extends State<MainStreamIpo>
    with TickerProviderStateMixin {
  late TabController tabCtrl;
  List<Tab> tabList = const [
    Tab(
      text: "Current & Upcoming",
    ),
    Tab(
      text: "Closed IPOs",
    ),
  ];

  int selectedTab = 0;
  @override
  void initState() {
    tabCtrl =
        TabController(length: tabList.length, vsync: this, initialIndex: 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ScopedReader watch, _) {
      final ipos = watch(ipoProvide);
      final mainstreamipo = watch(ipoProvide);
      final theme = watch(themeProvider);
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Column(
                  children: [
                    SvgPicture.asset(
                      assets.building,
                      width: 38,
                      height: 40,
                      fit: BoxFit.scaleDown,
                      color: theme.isDarkMode
                          ? colors.colorWhite
                          : colors.colorBlack,
                    )
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Main stream IPOs",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  16,
                                  FontWeight.w600)),
                          InkWell(
                            onTap: () {
                              ipos.activeMainStreamBtn(
                                  !ipos.isActiveMainStream);
                            },
                            child: Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                    color: theme.isDarkMode
                                        ? colors.colorbluegrey
                                        : const Color(0xffEBF1FF),
                                    borderRadius: BorderRadius.circular(20)),
                                child: SvgPicture.asset(
                                  ipos.isActiveMainStream
                                      ? assets.squareminus
                                      : assets.add,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.scaleDown,
                                  color: theme.isDarkMode
                                      ? colors.colorBlack
                                      : const Color(0xff0037B7),
                                )),
                          )
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                          "Initial public offering a new stock issuance for the first time.",
                          style: textStyle(
                              const Color(0xff666666), 14, FontWeight.w500)),
                    ],
                  ),
                )
              ],
            ),
          ),
          ipos.isActiveMainStream
              ? Column(children: [
                  mainstreamipo.mainStreamIpoModel!.msg == "no IPO found"
                      ? const NoDataFound()
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text(
                                      "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].name}",
                                      style: textStyle(
                                          theme.isDarkMode
                                              ? colors.colorWhite
                                              : colors.colorBlack,
                                          15,
                                          FontWeight.w600)),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Row(
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: theme.isDarkMode
                                                    ? colors.colorGrey
                                                        .withOpacity(.1)
                                                    : const Color(0xffF1F3F8),

                                                // border: Border.all(
                                                //     color: const Color(0xffC1E7BA)),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Text(
                                                "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].symbol}",
                                                style: textStyle(
                                                    colors.colorGrey,
                                                    11,
                                                    FontWeight.w500))),
                                        const SizedBox(width: 10),
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                                color: ipostartdate(
                                                            "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingStartDate}",
                                                            "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingEndDate}") ==
                                                        "Open"
                                                    ? theme.isDarkMode
                                                        ? const Color(0xffECF8F1)
                                                            .withOpacity(.3)
                                                        : const Color(0xffECF8F1)
                                                    : theme.isDarkMode
                                                        ? const Color(0xffFFF6E6)
                                                            .withOpacity(.3)
                                                        : const Color(0xffFFF6E6),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Text(
                                                ipostartdate(
                                                    "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingStartDate}",
                                                    "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingEndDate}"),
                                                style: textStyle(
                                                    Color(ipostartdate("${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingStartDate}", "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingEndDate}") == "Open" ? 0xff43A833 : 0xffB37702),
                                                    11,
                                                    FontWeight.w500))),
                                        const SizedBox(width: 10),
                                        Text(
                                            "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingStartDate!.substring(0, 2)}th - ${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingEndDate!.substring(5, 16)}",
                                            style: textStyle(
                                                const Color(0xff666666),
                                                13,
                                                FontWeight.w500)),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Price Range",
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  13,
                                                  FontWeight.w500)),
                                          Text(
                                              "₹${double.parse(mainstreamipo.mainStreamIpoModel!.mainIPO![index].minPrice!).toInt()}- ₹${double.parse(mainstreamipo.mainStreamIpoModel!.mainIPO![index].maxPrice!).toInt()}",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  15,
                                                  FontWeight.w500)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Min Qty",
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  13,
                                                  FontWeight.w500)),
                                          Text(
                                              "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].minBidQuantity}",
                                              style: textStyle(
                                                  theme.isDarkMode
                                                      ? colors.colorWhite
                                                      : colors.colorBlack,
                                                  15,
                                                  FontWeight.w500)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Min Amount",
                                              style: textStyle(
                                                  const Color(0xff666666),
                                                  13,
                                                  FontWeight.w500)),
                                          Text(
                                              "₹${mininv(double.parse(mainstreamipo.mainStreamIpoModel!.mainIPO![index].minPrice!).toDouble(), int.parse(mainstreamipo.mainStreamIpoModel!.mainIPO![index].minBidQuantity!).toInt()).toInt()}",
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
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  width: MediaQuery.of(context).size.width,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: theme.isDarkMode
                                              ? colors.colorbluegrey
                                              : const Color(0xffF1F3F8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          )),
                                      onPressed: () async {
                                        await context
                                            .read(ipoProvide)
                                            .validateCurrentTime();
                                        await context
                                            .read(fundProvider)
                                            .fetchUpiDetail();
                                        await context
                                            .read(ipoProvide)
                                            .mainipocategory(mainstreamipo
                                                .mainStreamIpoModel!
                                                .mainIPO![index]
                                                .type
                                                .toString());
                                        Navigator.pushNamed(
                                            context, Routes.applyIPO,
                                            arguments: mainstreamipo
                                                .mainStreamIpoModel!
                                                .mainIPO![index]);
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
                                                          "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingStartDate}",
                                                          "${mainstreamipo.mainStreamIpoModel!.mainIPO![index].biddingEndDate}") ==
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
                            );
                          },
                          itemCount:
                              mainstreamipo.mainStreamIpoModel!.mainIPO!.length,
                          separatorBuilder: (BuildContext context, int index) {
                            return Container(
                              color: theme.isDarkMode
                                  ? colors.darkColorDivider
                                  : const Color(0xffF1F3F8),
                              height: 7,
                            );
                          },
                        ),
                ])
              : Container()
        ],
      );
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
