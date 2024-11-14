// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../routes/route_names.dart';
import '../../../../sharedWidget/functions.dart';

class IpoCloseOrderDetails extends ConsumerWidget {
  final IpoOrderBookModel ipoclose;
  const IpoCloseOrderDetails({
    super.key,
    required this.ipoclose,
  });

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    int currentYear = DateTime.now().year;
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
                color: theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
              ),
            ),
          ),
          backgroundColor:
              theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
          shadowColor: const Color(0xffECEFF3),
          title: Text("Order Details",
              style: textStyles.appBarTitleTxt.copyWith(
                  color: theme.isDarkMode
                      ? colors.colorWhite
                      : colors.colorBlack))),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ipoclose.companyName.toString(),
                    style: textStyles.scripNameTxtStyle.copyWith(
                        color: theme.isDarkMode
                            ? colors.colorWhite
                            : colors.colorBlack),
                  ),
                  const SizedBox(height: 5),
                  Text(ipoclose.symbol.toString(),
                      style: textStyles.scripExchTxtStyle),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order",
                            style: textStyle(
                                colors.colorGrey, 13, FontWeight.w600),
                          ),
                          Text(
                            ipoclose.reponseStatus == "cancel success" ||
                                    ipoclose.reponseStatus == "new failed"
                                ? "Failed"
                                : "Success",
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                              ipoclose.reponseStatus == "cancel success" ||
                                      ipoclose.reponseStatus == "new failed"
                                  ? "assets/icon/failed.svg"
                                  : "assets/icon/pendingicon.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            ipoclose.reponseStatus == "cancel success" ||
                                    ipoclose.reponseStatus == "new failed"
                                ? "Failed"
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
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Payment",
                            style: textStyle(
                                colors.colorGrey, 13, FontWeight.w600),
                          ),
                          Text(
                            ipoclose.upiPaymentStatus == ""
                                ? "Failed"
                                : ipoclose.upiPaymentStatus.toString(),
                            style: textStyle(
                                theme.isDarkMode
                                    ? colors.colorWhite
                                    : colors.colorBlack,
                                14,
                                FontWeight.w600),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(ipoclose.upiPaymentStatus == ""
                              ? "assets/icon/failed.svg"
                              : "assets/icon/success.svg"),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            ipoclose.upiPaymentStatus == ""
                                ? "Failed"
                                : ipoclose.upiPaymentStatus.toString(),
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
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order Id",
                        style: textStyle(colors.colorGrey, 13, FontWeight.w600),
                      ),
                      Text(
                        ipoclose.applicationNumber.toString(),
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            14,
                            FontWeight.w600),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(ipoclose.upiPaymentStatus == ""
                          ? "assets/icon/failed.svg"
                          : "assets/icon/success.svg"),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        ipoclose.upiPaymentStatus == ""
                            ? "Failed"
                            : ipoclose.upiPaymentStatus.toString(),
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
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () async {
                          await context.read(ipoProvide).getSmeIpo();
                          await context.read(ipoProvide).getmainstreamipo();
                          await context
                              .read(ipoProvide)
                              .getipoperfomance(currentYear);
                          Navigator.pushNamed(context, Routes.ipo);
                        },
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                width: 1.4,
                                color: theme.isDarkMode
                                    ? colors.colorGrey
                                    : colors.colorBlack),
                            padding: const EdgeInsets.symmetric(vertical: 10.5),
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text("Place New order",
                              style: textStyle(
                                  theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                  14,
                                  FontWeight.w600)),
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Divider(
              color: theme.isDarkMode
                  ? colors.darkColorDivider
                  : colors.colorDivider,
            ),
            data(
                "App no",
                ipoclose.respBid == null
                    ? "NAN"
                    : ipoclose.respBid![0].bidReferenceNumber.toString(),
                theme),
            data("Quantity", ipoclose.bidDetail![0].quantity.toString(), theme),
            data(
                "Total amount",
                ipoclose.bidDetail![0].amount! == "null"
                    ? "NAN"
                    : "₹${getFormatter(
                        noDecimal: true,
                        v4d: false,
                        value: double.parse(ipoclose.bidDetail![0].amount!)
                            .toDouble(),
                      )}",
                theme),
            data(
                "Price",
                ipoclose.bidDetail![0].price == "null"
                    ? "NAN"
                    : "₹${ipoclose.bidDetail![0].price}",
                theme),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 15, bottom: 5),
              child: Text(
                ipoclose.bidDetail!.length == 1
                    ? "Single bid order"
                    : ipoclose.bidDetail!.length == 2
                        ? "Double bid order"
                        : "Triple bid order",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
            ),
            ListView.builder(
                itemCount: ipoclose.bidDetail!.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "bid ${index + 1}",
                          style:
                              textStyle(colors.colorGrey, 13, FontWeight.w500),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipoclose.bidDetail![0].amount! == "null"
                                      ? "NAN"
                                      : "₹${getFormatter(
                                          noDecimal: true,
                                          v4d: false,
                                          value: double.parse(ipoclose
                                                  .bidDetail![0].amount!)
                                              .toDouble(),
                                        )}",
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Amount",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipoclose.bidDetail![index].price == "null"
                                      ? "NAN"
                                      : ipoclose.bidDetail![index].price!,
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Price",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipoclose.bidDetail![index].quantity!
                                      .toString(),
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Quantity",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ipoclose.bidDetail![index].atCutOff == null
                                      ? "NAN"
                                      : ipoclose.bidDetail![index].atCutOff!
                                          .toString(),
                                  style: textStyle(
                                      theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Cut off",
                                  style: textStyle(
                                      colors.colorGrey, 13, FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Divider(
                          color: theme.isDarkMode
                              ? colors.darkColorDivider
                              : colors.colorDivider,
                        )
                      ],
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, bottom: 5),
              child: Text(
                "Reason",
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 16, bottom: 5),
              child: Text(
                ipoclose.failReason.toString(),
                style: textStyle(colors.colorGrey, 13, FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding data(String name, String value, ThemesProvider theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              ),
              Text(
                value,
                style: textStyle(
                    theme.isDarkMode ? colors.colorWhite : colors.colorBlack,
                    14,
                    FontWeight.w600),
              )
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            color: theme.isDarkMode
                ? colors.darkColorDivider
                : colors.colorDivider,
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
