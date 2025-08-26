// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../provider/thems.dart';
import '../../../../provider/transcation_provider.dart';
import '../../../../res/global_state_text.dart';
import '../../../../res/res.dart';
import '../../../../sharedWidget/custom_drag_handler.dart';
import '../../../../sharedWidget/functions.dart';
import '../../../../sharedWidget/payment_loader.dart';

class PaymentCancelAlert extends ConsumerStatefulWidget {
  const PaymentCancelAlert({
    super.key,
  });

  @override
  ConsumerState<PaymentCancelAlert> createState() => _PaymentCancelAlertState();
}

class _PaymentCancelAlertState extends ConsumerState<PaymentCancelAlert> {
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
    final theme = ref.read(themeProvider);
    // final fund = ref.read(transcationProvider);

    return PopScope(
        canPop: true, // Allows default back navigation
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return; // If system handled back, do nothing
        },
        child: SafeArea(
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
         color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
         border: Border(
                                  top: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  left: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                  right: BorderSide(
                                    color: theme.isDarkMode
                                        ? colors.textSecondaryDark
                                            .withOpacity(0.5)
                                        : colors.colorWhite,
                                  ),
                                ),),
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
                          TextWidget.paraText(
                              text: 'This will take a few seconds.',
                              theme: false,
                              color: theme.isDarkMode ? colors.textSecondaryDark : colors.textSecondaryLight,
                              ),
                        ])),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: () {
                                // Clear the amount text field
                                ref.read(transcationProvider).amount.clear();
                                Navigator.pop(context);
                                _timer?.cancel();
                                FocusScope.of(context).unfocus();
                              },
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
                                  color:  colors.colorWhite
                                             ,
                                  fw: 2))),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ])),
        ));
  }
}
