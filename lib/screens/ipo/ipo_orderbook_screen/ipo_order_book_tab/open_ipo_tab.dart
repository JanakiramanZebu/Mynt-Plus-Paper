import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';


class IpoOpenOrder extends ConsumerWidget {
  final IPOProvider open;
  const IpoOpenOrder({super.key, required this.open});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: open.openorder!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, Routes.ipoopendetailsscreen,
                      arguments: open.openorder![index]);
                },
                child: Column(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(open.openorder![index].symbol.toString(),
                                  style: textStyles.scripNameTxtStyle),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                      open.openorder![index].reponseStatus ==
                                              "new success"
                                          ? "assets/icon/success.svg"
                                          : "assets/icon/pendingicon.svg"),
                                  const SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    open.openorder![index].reponseStatus ==
                                            "new success"
                                        ? "Success"
                                        : "Pending",
                                    style: textStyle(
                                        colors.colorBlack, 13, FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "BID Qty: ",
                                    style: textStyle(
                                        colors.colorGrey, 12, FontWeight.w500),
                                  ),
                                  Text(
                                    "${open.openorder![index].bidDetail![0].quantity}",
                                    style: textStyle(
                                        colors.colorBlack, 13, FontWeight.w600),
                                  )
                                ],
                              ),
                            ],
                          ),
                          SvgPicture.asset(assets.rightArrowIcon)
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: Color(0xffECEDEE), thickness: 1.2),
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "₹${getFormatter(
                                  noDecimal: true,
                                  v4d: false,
                                  value: double.parse(open.openorder![index]
                                          .bidDetail![0].amount
                                          .toString())
                                      .toDouble(),
                                )}",
                                style: textStyle(
                                    colors.colorBlack, 13, FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                "Invested amount",
                                style: textStyle(
                                    colors.colorGrey, 12, FontWeight.w500),
                              )
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                open.openorder![index].responseDatetime
                                            .toString() ==
                                        ""
                                    ? "----"
                                    : ipodateres(open
                                        .openorder![index].responseDatetime
                                        .toString()),
                                style: textStyle(
                                    colors.colorBlack, 13, FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                "Bid Date & time",
                                style: textStyle(
                                    colors.colorGrey, 12, FontWeight.w500),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Container(color: const Color(0xffF1F3F8), height: 7);
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
