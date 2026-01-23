// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/ipo_model/ipo_order_book_model.dart';
import '../../../../models/ipo_model/ipo_place_order_model.dart';
import '../../../../provider/iop_provider.dart';
import '../../../../res/mynt_web_color_styles.dart';
import '../../../../res/mynt_web_text_styles.dart';

class IpoCancelAlert extends ConsumerStatefulWidget {
  final IpoOrderBookModel ipocancel;

  const IpoCancelAlert({super.key, required this.ipocancel});

  @override
  ConsumerState<IpoCancelAlert> createState() => _IpoCancelAlertState();
}

class _IpoCancelAlertState extends ConsumerState<IpoCancelAlert> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: resolveThemeColor(context,
              dark: MyntColors.backgroundColorDark,
              light: MyntColors.backgroundColor),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button (Top Right)
            Align(
              alignment: Alignment.topRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: resolveThemeColor(context,
                        dark: MyntColors.textSecondaryDark,
                        light: MyntColors.textSecondary),
                  ),
                ),
              ),
            ),

            // Text Content
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Are you sure you want to \ncancel this ',
                style: MyntWebTextStyles.title(
                  context,
                  color: resolveThemeColor(context,
                      dark: MyntColors.textPrimaryDark,
                      light: MyntColors.textPrimary),
                ).copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
                children: [
                  TextSpan(
                    text: 'IPO order?',
                    style: MyntWebTextStyles.title(
                      context,
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Button
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed:
                    _isCancelling ? null : () => _handleCancelOrder(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF0037B7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isCancelling
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Delete',
                        style: MyntWebTextStyles.buttonMd(
                          context,
                          color: Colors.white,
                        ).copyWith(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCancelOrder(BuildContext context) async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      final menudata = MenuData(
        flow: "can",
        type: widget.ipocancel.type.toString(),
        symbol: widget.ipocancel.symbol.toString(),
        category: "",
        name: widget.ipocancel.companyName.toString(),
        applicationNumber: widget.ipocancel.applicationNumber.toString(),
        respBid: [BidReference(bidReferenceNumber: '67890')],
      );

      const List<IposBid> iposbids = [];

      await ref
          .read(ipoProvide)
          .getipoplaceorder(context, menudata, iposbids, "");

      // Close the dialog after successful cancellation
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Handle error - dialog will remain open
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }
}
