import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/screens/profile_screen/fund_screen/upi_apps_screens/upi_apps_payment_failed.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';

class PaymentStatus extends StatefulWidget {
  final TranctionProvider ss;
  const PaymentStatus({
    super.key,
    required this.ss,
  });

  @override
  State<PaymentStatus> createState() => _PaymentStatusState();
}

class _PaymentStatusState extends State<PaymentStatus> {
  bool showNavigation = false;

  Timer? _timer;
  int _start = 300;
  String resendTime = "04:59";

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
            resendTime = formattedTime(timeInSecond: _start);
          });
        }
      },
    );
  }

  formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute : $second";
  }

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      widget.ss.hdfcUPIStatus?.data?.status == "REJECTED" ||
              widget.ss.hdfcUPIStatus?.data?.status == "SUCCESS"
          ? null
          : widget.ss.fetchUpiPaymentstatus(
              context,
              '${widget.ss.hdfcdirectpayment!.data!.orderNumber}',
              '${widget.ss.hdfcdirectpayment!.data!.upiTransactionNo}');
    });
    startTimer();
    super.initState();
    Future.delayed(const Duration(minutes: 5), () {
      setState(() {
        showNavigation = !showNavigation;
      });
    });
    // Future.delayed(const Duration(seconds: 2), () {
    //   launch("${widget.ss.hdfcdirectpayment!.data!.upilink}");
    // });
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, watch, child) {
        final fund = watch(transcationProvider);
        return Scaffold(
          backgroundColor: const Color(0xffffffff),
          appBar: AppBar(
              leadingWidth: 41,
              titleSpacing: 6,
              elevation: .3,
              backgroundColor: const Color(0xffffffff),
              title: Text(
                "Payment Status",
                style: textStyles.appBarTitleTxt,
              ),
              leading: InkWell(
                  onTap: () {
                    showNavigation ||
                            widget.ss.hdfcUPIStatus?.data?.status ==
                                "REJECTED" ||
                            widget.ss.hdfcUPIStatus?.data?.status == "SUCCESS"
                        ? Navigator.pop(context)
                        : null;
                  },
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: SvgPicture.asset(
                        assets.backArrow,
                        // ignore: deprecated_member_use
                        color: showNavigation
                            ? colors.colorBlack
                            : colors.colorGrey,
                      )))),
          body: fund.hdfcUPIStatus?.data?.status == "EXPIRED" ||
                  fund.hdfcUPIStatus?.data?.status == "REJECTED" ||
                  fund.hdfcUPIStatus?.data?.status == "SUCCESS"
              ? AtomTranscationFailed(fund: fund)
              : Column(
                  children: [
                    showNavigation
                        ? Container()
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            width: MediaQuery.of(context).size.width,
                            color: const Color(0xffffee58),
                            child: Text(
                              '!  Please do not press BACK BUTTON',
                              style: textStyles.appBarTitleTxt,
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Zebu Mobile UPI",
                            style: textStyle(
                                colors.colorBlack, 16, FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "UPI Address: ${fund.hdfcUPIStatus!.data!.clientVPA}",
                            style: textStyle(
                                colors.colorGrey, 14, FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "To complete the payment",
                            style: textStyle(
                                colors.colorBlack, 18, FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TimelineTile(
                            beforeLineStyle: LineStyle(color: colors.colorBlue),
                            isFirst: true,
                            indicatorStyle: IndicatorStyle(
                              width: 20,
                              color: colors.colorBlue,
                            ),
                            endChild: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                'Go to the UPI mobile app',
                                style: textStyle(
                                    colors.colorBlack, 14, FontWeight.w500),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 150,
                            child: TimelineTile(
                              beforeLineStyle:
                                  LineStyle(color: colors.colorBlue),
                              isLast: true,
                              indicatorStyle: IndicatorStyle(
                                width: 20,
                                color: colors.colorBlue,
                              ),
                              endChild: Container(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  'Check the pending requests and approve the payment by entering UPI PIN',
                                  style: textStyle(
                                      colors.colorBlack, 14, FontWeight.w500),
                                ),
                              ),
                            ),
                          ),
                          Center(
                              child: CircularProgressIndicator(
                            color: colors.colorBlue,
                          )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "To check payment status,",
                                style: textStyle(
                                    colors.colorGrey, 13, FontWeight.w500),
                              ),
                              TextButton(
                                  onPressed: () async {
                                    context
                                        .read(transcationProvider)
                                        .fetchUpiPaymentstatus(
                                            context,
                                            '${fund.hdfcdirectpayment!.data!.orderNumber}',
                                            '${fund.hdfcdirectpayment!.data!.upiTransactionNo}');
                                  },
                                  child: Text(
                                    "Click here",
                                    style: textStyle(
                                        colors.colorBlue, 13, FontWeight.w500),
                                  ))
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width,
                            color: const Color(0xffbbbbfa),
                            child: Text(resendTime,
                                style: textStyle(
                                    colors.colorBlack, 20, FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: colors.colorBlack,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  )),
                              onPressed: () async {
                                launch(
                                    "${widget.ss.hdfcdirectpayment!.data!.upilink}");
                              },
                              child: Text("PAY VIA UPI APPS",
                                  style: textStyle(
                                      colors.colorWhite, 14, FontWeight.w500)),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: colors.colorBlack,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                            onPressed: () async {
                              setState(() {
                                _timer!.cancel();
                                Navigator.pop(context);
                              });
                            },
                            child: Text("Cancel payment",
                                style: textStyle(
                                    colors.colorWhite, 14, FontWeight.w500)),
                          )),
                        ],
                      ),
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
