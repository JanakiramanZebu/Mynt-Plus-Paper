// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynt_plus/provider/transcation_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../provider/mf_provider.dart';
import '../../../../provider/thems.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/payment_loader.dart';

class UPIIDPaymentCancelAlert extends ConsumerStatefulWidget {
  const UPIIDPaymentCancelAlert({super.key, this.data});
  final String? data;
  @override
  ConsumerState<UPIIDPaymentCancelAlert> createState() =>
      _UPIIDPaymentCancelAlertState();
}

class _UPIIDPaymentCancelAlertState
    extends ConsumerState<UPIIDPaymentCancelAlert> {
  Timer? _timer;
  Timer? _autoPopTimer;
  @override
  void initState() {
    super.initState();
    _handleInitialLogic();
  }

  void _handleInitialLogic() async {
    final mfProv = ref.read(mfProvider);
    final txnProv = ref.read(transcationProvider);

    if (mfProv.triggerfromMF == true) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        await mfProv.getpaymentstatus(
            widget.data, context); // Use await if async

        final status = mfProv.statusCheckUpi?.status;
        if (status == 'PAYMENT REJECTED' || status == 'PAYMENT APPROVED') {
          _timer?.cancel(); // This is safe even if already cancelled
          _autoPopTimer?.cancel(); // Cancel auto-pop if running

          mfProv.setterformftrigger(false);

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        }
      });

      _autoPopTimer = Timer(const Duration(minutes: 3), () {
        _timer?.cancel(); // Also stop periodic timer here as a fallback
        mfProv.setterformftrigger(false);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    } else {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        final status = txnProv.hdfcpaymentstatus?.upiId?.status;
        if (status != "REJECTED" || status != "SUCCESS") {
          txnProv.fetchHdfcpaymetstatus(
            context,
            '${txnProv.hdfctranction!.data!.orderNumber}',
            '${txnProv.hdfctranction!.data!.upiTransactionNo}',
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoPopTimer?.cancel();
    super.dispose();
  }

  void _triggerButtonAction() {
    // Clear the amount text field
    if (ref.read(mfProvider).triggerfromMF == true) {
      ref.read(mfProvider).setterformftrigger(false);
      _timer?.cancel(); // This is safe even if already cancelled
          _autoPopTimer?.cancel();
      Navigator.pop(context);
      ref.read(mfProvider).IsPaymentCalled(false);
    } else {
      ref.read(transcationProvider).amount.clear();
      Navigator.pop(context);
      _timer?.cancel();
      FocusScope.of(context).unfocus();
      ref.read(mfProvider).IsPaymentCalled(false);
    }
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
            ),
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
                    child: TextWidget.subText(
                      text: 'Awaiting UPI conformation',
                      theme: false,
                      color: theme.isDarkMode
                          ? colors.textPrimaryDark
                          : colors.textPrimaryLight,
                    ),
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
                          color: colors.textPrimaryLight,
                        ),
                      ])),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed: _triggerButtonAction,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              minimumSize: const Size(0, 40),
                              backgroundColor: theme.isDarkMode
                                  ? colors.primaryDark
                                  : colors.primaryLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: TextWidget.subText(
                                text: "Cancel Transaction",
                                theme: false,
                                color: colors.colorWhite,
                                fw: 2))),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ])));
  }
}
