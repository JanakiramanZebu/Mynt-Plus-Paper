import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';

class UpiAppsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> upiapps;
  final ThemesProvider theme;
  const UpiAppsBottomSheet(
      {super.key, required this.upiapps, required this.theme});

  @override
  State<UpiAppsBottomSheet> createState() => _UpiAppsBottomSheetState();
}

class _UpiAppsBottomSheetState extends State<UpiAppsBottomSheet> {
  Timer? _timer;
  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read(transcationProvider).hdfcUPIStatus?.data?.status ==
                  "REJECTED" ||
              context.read(transcationProvider).hdfcUPIStatus?.data?.status ==
                  "SUCCESS"
          ? null
          : context.read(transcationProvider).fetchUpiPaymentstatus(
              context,
              '${context.read(transcationProvider).hdfcdirectpayment!.data!.orderNumber}',
              '${context.read(transcationProvider).hdfcdirectpayment!.data!.upiTransactionNo}');
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final fund = watch(transcationProvider);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: widget.theme.isDarkMode
                  ? colors.colorBlack
                  : colors.colorWhite,
              boxShadow: const [
                BoxShadow(
                    color: Color(0xff999999),
                    blurRadius: 4.0,
                    offset: Offset(2.0, 0.0))
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.upiapps.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      String upiLink =
                          "${fund.hdfcdirectpayment!.data!.upilink}";
                      String gpayLink =
                          upiLink.replaceFirst('upi://', 'gpay://upi/');
                      String paytmUrl =
                          upiLink.replaceFirst('upi://', 'paytm://upi/');

                      if (widget.upiapps[index]['name'] == "Google Pay") {
                        launch(gpayLink);
                      } else if (widget.upiapps[index]['name'] == "PhonePe") {
                        launch(
                            "phonepe://${fund.hdfcdirectpayment!.data!.upilink}");
                      } else {
                        launch(paytmUrl);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          widget.upiapps[index]['icon'],
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          widget.upiapps[index]['name'],
                          textAlign: TextAlign.center,
                          style: textStyle(
                              widget.theme.isDarkMode
                                  ? colors.colorWhite
                                  : colors.colorBlack,
                              14,
                              FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle textStyle(Color color, double fontSize, fWeight) {
    return GoogleFonts.inter(
        textStyle:
            TextStyle(fontWeight: fWeight, color: color, fontSize: fontSize));
  }
}
