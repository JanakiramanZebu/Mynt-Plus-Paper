import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../provider/transcation_provider.dart';
import '../../../../res/res.dart';
import 'upi_id_payment_fail_or_success.dart';

class UpiIdPaymentStatus extends StatefulWidget {
  final TranctionProvider ss;
  const UpiIdPaymentStatus({
    super.key,
    required this.ss,
  });

  @override
  State<UpiIdPaymentStatus> createState() => _UpiIdPaymentStatusState();
}

class _UpiIdPaymentStatusState extends State<UpiIdPaymentStatus> {
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
      widget.ss.hdfcpaymentstatus?.data?.status == "REJECTED" ||
              widget.ss.hdfcpaymentstatus?.data?.status == "SUCCESS"
          ? null
          : widget.ss.fetchHdfcpaymetstatus(
              context,
              '${widget.ss.hdfctranction!.data!.orderNumber}',
              '${widget.ss.hdfctranction!.data!.upiTransactionNo}');
    });
    startTimer();
    super.initState();
    Future.delayed(const Duration(minutes: 5), () {
      setState(() {
        showNavigation = !showNavigation;
      });
    });
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
                            widget.ss.hdfcpaymentstatus?.data?.status ==
                                "REJECTED" ||
                            widget.ss.hdfcpaymentstatus?.data?.status ==
                                "SUCCESS"
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
          body: fund.hdfcpaymentstatus?.data?.status == "EXPIRED" ||
                  fund.hdfcpaymentstatus?.data?.status == "REJECTED" ||
                  fund.hdfcpaymentstatus?.data?.status == "SUCCESS"
              ? UpiIdSucessorFaliureScreen(fund: fund)
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
                            "UPI Address: ${fund.hdfctranction!.data!.clientVPA}",
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
                                        .fetchHdfcpaymetstatus(
                                            context,
                                            '${fund.hdfctranction!.data!.orderNumber}',
                                            '${fund.hdfctranction!.data!.upiTransactionNo}');
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
