import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/thems.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../provider/transcation_provider.dart';
import '../../../../../res/global_state_text.dart';
import '../../../../../res/res.dart';
import '../../../../../sharedWidget/custom_drag_handler.dart';

class UpiAppsBottomSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> upiapps;
  final ThemesProvider theme;
  const UpiAppsBottomSheet(
      {super.key, required this.upiapps, required this.theme});

  @override
  ConsumerState<UpiAppsBottomSheet> createState() => _UpiAppsBottomSheetState();
}

class _UpiAppsBottomSheetState extends ConsumerState<UpiAppsBottomSheet> {
  Timer? _timer;
  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      ref.read(transcationProvider).hdfcUPIStatus?.data?.status ==
                  "FAILED" ||
              ref.read(transcationProvider).hdfcUPIStatus?.data?.status ==
                  "REJECTED" ||
              ref.read(transcationProvider).hdfcUPIStatus?.data?.status ==
                  "SUCCESS"
          ? null
          : ref.read(transcationProvider).fetchUpiPaymentstatus(
              context,
              '${ref.read(transcationProvider).hdfcdirectpayment!.data!.orderNumber}',
              '${ref.read(transcationProvider).hdfcdirectpayment!.data!.upiTransactionNo}');
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
      builder: (context, ref, child) {
        final fund = ref.watch(transcationProvider);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomDragHandler(),
              TextWidget.subText(
                  text: "Open with",
                  theme: false,
                  color: colors.colorGrey,
                  fw: 0),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                // padding: EdgeInsets.symmetric(vertical: 15),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.upiapps.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          String upiLink =
                              "${fund.hdfcdirectpayment!.data!.upilink}";
                          String gpayLink =
                              upiLink.replaceFirst('upi://', 'gpay://upi/');
                          String paytmUrl =
                              upiLink.replaceFirst('upi://', 'paytm://upi/');

                          if (widget.upiapps[index]['name'] == "Google Pay") {
                            launch(gpayLink);
                          } else if (widget.upiapps[index]['name'] ==
                              "PhonePe") {
                            launch(
                                "phonepe://${fund.hdfcdirectpayment!.data!.upilink}");
                          } else {
                            launch(paytmUrl);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipOval(
                              child: Container(
                                color: colors.colorDivider
                                    .withOpacity(.3), // Background color
                                width: 50, // Size of the circular clip
                                height: 50,
                                child: Container(
                                  padding: EdgeInsets.all(widget.upiapps[index]
                                              ['icon'] ==
                                          "assets/icon/paymentIcon/paytm.svg"
                                      ? 12
                                      : 10),
                                  child: SvgPicture.asset(
                                    widget.upiapps[index]['icon'],

                                    // fit: BoxFit
                                    //     .contain, // Ensure the SVG fits within the padding
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            TextWidget.subText(
                                text: widget.upiapps[index]['name'],
                                theme: false,
                                color: widget.theme.isDarkMode
                                      ? colors.colorWhite
                                      : colors.colorBlack,
                                fw: 0,
                                align: TextAlign.center),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
