// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/payment_loader.dart';

class UPIIDPaymentCancelAlert extends ConsumerStatefulWidget {
  const UPIIDPaymentCancelAlert({
    super.key,
  });

  @override
  ConsumerState<UPIIDPaymentCancelAlert> createState() =>
      _UPIIDPaymentCancelAlertState();
}

class _UPIIDPaymentCancelAlertState extends ConsumerState<UPIIDPaymentCancelAlert> {
  Timer? _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      ref.read(transcationProvider).hdfcpaymentstatus?.upiId?.status ==
                  "REJECTED" ||
              ref
                      .read(transcationProvider)
                      .hdfcpaymentstatus
                      ?.upiId
                      ?.status ==
                  "SUCCESS"
          ? null
          : ref.read(transcationProvider).fetchHdfcpaymetstatus(
              context,
              '${ref.read(transcationProvider).hdfctranction!.data!.orderNumber}',
              '${ref.read(transcationProvider).hdfctranction!.data!.upiTransactionNo}');
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
    final theme = ref.read(themeProvider);
    // final upiId = ref.read(transcationProvider);

    return PopScope(
        canPop: true, // Allows default back navigation
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return; // If system handled back, do nothing
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
                    child: TextWidget.titleText(
                        text: 'Awaiting UPI conformation',
                        theme: false,
                        color: theme.isDarkMode
                                ? colors.colorWhite
                                : colors.colorBlack,
                        fw: 1),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(children: [
                        // const ListDivider(),
                        const SizedBox(height: 3),
                        const ProgressiveDotsLoader(),
                        const SizedBox(height: 3),
                        TextWidget.subText(
                            text: 'This will take a few seconds.',
                            theme: false,
                            color: colors.colorGrey,
                            fw: 0),
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
                          child: TextWidget.subText(
                              text: "Cancel Transaction",
                              theme: false,
                              color: !theme.isDarkMode
                                          ? colors.colorWhite
                                          : colors.colorBlack,
                              fw: 0))),
                  SizedBox(
                    height: 10,
                  )
                ])));
  }
}
