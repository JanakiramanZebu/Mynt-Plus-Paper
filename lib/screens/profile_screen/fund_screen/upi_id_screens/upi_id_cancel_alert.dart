// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/payment_loader.dart';

class UPIIDPaymentCancelAlert extends StatefulWidget {
  const UPIIDPaymentCancelAlert({
    super.key,
  });

  @override
  State<UPIIDPaymentCancelAlert> createState() =>
      _UPIIDPaymentCancelAlertState();
}

class _UPIIDPaymentCancelAlertState extends State<UPIIDPaymentCancelAlert> {
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read(transcationProvider).hdfcpaymentstatus?.upiId?.status ==
                  "REJECTED" ||
              context
                      .read(transcationProvider)
                      .hdfcpaymentstatus
                      ?.upiId
                      ?.status ==
                  "SUCCESS"
          ? null
          : context.read(transcationProvider).fetchHdfcpaymetstatus(
              context,
              '${context.read(transcationProvider).hdfctranction!.data!.orderNumber}',
              '${context.read(transcationProvider).hdfctranction!.data!.upiTransactionNo}');
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _triggerButtonAction() {
    Navigator.pop(context);
    _timer?.cancel();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read(themeProvider);
    // final upiId = context.read(transcationProvider);

    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0xff999999),
                      blurRadius: 4.0,
                      offset: Offset(2.0, 0.0))
                ]),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomDragHandler(),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 5),
                    alignment: Alignment.center,
                    child: Text('Awaiting UPI conformation',
                        style: textStyle(
                            theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                            16,
                            FontWeight.w600)),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(children: [
                        // const ListDivider(),
                        const SizedBox(height: 3),
                        const ProgressiveDotsLoader(),
                        const SizedBox(height: 3),
                        Text('This will take a few seconds.',
                            style: textStyle(
                                colors.colorGrey, 13, FontWeight.w500)),
                      ])),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: _triggerButtonAction,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: theme.isDarkMode
                                ? colors.colorbluegrey
                                : colors.colorBlack,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text("Cancel Transaction",
                              style: GoogleFonts.inter(
                                  textStyle: textStyle(
                                      !theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                                      14,
                                      FontWeight.w500))))),
                  const SizedBox(
                    height: 10,
                  )
                ])));
  }
}
