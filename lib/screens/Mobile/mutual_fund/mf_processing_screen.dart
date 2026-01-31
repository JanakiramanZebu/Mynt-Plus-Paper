// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../provider/mf_provider.dart';
import '../../../../../provider/thems.dart';
import '../../../../../res/res.dart';
import '../../../../../res/mynt_web_text_styles.dart';
import '../../../../../sharedWidget/payment_loader.dart';
import '../../../../../sharedWidget/snack_bar.dart';
import '../profile_screen/fund_screen/upi_id_screens/mf_payment_resp_alert.dart';

class MfUPIProcessingScreen extends ConsumerStatefulWidget {
  const MfUPIProcessingScreen({super.key, this.data});
  final String? data;
  @override
  ConsumerState<MfUPIProcessingScreen> createState() =>
      _MfUPIProcessingScreen();
}

class _MfUPIProcessingScreen extends ConsumerState<MfUPIProcessingScreen> {
  Timer? _timer;
  Timer? _autoPopTimer;
  @override
  void initState() {
    super.initState();
    _handleInitialLogic();
  }

  void _handleInitialLogic() async {
    final mfProv = ref.read(mfProvider);

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await mfProv.getpaymentstatus(widget.data, context); // Use await if async

      final status = mfProv.statusCheckUpi?.status;
      if ( mfProv.statusCheckUpi?.stat == 'Not_Ok' || (status == 'PAYMENT REJECTED') || (status == 'PAYMENT COMPLETED' ||status ==  'PAYMENT PROCESSING')) {
        _timer?.cancel(); // This is safe even if already cancelled
        _autoPopTimer?.cancel(); // Cancel auto-pop if running

        mfProv.setterformftrigger(false);
        ref.read(mfProvider).IsPaymentCalled(false);

        if (Navigator.of(context).canPop()) {
          if (mfProv.paymentName == "UPI") {
            Navigator.of(context).pop();
          }
          if (mfProv.paymentName == "NET BANKING") {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          }
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => MfPaymentRespAlert(
              upiData: mfProv.statusCheckUpi?.toJson(),
              conditionval : mfProv.statusCheckUpi?.stat == 'Not_Ok' ? mfProv.statusCheckUpi?.remarks : '',
            ),
          );
        }
        warningMessage(context, '$status');
            mfProv.fetchmfsiplist();
        mfProv.fetchMfOrderbook(context);
      }
    });

    _autoPopTimer = Timer(const Duration(minutes: 3), () {
      _timer?.cancel(); // Also stop periodic timer here as a fallback
      mfProv.setterformftrigger(false);
      ref.read(mfProvider).IsPaymentCalled(false);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => MfPaymentRespAlert(
              upiData: mfProv.statusCheckUpi?.toJson(),
              conditionval : 'timeout'
            ),
          );
        warningMessage(context, 'Timeout try again');
            mfProv.fetchmfsiplist();
      mfProv.fetchMfOrderbook(context);
      }
    });
    
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoPopTimer?.cancel();
    super.dispose();
  }

  void _triggerButtonAction() {
    // Clear the amount text field

    ref.read(mfProvider).setterformftrigger(false);
    _timer?.cancel(); // This is safe even if already cancelled
    _autoPopTimer?.cancel();
    Navigator.pop(context);
    ref.read(mfProvider).IsPaymentCalled(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.read(themeProvider);
    final mfprovider = ref.read(mfProvider);

    return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            decoration: BoxDecoration(
              color: theme.isDarkMode ? colors.colorBlack : colors.colorWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Awaiting ${mfprovider.paymentName} confirmation',
                  style: MyntWebTextStyles.title(
                    context,
                    darkColor: colors.textPrimaryDark,
                    lightColor: colors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 24),
                const ProgressiveDotsLoader(),
                const SizedBox(height: 24),
                Text(
                  'This will take a few seconds.',
                  style: MyntWebTextStyles.para(
                    context,
                    darkColor: colors.textSecondaryDark,
                    lightColor: colors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _triggerButtonAction,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size(0, 48),
                      backgroundColor: theme.isDarkMode
                          ? colors.primaryDark
                          : colors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Cancel Transaction",
                      style: MyntWebTextStyles.buttonMd(
                        context,
                        color: colors.colorWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
